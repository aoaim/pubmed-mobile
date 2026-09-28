import 'package:pubmed_mobile/features/updates/domain/changelog_entry.dart';

/// Parses the fixed-format CHANGELOG.md.
///
/// Expected format (see CHANGELOG.md header for the full spec):
/// ```
/// ## [0.2.0] - 2026-09-28
/// ### 新增
/// - 新增：xxx
/// ### 修复
/// - 修复：yyy
///
/// ## [0.1.0] - 2026-09-01
/// - ...
/// ```
class ChangelogParser {
  ChangelogParser._();

  static final _entryHeader = RegExp(
    r'^##\s*\[(\d+\.\d+\.\d+(?:\+\d+)?)\]\s*-\s*(\d{4}-\d{2}-\d{2})\s*$',
  );

  /// Parses the whole changelog into entries, newest first (document order).
  static List<ChangelogEntry> parse(String raw) {
    final entries = <ChangelogEntry>[];
    final lines = raw.split('\n');

    String? currentVersion;
    String? currentDate;
    final currentLines = <String>[];

    void flush() {
      if (currentVersion != null) {
        entries.add(
          ChangelogEntry(
            version: currentVersion!,
            date: currentDate ?? '',
            lines: List.of(currentLines),
          ),
        );
      }
      currentVersion = null;
      currentDate = null;
      currentLines.clear();
    }

    for (final line in lines) {
      final match = _entryHeader.firstMatch(line.trim());
      if (match != null) {
        flush();
        currentVersion = match.group(1)!;
        currentDate = match.group(2)!;
        continue;
      }
      if (currentVersion != null) {
        final trimmed = line.trim();
        if (trimmed.startsWith('- ')) {
          currentLines.add(trimmed.substring(2).trim());
        }
      }
    }
    flush();
    return entries;
  }

  /// Returns the entries newer than [currentVersion], newest first.
  /// A missing current version does not make older entries into updates.
  static List<ChangelogEntry> entriesNewerThan(
    List<ChangelogEntry> entries,
    String currentVersion,
  ) {
    final result = <ChangelogEntry>[];
    for (final entry in entries) {
      if (compareVersions(entry.version, currentVersion) > 0) {
        result.add(entry);
      }
    }
    return result;
  }
}
