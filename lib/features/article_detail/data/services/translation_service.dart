import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pubmed_mobile/core/constants/app_constants.dart';
import 'package:pubmed_mobile/features/article_detail/domain/translation_failure.dart';
import 'package:pubmed_mobile/features/settings/data/settings_repository.dart';

final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService(
    dio: Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 15),
      ),
    ),
    settings: ref.watch(settingsRepositoryProvider),
  );
});

class TranslationService {
  TranslationService({required this.dio, required this.settings});

  final Dio dio;
  final SettingsRepository settings;

  TranslationProvider get activeProvider {
    if (settings.translationChannel == TranslationChannel.openai) {
      return TranslationProvider.openai;
    }
    final key = settings.deeplApiKey;
    return (key != null && key.endsWith(':fx'))
        ? TranslationProvider.deeplFree
        : TranslationProvider.deeplPro;
  }

  /// Translates text.
  /// Automatically detects if it contains Chinese characters.
  /// English -> zh-Hans, Chinese -> en
  Future<String> translate(String text, {CancelToken? cancelToken}) async {
    if (text.isEmpty) return text;

    // Detect language direction
    final hasChinese = RegExp(r'[\u4e00-\u9fa5]').hasMatch(text);
    final targetLang = hasChinese ? 'en' : 'zh';

    switch (settings.translationChannel) {
      case TranslationChannel.deepl:
        final deeplKey = settings.deeplApiKey;
        if (deeplKey == null || deeplKey.isEmpty) {
          throw const TranslationFailure(
            TranslationFailureKind.noProviderConfigured,
            provider: TranslationProvider.deeplFree,
            stage: TranslationStage.translation,
          );
        }
        return _translateDeepl(text, targetLang, deeplKey, cancelToken);
      case TranslationChannel.openai:
        final openaiKey = settings.openaiApiKey;
        if (openaiKey == null || openaiKey.isEmpty) {
          throw const TranslationFailure(
            TranslationFailureKind.noProviderConfigured,
            provider: TranslationProvider.openai,
            stage: TranslationStage.translation,
          );
        }
        return _translateOpenai(text, targetLang, openaiKey, cancelToken);
    }
  }

