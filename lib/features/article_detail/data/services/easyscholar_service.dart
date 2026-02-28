import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pubmed_mobile/features/settings/data/settings_repository.dart';

/// easyScholar journal ranking service.
///
/// API: https://www.easyscholar.cc/open/getPublicationRank
/// Hard rate limit: 2 requests/sec.
class EasyScholarService {
  EasyScholarService({required this.settings});

  final SettingsRepository settings;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://www.easyscholar.cc/open',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

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

      final ranking = JournalRanking(
        sciPartition: all['sci']?.toString(),         // JCR SCI 分区
        sciIf: all['sciif']?.toString(),               // SCI 影响因子
        sciUpPartition: all['sciUp']?.toString(),      // 中科院升级版大类分区
        sciUpSmall: all['sciUpSmall']?.toString(),     // 中科院升级版小类分区
        sciUpTop: all['sciUpTop']?.toString(),         // 中科院升级版Top
        esi: all['esi']?.toString(),                   // ESI学科分类
      );

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
  const JournalRanking({
    this.sciPartition,
    this.sciIf,
    this.sciUpPartition,
    this.sciUpSmall,
    this.sciUpTop,
    this.esi,
  });

  /// JCR SCI 分区 (e.g. "Q1")
  final String? sciPartition;
  /// SCI 影响因子 (e.g. "13.6")
  final String? sciIf;
  /// 中科院升级版大类分区 (e.g. "1区")
  final String? sciUpPartition;
  /// 中科院升级版小类分区 (e.g. "医学1区")
  final String? sciUpSmall;
  /// 中科院升级版Top分区 (e.g. "医学TOP")
  final String? sciUpTop;
  /// ESI学科分类 (e.g. "CLINICAL MEDICINE")
  final String? esi;

  /// Whether any ranking data is available.
  bool get hasData =>
      sciPartition != null ||
      sciIf != null ||
      sciUpPartition != null;
}

/// Provider for EasyScholarService.
final easyScholarServiceProvider = Provider<EasyScholarService>((ref) {
  return EasyScholarService(settings: ref.watch(settingsRepositoryProvider));
});
