import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pubmed_mobile/features/settings/data/settings_repository.dart';
import 'package:pubmed_mobile/features/article_detail/domain/journal_metric.dart';

/// easyScholar journal ranking service.
///
/// API: https://www.easyscholar.cc/open/getPublicationRank
/// Hard rate limit: 2 requests/sec.
class EasyScholarService {
  EasyScholarService({required this.settings});

  final SettingsRepository settings;
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.easyscholar.cc/open',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// In-memory cache: journal name → ranking data.
  final Map<String, JournalRanking?> _cache = {};

  /// Simple rate limiter: track last request time to ensure ≤2 req/sec.
  DateTime _lastRequestTime = DateTime.fromMillisecondsSinceEpoch(0);
  int _requestsInWindow = 0;

  /// Whether easyScholar is configured (key provided).
  bool get isConfigured {
    final key = settings.easyScholarKey;
    return key != null && key.isNotEmpty;
  }

  /// Wait if necessary to respect the 2-per-second rate limit.
  Future<void> _waitForRateLimit() async {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRequestTime).inMilliseconds;

    if (elapsed >= 1000) {
      // New window
      _requestsInWindow = 0;
      _lastRequestTime = now;
    }

    if (_requestsInWindow >= 2) {
      // Wait until the window resets
      final waitMs = 1000 - elapsed;
      if (waitMs > 0) {
        await Future.delayed(Duration(milliseconds: waitMs));
      }
      _requestsInWindow = 0;
      _lastRequestTime = DateTime.now();
    }

    _requestsInWindow++;
  }

  /// Query journal ranking. Returns null if not configured or not found.
  Future<JournalRanking?> getJournalRanking(String journalName) async {
    if (!isConfigured || journalName.isEmpty) return null;

    // Check cache
    final normalized = journalName.toLowerCase().trim();
    if (_cache.containsKey(normalized)) return _cache[normalized];

    // Respect rate limit
    await _waitForRateLimit();

    try {
      final response = await _dio.get(
        '/getPublicationRank',
        queryParameters: {
          'secretKey': settings.easyScholarKey,
          'publicationName': journalName,
        },
      );

      final data = response.data;
      if (data['code'] != 200 || data['data'] == null) {
        _cache[normalized] = null;
        return null;
      }

      final officialRank = data['data']['officialRank'];
      final all = officialRank?['all'] as Map<String, dynamic>? ?? {};

      final ranking = JournalRanking.fromOfficialRank(all);

      _cache[normalized] = ranking;
      return ranking;
    } catch (e) {
      _cache[normalized] = null;
      return null;
    }
  }
}

/// Journal ranking data from easyScholar.
class JournalRanking {
  JournalRanking.fromOfficialRank(Map<String, dynamic> all)
    : values = {
        for (final metric in JournalMetric.values)
          if (all[metric.apiKey]?.toString().trim().isNotEmpty == true)
            metric: all[metric.apiKey].toString().trim(),
      };

  final Map<JournalMetric, String> values;
  String? valueFor(JournalMetric metric) => values[metric];
  bool get hasData => values.isNotEmpty;
}

/// Provider for EasyScholarService.
final easyScholarServiceProvider = Provider<EasyScholarService>((ref) {
  ref.watch(credentialsRevisionProvider);
  return EasyScholarService(settings: ref.watch(settingsRepositoryProvider));
});
