#!/usr/bin/env node
// Claude Code Stop hook: run slow project-level checks once when Claude is
// about to finish, but only for stacks whose files were actually changed
// (per `git status`). Exit 2 blocks the stop and feeds the output back.
//
//   Rust: cargo clippy --all-targets -- -D warnings   (if Cargo.toml + changed .rs)
//   TS:   <pm> run check                               (if tsconfig.json + changed .ts/.tsx and the package.json
//                                                       next to it has a `check` script; pm from the lockfile:
//                                                       pnpm, yarn, else npm; only once node_modules is installed)
//         node_modules/.bin/tsc --noEmit               (otherwise)
//
// Lockfiles and node_modules are looked for up to the root of the git repository, not above it.
// Missing tools are skipped. `stop_hook_active` guards against endless loops. A check that runs out of time
// (CHECK_STOP_TIMEOUT_MS, default 5 min) blocks the stop and is ended with its whole process tree.

const { execFileSync, spawn, spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const IS_WIN = process.platform === 'win32';
const TIMEOUT_MS = Number(process.env.CHECK_STOP_TIMEOUT_MS) || 5 * 60 * 1000;

/** End `child` and everything it started: with `shell` on Windows the child is cmd.exe, its program a grandchild. */
function killTree(child) {
  if (IS_WIN) {
    // By its full path: the PATH of a hook may lack System32.
    const taskkill = path.join(process.env.SystemRoot || 'C:\\Windows', 'System32', 'taskkill.exe');
    spawnSync(taskkill, ['/T', '/F', '/PID', String(child.pid)], { stdio: 'ignore' });
  } else {
    try {
      process.kill(-child.pid, 'SIGKILL');
    } catch {
      child.kill('SIGKILL');
    }
  }
}

/** Run a check; null when it passed or its program is missing, else its output for the reason of the block. */
function run(bin, args, cwd, shell = false) {
  return new Promise((resolve) => {
    let out = '';
    let timedOut = false;
    const shown = `$ ${path.basename(bin.replace(/"/g, ''))} ${args.join(' ')}`;
    // With a shell the command is one line (the args are fixed words): node warns about an array of args (DEP0190).
    const child = shell
      ? spawn([bin, ...args].join(' '), { cwd, shell, detached: !IS_WIN, windowsHide: true })
      : spawn(bin, args, { cwd, detached: !IS_WIN, windowsHide: true });
    child.stdout.on('data', (d) => (out += d));
    child.stderr.on('data', (d) => (out += d));
    const why = () => `timed out after ${Math.round(TIMEOUT_MS / 1000)} s, ended with its processes\n`;
    const timer = setTimeout(() => {
      timedOut = true;
      killTree(child);
      // A process that outlives the kill keeps the pipes open and `close` never comes: the stop is not held up by it.
      setTimeout(() => resolve(`${shown}\n${why()}${out}`), 5000).unref();
    }, TIMEOUT_MS);
    child.on('error', (err) => {
      clearTimeout(timer);
      resolve(err.code === 'ENOENT' ? null : `${shown}\n${err.message}`);
    });
    child.on('close', (code) => {
      clearTimeout(timer);
      if (code === 0 && !timedOut) return resolve(null);
      resolve(`${shown}\n${timedOut ? why() : ''}${out}`);
    });
  });
}

/** Whether two paths name one folder (git writes `E:/x`, the hook may get `e:\x`; Windows ignores case). */
function samePath(a, b) {
  const norm = (p) => (IS_WIN ? path.resolve(p).toLowerCase() : path.resolve(p));
  return norm(a) === norm(b);
}

/** `rel` in `start` or a folder above it, up to `stop` (the root of the repository) when it is given. */
function findUp(start, rel, stop = null) {
  let dir = start;
  for (;;) {
    const candidate = path.join(dir, rel);
    if (fs.existsSync(candidate)) return candidate;
    const parent = path.dirname(dir);
    if (parent === dir || (stop && samePath(dir, stop))) return null;
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
 * { bin, dir }, or null when there is none, the packages are not installed (a fresh worktree: the script would only
 * fail on its missing tools) or the package manager is not on PATH.
 */
function checkScript(dir, root) {
  const pkgPath = path.join(dir, 'package.json');
  let pkg;
  try {
    pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
  } catch {
    return null;
  }
  if (!pkg || !pkg.scripts || typeof pkg.scripts.check !== 'string') return null;
  if (!findUp(dir, 'node_modules', root)) return null;
  let manager = 'npm';
  if (findUp(dir, 'pnpm-lock.yaml', root) || findUp(dir, 'pnpm-workspace.yaml', root)) manager = 'pnpm';
  else if (findUp(dir, 'yarn.lock', root)) manager = 'yarn';
  const bin = which(manager);
  return bin ? { bin: IS_WIN ? `"${bin}"` : bin, dir } : null;
}

let input = '';
process.stdin.on('data', (chunk) => (input += chunk));
process.stdin.on('end', async () => {
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
  let root = null;
  try {
    root = execFileSync('git', ['rev-parse', '--show-toplevel'], { cwd, encoding: 'utf8' }).trim() || null;
  } catch {
    root = null;
  }

  const errors = [];

  if (changed.some((f) => f.endsWith('.rs'))) {
    const cargoToml = findUp(cwd, 'Cargo.toml');
    if (cargoToml) {
      const err = await run('cargo', ['clippy', '--all-targets', '--', '-D', 'warnings'], path.dirname(cargoToml));
      if (err) errors.push(err);
    }
  }

  if (changed.some((f) => /\.(ts|tsx)$/.test(f))) {
    const tsconfig = findUp(cwd, 'tsconfig.json');
    const projectCheck = tsconfig && checkScript(path.dirname(tsconfig), root);
    if (projectCheck) {
      // The project's own type check (e.g. svelte-check + tsc -p ...): a bare tsc cannot read every file it can.
      const err = await run(projectCheck.bin, ['run', 'check'], projectCheck.dir, IS_WIN);
      if (err) errors.push(err);
    } else {
      const tsc =
        tsconfig && findUp(path.dirname(tsconfig), path.join('node_modules', '.bin', IS_WIN ? 'tsc.cmd' : 'tsc'), root);
      if (tsc) {
        const err = await run(IS_WIN ? `"${tsc}"` : tsc, ['--noEmit'], path.dirname(tsconfig), IS_WIN);
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
