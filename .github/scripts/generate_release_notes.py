"""Build GitHub Release notes from the matching CHANGELOG.md section."""

import os
import re
import sys
from pathlib import Path


VERSION_RE = r"\d+\.\d+\.\d+(?:\+\d+)?"
TAG_RE = re.compile(rf"^v({VERSION_RE})$")
PUBSPEC_VERSION_RE = re.compile(rf"^version:\s*['\"]?({VERSION_RE})['\"]?\s*$", re.M)
CHANGELOG_HEADER_RE = re.compile(
    rf"^## \[({VERSION_RE})\] - \d{{4}}-\d{{2}}-\d{{2}}\s*$", re.M
)
REPOSITORY_RE = re.compile(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$")


def version_core(version: str) -> str:
    return version.split("+", 1)[0]


def build_release_notes(
    changelog: str, pubspec: str, tag: str, repository: str
) -> str:
    tag_match = TAG_RE.fullmatch(tag)
    if tag_match is None:
        raise ValueError(f"Release tag must be vX.Y.Z or vX.Y.Z+build: {tag}")
    if REPOSITORY_RE.fullmatch(repository) is None:
        raise ValueError(f"Invalid GitHub repository: {repository}")

    tag_version = tag_match.group(1)
    pubspec_match = PUBSPEC_VERSION_RE.search(pubspec)
    if pubspec_match is None:
        raise ValueError("pubspec.yaml has no valid version field")
    if version_core(pubspec_match.group(1)) != version_core(tag_version):
        raise ValueError(
            f"Tag {tag} does not match pubspec.yaml version {pubspec_match.group(1)}"
        )

    headers = list(CHANGELOG_HEADER_RE.finditer(changelog))
    matching = [
        index
        for index, header in enumerate(headers)
        if version_core(header.group(1)) == version_core(tag_version)
    ]
    if len(matching) != 1:
        raise ValueError(f"Expected one CHANGELOG.md entry for {tag}, found {len(matching)}")

    index = matching[0]
    start = headers[index].start()
    end = headers[index + 1].start() if index + 1 < len(headers) else len(changelog)
    section = changelog[start:end].strip()
    if not any(line.startswith("- ") for line in section.splitlines()):
        raise ValueError(f"CHANGELOG.md entry for {tag} has no changes")

    full_changelog = f"https://github.com/{repository}/blob/{tag}/CHANGELOG.md"
    return f"{section}\n\n[查看完整更新日志]({full_changelog})\n"


def main() -> None:
    if os.environ.get("GITHUB_REF_TYPE") != "tag":
        raise ValueError("Choose a version tag when running the release workflow")

    notes = build_release_notes(
        Path("CHANGELOG.md").read_text(encoding="utf-8"),
        Path("pubspec.yaml").read_text(encoding="utf-8"),
        os.environ.get("GITHUB_REF_NAME", ""),
        os.environ.get("GITHUB_REPOSITORY", ""),
    )
    output = Path(os.environ.get("RELEASE_NOTES_PATH", "release-notes.md"))
    output.write_text(notes, encoding="utf-8")
    print(f"Release notes written to {output}")


if __name__ == "__main__":
    try:
        main()
    except ValueError as error:
        print(f"::error::{error}", file=sys.stderr)
        raise SystemExit(1) from error
