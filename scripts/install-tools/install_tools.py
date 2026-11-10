#!/usr/bin/env python3
"""Install the CLI tools the own nvim plugins and repos need, with one command.

Sources (merged, one entry per binary):
  * every $REPOS_DIR/*/docs/install.json (the lib.nvim.deps spec of each plugin)
  * tools.json next to this file (groups, extra routes, tools without a spec, dev toolchain)

Route per missing tool: the system package manager (winget, then scoop on Windows;
apt/dnf/pacman/zypper/apk, then brew elsewhere), else npm / pip / cargo, else a download link.
Python standard library only; started by install-tools.ps1 / install-tools.sh.

Two ways to pick tools: groups (core/plugins/heavy/dev, the default) or the stack profiles of
the Claude setup (--profile nvim,cpp,rust,web,tauri; setup-claude-code calls --status and
--profile). This replaced docs/NOTES/CDX/setup-devtools.js and its tools.json.

On the Tricentis workstation (NVIM_MACHINE_ROLE=workstation) prebuilt packages are installed as anywhere
else; what would compile locally is left out (build toolchains, cargo install, pip source builds).

Exit code: 0 nothing failed, 1 an install failed, 2 bad arguments or declined.
"""

import argparse
import glob
import json
import os
import platform
import re
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GROUP_ORDER = ["core", "plugins", "heavy", "dev"]
DEFAULT_GROUPS = ["core", "plugins", "dev"]
LINUX_PMS = ["apt", "dnf", "pacman", "zypper", "apk"]
PM_EXE = {"apt": "apt-get", "dnf": "dnf", "pacman": "pacman", "zypper": "zypper", "apk": "apk"}


# ---------------------------------------------------------------- platform

def this_os():
    s = platform.system()
    if s == "Windows":
        return "win"
    if s == "Darwin":
        return "mac"
    return "linux"


OS = this_os()
WSL = OS == "linux" and "microsoft" in platform.release().lower()


def refresh_path():
    """Windows: re-read Machine + User PATH from the registry, so tools winget just
    installed are found by the phases after it (a running process keeps its old PATH)."""
    if OS != "win":
        return
    try:
        import winreg
    except ImportError:
        return
    parts = []
    keys = [
        (winreg.HKEY_LOCAL_MACHINE, r"SYSTEM\CurrentControlSet\Control\Session Manager\Environment"),
        (winreg.HKEY_CURRENT_USER, r"Environment"),
    ]
    for root, sub in keys:
        try:
            with winreg.OpenKey(root, sub) as k:
                value, _ = winreg.QueryValueEx(k, "Path")
                parts.append(os.path.expandvars(value))
        except OSError:
            pass
    if parts:
        merged = os.pathsep.join(parts + [os.environ.get("PATH", "")])
        seen, out = set(), []
        for p in merged.split(os.pathsep):
            key = p.strip().rstrip("\\/").lower()
            if key and key not in seen:
                seen.add(key)
                out.append(p.strip())
        os.environ["PATH"] = os.pathsep.join(out)


# ---------------------------------------------------------------- loading

def load_json(path):
    with open(path, "r", encoding="utf-8-sig") as f:
        return json.load(f)


def repos_dir(arg):
    if arg:
        return arg
    env = os.environ.get("REPOS_DIR")
    if env and os.path.isdir(env):
        return env
    # the config usually lives next to the repos only on Linux; on Windows it is in AppData
    return os.path.dirname(os.path.dirname(os.path.dirname(HERE)))


def as_list(v):
    """A JSON list, or nothing: a bare string would iterate as characters (lib.nvim.deps rejects it too)."""
    return v if isinstance(v, list) else []


def union(a, b):
    out = list(as_list(a))
    for x in as_list(b):
        if x not in out:
            out.append(x)
    return out


