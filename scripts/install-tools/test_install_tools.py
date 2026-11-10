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


class ShortTest(unittest.TestCase):
    def test_too_short_first_sentence_takes_the_second(self):
        self.assertTrue(it.short("Two things. The second one explains it.").startswith("Two things. The second"))
        self.assertTrue(it.short("x" * 200).endswith("..."))


if __name__ == "__main__":
    unittest.main()
