#!/usr/bin/env node
// Installs the cloud push guard into repositories: copies hooks/cloud-push-guard.mjs to <repo>/.claude/hooks/ and adds
// its PreToolUse entry (matcher Bash) to <repo>/.claude/settings.json. Idempotent; every other key of settings.json
// stays as it is. When the repository's .gitignore hides `.claude/` (`.claude/`, `/.claude/` or `.claude/*`), the
// line becomes `/.claude/*` with exceptions for settings.json and hooks/, so both files can be committed. The vaults
// are refused: there a cloud session pushes to main on purpose (rule GIT-09).
//
// Usage: node install-cloud-push-guard.js [--check] <repo>...
//   --check  change nothing; exit 1 when a repository lacks the guard or has an old copy
// Prints one line per repository: installed | updated | unchanged | missing | outdated | refused | held | error.
// `held`: settings.json or .gitignore has uncommitted changes of someone else; nothing was written.

const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const HOOK_NAME = 'cloud-push-guard.mjs';
const SOURCE = path.join(__dirname, 'hooks', HOOK_NAME);
// The shell test keeps local sessions free of a node start on every Bash call.
const COMMAND = `[ -z "$CLAUDE_CODE_REMOTE" ] || node "$CLAUDE_PROJECT_DIR/.claude/hooks/${HOOK_NAME}"`;
const VAULTS = new Set(['tasks-vault', 'rules-vault', 'tricentis-vault']);
const HOOK_REL = `.claude/hooks/${HOOK_NAME}`;
const SETTINGS_REL = '.claude/settings.json';

