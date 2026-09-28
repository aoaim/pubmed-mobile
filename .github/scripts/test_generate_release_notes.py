"""Regression checks for the Release description built from CHANGELOG.md."""

import unittest
from pathlib import Path

from generate_release_notes import (
    PUBSPEC_VERSION_RE,
    build_release_notes,
    version_core,
)


CHANGELOG = """# Changelog

## [0.2.0] - 2026-09-28

### 新增

- 新增：功能 A

### 修复

- 修复：问题 B

## [0.1.2] - 2026-09-20

- 旧版内容
"""
PUBSPEC = "version: 0.2.0+1\n"


class GenerateReleaseNotesTest(unittest.TestCase):
    def test_copies_only_matching_version_and_links_to_tagged_changelog(self):
        notes = build_release_notes(
            CHANGELOG, PUBSPEC, "v0.2.0", "aoaim/pubmed-mobile"
        )
        self.assertIn("## [0.2.0] - 2026-09-28", notes)
        self.assertIn("- 新增：功能 A", notes)
        self.assertIn("### 新增", notes)
        self.assertIn("### 修复", notes)
        self.assertIn("- 修复：问题 B", notes)
        self.assertNotIn("旧版内容", notes)
        self.assertIn(
            "https://github.com/aoaim/pubmed-mobile/blob/v0.2.0/CHANGELOG.md",
            notes,
        )

    def test_rejects_missing_or_mismatched_versions(self):
        for tag in ("v0.1.2", "v0.3.0", "main"):
            with self.subTest(tag=tag), self.assertRaises(ValueError):
                build_release_notes(CHANGELOG, PUBSPEC, tag, "aoaim/pubmed-mobile")

        with self.assertRaises(ValueError):
            build_release_notes(
                "## [0.1.2] - 2026-09-20\n- old\n",
                PUBSPEC,
                "v0.2.0",
                "aoaim/pubmed-mobile",
            )

    def test_current_repository_changelog_can_generate_release_notes(self):
        root = Path(__file__).resolve().parents[2]
        pubspec = (root / "pubspec.yaml").read_text(encoding="utf-8")
        version_match = PUBSPEC_VERSION_RE.search(pubspec)
        self.assertIsNotNone(version_match)
        current_version = version_core(version_match.group(1))
        notes = build_release_notes(
            (root / "CHANGELOG.md").read_text(encoding="utf-8"),
            pubspec,
            f"v{current_version}",
            "aoaim/pubmed-mobile",
        )
        self.assertTrue(notes.startswith(f"## [{current_version}]"))


if __name__ == "__main__":
    unittest.main()
