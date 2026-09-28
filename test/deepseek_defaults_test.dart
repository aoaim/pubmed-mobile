import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pubmed_mobile/core/constants/app_constants.dart';
import 'package:pubmed_mobile/features/article_detail/data/services/translation_service.dart';
import 'package:pubmed_mobile/features/article_detail/domain/translation_failure.dart';
import 'package:pubmed_mobile/features/settings/data/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SettingsRepository> createSettings(
    Map<String, Object> preferences,
    Map<String, String> credentials,
  ) async {
    SharedPreferences.setMockInitialValues(preferences);
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      credentials,
    );
    final prefs = await SharedPreferences.getInstance();
    return SettingsRepository.create(prefs, const FlutterSecureStorage());
  }

  test(
    'fresh installations use the official DeepSeek endpoint and model',
    () async {
      final settings = await createSettings({}, {});
      expect(settings.openaiBaseUrl, 'https://api.deepseek.com');
      expect(settings.openaiModel, 'deepseek-flash');
      expect(settings.translationChannel, TranslationChannel.deepl);

      await settings.setOpenaiApiKey('new-deepseek-key');
      expect(settings.openaiBaseUrl, AppConstants.defaultOpenaiBaseUrl);
      expect(settings.openaiModel, AppConstants.defaultOpenaiModel);
    },
  );

  test('a saved DeepSeek key keeps DeepSeek defaults after restart', () async {
    final credentials = <String, String>{};
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      credentials,
    );
    final prefs = await SharedPreferences.getInstance();
    const storage = FlutterSecureStorage();
    final firstLaunch = await SettingsRepository.create(prefs, storage);

    await firstLaunch.setOpenaiApiKey('new-deepseek-key');
    final secondLaunch = await SettingsRepository.create(prefs, storage);

    expect(secondLaunch.openaiApiKey, 'new-deepseek-key');
    expect(secondLaunch.openaiBaseUrl, AppConstants.defaultOpenaiBaseUrl);
    expect(secondLaunch.openaiModel, AppConstants.defaultOpenaiModel);
  });

  test('resets provider settings once and preserves later edits', () async {
    final credentials = {'openai_api_key': 'deepseek-key'};
    SharedPreferences.setMockInitialValues({
      'openai_base_url': 'https://example.org/v1',
      'openai_model': 'old-model',
    });
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      credentials,
    );
    final prefs = await SharedPreferences.getInstance();
    const storage = FlutterSecureStorage();

    final upgraded = await SettingsRepository.create(prefs, storage);
    expect(upgraded.openaiBaseUrl, AppConstants.defaultOpenaiBaseUrl);
    expect(upgraded.openaiModel, AppConstants.defaultOpenaiModel);

    await upgraded.setOpenaiConfiguration(
      baseUrl: 'https://example.org/v1',
      apiKey: 'custom-key',
      model: 'custom-model',
    );
    final restarted = await SettingsRepository.create(prefs, storage);
    expect(restarted.openaiBaseUrl, 'https://example.org/v1');
    expect(restarted.openaiModel, 'custom-model');
  });

  test(
    'default DeepSeek translation uses its URL and non-thinking mode',
    () async {
      final settings = await createSettings({}, {});
      await settings.setOpenaiApiKey('deepseek-key');
      await settings.setTranslationChannel(TranslationChannel.openai);
      final dio = Dio();
      RequestOptions? request;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            request = options;
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'choices': [
                    {
                      'message': {'content': '译文'},
                      'finish_reason': 'stop',
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final service = TranslationService(dio: dio, settings: settings);
      expect(await service.translate('Example text'), '译文');
      expect(
        request?.uri.toString(),
        'https://api.deepseek.com/chat/completions',
      );
      expect((request?.data as Map)['model'], 'deepseek-flash');
      expect((request?.data as Map)['thinking'], {'type': 'disabled'});
    },
  );

  test(
    'an explicitly chosen DeepSeek URL gets the new default model',
    () async {
      final settings = await createSettings(
        {'openai_base_url': 'https://api.deepseek.com'},
        {'openai_api_key': 'deepseek-key'},
      );

      expect(settings.openaiBaseUrl, AppConstants.defaultOpenaiBaseUrl);
      expect(settings.openaiModel, AppConstants.defaultOpenaiModel);
    },
  );

  test('a cut-off model response is not accepted as a translation', () async {
    final settings = await createSettings({}, {});
    await settings.setOpenaiApiKey('deepseek-key');
    await settings.setTranslationChannel(TranslationChannel.openai);
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              data: {
                'choices': [
                  {
                    'message': {'content': '部分译文'},
                    'finish_reason': 'length',
                  },
                ],
              },
            ),
          );
        },
      ),
    );

    final service = TranslationService(dio: dio, settings: settings);
    expect(
      service.translate('Long text'),
      throwsA(
        isA<TranslationFailure>().having(
          (failure) => failure.kind,
          'kind',
          TranslationFailureKind.invalidResponse,
        ),
      ),
    );
  });
}
