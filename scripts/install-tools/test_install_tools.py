"""Tests for install_tools.py: python -I scripts/install-tools/test_install_tools.py"""

import json
import os
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import install_tools as it  # noqa: E402


def make_repos(specs):
    root = tempfile.mkdtemp(prefix="install-tools-test-")
    for plugin, tools in specs.items():
        d = os.path.join(root, plugin, "docs")
        os.makedirs(d)
        with open(os.path.join(d, "install.json"), "w", encoding="utf-8") as f:
            json.dump({"tools": tools}, f)
    return root


class MergeTest(unittest.TestCase):
    def test_one_entry_per_bin_with_all_declarers(self):
        root = make_repos({
            "a.nvim": [{"bin": "rg", "why": "first", "pkg": {"winget": "A.Rg"}}],
            "b.nvim": [{"bin": "rg", "required": True, "why": "second", "pkg": {"winget": "B.Rg", "apt": "ripgrep"}}],
        })
        try:
            tools, _, problems = it.collect(root)
        finally:
            shutil.rmtree(root)
        rg = tools["rg"]
        self.assertTrue(rg["required"])
        self.assertEqual(rg["why"], "first")
        self.assertEqual(rg["pkg"]["apt"], "ripgrep")
        self.assertEqual(rg["used_by"][:2], ["a.nvim", "b.nvim"])
        self.assertEqual(problems, [])

    def test_override_wins_over_spec_package(self):
        root = make_repos({"x.nvim": [{"bin": "node", "why": "w", "pkg": {"winget": "OpenJS.NodeJS"}}]})
        try:
            tools, _, _ = it.collect(root)
        finally:
            shutil.rmtree(root)
        self.assertEqual(tools["node"]["pkg"]["winget"], "OpenJS.NodeJS.LTS")
        self.assertEqual(tools["node"]["group"], "core")

    def test_string_alternatives_do_not_become_characters(self):
        dst = {"bin": "gs"}
        it.merge_tool(dst, {"bin": "gs", "bin_alternatives": "gswin64c", "paths": {"win": "C:\\x"}}, "p")
        self.assertEqual(dst["bin_alternatives"], [])
        self.assertEqual(dst["paths"]["win"], [])
        self.assertIsNone(it.find_tool({"bin": "definitely-not-a-tool-xyz", "bin_alternatives": "abc"}))

    def test_missing_specs_are_reported(self):
        root = tempfile.mkdtemp(prefix="install-tools-empty-")
        try:
            _, _, problems = it.collect(root)
        finally:
            shutil.rmtree(root)
        self.assertTrue(any("REPOS_DIR" in p for p in problems))


class RouteTest(unittest.TestCase):
    def test_package_manager_before_alt_before_url(self):
        t = {"pkg": {"scoop": "s"}, "alt": {"pip": "p", "url": "u"}}
        self.assertEqual(it.route_for(t, ["winget", "scoop"]), ("scoop", "s"))
        self.assertEqual(it.route_for(t, ["winget"]), ("pip", "p"))
        self.assertEqual(it.route_for({"alt": {"url": "u"}}, ["apt"]), ("url", "u"))
        self.assertEqual(it.route_for({}, ["apt"]), ("none", ""))

    def test_winget_one_call_per_package_deduplicated(self):
        cmds = it.commands_for("winget", ["Gyan.FFmpeg", "Gyan.FFmpeg", "qpdf.qpdf"], yes=False)
        self.assertEqual(len(cmds), 2)
        self.assertNotIn("--accept-package-agreements", cmds[0])


class InstallKindTest(unittest.TestCase):
    def setUp(self):
        self._sudo = it.needs_sudo
        it.needs_sudo = lambda: False

    def tearDown(self):
        it.needs_sudo = self._sudo

    def test_one_unknown_package_does_not_block_the_others(self):
        calls = []

        def runner(argv):
            calls.append(argv)
            if argv[:2] == ["apt-get", "update"]:
                return 0
            return 100 if "lazygit" in argv else 0

        items = [({"bin": "lazygit"}, "lazygit"), ({"bin": "jq"}, "jq"), ({"bin": "zip"}, "zip")]
        failed = it.install_kind("apt", items, True, runner)
        self.assertEqual(failed, ["lazygit"])
        self.assertEqual(calls[0], ["apt-get", "update"])
        self.assertIn(["apt-get", "install", "-y", "jq"], calls)

    def test_npm_failure_is_not_retried(self):
        items = [({"bin": "cspell"}, "cspell")]
        failed = it.install_kind("npm", items, True, lambda argv: 1)
        self.assertEqual(failed, ["cspell"])


