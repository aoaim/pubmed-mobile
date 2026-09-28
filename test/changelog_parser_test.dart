import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pubmed_mobile/features/updates/data/changelog_parser.dart';
import 'package:pubmed_mobile/features/updates/domain/changelog_entry.dart';

void main() {
  group('compareVersions', () {
    test('compares major/minor/patch', () {
      expect(compareVersions('0.2.0', '0.1.0'), greaterThan(0));
      expect(compareVersions('0.1.0', '0.2.0'), lessThan(0));
      expect(compareVersions('1.0.0', '0.9.9'), greaterThan(0));
      expect(compareVersions('0.2.0', '0.2.0'), 0);
    });

    test('ignores build numbers', () {
      expect(compareVersions('0.2.0+1', '0.2.0'), 0);
      expect(compareVersions('0.2.0+5', '0.2.0+1'), 0);
      expect(compareVersions('0.3.0+1', '0.2.0+99'), greaterThan(0));
    });

    test('orders prerelease versions before their stable release', () {
      expect(compareVersions('0.3.0', '0.3.0-dev'), greaterThan(0));
      expect(compareVersions('0.3.0-dev.2', '0.3.0-dev.10'), lessThan(0));
    });

    test('degrades gracefully on malformed input', () {
      expect(compareVersions('abc', '0.1.0'), lessThan(0));
      expect(compareVersions('0.1', '0.1.0'), lessThan(0));
      expect(compareVersions('', '0.1.0'), lessThan(0));
      expect(compareVersions('abc', 'abc'), 0);
    });
  });

  group('ChangelogParser.parse', () {
    const sample = '''
# PubMed Mobile Changelog

## [0.2.0] - 2026-09-28
### 新增
- 新增：Aptabase 分析
### 修复
- 修复：版本号不同步

## [0.1.0] - 2026-09-01
- 首个正式版本
''';

    test('parses entries newest first', () {
      final entries = ChangelogParser.parse(sample);
      expect(entries, hasLength(2));
      expect(entries[0].version, '0.2.0');
      expect(entries[0].date, '2026-09-28');
      expect(entries[1].version, '0.1.0');
    });

    test('parses bullet lines without the dash prefix', () {
      final entries = ChangelogParser.parse(sample);
      expect(entries[0].lines, ['新增：Aptabase 分析', '修复：版本号不同步']);
    });

    test('supports build numbers in version headers', () {
      final entries = ChangelogParser.parse('''
## [0.2.0+1] - 2026-09-28
- x
''');
      expect(entries, hasLength(1));
      expect(entries[0].version, '0.2.0+1');
    });

    test('ignores non-bullet lines inside entries', () {
      final entries = ChangelogParser.parse('''
## [0.2.0] - 2026-09-28
- 新增：x
  缩进说明文字
- 修复：y
''');
      expect(entries[0].lines, ['新增：x', '修复：y']);
    });

    test('returns empty list for garbage input', () {
      expect(ChangelogParser.parse('no entries here'), isEmpty);
      expect(ChangelogParser.parse(''), isEmpty);
    });

    test('repository changelog is readable and matches the app version', () {
      final entries = ChangelogParser.parse(
        File('CHANGELOG.md').readAsStringSync(),
      );
      final versionLine = File('pubspec.yaml')
          .readAsLinesSync()
          .firstWhere((line) => line.startsWith('version:'));
      final appVersion = versionLine.substring('version:'.length).trim();

      expect(entries, isNotEmpty);
      expect(
        entries.first.version.split('+').first,
        appVersion.split('+').first,
      );
    });

    test('repository changelog keeps category headings ordered', () {
      final raw = File('CHANGELOG.md').readAsStringSync();
      const order = ['新增', '优化', '修复', '调整'];
      final versions = raw.split(RegExp(r'^## \[', multiLine: true)).skip(1);
      for (final version in versions) {
        final headings = RegExp(
          r'^### (新增|优化|修复|调整)$',
          multiLine: true,
        ).allMatches(version).map((match) => match.group(1)!).toList();
        final expected = [...headings]
          ..sort((a, b) => order.indexOf(a).compareTo(order.indexOf(b)));
        expect(headings, expected);
        expect(headings.toSet(), hasLength(headings.length));
      }
    });

    test('repository changelog bullets match their category heading', () {
      final lines = File('CHANGELOG.md').readAsLinesSync();
      String? category;
      var insideVersion = false;
      for (final line in lines) {
        if (line.startsWith('## [')) {
          insideVersion = true;
          category = null;
        } else if (line.startsWith('### ')) {
          category = line.substring(4).trim();
        } else if (insideVersion && line.startsWith('- ')) {
          expect(category, isNotNull, reason: '分类标题缺失：$line');
          expect(line, startsWith('- $category：'), reason: '条目与分类不一致：$line');
        }
      }
    });
  });

  group('ChangelogParser.entriesNewerThan', () {
    final entries = ChangelogParser.parse('''
## [0.3.0] - 2026-10-01
- 新功能

## [0.2.0] - 2026-09-28
- 分析

## [0.1.0] - 2026-09-01
- 初始
''');

    test('returns only entries newer than current version', () {
      final newer = ChangelogParser.entriesNewerThan(entries, '0.2.0');
      expect(newer, hasLength(1));
      expect(newer.first.version, '0.3.0');
    });

    test('returns empty when already on the latest version', () {
      expect(ChangelogParser.entriesNewerThan(entries, '0.3.0'), isEmpty);
    });

    test('returns only newer entries when current version is absent', () {
      final newer = ChangelogParser.entriesNewerThan(entries, '0.2.5');
      expect(newer.map((entry) => entry.version), ['0.3.0']);
    });

    test('does not suggest older releases to a newer build', () {
      final newer = ChangelogParser.entriesNewerThan(entries, '9.9.9-dev');
      expect(newer, isEmpty);
    });
  });

  group('ChangelogEntry.toMarkdown', () {
    test('renders entry as markdown', () {
      const entry = ChangelogEntry(
        version: '0.2.0',
        date: '2026-09-28',
        lines: ['新增：x', '修复：y'],
      );
      expect(entry.toMarkdown(), '## [0.2.0] - 2026-09-28\n- 新增：x\n- 修复：y');
    });
  });
}