def merge_tool(dst, src, owner):
    """lib.nvim.deps.status merge rules: required = any, pkg first-wins per key,
    bin_alternatives / paths unioned, first why wins, used_by collects the declarers."""
    dst["required"] = bool(dst.get("required")) or bool(src.get("required"))
    pkg = dst.setdefault("pkg", {})
    for k, v in (src.get("pkg") or {}).items():
        pkg.setdefault(k, v)
    dst["bin_alternatives"] = union(dst.get("bin_alternatives"), src.get("bin_alternatives"))
    paths = dst.setdefault("paths", {})
    for plat, lst in (src.get("paths") or {}).items():
        paths[plat] = union(paths.get(plat), lst)  # a non-list value is dropped by union
    if not dst.get("why") and src.get("why"):
        dst["why"] = src["why"]
    dst["used_by"] = union(dst.get("used_by"), src.get("used_by") or ([owner] if owner else []))
    dst["profiles"] = union(dst.get("profiles"), src.get("profiles"))
    for key in ("group", "os", "reject", "skip_wsl", "detect", "fallback_for", "winget_override",
                "not_on_workstation"):
        if src.get(key) and not dst.get(key):
            dst[key] = src[key]
    alt = dst.setdefault("alt", {})
    for k, v in (src.get("alt") or {}).items():
        alt.setdefault(k, v)


def collect(repos):
    manifest = load_json(os.path.join(HERE, "tools.json"))
    tools, problems = {}, []
    for spec in sorted(glob.glob(os.path.join(repos, "*", "docs", "install.json"))):
        plugin = os.path.basename(os.path.dirname(os.path.dirname(spec)))
        try:
            data = load_json(spec)
        except (OSError, ValueError) as e:
            problems.append("%s: unreadable (%s)" % (spec, e))
            continue
        for t in data.get("tools") or []:
            if not isinstance(t, dict) or not t.get("bin"):
                problems.append("%s: entry without bin" % spec)
                continue
            merge_tool(tools.setdefault(t["bin"], {"bin": t["bin"]}), t, plugin)
    if not tools:
        problems.append("keine docs/install.json unter %s - REPOS_DIR setzen oder --repos-dir angeben;"
                        " ohne sie fehlen alle Plugin-Tools" % repos)
    for t in manifest.get("tools") or []:
        merge_tool(tools.setdefault(t["bin"], {"bin": t["bin"]}), t, None)
    # overrides are deliberate choices of this manifest: their keys win
    for name, ov in (manifest.get("overrides") or {}).items():
        t = tools.get(name)
        if t is None:
            continue  # the plugin declaring it is not cloned here: nothing to override
        for k, v in ov.items():
            if isinstance(v, dict):
                t.setdefault(k, {}).update(v)
            else:
                t[k] = v
    default_group = manifest.get("default_group", "plugins")
    for t in tools.values():
        t.setdefault("group", default_group)
    return tools, manifest, problems


# ---------------------------------------------------------------- detection

def expand(path):
    def repl(m):
        return os.environ.get(m.group(1), os.environ.get(m.group(1).upper(), m.group(0)))
    return re.sub(r"\$([A-Za-z_][A-Za-z0-9_]*(?:\([Xx]86\))?)", repl, path)


def has_msvc():
    """MSVC with the VC tools, asked from vswhere (not on PATH; cl.exe is only there in a dev shell)."""
    base = os.environ.get("ProgramFiles(x86)")
    vswhere = os.path.join(base, "Microsoft Visual Studio", "Installer", "vswhere.exe") if base else ""
    if not vswhere or not os.path.isfile(vswhere):
        return None
    try:
        out = subprocess.run(
            [vswhere, "-latest", "-products", "*", "-requires", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
             "-property", "installationPath"], capture_output=True, text=True, check=False).stdout.strip()
    except OSError:
        return None
    return out or None


def has_webview2():
    for var in ("ProgramFiles(x86)", "ProgramFiles"):
        base = os.environ.get(var)
        d = os.path.join(base, "Microsoft", "EdgeWebView", "Application") if base else ""
        if d and os.path.isdir(d):
            return d
    return None


DETECTORS = {"msvc": has_msvc, "webview2": has_webview2}