class ProfileTest(unittest.TestCase):
    """The stack profiles that replaced setup-devtools.js."""

    def setUp(self):
        root = tempfile.mkdtemp(prefix="install-tools-noplugins-")
        try:
            self.tools, self.manifest, _ = it.collect(root)  # no plugin cloned: the Claude-setup case
        finally:
            shutil.rmtree(root)

    def test_core_profile_stands_without_plugin_specs(self):
        _, wanted, err = it.resolve_profiles("core", self.manifest)
        self.assertIsNone(err)
        bins = [t["bin"] for t in it.by_profiles(self.tools, wanted)]
        self.assertEqual(sorted(bins), ["fd", "git", "node", "rg"])

    def test_profiles_match_the_old_setup_devtools_table(self):
        expected = {
            "nvim": {"nvim", "stylua", "lua-language-server", "luacheck"},
            "cpp": {"cmake", "ninja", "msvc", "clang-format"},
            "rust": {"cargo"},
            "web": {"pnpm"},
            "tauri": {"webview2"},
        }
        for prof, bins in expected.items():
            got = {t["bin"] for t in it.by_profiles(self.tools, {prof})}
            self.assertEqual(got, bins, prof)

    def test_tauri_implies_rust_and_web_plus_core(self):
        _, wanted, _ = it.resolve_profiles("tauri", self.manifest)
        self.assertEqual(wanted, {"core", "tauri", "rust", "web"})
        _, wanted, _ = it.resolve_profiles("all", self.manifest)
        self.assertEqual(wanted, set(self.manifest["profiles"]["names"]))

    def test_unknown_profile_is_an_error(self):
        _, _, err = it.resolve_profiles("nvim,foo", self.manifest)
        self.assertIn("foo", err)

    def test_saved_profiles_come_from_the_file(self):
        d = tempfile.mkdtemp(prefix="install-tools-profile-")
        old = it.PROFILE_FILE
        it.PROFILE_FILE = os.path.join(d, "devtools.profile")
        try:
            self.assertIsNotNone(it.resolve_profiles("saved", self.manifest)[2])
            with open(it.PROFILE_FILE, "w", encoding="utf-8") as f:
                f.write("rust,web\n")
            requested, wanted, err = it.resolve_profiles("saved", self.manifest)
            self.assertIsNone(err)
            self.assertEqual(requested, ["rust", "web"])
            self.assertIn("core", wanted)
        finally:
            it.PROFILE_FILE = old
            shutil.rmtree(d)

    def test_clang_only_while_msvc_is_missing(self):
        clang = self.tools["clang-format"]
        old = it.DETECTORS["msvc"]
        try:
            it.DETECTORS["msvc"] = lambda: "C:\\VS"
            self.assertEqual(it.fallback_not_needed(clang, self.tools), it.applies_here(self.tools["msvc"]))
            it.DETECTORS["msvc"] = lambda: None
            self.assertFalse(it.fallback_not_needed(clang, self.tools))
        finally:
            it.DETECTORS["msvc"] = old

    def test_msvc_winget_call_carries_the_workload_override(self):
        msvc = self.tools["msvc"]
        calls = []
        it.install_kind("winget", [(msvc, msvc["pkg"]["winget"])], False, lambda argv: calls.append(argv) or 0)
        self.assertEqual(calls[0][-2], "--override")
        self.assertIn("Microsoft.VisualStudio.Workload.VCTools", calls[0][-1])

    def test_a_package_list_installs_every_package(self):
        self.assertEqual(it.packages_of(["clang", "clang-format"]), ["clang", "clang-format"])
        self.assertEqual(it.packages_of("llvm"), ["llvm"])
        self.assertEqual(it.packages_of(None), [])


class WorkstationTest(unittest.TestCase):
    """Prebuilt packages yes, nothing compiled locally (CrowdStrike Falcon)."""

    def setUp(self):
        root = tempfile.mkdtemp(prefix="install-tools-ws-")
        try:
            self.tools, _, _ = it.collect(root)
        finally:
            shutil.rmtree(root)
        it.NO_LOCAL_BUILDS = True

    def tearDown(self):
        it.NO_LOCAL_BUILDS = False
        it.ON_WORKSTATION = False

    def test_no_scoop_bootstrap_through_iex(self):
        it.ON_WORKSTATION = True
        calls = []
        old_which, old_run = it.shutil.which, it.run
        it.shutil.which = lambda name: None if name == "scoop" else old_which(name)
        it.run = lambda argv, dry: calls.append(argv) or 0
        try:
            self.assertFalse(it.bootstrap_scoop(dry=False, yes=True))
            if it.OS == "win":
                self.assertNotIn("scoop?", it.system_managers())
        finally:
            it.shutil.which, it.run = old_which, old_run
        self.assertEqual(calls, [])

    def test_prebuilt_tools_stay_installable(self):
        for b in ("lazygit", "nvim", "gh", "stylua", "pnpm"):
            self.assertTrue(it.applies_here(self.tools[b]) or it.skip_reason(self.tools[b]) != "workstation: builds", b)
        self.assertEqual(it.route_for(self.tools["lazygit"], ["winget"])[0], "winget")

    def test_build_toolchains_are_left_out(self):
        for b in ("cargo", "msvc", "cmake", "ninja", "tree-sitter", "zig", "iscc", "cargo-audit"):
            t = self.tools[b]
            if it.OS in (t.get("os") or [it.OS]):
                self.assertEqual(it.skip_reason(t), "workstation: builds", b)

    def test_cargo_is_no_route_there(self):
        self.assertEqual(it.route_for({"alt": {"cargo": "typos-cli"}}, ["winget"]), ("none", ""))
        it.NO_LOCAL_BUILDS = False
        self.assertEqual(it.route_for({"alt": {"cargo": "typos-cli"}}, ["winget"]), ("cargo", "typos-cli"))

    def test_pip_takes_wheels_only(self):
        argv = it.commands_for("pip", ["codespell"], yes=False)[0]
        self.assertTrue("--only-binary" in argv or "--pip-args=--only-binary=:all:" in argv)

    def test_main_does_not_refuse_on_the_workstation(self):
        old = os.environ.get("NVIM_MACHINE_ROLE")
        os.environ["NVIM_MACHINE_ROLE"] = "workstation"
        try:
            rc = it.main(["--only", "core", "--dry-run", "--repos-dir", tempfile.gettempdir()])
        finally:
            if old is None:
                del os.environ["NVIM_MACHINE_ROLE"]
            else:
                os.environ["NVIM_MACHINE_ROLE"] = old
        self.assertEqual(rc, 0)


class ShortTest(unittest.TestCase):
    def test_too_short_first_sentence_takes_the_second(self):
        self.assertTrue(it.short("Two things. The second one explains it.").startswith("Two things. The second"))
        self.assertTrue(it.short("x" * 200).endswith("..."))


if __name__ == "__main__":
    unittest.main()
