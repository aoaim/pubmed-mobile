import 'package:dio/dio.dart';

enum TranslationFailureKind {
  invalidApiKey,
  network,
  quotaExceeded,
  rateLimited,
  serviceUnavailable,
  requestRejected,
  invalidResponse,
  noProviderConfigured,
  unknown,
}

enum TranslationProvider { deeplFree, deeplPro, openai }

enum TranslationStage { authentication, translation }

class TranslationFailure implements Exception {
  const TranslationFailure(
    this.kind, {
    required this.provider,
    required this.stage,
    this.statusCode,
    this.networkType,
  });

  factory TranslationFailure.fromDio(
    DioException error, {
    required TranslationProvider provider,
    required TranslationStage stage,
  }) {
    final statusCode = error.response?.statusCode;
    TranslationFailure failure(TranslationFailureKind kind) =>
        TranslationFailure(
          kind,
          provider: provider,
          stage: stage,
          statusCode: statusCode,
          networkType: error.type,
        );

    if (statusCode == 401 || statusCode == 403) {
      return failure(TranslationFailureKind.invalidApiKey);
    }
    if (statusCode == 402 || statusCode == 456) {
      return failure(TranslationFailureKind.quotaExceeded);
    }
    if (statusCode == 429) {
      return failure(TranslationFailureKind.rateLimited);
    }
    if (statusCode != null && statusCode >= 500) {
      return failure(TranslationFailureKind.serviceUnavailable);
    }
    if (statusCode != null && statusCode >= 400) {
      return failure(TranslationFailureKind.requestRejected);
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate => failure(
        TranslationFailureKind.network,
      ),
      DioExceptionType.badResponse => failure(
        TranslationFailureKind.serviceUnavailable,
      ),
      DioExceptionType.cancel ||
      DioExceptionType.unknown => failure(TranslationFailureKind.unknown),
    };
  }

  final TranslationFailureKind kind;
  final TranslationProvider provider;
  final TranslationStage stage;
  final int? statusCode;
  final DioExceptionType? networkType;
}