def find_tool(t):
    """Where the tool is, or None. PATH under every name first, then the literal paths."""
    if t.get("detect") in DETECTORS:
        return DETECTORS[t["detect"]]()
    reject = [r.lower() for r in t.get("reject") or []]
    for name in [t["bin"]] + as_list(t.get("bin_alternatives")):
        hit = shutil.which(name)
        if hit and not any(r in hit.lower() for r in reject):
            return hit
    for p in as_list((t.get("paths") or {}).get(OS)):
        p = expand(p)
        if os.path.isfile(p):
            return p
    return None


# Set by main() on the Tricentis workstation (NVIM_MACHINE_ROLE=workstation, without --force): prebuilt
# third-party tools may be installed there, but nothing may be compiled locally (CrowdStrike Falcon reports
# own unsigned builds). So build toolchains are left out, cargo install is no route, pip takes wheels only.
NO_LOCAL_BUILDS = False
# Also set by main(), independent of --force: on the workstation no installer is fetched and run through
# iex (irm get.scoop.sh | iex is "code from the net started directly", a Falcon trigger of its own).
ON_WORKSTATION = False


def skip_reason(t):
    """Why this tool is not for this machine, or None."""
    if WSL and t.get("skip_wsl"):
        return "not for wsl"
    oses = t.get("os")
    if oses and OS not in oses:
        return "not for %s" % OS
    if NO_LOCAL_BUILDS and t.get("not_on_workstation"):
        return "workstation: builds"
    return None


def applies_here(t):
    return skip_reason(t) is None


def fallback_not_needed(t, tools):
    """A fallback (clang for msvc) is only wanted while its primary is missing here."""
    primary = tools.get(t.get("fallback_for") or "")
    return bool(primary) and applies_here(primary) and bool(find_tool(primary))


def packages_of(value):
    """A pkg value is one package name or a list of them (apt: clang + clang-format)."""
    return [p for p in value if p] if isinstance(value, list) else ([value] if value else [])


# ---------------------------------------------------------------- routes

def system_managers():
    """Package managers present here, in preference order."""
    if OS == "win":
        found = [pm for pm in ("winget", "scoop") if shutil.which(pm)]
        # scoop is offered even when missing: this script can bootstrap it (not on the workstation: iex)
        if "scoop" not in found and not ON_WORKSTATION:
            found.append("scoop?")
        return found
    found = [pm for pm in LINUX_PMS if shutil.which(PM_EXE[pm])] if OS == "linux" else []
    if shutil.which("brew"):
        found.append("brew")
    return found


def route_for(t, managers):
    """(kind, package) - kind is a manager id, npm/pip/cargo, url, or none."""
    pkg = t.get("pkg") or {}
    for pm in managers:
        key = pm.rstrip("?")
        if pkg.get(key):
            return key, pkg[key]
    alt = t.get("alt") or {}
    for kind in ("npm", "pip", "cargo"):
        if kind == "cargo" and NO_LOCAL_BUILDS:
            continue  # cargo install compiles: an own unsigned binary
        if alt.get(kind):
            return kind, alt[kind]
    if alt.get("url"):
        return "url", alt["url"]
    return "none", ""


def needs_sudo():
    return OS != "win" and hasattr(os, "geteuid") and os.geteuid() != 0 and shutil.which("sudo")


def npm_needs_sudo():
    """A distro node installs globals under /usr: npm -g then fails with EACCES without sudo."""
    if not needs_sudo() or not shutil.which("npm"):
        return False
    try:
        prefix = subprocess.check_output(["npm", "config", "get", "prefix"], text=True).strip()
    except (OSError, subprocess.CalledProcessError):
        return False
    target = os.path.join(prefix, "lib")
    return bool(prefix) and not os.access(target if os.path.isdir(target) else prefix, os.W_OK)


