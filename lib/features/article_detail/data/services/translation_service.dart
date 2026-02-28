import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pubmed_mobile/features/settings/data/settings_repository.dart';

final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService(
    dio: Dio(),
    settings: ref.watch(settingsRepositoryProvider),
  );
});

class TranslationService {
  TranslationService({required this.dio, required this.settings});

  final Dio dio;
  final SettingsRepository settings;

  /// Translates text.
  /// Automatically detects if it contains Chinese characters.
  /// English -> zh-Hans, Chinese -> en
  Future<String> translate(String text) async {
    if (text.isEmpty) return text;

    // Detect language direction
    final hasChinese = RegExp(r'[\u4e00-\u9fa5]').hasMatch(text);
    final targetLang = hasChinese ? 'en' : 'zh'; // For DeepL: EN or ZH
    final microsoftTargetLang = hasChinese ? 'en' : 'zh-Hans';
    final microsoftSourceLang = hasChinese ? 'zh-Hans' : 'en';

    // Try DeepL if key is configured
    final deeplKey = settings.deeplApiKey;
    if (deeplKey != null && deeplKey.isNotEmpty) {
      try {
        return await _translateDeepl(text, targetLang, deeplKey);
      } catch (e) {
        // Fallback to Microsoft
      }
    }

    // Default to Microsoft free API
    return await _translateMicrosoft(text, microsoftTargetLang, microsoftSourceLang);
  }

  Future<String> _translateDeepl(
      String text, String targetLang, String apiKey) async {
    final isFreeApi = apiKey.endsWith(':fx');
    final baseUrl = isFreeApi
        ? 'https://api-free.deepl.com/v2/translate'
        : 'https://api.deepl.com/v2/translate';

    final response = await dio.post(
      baseUrl,
      options: Options(headers: {
        'Authorization': 'DeepL-Auth-Key $apiKey',
        'Content-Type': 'application/json',
      }),
      data: {
        'text': [text],
        'target_lang': targetLang.toUpperCase(),
        'model_type': 'prefer_quality_optimized',
      },
    );

    if (response.statusCode == 200) {
      final translations = response.data['translations'] as List;
      if (translations.isNotEmpty) {
        return translations.first['text'] as String;
      }
    }
    throw Exception('DeepL Translation Failed');
  }

  Future<String> _translateMicrosoft(
      String text, String targetLang, String sourceLang) async {
    // Step 1: Get Auth Token
    final authResponse = await dio.get(
      'https://edge.microsoft.com/translate/auth',
      options: Options(
        responseType: ResponseType.plain,
        validateStatus: (status) => status == 200,
      ),
    );

    final authToken = authResponse.data.toString();

    // Step 2: Translate
    final translateUrl =
        'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=$targetLang&from=$sourceLang';

    final translateResponse = await dio.post(
      translateUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
      data: [
        {'text': text}
      ],
    );

    if (translateResponse.statusCode == 200) {
      final data = translateResponse.data as List;
      if (data.isNotEmpty && data[0]['translations'] != null) {
        final translations = data[0]['translations'] as List;
        if (translations.isNotEmpty) {
          return translations[0]['text'] as String;
        }
      }
    }
    throw Exception('Microsoft Translation Failed');
  }
}
