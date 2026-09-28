/// A single version entry parsed from CHANGELOG.md.
class ChangelogEntry {
  const ChangelogEntry({
    required this.version,
    required this.date,
    required this.lines,
  });

  /// Semantic version, e.g. `0.2.0` (build number stripped).
  final String version;

  /// Release date in `YYYY-MM-DD` format.
  final String date;

  /// Bullet lines of the entry (without the leading `- `).
  final List<String> lines;

  /// Renders the entry as markdown text for display.
  String toMarkdown() {
    final body = lines.map((l) => '- $l').join('\n');
    return '## [$version] - $date\n$body';
  }
}

/// Compares two semantic versions like `0.2.0`, `0.2.0-dev`, or `0.2.0+1`.
///
/// Returns:
/// - negative if [a] < [b]
/// - zero if equal (build numbers ignored)
/// - positive if [a] > [b]
int compareVersions(String a, String b) {
  final pa = _parse(a);
  final pb = _parse(b);
  for (var i = 0; i < 3; i++) {
    if (pa[i] != pb[i]) return pa[i].compareTo(pb[i]);
  }
  final aPre = _preRelease(a);
  final bPre = _preRelease(b);
  if (aPre == null && bPre == null) return 0;
  if (aPre == null) return 1;
  if (bPre == null) return -1;

  final aParts = aPre.split('.');
  final bParts = bPre.split('.');
  for (var i = 0; i < aParts.length && i < bParts.length; i++) {
    final aNum = int.tryParse(aParts[i]);
    final bNum = int.tryParse(bParts[i]);
    if (aNum != null && bNum != null) {
      if (aNum != bNum) return aNum.compareTo(bNum);
    } else if (aNum != null) {
      return -1;
    } else if (bNum != null) {
      return 1;
    } else {
      final comparison = aParts[i].compareTo(bParts[i]);
      if (comparison != 0) return comparison;
    }
  }
  return aParts.length.compareTo(bParts.length);
}

/// Parses the numeric core of `x.y.z[-prerelease][+build]`.
/// Malformed input degrades gracefully to `[0, 0, 0]`.
List<int> _parse(String version) {
  final core = version.split('+').first.split('-').first.trim();
  final parts = core.split('.');
  if (parts.length != 3) return [0, 0, 0];
  final nums = parts.map(int.tryParse);
  if (nums.any((n) => n == null)) return [0, 0, 0];
  return nums.cast<int>().toList();
}

String? _preRelease(String version) {
  final withoutBuild = version.split('+').first.trim();
  final dash = withoutBuild.indexOf('-');
  return dash < 0 ? null : withoutBuild.substring(dash + 1);
}