def commands_for(kind, packages, yes):
    """argv lists for one route kind and its packages (deduplicated, order kept)."""
    pkgs = list(dict.fromkeys(packages))
    sudo = ["sudo"] if needs_sudo() else []
    if kind == "winget":
        extra = ["--accept-package-agreements", "--accept-source-agreements"] if yes else []
        # winget takes one package per call (extra tokens become query terms)
        return [["winget", "install", "-e", "--id", p, "--source", "winget"] + extra for p in pkgs]
    if kind == "scoop":
        return [["scoop", "install"] + pkgs]
    if kind == "apt":
        return [sudo + ["apt-get", "install"] + (["-y"] if yes else []) + pkgs]
    if kind == "dnf":
        return [sudo + ["dnf", "install"] + (["-y"] if yes else []) + pkgs]
    if kind == "pacman":
        return [sudo + ["pacman", "-S", "--needed"] + (["--noconfirm"] if yes else []) + pkgs]
    if kind == "zypper":
        return [sudo + ["zypper"] + (["--non-interactive"] if yes else []) + ["install"] + pkgs]
    if kind == "apk":
        return [sudo + ["apk", "add"] + pkgs]
    if kind == "brew":
        return [["brew", "install"] + pkgs]
    if kind == "npm":
        return [(["sudo"] if npm_needs_sudo() else []) + ["npm", "install", "-g"] + pkgs]
    if kind == "pip":
        # wheels only where nothing may be compiled: a source distribution would build native code locally
        wheels = ["--only-binary", ":all:"] if NO_LOCAL_BUILDS else []
        if OS == "win":
            py = shutil.which("python") or shutil.which("py") or "python"
            return [[py, "-m", "pip", "install", "--upgrade"] + wheels + pkgs]
        # PEP 668: distro pythons refuse a global pip install; pipx gives each tool its own venv
        extra = ["--pip-args=--only-binary=:all:"] if NO_LOCAL_BUILDS else []
        return [["pipx", "install"] + extra + [p] for p in pkgs]
    if kind == "cargo":
        return [["cargo", "install", "--locked"] + pkgs]
    return []


# ---------------------------------------------------------------- output

def short(text, limit=110):
    text = re.sub(r"`", "", (text or "").strip())
    parts = re.split(r"(?<=[.!?])\s", text)
    first = parts[0]
    if len(first) < 40 and len(parts) > 1:
        first = first + " " + parts[1]  # "Two things, both optional." says nothing alone
    if len(first) > limit:
        first = first[: limit - 3].rstrip() + "..."
    return first


def selected(tools, groups):
    out = [t for t in tools.values() if t["group"] in groups]
    return sorted(out, key=lambda t: (GROUP_ORDER.index(t["group"]) if t["group"] in GROUP_ORDER else 99, t["bin"]))


def print_list(rows, managers, tools):
    print("%-20s %-8s %-8s %-48s %s" % ("tool", "group", "state", "route", "used by"))
    for t in rows:
        if not applies_here(t):
            state, route = "n/a", "(%s)" % skip_reason(t)
        elif fallback_not_needed(t, tools):
            state, route = "n/a", "(%s is there)" % t["fallback_for"]
        else:
            state = "ok" if find_tool(t) else "MISSING"
            kind, pkg = route_for(t, managers)
            route = "%s %s" % (kind, " ".join(packages_of(pkg))) if kind != "none" else "-- no route --"
        print("%-20s %-8s %-8s %-48s %s" % (t["bin"], t["group"], state, route[:48], ", ".join(t.get("used_by") or [])))


def md_cell(s):
    return (s or "").replace("|", "\\|")


README_BEGIN = "<!-- tools:begin (generated: install_tools.py --write-readme) -->"
README_END = "<!-- tools:end -->"


