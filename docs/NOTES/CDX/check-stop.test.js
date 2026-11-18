// End-to-end test for check-stop.js: which type check runs for a changed .ts file.
// Run: node check-stop.test.js   (needs git and npm on PATH)
//
// Every case is a throwaway git repo in the temp folder with a changed a.ts, a tsconfig.json and a fake
// node_modules/.bin/tsc that always fails. A project with a `check` script must be judged by that script, not by the
// bare tsc (tasks-desktop: tsc --noEmit cannot read generic .svelte components, `pnpm check` can).
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const HOOK = path.join(__dirname, 'check-stop.js');
const IS_WIN = process.platform === 'win32';

for (const tool of ['git', 'npm']) {
  if (spawnSync(tool, ['--version'], { shell: IS_WIN }).status !== 0) {
    console.log(`skip: ${tool} not on PATH`);
    process.exit(0);
  }
}

const base = fs.mkdtempSync(path.join(os.tmpdir(), 'check-stop-test-'));
let failed = 0;

function project(name, scripts) {
  const dir = path.join(base, name);
  const mk = (rel, text) => {
    const p = path.join(dir, rel);
    fs.mkdirSync(path.dirname(p), { recursive: true });
    fs.writeFileSync(p, text);
  };
  mk('tsconfig.json', '{}\n');
  mk('a.ts', 'export const a = 1;\n');
  mk('package.json', JSON.stringify({ name, private: true, scripts }, null, 2));
  mk('pass.js', 'process.exit(0);\n');
  mk('fail.js', 'console.log("CHECK-SCRIPT-FAILED"); process.exit(1);\n');
  // The fake tsc fails loudly: when it runs, the stop is blocked with its marker.
  if (IS_WIN) mk('node_modules/.bin/tsc.cmd', '@echo BARE-TSC-RAN\r\n@exit /b 1\r\n');
  else {
    mk('node_modules/.bin/tsc', '#!/bin/sh\necho BARE-TSC-RAN\nexit 1\n');
    fs.chmodSync(path.join(dir, 'node_modules/.bin/tsc'), 0o755);
  }
  spawnSync('git', ['init', '-q'], { cwd: dir });
  return dir;
}

function stop(dir) {
  const r = spawnSync(process.execPath, [HOOK], {
    input: JSON.stringify({ cwd: dir, stop_hook_active: false }),
    encoding: 'utf8',
  });
  return { status: r.status, out: `${r.stdout}${r.stderr}` };
}

function expect(name, dir, status, marker, absent) {
  const r = stop(dir);
  const ok = r.status === status && (!marker || r.out.includes(marker)) && (!absent || !r.out.includes(absent));
  if (!ok) {
    failed++;
    console.log(`FAIL ${name}: exit ${r.status} (want ${status})\n${r.out}`);
  } else console.log(`ok   ${name}`);
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
} finally {
  fs.rmSync(base, { recursive: true, force: true });
}

if (failed) {
  console.log(`${failed} failed`);
  process.exit(1);
}
console.log('all passed');