  /// Fetches models using the credentials currently entered in Settings.
  /// They need not be saved before the user refreshes the model list.
  Future<List<String>> fetchModels({
    required String baseUrl,
    required String apiKey,
  }) async {
    final url = _normalizeBaseUrl(baseUrl);
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw const TranslationFailure(
        TranslationFailureKind.noProviderConfigured,
        provider: TranslationProvider.openai,
        stage: TranslationStage.translation,
      );
    }
    try {
      final response = await dio.get(
        '$url/models',
        options: Options(headers: {'Authorization': 'Bearer $key'}),
      );
      final data = response.data['data'] as List?;
      if (data == null) {
        throw const TranslationFailure(
          TranslationFailureKind.invalidResponse,
          provider: TranslationProvider.openai,
          stage: TranslationStage.translation,
        );
      }
      final models = <String>{};
      for (final entry in data) {
        if (entry is! Map || entry['id'] is! String) continue;
        final id = (entry['id'] as String).trim();
        if (id.isNotEmpty) models.add(id);
      }
      if (models.isEmpty) {
        throw const TranslationFailure(
          TranslationFailureKind.invalidResponse,
          provider: TranslationProvider.openai,
          stage: TranslationStage.translation,
        );
      }
      return models.toList();
    } on DioException catch (error) {
      throw TranslationFailure.fromDio(
        error,
        provider: TranslationProvider.openai,
        stage: TranslationStage.translation,
      );
    } on TranslationFailure {
      rethrow;
    } catch (_) {
      throw const TranslationFailure(
        TranslationFailureKind.invalidResponse,
        provider: TranslationProvider.openai,
        stage: TranslationStage.translation,
      );
    }
  }

  String _normalizeBaseUrl(String baseUrl) {
    var url = baseUrl.trim();
    if (url.isEmpty) url = AppConstants.defaultOpenaiBaseUrl;
    return url.replaceAll(RegExp(r'/+$'), '');
  }

  Future<String> _translateDeepl(
    String text,
    String targetLang,
    String apiKey,
    CancelToken? cancelToken,
  ) async {
    final isFreeApi = apiKey.endsWith(':fx');
    final provider = isFreeApi
        ? TranslationProvider.deeplFree
        : TranslationProvider.deeplPro;
    final baseUrl = isFreeApi
        ? 'https://api-free.deepl.com/v2/translate'
        : 'https://api.deepl.com/v2/translate';

    try {
      final response = await dio.post(
        baseUrl,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Authorization': 'DeepL-Auth-Key $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'text': [text],
          'target_lang': targetLang.toUpperCase(),
          'model_type': 'prefer_quality_optimized',
        },
      );
      final translations = response.data['translations'] as List;
      if (translations.isNotEmpty) {
        return translations.first['text'] as String;
      }
      throw TranslationFailure(
        TranslationFailureKind.invalidResponse,
        provider: provider,
        stage: TranslationStage.translation,
      );
    } on DioException catch (error) {
      if (error.type == DioExceptionType.cancel) rethrow;
      throw TranslationFailure.fromDio(
        error,
        provider: provider,
        stage: TranslationStage.translation,
      );
    } on TranslationFailure {
      rethrow;
    } catch (_) {
      throw TranslationFailure(
        TranslationFailureKind.invalidResponse,
        provider: provider,
        stage: TranslationStage.translation,
      );
    }
  }

  Future<String> _translateOpenai(
    String text,
    String targetLang,
    String apiKey,
    CancelToken? cancelToken,
  ) async {
    final baseUrl = _normalizeBaseUrl(settings.openaiBaseUrl);
    final model = settings.openaiModel;
    final toChinese = targetLang == 'zh';
    final systemPrompt = toChinese
        ? 'You are a professional medical translator. Translate the following '
              'text into Simplified Chinese (zh-Hans). Keep the meaning accurate, '
              'use standard medical terminology, and output only the translation '
              'without any explanation or extra text.'
        : 'You are a professional medical translator. Translate the following '
              'text into English. Keep the meaning accurate, use standard medical '
              'terminology, and output only the translation without any '
              'explanation or extra text.';

    try {
      final response = await dio.post(
        '$baseUrl/chat/completions',
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          // DeepSeek currently enables thinking by default. Translation only
          // needs the final text; non-thinking keeps requests responsive.
          if (Uri.tryParse(baseUrl)?.host == 'api.deepseek.com' &&
              model == AppConstants.defaultOpenaiModel)
            'thinking': {'type': 'disabled'},
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': text},
          ],
          'temperature': 0.3,
          'max_tokens': 4096,
        },
      );
      final choices = response.data['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        final choice = choices.first;
        if (choice['finish_reason'] == 'length') {
          throw const TranslationFailure(
            TranslationFailureKind.invalidResponse,
            provider: TranslationProvider.openai,
            stage: TranslationStage.translation,
          );
        }
        final content = choice['message']?['content'] as String?;
        if (content != null && content.trim().isNotEmpty) {
          return content.trim();
        }
      }
      throw const TranslationFailure(
        TranslationFailureKind.invalidResponse,
        provider: TranslationProvider.openai,
        stage: TranslationStage.translation,
      );
    } on DioException catch (error) {
      if (error.type == DioExceptionType.cancel) rethrow;
      throw TranslationFailure.fromDio(
        error,
        provider: TranslationProvider.openai,
        stage: TranslationStage.translation,
      );
    } on TranslationFailure {
      rethrow;
    } catch (_) {
      throw const TranslationFailure(
        TranslationFailureKind.invalidResponse,
        provider: TranslationProvider.openai,
        stage: TranslationStage.translation,
      );
    }
  }
}