def markdown_lines(tools, manifest):
    out = []
    groups = manifest.get("groups") or {}
    for g in GROUP_ORDER:
        rows = selected(tools, [g])
        if not rows:
            continue
        out.append("\n### %s - %s\n" % (g, groups.get(g, "")))
        out.append("| Tool | Wofür (aus der Spec) | Wer braucht es | Windows | Linux / macOS |")
        out.append("|---|---|---|---|---|")
        for t in rows:
            pkg, alt = t.get("pkg") or {}, t.get("alt") or {}
            oses = t.get("os")
            if oses and "win" not in oses:
                win = "nur Linux/macOS"
            elif pkg.get("winget"):
                win = "winget `%s`" % " ".join(packages_of(pkg["winget"]))
            elif pkg.get("scoop"):
                win = "scoop `%s`" % " ".join(packages_of(pkg["scoop"]))
            else:
                win = next(("%s `%s`" % (k, alt[k]) for k in ("npm", "pip", "cargo") if alt.get(k)), None) \
                    or ("[Download](%s)" % alt["url"] if alt.get("url") else "-")
            if oses == ["win"]:
                unix = "nur Windows"
            else:
                apt = "apt `%s`" % " ".join(packages_of(pkg["apt"])) if pkg.get("apt") else None
                brew = "brew `%s`" % " ".join(packages_of(pkg["brew"])) if pkg.get("brew") else None
                other = next(("%s `%s`" % (k, alt[k]) for k in ("npm", "pip", "cargo") if alt.get(k)), None)
                unix = ", ".join(x for x in (apt, brew) if x) or other or \
                    ("[Download](%s)" % alt["url"] if alt.get("url") else "-")
            name = "`%s`%s%s" % (t["bin"], " (Pflicht)" if t.get("required") else "",
                                 " (nicht auf der Workstation)" if t.get("not_on_workstation") else "")
            out.append("| %s | %s | %s | %s | %s |" % (
                name, md_cell(short(t.get("why"))), md_cell(", ".join(t.get("used_by") or [])), win, unix))
    return "\n".join(out).lstrip("\n") + "\n"


def write_readme(tools, manifest):
    """Replace the block between the markers in README.md (UTF-8, LF)."""
    path = os.path.join(HERE, "README.md")
    with open(path, "r", encoding="utf-8", newline="") as f:
        text = f.read()
    start, end = text.find(README_BEGIN), text.find(README_END)
    if start < 0 or end < start:
        print("README.md: Marker fehlen (%s ... %s)" % (README_BEGIN, README_END))
        return 2
    new = text[: start + len(README_BEGIN)] + "\n\n" + markdown_lines(tools, manifest) + "\n" + text[end:]
    if new != text:
        with open(path, "w", encoding="utf-8", newline="") as f:
            f.write(new)
        print("README.md aktualisiert.")
    else:
        print("README.md ist aktuell.")
    return 0


# ---------------------------------------------------------------- install

def ask(question, yes):
    if yes:
        return True
    if not sys.stdin.isatty():
        return False
    try:
        return input(question + " [j/N] ").strip().lower() in ("j", "ja", "y", "yes")
    except EOFError:
        return False


def run(argv, dry):
    print("  > " + " ".join(argv))
    if dry:
        return 0
    exe = shutil.which(argv[0])
    if not exe:
        print("    nicht gefunden: %s" % argv[0])
        return 127
    try:
        return subprocess.call([exe] + argv[1:])
    except OSError as e:
        print("    Fehler: %s" % e)
        return 1


def bootstrap_scoop(dry, yes):
    if shutil.which("scoop"):
        return True
    if ON_WORKSTATION:
        print("  scoop fehlt; auf der Workstation startet dieses Skript keinen Installer per iex aus dem Netz"
              " - scoop von Hand einrichten (https://scoop.sh) oder diese Tools weglassen.")
        return False
    if not ask("scoop fehlt, wird aber gebraucht. Jetzt installieren (irm get.scoop.sh | iex)?", yes):
        return False
    shell = shutil.which("pwsh") or shutil.which("powershell")
    rc = run([shell or "powershell", "-NoProfile", "-ExecutionPolicy", "RemoteSigned", "-Command",
              "Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression"], dry)
    refresh_path()
    scoop_shims = os.path.join(os.environ.get("USERPROFILE", ""), "scoop", "shims")
    if os.path.isdir(scoop_shims):
        os.environ["PATH"] = scoop_shims + os.pathsep + os.environ.get("PATH", "")
    return rc == 0 or dry


