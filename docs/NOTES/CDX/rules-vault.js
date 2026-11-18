#!/usr/bin/env node
// rules-vault.js -- keeps the local rules-vault checkout current and links its
// context documents into ~/.claude/rules/, which Claude Code loads at the start
// of every session without an approval dialog. Shared by setup-claude-code.ps1
// and setup-claude-code.sh so both platforms behave the same.
//
// Usage:
//   node rules-vault.js ensure <vault-dir>
//     Missing: clone WKDSteve/rules-vault (gh, fallback git over https).
//     Present, clean and on main: git pull --ff-only.
//     Anything else (foreign changes, other branch, pull error): warn, touch nothing.
//   node rules-vault.js link <vault-dir|-> <claude-dir> [--workstation]
//     Links every <vault>/rulesets/arbeit/kontext/*.md as
//     <claude-dir>/rules/rules-vault-<name>.md (symlink, fallback copy); with
//     --workstation also kontext/workstation/*.md as rules-vault-workstation-<name>.md.
//     Own entries are recognised by the prefix; stale own entries are removed,
//     every other file in rules/ is left alone. A missing vault or kontext/
//     folder is a hint, not an error; '-' stands for "no vault" (PowerShell 5.1
//     drops an empty argument).
//
// Exit code is 0 for every outcome above (warnings only); 2 for bad usage.
// Test hooks (environment): RULES_VAULT_REMOTE = clone URL instead of GitHub
// (skips gh), RULES_VAULT_NO_SYMLINK=1 = take the copy fallback.
'use strict';

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const PREFIX = 'rules-vault-';
const GH_REPO = 'WKDSteve/rules-vault';
const HTTPS_URL = 'https://github.com/WKDSteve/rules-vault.git';

const say = (msg) => console.log(`  ${msg}`);
const warn = (msg) => console.log(`  WARNUNG: ${msg}`);

/** Runs a command without a shell; returns { ok, out } (stdout+stderr, trimmed). */
function run(cmd, args, cwd) {
  const res = spawnSync(cmd, args, { cwd, encoding: 'utf8', windowsHide: true });
  if (res.error) return { ok: false, out: String(res.error.message || res.error), missing: res.error.code === 'ENOENT' };
  return { ok: res.status === 0, out: `${res.stdout || ''}${res.stderr || ''}`.trim() };
}

function ensure(vault) {
  if (!fs.existsSync(vault)) {
    const parent = path.dirname(vault);
    if (!fs.existsSync(parent)) {
      warn(`${parent} fehlt: rules-vault nicht geklont.`);
      return;
    }
    const remote = process.env.RULES_VAULT_REMOTE;
    if (!remote) {
      const gh = run('gh', ['repo', 'clone', GH_REPO, vault]);
      if (gh.ok) {
        say(`rules-vault geklont (gh): ${vault}`);
        return;
      }
      if (fs.existsSync(vault)) {
        // gh created something and failed: do not clone over a half-made folder
        warn(`gh repo clone schlug fehl und hinterliess ${vault}; von Hand pruefen.\n${gh.out}`);
        return;
      }
      say(gh.missing ? 'gh nicht gefunden, klone per git.' : 'gh repo clone schlug fehl, klone per git.');
    }
    const git = run('git', ['clone', remote || HTTPS_URL, vault]);
    if (git.ok) say(`rules-vault geklont: ${vault}`);
    else warn(`git clone schlug fehl, rules-vault fehlt:\n${git.out}`);
    return;
  }

  const top = run('git', ['rev-parse', '--show-toplevel'], vault);
  // Windows paths compare without case (git may print e:/ for an E:\ argument)
  if (!top.ok || !sameFile(top.out, vault)) {
    warn(`${vault} ist kein eigenes Git-Repo: nicht aktualisiert.`);
    return;
  }
  const branch = run('git', ['symbolic-ref', '--short', '-q', 'HEAD'], vault);
  if (!branch.ok || branch.out !== 'main') {
    warn(`rules-vault steht nicht auf main (${branch.out || 'detached HEAD'}): nicht aktualisiert.`);
    return;
  }
  const status = run('git', ['status', '--porcelain'], vault);
  if (!status.ok || status.out !== '') {
    warn(`rules-vault hat uncommittete Aenderungen: nicht aktualisiert (fremde Arbeit, nichts angefasst).`);
    return;
  }
  const pull = run('git', ['pull', '--ff-only'], vault);
  if (pull.ok) say(`rules-vault aktuell (git pull --ff-only): ${vault}`);
  else warn(`git pull --ff-only schlug fehl, rules-vault bleibt wie er ist:\n${pull.out}`);
}

