import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pubmed_mobile/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pubmed_mobile/features/article_detail/domain/journal_metric.dart';

/// Which translation backend the app should use.
enum TranslationChannel { deepl, openai }

/// Manages user-configurable settings.
class SettingsRepository {
  SettingsRepository._(
    this._prefs,
    this._secureStorage,
    this._apiKey,
    this._deeplApiKey,
    this._openaiApiKey,
    this._easyScholarKey,
  );

  /// Loads credentials from platform-protected storage and migrates values
  /// saved by older releases in SharedPreferences.
  static Future<SettingsRepository> create(
    SharedPreferences prefs,
    FlutterSecureStorage secureStorage,
  ) async {
    Future<String?> loadCredential(String key) async {
      final secureValue = await secureStorage.read(key: key);
      if (secureValue != null && secureValue.isNotEmpty) {
        await prefs.remove(key);
        return secureValue;
      }

      final legacyValue = prefs.getString(key);
      if (legacyValue == null || legacyValue.isEmpty) {
        await prefs.remove(key);
        return null;
      }

      await secureStorage.write(key: key, value: legacyValue);
      await prefs.remove(key);
      return legacyValue;
    }

    // Migrate the old SiliconFlow key (stored by an earlier build) to the
    // generic OpenAI-compatible key.
    final legacySiliconflowKey = await loadCredential(_keyLegacySiliconflowKey);
    final openaiKey = await loadCredential(_keyOpenaiApiKey);
    if (legacySiliconflowKey != null && openaiKey == null) {
      await secureStorage.write(
        key: _keyOpenaiApiKey,
        value: legacySiliconflowKey,
      );
    }
    final effectiveOpenaiKey = openaiKey ?? legacySiliconflowKey;
    // Existing keys were entered when SiliconFlow and Qwen were the defaults.
    // Keep their endpoint/model together so an upgrade never sends a saved key
    // to DeepSeek. Fresh installs use the DeepSeek defaults below.
    if (effectiveOpenaiKey != null &&
        prefs.getString(_keyOpenaiBaseUrl) == null) {
      await prefs.setString(_keyOpenaiBaseUrl, _legacyOpenaiBaseUrl);
    }
    if (prefs.getString(_keyOpenaiModel) == null &&
        (effectiveOpenaiKey != null ||
            prefs.getString(_keyOpenaiBaseUrl) == _legacyOpenaiBaseUrl) &&
        prefs.getString(_keyOpenaiBaseUrl) !=
            AppConstants.defaultOpenaiBaseUrl) {
      await prefs.setString(_keyOpenaiModel, _legacyOpenaiModel);
    }
    if (legacySiliconflowKey != null) {
      await secureStorage.delete(key: _keyLegacySiliconflowKey);
    }

    return SettingsRepository._(
      prefs,
      secureStorage,
      await loadCredential(_keyApiKey),
      await loadCredential(_keyDeeplApiKey),
      effectiveOpenaiKey,
      await loadCredential(_keyEasyScholarKey),
    );
  }

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  String? _apiKey;
  String? _deeplApiKey;
  String? _openaiApiKey;
  String? _easyScholarKey;

  // Keys
  static const _keyApiKey = 'ncbi_api_key';
  static const _keyDeeplApiKey = 'deepl_api_key';
  static const _keyOpenaiApiKey = 'openai_api_key';
  static const _keyLegacySiliconflowKey = 'siliconflow_api_key';
  static const _keyOpenaiBaseUrl = 'openai_base_url';
  static const _keyOpenaiModel = 'openai_model';
  static const _keyTranslationChannel = 'translation_channel';
  static const _keyEasyScholarKey = 'easyscholar_key';
  static const _keyThemeMode = 'theme_mode';
  static const _keyLocale = 'locale';
  static const _keyMaxCacheMB = 'max_cache_mb';
  static const _keyUseDynamicColor = 'use_dynamic_color';
  static const _keyPageSize = 'page_size';
  static const _keySimplifyPmcReader = 'simplify_pmc_reader';
  static const _keyJournalMetrics = 'journal_metrics';
  static const _legacyOpenaiBaseUrl = 'https://api.siliconflow.cn/v1';
  static const _legacyOpenaiModel = 'Qwen/Qwen2.5-7B-Instruct';

  static const defaultJournalMetrics = <JournalMetric>{
    JournalMetric.jcr,
    JournalMetric.casMajor,
    JournalMetric.casTop,
    JournalMetric.impactFactor,
  };