def bootstrap_pipx(dry, yes, managers):
    if OS == "win" or shutil.which("pipx"):
        return True
    for pm in managers:
        if pm in ("apt", "dnf", "pacman", "zypper", "brew"):
            name = "python-pipx" if pm == "pacman" else ("python3-pipx" if pm == "zypper" else "pipx")
            for argv in commands_for(pm, [name], yes):
                run(argv, dry)
            break
    if shutil.which("pipx") and not dry:
        run(["pipx", "ensurepath"], dry)
    return dry or bool(shutil.which("pipx"))


SYSTEM_PMS = LINUX_PMS + ["brew", "scoop"]


def install_kind(kind, items, yes, runner):
    """Run one route kind; returns the bins that failed. A system manager that refuses the
    combined command (one unknown name aborts apt/dnf/pacman for all) is retried per package."""
    failed = []
    if kind == "apt":
        runner((["sudo"] if needs_sudo() else []) + ["apt-get", "update"])
    for argv in commands_for(kind, [p for _, p in items], yes):
        if kind == "winget":
            # MSVC Build Tools: the workload goes in through the installer's own arguments
            ov = next((t.get("winget_override") for t, p in items if p in argv and t.get("winget_override")), None)
            if ov:
                argv = argv + ["--override", ov]
        rc = runner(argv)
        if rc == 0:
            continue
        print("    Exit %s" % rc)
        pkgs = [p for _, p in items if p in argv]
        if kind in SYSTEM_PMS and len(set(pkgs)) > 1:
            print("    einzeln nachversuchen ...")
            for p in dict.fromkeys(pkgs):
                if runner(commands_for(kind, [p], yes)[0]) != 0:
                    failed += [t["bin"] for t, q in items if q == p]
        else:
            failed += [t["bin"] for t, q in items if q in pkgs]
    return failed


def install(rows, managers, dry, yes, tools=None):
    plan = {}  # kind -> [(tool, package)]
    links, unroutable = [], []
    for t in rows:
        if not applies_here(t) or fallback_not_needed(t, tools or {}) or find_tool(t):
            continue
        kind, pkg = route_for(t, managers)
        if kind == "url":
            links.append((t, pkg))
        elif kind == "none":
            unroutable.append(t)
        else:
            for p in packages_of(pkg):
                plan.setdefault(kind, []).append((t, p))

    if not plan and not links and not unroutable:
        print("Alles da - nichts zu installieren.")
        return 0

    print("\nGeplant:")
    for kind, items in plan.items():
        print("  %-7s %s" % (kind, ", ".join(sorted(set(p for _, p in items)))))
    if links:
        print("  manuell %s" % ", ".join(t["bin"] for t, _ in links))
    if not dry and not ask("\nInstallieren?", yes):
        print("Abgebrochen.")
        return 2

    failed = []
    # phase 1: system package managers; phase 2 (npm/pip/cargo) needs node/python/cargo from phase 1
    for phase in (["winget", "scoop"] + LINUX_PMS + ["brew"], ["npm", "pip", "cargo"]):
        for kind in phase:
            items = plan.get(kind)
            if not items:
                continue
            print("\n== %s ==" % kind)
            if kind == "scoop" and not bootstrap_scoop(dry, yes):
                failed += [t["bin"] for t, _ in items]
                continue
            if kind == "pip" and not bootstrap_pipx(dry, yes, managers):
                print("  pipx fehlt - pip-Tools ausgelassen")
                failed += [t["bin"] for t, _ in items]
                continue
            if kind in ("npm", "cargo", "pip") and not dry:
                need = {"npm": "npm", "cargo": "cargo", "pip": "python" if OS == "win" else "pipx"}[kind]
                if not shutil.which(need):
                    print("  %s fehlt (erst core/dev installieren, dann neues Terminal) - ausgelassen" % need)
                    failed += [t["bin"] for t, _ in items]
                    continue
            failed += install_kind(kind, items, yes, lambda argv: run(argv, dry))
        refresh_path()

    print("\n== Ergebnis ==")
    if links:
        print("Manuell herunterladen:")
        for t, url in links:
            print("  %-16s %s" % (t["bin"], url))
    if unroutable:
        print("Kein Weg auf %s: %s" % (OS, ", ".join(t["bin"] for t in unroutable)))
    if not dry:
        still = [t["bin"] for t in rows
                 if applies_here(t) and not fallback_not_needed(t, tools or {}) and not find_tool(t)]
        print("Noch nicht im PATH dieses Prozesses: %s" % (", ".join(still) or "-"))
        print("(Neues Terminal oeffnen; danach in nvim :Lib deps status und :checkhealth,"
              " fuer die Runner scripts/runner_tools_check.ps1. LSP-Server bringt Mason/lsp.nvim.)")
    if failed:
        print("Fehlgeschlagen: %s" % ", ".join(sorted(set(failed))))
        return 1
    return 0


