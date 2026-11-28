// Test for merge-claude-settings.js and the Stop hook entry of settings.global.json.
// Run: node merge-claude-settings.test.js
//
// Claude Code ends a command hook after the hook's `timeout` (seconds) or its own default. check-stop.js ends a slow
// check itself after CHECK_STOP_TIMEOUT_MS and blocks the stop with the reason; that only works when Claude Code waits
// longer than that. So the template sets a timeout above the hook's default, and the merge also gives it to a Stop
// hook that an older setup run merged without one.
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const MERGE = path.join(__dirname, 'merge-claude-settings.js');
const TEMPLATE = path.join(__dirname, 'settings.global.json');
const STOP = path.join(__dirname, 'check-stop.js');
const NVIM = 'C:/nvim-config';
const STOP_COMMAND = `node "${NVIM}/docs/NOTES/CDX/check-stop.js"`;

const base = fs.mkdtempSync(path.join(os.tmpdir(), 'merge-settings-test-'));
let failed = 0;

function check(name, ok, detail = '') {
  if (ok) console.log(`ok   ${name}`);
  else {
    failed++;
    console.log(`FAIL ${name}${detail ? `\n${detail}` : ''}`);
  }
}

/** Merge the template into `existing` (an object, or null for no settings.json); the merged settings. */
function merge(name, existing) {
  const file = path.join(base, `${name}.json`);
  if (existing) fs.writeFileSync(file, JSON.stringify(existing, null, 2));
  const r = spawnSync(process.execPath, [MERGE, TEMPLATE, file, NVIM], { encoding: 'utf8' });
  if (r.status !== 0) throw new Error(`merge failed (${r.status}): ${r.stdout}${r.stderr}`);
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

/** The Stop hook entries of `settings` that run check-stop.js. */
function stopHooks(settings) {
  return (settings.hooks?.Stop ?? []).flatMap((e) => e.hooks ?? []).filter((h) => h.command === STOP_COMMAND);
}

try {
  // The default time limit of check-stop.js, read from its source (the script itself only runs as a hook).
  const src = fs.readFileSync(STOP, 'utf8');
  const m = src.match(/const TIMEOUT_MS = Number\(process\.env\.CHECK_STOP_TIMEOUT_MS\) \|\| ([\d\s*]+);/);
  check('check-stop.js has a readable default time limit', !!m);
  const defaultMs = m ? m[1].split('*').reduce((acc, n) => acc * Number(n.trim()), 1) : 0;

  const template = JSON.parse(fs.readFileSync(TEMPLATE, 'utf8'));
  const tplStop = (template.hooks?.Stop ?? []).flatMap((e) => e.hooks ?? []);
  const tplTimeout = tplStop[0]?.timeout;
  check(
    'the template gives the Stop hook a timeout above the default of check-stop.js',
    typeof tplTimeout === 'number' && defaultMs > 0 && tplTimeout * 1000 > defaultMs,
    `timeout ${tplTimeout} s, check-stop.js default ${defaultMs / 1000} s`,
  );

  const fresh = stopHooks(merge('fresh', null));
  check(
    'a fresh settings.json gets the Stop hook with its timeout',
    fresh.length === 1 && fresh[0].timeout === tplTimeout,
    JSON.stringify(fresh),
  );

  const old = merge('old', {
    model: 'keep-me',
    hooks: { Stop: [{ hooks: [{ type: 'command', command: STOP_COMMAND }] }] },
  });
  const oldStop = stopHooks(old);
  check(
    'a Stop hook merged before without a timeout gets it, and is not added twice',
    oldStop.length === 1 && oldStop[0].timeout === tplTimeout,
    JSON.stringify(old.hooks.Stop),
  );
  check('other keys of settings.json stay', old.model === 'keep-me');

  const again = stopHooks(merge('old', old));
  check('a second merge changes nothing', again.length === 1 && again[0].timeout === tplTimeout);
} finally {
  fs.rmSync(base, { recursive: true, force: true });
}

if (failed) {
  console.log(`${failed} failed`);
  process.exit(1);
}
console.log('all passed');
