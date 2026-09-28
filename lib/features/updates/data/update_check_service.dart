import 'dart:async';

import 'package:dio/dio.dart';
import 'package:pubmed_mobile/features/updates/data/changelog_parser.dart';
import 'package:pubmed_mobile/features/updates/domain/changelog_entry.dart';

/// Result of an update check.
class UpdateCheckResult {
  const UpdateCheckResult({
    required this.latestVersion,
    required this.latestEntry,
    required this.entries,
  });

  /// Latest version found in the changelog.
  final String latestVersion;

  /// Full changelog entry of the latest version (for the up-to-date dialog).
  final ChangelogEntry latestEntry;

  /// Changelog entries newer than the current version (newest first).
  final List<ChangelogEntry> entries;

  bool get hasUpdate => entries.isNotEmpty;
}

/// Why an update check failed.
enum UpdateCheckFailureKind { network, parse }

class UpdateCheckException implements Exception {
  const UpdateCheckException(this.kind);

  final UpdateCheckFailureKind kind;
}

/// Fetches CHANGELOG.md from GitHub raw and checks for updates.
/// Uses a dedicated Dio instance (no rate limiter — this is not an NCBI
/// API call).
class UpdateCheckService {
  UpdateCheckService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 10),
                responseType: ResponseType.plain,
              ),
            );

  final Dio _dio;

  /// URLs for CHANGELOG.md, tried concurrently.
  ///
  /// Only raw.githubusercontent.com is used: jsdelivr mirrors have up to
  /// 24h cache lag (manual purge required), which would delay update
  /// notifications after a release. raw.githubusercontent.com is real-time.
  static const changelogUrls = [
    'https://raw.githubusercontent.com/aoaim/pubmed-mobile/main/CHANGELOG.md',
  ];

  /// Fetches the changelog from all URLs **concurrently**; the first
  /// success wins. Returns null if all fail.
  Future<String?> fetchChangelog() async {
    final completer = Completer<String?>();
    var pending = changelogUrls.length;
    var done = false;

    for (final url in changelogUrls) {
      _fetchOne(url).then((result) {
        if (done) return;
        if (result != null) {
          done = true;
          completer.complete(result);
        } else {
          pending--;
          if (pending == 0) completer.complete(null);
        }
      });
    }
    return completer.future;
  }

  Future<String?> _fetchOne(String url) async {
    try {
      final response = await _dio.get<String>(url);
      final data = response.data;
      if (data == null || data.isEmpty) return null;
      return data;
    } catch (_) {
      return null;
    }
  }

  /// Checks for updates.
  ///
  /// Throws [UpdateCheckException] when the changelog could not be fetched
  /// from any mirror (kind: [UpdateCheckFailureKind.network]) or could not
  /// be parsed (kind: [UpdateCheckFailureKind.parse]).
  Future<UpdateCheckResult> checkForUpdate(String currentVersion) async {
    final raw = await fetchChangelog();
    if (raw == null) {
      throw const UpdateCheckException(UpdateCheckFailureKind.network);
    }

    final entries = ChangelogParser.parse(raw);
    if (entries.isEmpty) {
      throw const UpdateCheckException(UpdateCheckFailureKind.parse);
    }

    final newer = ChangelogParser.entriesNewerThan(entries, currentVersion);
    return UpdateCheckResult(
      latestVersion: entries.first.version,
      latestEntry: entries.first,
      entries: newer,
    );
  }
}