# ---------------------------------------------------------------- main

def parse_groups(value):
    return [g.strip().lower() for g in re.split(r"[,\s]+", value or "") if g.strip()]


PROFILE_FILE = os.path.join(os.path.expanduser("~"), ".claude", "devtools.profile")


def resolve_profiles(value, manifest):
    """--profile value -> (requested names, expanded set incl. core and implied) or an error text.
    'all' = every profile, 'saved' = the choice remembered in ~/.claude/devtools.profile."""
    spec = manifest.get("profiles") or {}
    names = spec.get("names") or []
    requested = parse_groups(value)
    if requested == ["saved"]:
        try:
            with open(PROFILE_FILE, "r", encoding="utf-8") as f:
                requested = parse_groups(f.read())
        except OSError:
            return None, None, "Keine gemerkten Profile (%s)." % PROFILE_FILE
    if not requested:
        return None, None, "Kein Profil angegeben (%s, all)." % ", ".join(names)
    bad = [p for p in requested if p != "all" and p not in names]
    if bad:
        return None, None, "Unbekanntes Profil: %s (bekannt: %s, all)" % (", ".join(bad), ", ".join(names))
    wanted = set(names) if "all" in requested else set(requested) | {"core"}
    for p in list(wanted):
        wanted.update((spec.get("implies") or {}).get(p) or [])
    return requested, wanted, None


def by_profiles(tools, wanted):
    rows = [t for t in tools.values() if set(t.get("profiles") or []) & wanted]
    return sorted(rows, key=lambda t: t["bin"])


def print_status(tools, manifest):
    """Per profile: what is here. Installs nothing (the Claude setup shows this before asking)."""
    for prof in (manifest.get("profiles") or {}).get("names") or []:
        # the workstation's left-out build toolchains are shown, so an empty cpp profile is explained
        rows = [t for t in by_profiles(tools, {prof})
                if applies_here(t) or skip_reason(t) == "workstation: builds"]
        if not rows:
            continue
        print("  %s" % prof)
        for t in rows:
            if not applies_here(t):
                state, note = "  -  ", "  (Workstation: wird nicht installiert, baut Programme)"
            elif fallback_not_needed(t, tools):
                state, note = "ok   ", "  (nicht noetig: %s ist da)" % t["fallback_for"]
            else:
                state = "ok   " if find_tool(t) else "fehlt"
                note = "  (Ersatz fuer %s)" % t["fallback_for"] if t.get("fallback_for") else ""
            print("    %s  %s%s" % (state, t["bin"], note))