  Set<JournalMetric> get journalMetrics {
    final saved = _prefs.getStringList(_keyJournalMetrics);
    if (saved == null) return {...defaultJournalMetrics};
    return {
      for (final name in saved)
        if (JournalMetric.values.any((metric) => metric.name == name))
          JournalMetric.values.firstWhere((metric) => metric.name == name),
    };
  }

  Future<void> setJournalMetrics(Set<JournalMetric> metrics) async {
    await _prefs.setStringList(
      _keyJournalMetrics,
      metrics.map((metric) => metric.name).toList(),
    );
  }

  // NCBI API Key
  String? get apiKey => _apiKey;
  Future<void> setApiKey(String? value) async {
    if (value == null || value.isEmpty) {
      await _secureStorage.delete(key: _keyApiKey);
      await _prefs.remove(_keyApiKey);
      _apiKey = null;
    } else {
      await _secureStorage.write(key: _keyApiKey, value: value);
      await _prefs.remove(_keyApiKey);
      _apiKey = value;
    }
  }

  // DeepL API Key
  String? get deeplApiKey => _deeplApiKey;
  Future<void> setDeeplApiKey(String? value) async {
    if (value == null || value.isEmpty) {
      await _secureStorage.delete(key: _keyDeeplApiKey);
      await _prefs.remove(_keyDeeplApiKey);
      _deeplApiKey = null;
    } else {
      await _secureStorage.write(key: _keyDeeplApiKey, value: value);
      await _prefs.remove(_keyDeeplApiKey);
      _deeplApiKey = value;
    }
  }

  // OpenAI-compatible API Key (DeepSeek by default)
  String? get openaiApiKey => _openaiApiKey;
  Future<void> setOpenaiApiKey(String? value) async {
    if (value == null || value.isEmpty) {
      await _secureStorage.delete(key: _keyOpenaiApiKey);
      await _prefs.remove(_keyOpenaiApiKey);
      _openaiApiKey = null;
    } else {
      await _secureStorage.write(key: _keyOpenaiApiKey, value: value);
      await _prefs.remove(_keyOpenaiApiKey);
      _openaiApiKey = value;
    }
  }

  // OpenAI-compatible base URL (defaults to DeepSeek)
  String get openaiBaseUrl =>
      _prefs.getString(_keyOpenaiBaseUrl) ?? AppConstants.defaultOpenaiBaseUrl;

  Future<void> setOpenaiBaseUrl(String value) async {
    final url = value.trim();
    if (url.isEmpty) {
      await _prefs.remove(_keyOpenaiBaseUrl);
    } else {
      await _prefs.setString(_keyOpenaiBaseUrl, url);
    }
  }

  // OpenAI-compatible model name
  String get openaiModel =>
      _prefs.getString(_keyOpenaiModel) ?? AppConstants.defaultOpenaiModel;

  Future<void> setOpenaiModel(String value) async {
    final model = value.trim();
    if (model.isEmpty) {
      await _prefs.remove(_keyOpenaiModel);
    } else {
      await _prefs.setString(_keyOpenaiModel, model);
    }
  }

  // Translation channel
  TranslationChannel get translationChannel {
    final value = _prefs.getString(_keyTranslationChannel);
    return value == TranslationChannel.openai.name
        ? TranslationChannel.openai
        : TranslationChannel.deepl;
  }

  Future<void> setTranslationChannel(TranslationChannel channel) async {
    await _prefs.setString(_keyTranslationChannel, channel.name);
  }

  // easyScholar Key
  String? get easyScholarKey => _easyScholarKey;
  Future<void> setEasyScholarKey(String? value) async {
    if (value == null || value.isEmpty) {
      await _secureStorage.delete(key: _keyEasyScholarKey);
      await _prefs.remove(_keyEasyScholarKey);
      _easyScholarKey = null;
    } else {
      await _secureStorage.write(key: _keyEasyScholarKey, value: value);
      await _prefs.remove(_keyEasyScholarKey);
      _easyScholarKey = value;
    }
  }

