// End-to-end test for check-stop.js: which type check runs for a changed .ts file.
// Run: node check-stop.test.js   (needs git and npm on PATH)
//
// Every case is a throwaway git repo in the temp folder with a changed a.ts and a tsconfig.json. A project with a
// `check` script must be judged by that script, not by the bare tsc (tasks-desktop: tsc --noEmit cannot read generic
// .svelte components, `pnpm check` can); the package manager comes from the lockfile. The fake programs fail loudly
// with a marker, so the output says which one ran. Cases with a PATH of their own see only the fake package managers
// and git.
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const HOOK = path.join(__dirname, 'check-stop.js');
const IS_WIN = process.platform === 'win32';

for (const tool of ['git', 'npm']) {
  if (spawnSync(`${tool} --version`, { shell: true }).status !== 0) {
    console.log(`skip: ${tool} not on PATH`);
    process.exit(0);
  }
}
const gitPath = spawnSync(IS_WIN ? 'where' : 'which', ['git'], { encoding: 'utf8' }).stdout.split(/\r?\n/)[0].trim();

const base = fs.mkdtempSync(path.join(os.tmpdir(), 'check-stop-test-'));
// A lockfile above the projects (as one above the temp folder could be) must not choose their package manager.
fs.writeFileSync(path.join(base, 'pnpm-lock.yaml'), 'lockfileVersion: 9.0\n');
let failed = 0;
const leftovers = [];

function write(dir, rel, text, exec = false) {
  const p = path.join(dir, rel);
  fs.mkdirSync(path.dirname(p), { recursive: true });
  fs.writeFileSync(p, text);
  if (exec && !IS_WIN) fs.chmodSync(p, 0o755);
}

/** A program `name` that prints `marker` and fails, in `dir`. */
function fakeProgram(dir, name, marker) {
  if (IS_WIN) write(dir, `${name}.cmd`, `@echo ${marker} %*\r\n@exit /b 1\r\n`);
  else write(dir, name, `#!/bin/sh\necho ${marker} "$@"\nexit 1\n`, true);
}

/** A git repo with a changed a.ts; `opts.modules` puts a failing fake tsc into node_modules, `opts.files` adds files. */
function project(name, scripts, opts = {}) {
  const dir = path.join(base, name);
  write(dir, 'tsconfig.json', '{}\n');
  write(dir, 'a.ts', 'export const a = 1;\n');
  write(dir, 'package.json', JSON.stringify({ name, private: true, scripts }, null, 2));
  write(dir, 'pass.js', 'process.exit(0);\n');
  write(dir, 'fail.js', 'console.log("CHECK-SCRIPT-FAILED"); process.exit(1);\n');
  // The check of the timeout: a program that leaves its pid and never ends.
  write(dir, 'hang.js', 'require("fs").writeFileSync("hang.pid", String(process.pid)); setInterval(() => {}, 1000);\n');
  if (opts.modules !== false) fakeProgram(path.join(dir, 'node_modules', '.bin'), 'tsc', 'BARE-TSC-RAN');
  for (const [rel, text] of Object.entries(opts.files || {})) write(dir, rel, text);
  spawnSync('git', ['init', '-q'], { cwd: dir });
  return dir;
}

/** A folder of fake package managers for a PATH of its own: `names` of npm, pnpm, yarn. */
function bin(name, names) {
  const dir = path.join(base, `bin-${name}`);
  fs.mkdirSync(dir, { recursive: true });
  for (const n of names) fakeProgram(dir, n, `RAN-${n}`);
  return dir;
}

/** The environment with PATH replaced by `dirs` and git (on Windows the key is spelled `Path`). */
function onlyPath(dirs, extra = {}) {
  const env = {};
  for (const [k, v] of Object.entries(process.env)) if (k.toUpperCase() !== 'PATH') env[k] = v;
  env.PATH = [...dirs, path.dirname(gitPath)].join(path.delimiter);
  return { ...env, ...extra };
}

function stop(dir, env = process.env) {
  const r = spawnSync(process.execPath, [HOOK], {
    input: JSON.stringify({ cwd: dir, stop_hook_active: false }),
    encoding: 'utf8',
    env,
    timeout: 60_000,
  });
  return { status: r.status, out: `${r.stdout}${r.stderr}` };
}

function expect(name, dir, status, marker, absent, env) {
  const r = stop(dir, env);
  const ok = r.status === status && (!marker || r.out.includes(marker)) && (!absent || !r.out.includes(absent));
  if (!ok) {
    failed++;
    console.log(`FAIL ${name}: exit ${r.status} (want ${status})\n${r.out}`);
  } else console.log(`ok   ${name}`);
  return r;
}

function alive(pid) {
  try {
    process.kill(pid, 0);
    return true;
  } catch {
    return false;
  }
}