def main(argv=None):
    ap = argparse.ArgumentParser(description="CLI-Tools der eigenen nvim-Plugins und Repos installieren.")
    ap.add_argument("--list", action="store_true", help="Tabelle: Tool, Gruppe, vorhanden?, Route")
    ap.add_argument("--markdown", action="store_true", help="die Tool-Liste als Markdown ausgeben")
    ap.add_argument("--write-readme", action="store_true", help="die Tool-Liste in README.md neu schreiben")
    ap.add_argument("--dry-run", action="store_true", help="nur zeigen, was installiert wuerde")
    ap.add_argument("--all", action="store_true", help="auch die Gruppe heavy")
    ap.add_argument("--only", help="nur diese Gruppen (core,plugins,heavy,dev)")
    ap.add_argument("--skip", help="diese Gruppen auslassen")
    ap.add_argument("--yes", action="store_true", help="nicht nachfragen, Lizenzen von winget annehmen")
    ap.add_argument("--repos-dir", help="Wurzel der Repos (Default $REPOS_DIR)")
    ap.add_argument("--force", action="store_true",
                    help="auf der Workstation auch Bau-Toolchains und cargo install (sonst dort ausgelassen)")
    ap.add_argument("--profile", help="statt Gruppen die Stack-Profile des Claude-Setups"
                    " (core,nvim,cpp,rust,web,tauri, all, saved = die gemerkten)")
    ap.add_argument("--status", action="store_true", help="je Profil zeigen, was da ist (installiert nichts)")
    a = ap.parse_args(argv)

    groups = parse_groups(a.only) or (GROUP_ORDER if a.all else DEFAULT_GROUPS)
    bad = [g for g in groups + parse_groups(a.skip) if g not in GROUP_ORDER]
    if bad:
        print("Unbekannte Gruppe: %s (erlaubt: %s)" % (", ".join(bad), ", ".join(GROUP_ORDER)))
        return 2
    groups = [g for g in groups if g not in parse_groups(a.skip)]

    global NO_LOCAL_BUILDS, ON_WORKSTATION
    ON_WORKSTATION = (os.environ.get("NVIM_MACHINE_ROLE") or "").strip().lower() == "workstation"
    NO_LOCAL_BUILDS = ON_WORKSTATION and not a.force

    repos = repos_dir(a.repos_dir)
    tools, manifest, problems = collect(repos)
    profile_mode = a.status or a.profile
    for p in problems:
        # the profile tools all stand in tools.json: no plugin spec needed (the Claude setup runs before cloning)
        if not (profile_mode and "REPOS_DIR" in p):
            print("Hinweis: %s" % p, file=sys.stderr)

    if a.write_readme:
        return write_readme(tools, manifest)
    if a.markdown:
        sys.stdout.write(markdown_lines(tools, manifest))
        return 0
    if a.status:
        print_status(tools, manifest)
        return 0

    managers = system_managers()
    requested = None
    if a.profile:
        requested, wanted, err = resolve_profiles(a.profile, manifest)
        if err:
            print(err)
            return 2
        rows = by_profiles(tools, wanted)
        label = "Profile: %s" % ", ".join(sorted(wanted))
    else:
        rows = selected(tools, groups)
        label = "Gruppen: %s" % ", ".join(groups)
    if a.list:
        print("Repos: %s | System: %s | Paketmanager: %s | %s\n" % (
            repos, OS, ", ".join(managers) or "-", label))
        print_list(rows, managers, tools)
        return 0

    if NO_LOCAL_BUILDS:
        print("Workstation: fertige Pakete ja, nichts lokal Gebautes - Bau-Toolchains und cargo install"
              " bleiben aus, pip nimmt nur Wheels (bewusste Ausnahme: --force).")
    if not managers or managers == ["scoop?"]:
        print("Kein Paketmanager gefunden (winget/scoop/apt/dnf/pacman/zypper/apk/brew).")
    print(label)
    rc = install(rows, managers, a.dry_run, a.yes, tools)
    if requested and parse_groups(a.profile) != ["saved"] and not a.dry_run and rc != 2:
        os.makedirs(os.path.dirname(PROFILE_FILE), exist_ok=True)
        with open(PROFILE_FILE, "w", encoding="utf-8", newline="") as f:
            f.write(",".join(requested) + "\n")
        print("Profile gemerkt in %s (wieder: --profile saved)" % PROFILE_FILE)
    return rc


if __name__ == "__main__":
    sys.exit(main())
