import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pubmed_mobile/features/article_detail/domain/translation_failure.dart';

void main() {
  DioException responseError(int statusCode) {
    final request = RequestOptions(path: '/translate');
    return DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: request, statusCode: statusCode),
    );
  }

  test('classifies an invalid user API key', () {
    final failure = TranslationFailure.fromDio(
      responseError(403),
      provider: TranslationProvider.deeplFree,
      stage: TranslationStage.translation,
    );

    expect(failure.kind, TranslationFailureKind.invalidApiKey);
    expect(failure.provider, TranslationProvider.deeplFree);
    expect(failure.statusCode, 403);
  });

  test('classifies a DeepSeek 401 as an invalid API key', () {
    final failure = TranslationFailure.fromDio(
      responseError(401),
      provider: TranslationProvider.openai,
      stage: TranslationStage.translation,
    );

    expect(failure.kind, TranslationFailureKind.invalidApiKey);
    expect(failure.provider, TranslationProvider.openai);
    expect(failure.statusCode, 401);
  });

  test('classifies quota, rate limit, and network failures', () {
    expect(
      TranslationFailure.fromDio(
        responseError(456),
        provider: TranslationProvider.deeplPro,
        stage: TranslationStage.translation,
      ).kind,
      TranslationFailureKind.quotaExceeded,
    );
    expect(
      TranslationFailure.fromDio(
        responseError(429),
        provider: TranslationProvider.deeplFree,
        stage: TranslationStage.translation,
      ).kind,
      TranslationFailureKind.rateLimited,
    );

    final request = RequestOptions(path: '/translate');
    final networkError = DioException(
      requestOptions: request,
      type: DioExceptionType.connectionError,
    );
    expect(
      TranslationFailure.fromDio(
        networkError,
        provider: TranslationProvider.openai,
        stage: TranslationStage.translation,
      ).kind,
      TranslationFailureKind.network,
    );
  });

  test('keeps the HTTP status for a rejected request', () {
    final failure = TranslationFailure.fromDio(
      responseError(400),
      provider: TranslationProvider.deeplFree,
      stage: TranslationStage.translation,
    );

    expect(failure.kind, TranslationFailureKind.requestRejected);
    expect(failure.statusCode, 400);
  });
}