function git(root, args) {
  return execFileSync('git', ['-C', root, ...args], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
}

/** The rule that ignores `rel`, as `{ source, line, pattern }`, or null when it is not ignored. */
function ignoredBy(root, rel) {
  try {
    const out = git(root, ['check-ignore', '-v', '--no-index', rel]).trim();
    const m = out.match(/^(.*):(\d+):(.*)\t/);
    // -v also reports the exception that lets a path through (`!/.claude/settings.json`)
    return m && !m[3].startsWith('!') ? { source: m[1], line: Number(m[2]), pattern: m[3] } : null;
  } catch {
    return null; // exit 1: not ignored
  }
}

/**
 * The repository's .gitignore text with `.claude/settings.json` and `.claude/hooks/` let through, or null when it
 * needs no change. Throws when another rule (a nested .gitignore, info/exclude, a global file) hides them.
 */
function gitignoreFix(root) {
  const settingsRule = ignoredBy(root, SETTINGS_REL);
  const hookRule = ignoredBy(root, HOOK_REL);
  const rules = [settingsRule, hookRule].filter(Boolean);
  if (rules.length === 0) return null;
  const file = path.join(root, '.gitignore');
  const lines = fs.readFileSync(file, 'utf8').split('\n');
  for (const rule of rules) {
    const own = path.resolve(root, rule.source) === file;
    const known = ['.claude/', '/.claude/', '.claude', '/.claude', '.claude/*', '/.claude/*'].includes(rule.pattern);
    if (!own || !known || lines[rule.line - 1].trim() !== rule.pattern || rule.line !== rules[0].line) {
      throw new Error(`${rule.source}:${rule.line} \`${rule.pattern}\` hides .claude/; let it through by hand`);
    }
  }
  const at = rules[0].line - 1;
  const eol = lines[at].endsWith('\r') ? '\r' : '';
  // `.claude/*` stays and gets only the exceptions it lacks; a rule for the folder itself cannot have exceptions,
  // so it becomes `/.claude/*` with both
  const folder = !rules[0].pattern.endsWith('*');
  const add = [];
  if (folder || settingsRule) add.push(`!/.claude/settings.json${eol}`);
  if (folder || hookRule) add.push(`!/.claude/hooks/${eol}`);
  lines.splice(at, 1, folder ? `/.claude/*${eol}` : lines[at], ...add);
  return lines.join('\n');
}

/**
 * The new text of settings.json. Without a `hooks` key the block is added in front of the closing brace and every
 * other byte stays as it was (a repository may format its JSON its own way); otherwise the whole file is rewritten.
 */
function settingsText(oldText, settings) {
  const next = withGuard(settings);
  if (oldText === null || settings.hooks !== undefined || typeof settings !== 'object' || Array.isArray(settings)) {
    return `${JSON.stringify(next, null, 2)}\n`;
  }
  const end = oldText.lastIndexOf('}');
  const head = oldText.slice(0, end).replace(/\s*$/, '');
  const indent = oldText.match(/\n([ \t]+)"/)?.[1] ?? '  ';
  const block = JSON.stringify(next.hooks, null, indent).replace(/\n/g, `\n${indent}`);
  const text = `${head}${head.endsWith('{') ? '' : ','}\n${indent}"hooks": ${block}\n}${oldText.slice(end + 1)}`;
  return oldText.includes('\r\n') ? text.replace(/\r?\n/g, '\r\n') : text;
}

/** The settings object with the guard's entry in place (a new object; `settings` is not changed). */
function withGuard(settings) {
  const next = JSON.parse(JSON.stringify(settings));
  next.hooks ??= {};
  next.hooks.PreToolUse ??= [];
  const entry = { type: 'command', command: COMMAND, timeout: 10 };
  for (const group of next.hooks.PreToolUse) {
    const hooks = group.hooks ?? [];
    const i = hooks.findIndex((h) => typeof h.command === 'string' && h.command.includes(HOOK_NAME));
    if (i !== -1) {
      hooks[i] = entry;
      group.matcher = 'Bash';
      return next;
    }
  }
  next.hooks.PreToolUse.push({ matcher: 'Bash', hooks: [entry] });
  return next;
}

/**
 * Install (or with `check`, only compare) the guard in one repository.
 * @param {string} repo
 * @param {{ check?: boolean, ownTree?: boolean }} [opts] `ownTree`: the caller owns every uncommitted change (a new
 *   project), so nothing is held
 * @returns {'installed'|'updated'|'unchanged'|'missing'|'outdated'|'refused'|'held'}
 */
function install(repo, opts = {}) {
  const root = path.resolve(repo);
  if (VAULTS.has(path.basename(root))) return 'refused';
  if (!fs.existsSync(path.join(root, '.git'))) throw new Error(`no git checkout: ${root}`);
  const hookPath = path.join(root, HOOK_REL);
  const settingsPath = path.join(root, SETTINGS_REL);
  const source = fs.readFileSync(SOURCE, 'utf8');

  const hadHook = fs.existsSync(hookPath);
  const hookSame = hadHook && fs.readFileSync(hookPath, 'utf8') === source;
  const oldText = fs.existsSync(settingsPath) ? fs.readFileSync(settingsPath, 'utf8') : null;
  let settings = {};
  if (oldText !== null) {
    try {
      settings = JSON.parse(oldText);
    } catch (e) {
      throw new Error(`${settingsPath}: not JSON (${e.message})`);
    }
  }
  const nextText = settingsText(oldText, settings);
  const settingsSame = oldText !== null && JSON.stringify(settings) === JSON.stringify(JSON.parse(nextText));
  const ignoreText = gitignoreFix(root);

  if (hookSame && settingsSame && ignoreText === null) return 'unchanged';
  const fresh = !hadHook && !(oldText ?? '').includes(HOOK_NAME);
  if (opts.check) return fresh ? 'missing' : 'outdated';

  // someone else's uncommitted edits in a file this would rewrite: leave the repository alone (GIT-05)
  const touched = [];
  if (!settingsSame && oldText !== null) touched.push(SETTINGS_REL);
  if (ignoreText !== null) touched.push('.gitignore');
  if (!opts.ownTree && touched.length > 0 && git(root, ['status', '--porcelain', '--', ...touched]).trim() !== '') {
    return 'held';
  }

  fs.mkdirSync(path.dirname(hookPath), { recursive: true });
  if (!hookSame) fs.writeFileSync(hookPath, source);
  if (!settingsSame) fs.writeFileSync(settingsPath, nextText);
  if (ignoreText !== null) fs.writeFileSync(path.join(root, '.gitignore'), ignoreText);
  const still = [SETTINGS_REL, HOOK_REL].filter((rel) => ignoredBy(root, rel));
  if (still.length > 0) throw new Error(`still ignored after the fix: ${still.join(', ')}`);
  return fresh ? 'installed' : 'updated';
}

module.exports = { install, withGuard, COMMAND, HOOK_NAME };

if (require.main === module) {
  const args = process.argv.slice(2);
  const check = args.includes('--check');
  const repos = args.filter((a) => a !== '--check');
  if (repos.length === 0) {
    console.error('usage: node install-cloud-push-guard.js [--check] <repo>...');
    process.exit(2);
  }
  let bad = false;
  for (const repo of repos) {
    try {
      const result = install(repo, { check });
      if (['missing', 'outdated', 'held'].includes(result)) bad = true;
      console.log(`${result}\t${repo}`);
    } catch (e) {
      bad = true;
      console.log(`error\t${repo}\t${e.message}`);
    }
  }
  process.exit(bad ? 1 : 0);
}