try {
  expect(
    'a passing check script wins over a failing bare tsc',
    project('passing', { check: 'node pass.js' }),
    0,
    null,
    'BARE-TSC-RAN',
  );
  expect(
    'a failing check script blocks the stop with its output',
    project('failing', { check: 'node fail.js' }),
    2,
    'CHECK-SCRIPT-FAILED',
    'BARE-TSC-RAN',
  );
  expect('without a check script the bare tsc still runs', project('bare', { test: 'node pass.js' }), 2, 'BARE-TSC-RAN');
  expect(
    'without node_modules (a fresh worktree) the check script is not run',
    project('fresh', { check: 'node fail.js' }, { modules: false }),
    0,
    null,
    'CHECK-SCRIPT-FAILED',
  );
  const all = bin('all', ['npm', 'pnpm', 'yarn']);
  expect(
    'a pnpm-lock.yaml runs the check with pnpm',
    project('pnpm', { check: 'node pass.js' }, { files: { 'pnpm-lock.yaml': 'lockfileVersion: 9.0\n' } }),
    2,
    'RAN-pnpm run check',
    'RAN-npm',
    onlyPath([all]),
  );
  expect(
    'a yarn.lock runs the check with yarn',
    project('yarn', { check: 'node pass.js' }, { files: { 'yarn.lock': '\n' } }),
    2,
    'RAN-yarn run check',
    'RAN-pnpm',
    onlyPath([all]),
  );
  expect(
    'a lockfile above the repository does not choose the package manager',
    project('npm', { check: 'node pass.js' }),
    2,
    'RAN-npm run check',
    'RAN-pnpm',
    onlyPath([all]),
  );
  if (IS_WIN) {
    expect(
      '... also when the hook gets the drive in lower case',
      project('npm-lower', { check: 'node pass.js' }).replace(/^[A-Z]:/, (d) => d.toLowerCase()),
      2,
      'RAN-npm run check',
      'RAN-pnpm',
      onlyPath([all]),
    );
  }
  expect(
    'without the package manager on PATH the bare tsc runs',
    project('nopm', { check: 'node pass.js' }, { files: { 'pnpm-lock.yaml': 'lockfileVersion: 9.0\n' } }),
    2,
    'BARE-TSC-RAN',
    'RAN-pnpm',
    onlyPath([bin('none', [])]),
  );
  // tasks-desktop: the session stands in the root of the repository, the tsconfig.json is in ui/.
  const nested = path.join(base, 'nested');
  for (const sub of ['ui', 'web']) {
    write(nested, `${sub}/tsconfig.json`, '{}\n');
    write(nested, `${sub}/src/a.ts`, 'export const a = 1;\n');
    write(nested, `${sub}/package.json`, JSON.stringify({ name: sub, private: true, scripts: { check: 'node fail.js' } }));
    write(nested, `${sub}/fail.js`, `console.log("CHECK-${sub.toUpperCase()}-FAILED"); process.exit(1);\n`);
    fs.mkdirSync(path.join(nested, sub, 'node_modules'), { recursive: true });
  }
  write(nested, 'web/src/b.ts', 'export const b = 1;\n');
  spawnSync('git', ['init', '-q'], { cwd: nested });
  const n = expect('the tsconfig of a changed file in a subfolder is found from the root', nested, 2, 'CHECK-UI-FAILED');
  const webRuns = n.out.split('CHECK-WEB-FAILED').length - 1;
  if (webRuns !== 1) {
    failed++;
    console.log(`FAIL ... and each project is checked once (web ran ${webRuns} times)\n${n.out}`);
  } else console.log('ok   ... and each project is checked once');
  const hang = project('hang', { check: 'node hang.js' });
  const r = expect('a check that runs out of time blocks the stop', hang, 2, 'timed out', null, {
    ...process.env,
    CHECK_STOP_TIMEOUT_MS: '4000',
  });
  const pidFile = path.join(hang, 'hang.pid');
  const pid = fs.existsSync(pidFile) ? Number(fs.readFileSync(pidFile, 'utf8')) : 0;
  if (!pid) {
    failed++;
    console.log(`FAIL the hanging check did not start\n${r.out}`);
  } else {
    // taskkill returns before the process is gone.
    const until = Date.now() + 5000;
    while (alive(pid) && Date.now() < until) spawnSync(process.execPath, ['-e', 'setTimeout(() => {}, 200)']);
    if (alive(pid)) {
      failed++;
      leftovers.push(pid);
      console.log(`FAIL the program of a check that ran out of time still runs (pid ${pid})`);
    } else console.log('ok   ... and its program is ended with it');
  }
} finally {
  for (const pid of leftovers) {
    try {
      process.kill(pid);
    } catch {}
  }
  fs.rmSync(base, { recursive: true, force: true });
}

if (failed) {
  console.log(`${failed} failed`);
  process.exit(1);
}
console.log('all passed');