/** The *.md files of a folder, sorted; [] when it does not exist. */
function mdFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  return fs
    .readdirSync(dir, { withFileTypes: true })
    .filter((e) => e.isFile() && e.name.toLowerCase().endsWith('.md'))
    .map((e) => e.name)
    .sort();
}

function sameFile(a, b) {
  if (process.platform !== 'win32') return path.resolve(a) === path.resolve(b);
  return path.resolve(a).toLowerCase() === path.resolve(b).toLowerCase();
}

/** Puts one own entry in place; returns a short word for the summary. */
function place(src, dst) {
  let st = null;
  try {
    st = fs.lstatSync(dst);
  } catch {
    st = null;
  }
  if (st && st.isSymbolicLink()) {
    const target = path.resolve(path.dirname(dst), fs.readlinkSync(dst));
    if (sameFile(target, src)) return 'ok';
  }
  if (st && st.isDirectory()) {
    // never ours (we only write files and file links): leave it, the setup goes on
    warn(`${dst} ist ein Ordner: nicht ersetzt, Dokument nicht verlinkt.`);
    return 'skipped';
  }
  const noSymlink = process.env.RULES_VAULT_NO_SYMLINK === '1';
  if (st && st.isFile() && noSymlink && fs.readFileSync(dst).equals(fs.readFileSync(src))) return 'ok';
  if (st) fs.rmSync(dst, { force: true });
  if (!noSymlink) {
    try {
      fs.symlinkSync(src, dst, 'file');
      return 'link';
    } catch {
      // no symlink right (Developer Mode / admin missing): copy below
    }
  }
  fs.copyFileSync(src, dst);
  return 'copy';
}

function link(vault, claudeDir, workstation) {
  const rulesDir = path.join(claudeDir, 'rules');
  const kontext = vault ? path.join(vault, 'rulesets', 'arbeit', 'kontext') : '';
  const wanted = new Map(); // link name -> source
  if (!vault || !fs.existsSync(vault)) {
    say(`Hinweis: kein rules-vault (${vault || 'RULES_VAULT leer'}): keine Kontext-Dokumente verlinkt.`);
  } else if (!fs.existsSync(kontext)) {
    say(`Hinweis: ${kontext} fehlt noch: keine Kontext-Dokumente verlinkt.`);
  } else {
    for (const name of mdFiles(kontext)) wanted.set(PREFIX + name, path.join(kontext, name));
    if (workstation) {
      const ws = path.join(kontext, 'workstation');
      for (const name of mdFiles(ws)) wanted.set(`${PREFIX}workstation-${name}`, path.join(ws, name));
    }
  }

  if (wanted.size > 0) fs.mkdirSync(rulesDir, { recursive: true });
  const counts = { ok: 0, link: 0, copy: 0, removed: 0, skipped: 0 };
  for (const [name, src] of wanted) {
    const how = place(src, path.join(rulesDir, name));
    counts[how] += 1;
    if (how === 'link' || how === 'copy') say(`${how === 'link' ? 'verlinkt' : 'kopiert'}: rules/${name} -> ${src}`);
  }

  // Remove own entries that no longer have a source (only the prefix is ours).
  if (fs.existsSync(rulesDir)) {
    for (const e of fs.readdirSync(rulesDir, { withFileTypes: true })) {
      if (!e.name.startsWith(PREFIX) || wanted.has(e.name)) continue;
      if (e.isDirectory()) continue;
      fs.rmSync(path.join(rulesDir, e.name), { force: true });
      counts.removed += 1;
      say(`entfernt (verwaist): rules/${e.name}`);
    }
  }
  say(
    `rules/: ${wanted.size} Kontext-Dokument(e), ${counts.ok} unveraendert, ${counts.link} verlinkt, ` +
      `${counts.copy} kopiert, ${counts.removed} entfernt.`
  );
  if (counts.copy > 0) say('Kopien statt Links: nach Aenderungen im rules-vault das Setup erneut ausfuehren.');
}

function main(argv) {
  const [cmd, ...rest] = argv;
  if (cmd === 'ensure' && rest.length === 1) return ensure(path.resolve(rest[0]));
  if (cmd === 'link' && (rest.length === 2 || rest.length === 3)) {
    const flags = rest.slice(2);
    if (flags.some((f) => f !== '--workstation')) return usage();
    const vault = rest[0] && rest[0] !== '-' ? path.resolve(rest[0]) : '';
    return link(vault, path.resolve(rest[1]), flags.includes('--workstation'));
  }
  return usage();
}

function usage() {
  console.error('usage: rules-vault.js ensure <vault-dir> | link <vault-dir|-> <claude-dir> [--workstation]');
  process.exitCode = 2;
}

main(process.argv.slice(2));
