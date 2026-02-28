import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pubmed_mobile/core/constants/app_constants.dart';
import 'package:pubmed_mobile/core/network/rate_limiter.dart';
import 'package:pubmed_mobile/features/settings/data/settings_repository.dart';

/// Provides the configured Dio instance.
final dioProvider = Provider<Dio>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  final apiKey = settings.apiKey;

  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.ncbiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    queryParameters: {
      'tool': AppConstants.toolName,
      'email': AppConstants.contactEmail,
      if (apiKey != null && apiKey.isNotEmpty) 'api_key': apiKey,
    },
  ));

  // Rate limiting interceptor (must be first)
  final rateLimit = apiKey != null && apiKey.isNotEmpty
      ? AppConstants.rateLimitWithKey
      : AppConstants.rateLimitWithoutKey;
  dio.interceptors.add(RateLimitInterceptor(maxPerSecond: rateLimit));

  // 429 retry interceptor
  dio.interceptors.add(RetryOn429Interceptor(dio));

  // Logging in debug mode
  assert(() {
    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
    ));
    return true;
  }());

  return dio;
});

/// Interceptor that enforces rate limiting using a token bucket.
class RateLimitInterceptor extends Interceptor {
  RateLimitInterceptor({required int maxPerSecond})
      : _rateLimiter = RateLimiter(maxPerSecond: maxPerSecond);

  final RateLimiter _rateLimiter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await _rateLimiter.acquire();
    handler.next(options);
  }
}

/// Interceptor that retries on HTTP 429 (Too Many Requests).
class RetryOn429Interceptor extends Interceptor {
  RetryOn429Interceptor(this._dio, {this.maxRetries = 3});

  final Dio _dio;
  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (err.response?.statusCode == 429 && retryCount < maxRetries) {
      final retryAfter = int.tryParse(
              err.response?.headers.value('retry-after') ?? '') ??
          2;
      await Future.delayed(Duration(seconds: retryAfter));

      final opts = err.requestOptions;
      opts.extra['retryCount'] = retryCount + 1;

      try {
        final response = await _dio.fetch(opts);
        handler.resolve(response);
      } on DioException catch (e) {
        handler.next(e);
      }
    } else {
      handler.next(err);
    }
  }
}

