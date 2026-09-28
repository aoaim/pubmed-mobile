import 'package:aptabase_flutter/aptabase_flutter.dart';

/// Central registry of analytics event names.
abstract final class AnalyticsEvents {
  static const appStarted = 'app_started';
  static const searchPerformed = 'search_performed';
  static const articleOpened = 'article_opened';
  static const favoriteAdded = 'favorite_added';
  static const favoriteRemoved = 'favorite_removed';
  static const translationRequested = 'translation_requested';
  static const translationCompleted = 'translation_completed';
  static const translationFailed = 'translation_failed';
  static const readerOpened = 'reader_opened';
  static const externalLinkOpened = 'external_link_opened';
  static const articleShared = 'article_shared';
  static const themeChanged = 'theme_changed';
  static const localeChanged = 'locale_changed';
  static const pageSizeChanged = 'page_size_changed';
  static const simplifyReaderChanged = 'simplify_reader_changed';
  static const cacheCleared = 'cache_cleared';
}

/// Thin wrapper around Aptabase.
///
/// Only active after [Analytics.init] is called from `main()`, so widget
/// tests (which never run `main()`) are unaffected.
abstract final class Analytics {
  static bool _enabled = false;

  /// Initializes the Aptabase SDK and enables tracking.
  static Future<void> init(String appKey) async {
    await Aptabase.init(appKey);
    _enabled = true;
  }

  /// Tracks an event. Only strings and numbers are allowed as property
  /// values. Fire-and-forget — no need to await.
  static void track(String event, [Map<String, Object>? params]) {
    if (!_enabled) return;
    Aptabase.instance.trackEvent(event, params);
  }
}
