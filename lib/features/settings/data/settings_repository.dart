import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages user-configurable settings.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  // Keys
  static const _keyApiKey = 'ncbi_api_key';
  static const _keyDeeplApiKey = 'deepl_api_key';
  static const _keyEasyScholarKey = 'easyscholar_key';
  static const _keyThemeMode = 'theme_mode';
  static const _keyLocale = 'locale';
  static const _keyMaxCacheMB = 'max_cache_mb';
  static const _keyUseDynamicColor = 'use_dynamic_color';
  static const _keyPageSize = 'page_size';
  static const _keySimplifyPmcReader = 'simplify_pmc_reader';

  // NCBI API Key
  String? get apiKey => _prefs.getString(_keyApiKey);
  Future<void> setApiKey(String? value) async {
    if (value == null || value.isEmpty) {
      await _prefs.remove(_keyApiKey);
    } else {
      await _prefs.setString(_keyApiKey, value);
    }
  }

  // DeepL API Key
  String? get deeplApiKey => _prefs.getString(_keyDeeplApiKey);
  Future<void> setDeeplApiKey(String? value) async {
    if (value == null || value.isEmpty) {
      await _prefs.remove(_keyDeeplApiKey);
    } else {
      await _prefs.setString(_keyDeeplApiKey, value);
    }
  }

  // easyScholar Key
  String? get easyScholarKey => _prefs.getString(_keyEasyScholarKey);
  Future<void> setEasyScholarKey(String? value) async {
    if (value == null || value.isEmpty) {
      await _prefs.remove(_keyEasyScholarKey);
    } else {
      await _prefs.setString(_keyEasyScholarKey, value);
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
  int get maxCacheMB => _prefs.getInt(_keyMaxCacheMB) ?? 200;
  Future<void> setMaxCacheMB(int mb) async {
    await _prefs.setInt(_keyMaxCacheMB, mb);
  }

  // Page Size
  int get pageSize => _prefs.getInt(_keyPageSize) ?? 20;

  Future<void> setPageSize(int size) async {
    await _prefs.setInt(_keyPageSize, size);
  }
}

/// Provider for SharedPreferences — must be overridden at app start.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized before use');
});

/// Provider for SettingsRepository.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
});

/// Theme mode notifier for reactive UI updates.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
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
final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
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
final pageSizeProvider =
    StateNotifierProvider<PageSizeNotifier, int>((ref) {
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
  SimplifyPmcReaderNotifier(this._settings) : super(_settings.simplifyPmcReader);

  final SettingsRepository _settings;

  Future<void> setSimplifyPmcReader(bool value) async {
    await _settings.setSimplifyPmcReader(value);
    state = value;
  }
}
