#!/usr/bin/env node
// Claude Code Stop hook: run slow project-level checks once when Claude is
// about to finish, but only for stacks whose files were actually changed
// (per `git status`). Exit 2 blocks the stop and feeds the output back.
//
//   Rust: cargo clippy --all-targets -- -D warnings   (if Cargo.toml + changed .rs)
//   TS:   <pm> run check                               (if tsconfig.json + changed .ts/.tsx and the package.json
//                                                       next to it has a `check` script; pm from the lockfile:
//                                                       pnpm, yarn, else npm)
//         node_modules/.bin/tsc --noEmit               (otherwise)
//
// Missing tools are skipped. `stop_hook_active` guards against endless loops.

const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const IS_WIN = process.platform === 'win32';
const TIMEOUT_MS = 5 * 60 * 1000;

function run(bin, args, cwd, shell = false) {
  try {
    execFileSync(bin, args, { cwd, stdio: 'pipe', timeout: TIMEOUT_MS, shell });
    return null;
  } catch (err) {
    if (err.code === 'ENOENT') return null;
    return `$ ${path.basename(bin)} ${args.join(' ')}\n${err.stdout || ''}${err.stderr || ''}`;
  }
}

function findUp(start, rel) {
  let dir = start;
  for (;;) {
    const candidate = path.join(dir, rel);
    if (fs.existsSync(candidate)) return candidate;
    const parent = path.dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}

/** The program `name` on PATH (with PATHEXT on Windows), or null. */
function which(name) {
  const exts = IS_WIN ? (process.env.PATHEXT || '.EXE;.CMD;.BAT').split(';') : [''];
  for (const dir of (process.env.PATH || '').split(path.delimiter)) {
    if (!dir) continue;
    for (const ext of exts) {
      const candidate = path.join(dir, name + ext);
      if (fs.existsSync(candidate) && fs.statSync(candidate).isFile()) return candidate;
    }
  }
  return null;
}

/**
 * The `check` script of the package.json next to the tsconfig, run by the package manager its lockfile names:
 * { bin, dir }, or null when there is none or the package manager is not installed.
 */
function checkScript(dir) {
  const pkgPath = path.join(dir, 'package.json');
  let pkg;
  try {
    pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
  } catch {
    return null;
  }
  if (!pkg || !pkg.scripts || typeof pkg.scripts.check !== 'string') return null;
  let manager = 'npm';
  if (findUp(dir, 'pnpm-lock.yaml') || findUp(dir, 'pnpm-workspace.yaml')) manager = 'pnpm';
  else if (findUp(dir, 'yarn.lock')) manager = 'yarn';
  const bin = which(manager);
  return bin ? { bin: IS_WIN ? `"${bin}"` : bin, dir } : null;
}

let input = '';
process.stdin.on('data', (chunk) => (input += chunk));
process.stdin.on('end', () => {
  let data;
  try {
    data = JSON.parse(input);
  } catch {
    process.exit(0);
  }
  if (data.stop_hook_active) process.exit(0);

  const cwd = data.cwd || process.cwd();
  let changed;
  try {
    changed = execFileSync('git', ['status', '--porcelain', '--untracked-files=all'], { cwd, encoding: 'utf8' })
      .split('\n')
      .map((l) => l.slice(3).trim())
      .filter(Boolean);
  } catch {
    process.exit(0); // not a git repo
  }

  const errors = [];

  if (changed.some((f) => f.endsWith('.rs'))) {
    const cargoToml = findUp(cwd, 'Cargo.toml');
    if (cargoToml) {
      const err = run('cargo', ['clippy', '--all-targets', '--', '-D', 'warnings'], path.dirname(cargoToml));
      if (err) errors.push(err);
    }
  }

  if (changed.some((f) => /\.(ts|tsx)$/.test(f))) {
    const tsconfig = findUp(cwd, 'tsconfig.json');
    const projectCheck = tsconfig && checkScript(path.dirname(tsconfig));
    if (projectCheck) {
      // The project's own type check (e.g. svelte-check + tsc -p ...): a bare tsc cannot read every file it can.
      const err = run(projectCheck.bin, ['run', 'check'], projectCheck.dir, IS_WIN);
      if (err) errors.push(err);
    } else {
      const tsc = tsconfig && findUp(path.dirname(tsconfig), path.join('node_modules', '.bin', IS_WIN ? 'tsc.cmd' : 'tsc'));
      if (tsc) {
        const err = run(IS_WIN ? `"${tsc}"` : tsc, ['--noEmit'], path.dirname(tsconfig), IS_WIN);
        if (err) errors.push(err);
      }
    }
  }

  if (errors.length) {
    console.error(`slow checks failed:\n\n${errors.join('\n\n')}`);
    process.exit(2);
  }
  process.exit(0);
});