  // Theme mode
  ThemeMode get themeMode {
    final value = _prefs.getString(_keyThemeMode);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_keyThemeMode, mode.name);
  }

  // Dynamic Color
  bool get useDynamicColor => _prefs.getBool(_keyUseDynamicColor) ?? true;

  Future<void> setUseDynamicColor(bool value) async {
    await _prefs.setBool(_keyUseDynamicColor, value);
  }

  // Simplify PMC Reader
  bool get simplifyPmcReader => _prefs.getBool(_keySimplifyPmcReader) ?? true;

  Future<void> setSimplifyPmcReader(bool value) async {
    await _prefs.setBool(_keySimplifyPmcReader, value);
  }

  // Locale
  Locale get locale {
    final value = _prefs.getString(_keyLocale);
    return switch (value) {
      'zh' => const Locale('zh', 'CN'),
      'en' => const Locale('en', 'GB'),
      _ => const Locale('zh', 'CN'), // Default to Chinese
    };
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_keyLocale, locale.languageCode);
  }

  // Max cache size
  int get maxCacheMB =>
      _prefs.getInt(_keyMaxCacheMB) ?? AppConstants.defaultMaxCacheMB;
  Future<void> setMaxCacheMB(int mb) async {
    await _prefs.setInt(_keyMaxCacheMB, mb);
  }

  // Page Size
  int get pageSize => _prefs.getInt(_keyPageSize) ?? 20;

  Future<void> setPageSize(int size) async {
    await _prefs.setInt(_keyPageSize, size);
  }
}

/// Provider for SettingsRepository — must be overridden at app start.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('SettingsRepository must be initialized before use');
});

/// Bumped after credentials change so dependent clients are recreated without
/// requiring an application restart.
final credentialsRevisionProvider = StateProvider<int>((ref) => 0);

final journalMetricsProvider =
    StateNotifierProvider<JournalMetricsNotifier, Set<JournalMetric>>((ref) {
      return JournalMetricsNotifier(ref.watch(settingsRepositoryProvider));
    });

class JournalMetricsNotifier extends StateNotifier<Set<JournalMetric>> {
  JournalMetricsNotifier(this._settings) : super(_settings.journalMetrics);
  final SettingsRepository _settings;

  Future<void> toggle(JournalMetric metric) async {
    final next = {...state};
    if (!next.add(metric)) next.remove(metric);
    await _settings.setJournalMetrics(next);
    state = next;
  }
}

/// Translation channel notifier for reactive UI updates.
final translationChannelProvider =
    StateNotifierProvider<TranslationChannelNotifier, TranslationChannel>((
      ref,
    ) {
      final settings = ref.watch(settingsRepositoryProvider);
      return TranslationChannelNotifier(settings);
    });

class TranslationChannelNotifier extends StateNotifier<TranslationChannel> {
  TranslationChannelNotifier(this._settings)
    : super(_settings.translationChannel);

  final SettingsRepository _settings;

  Future<void> setChannel(TranslationChannel channel) async {
    await _settings.setTranslationChannel(channel);
    state = channel;
  }
}

/// Theme mode notifier for reactive UI updates.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final settings = ref.watch(settingsRepositoryProvider);
  return ThemeModeNotifier(settings);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._settings) : super(_settings.themeMode);

  final SettingsRepository _settings;

  Future<void> setThemeMode(ThemeMode mode) async {
    await _settings.setThemeMode(mode);
    state = mode;
  }
}

/// Locale notifier for reactive language switching.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return LocaleNotifier(settings);
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._settings) : super(_settings.locale);

  final SettingsRepository _settings;

  Future<void> setLocale(Locale locale) async {
    await _settings.setLocale(locale);
    state = locale;
  }
}

/// Dynamic Color notifier
final useDynamicColorProvider =
    StateNotifierProvider<UseDynamicColorNotifier, bool>((ref) {
      final settings = ref.watch(settingsRepositoryProvider);
      return UseDynamicColorNotifier(settings);
    });

class UseDynamicColorNotifier extends StateNotifier<bool> {
  UseDynamicColorNotifier(this._settings) : super(_settings.useDynamicColor);

  final SettingsRepository _settings;

  Future<void> setUseDynamicColor(bool value) async {
    await _settings.setUseDynamicColor(value);
    state = value;
  }
}

/// Page Size notifier
final pageSizeProvider = StateNotifierProvider<PageSizeNotifier, int>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return PageSizeNotifier(settings);
});

class PageSizeNotifier extends StateNotifier<int> {
  PageSizeNotifier(this._settings) : super(_settings.pageSize);

  final SettingsRepository _settings;

  Future<void> setPageSize(int size) async {
    await _settings.setPageSize(size);
    state = size;
  }
}

/// Simplify PMC Reader notifier
final simplifyPmcReaderProvider =
    StateNotifierProvider<SimplifyPmcReaderNotifier, bool>((ref) {
      final settings = ref.watch(settingsRepositoryProvider);
      return SimplifyPmcReaderNotifier(settings);
    });

class SimplifyPmcReaderNotifier extends StateNotifier<bool> {
  SimplifyPmcReaderNotifier(this._settings)
    : super(_settings.simplifyPmcReader);

  final SettingsRepository _settings;

  Future<void> setSimplifyPmcReader(bool value) async {
    await _settings.setSimplifyPmcReader(value);
    state = value;
  }
}
