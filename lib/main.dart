import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:pubmed_mobile/core/theme/app_theme.dart';
import 'package:pubmed_mobile/core/router/app_router.dart';
import 'package:pubmed_mobile/core/l10n/app_localizations.dart';
import 'package:pubmed_mobile/core/analytics/analytics.dart';
import 'package:pubmed_mobile/features/settings/data/settings_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Aptabase analytics; successful search queries are sent as documented in README.
  await Analytics.init('A-EU-0620997581');
  Analytics.track(AnalyticsEvents.appStarted);

  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();
  final settings = await SettingsRepository.create(prefs, secureStorage);

  runApp(
    ProviderScope(
      overrides: [settingsRepositoryProvider.overrideWithValue(settings)],
      child: const PubMedMobileApp(),
    ),
  );
}

class PubMedMobileApp extends ConsumerWidget {
  const PubMedMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final useDynamicColor = ref.watch(useDynamicColorProvider);
    final locale = ref.watch(localeProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp.router(
          title: 'PubMed Mobile',
          debugShowCheckedModeBanner: false,
          // Theme — use dynamic color if available
          theme: AppTheme.light(
            dynamicScheme: useDynamicColor ? lightDynamic : null,
          ),
          darkTheme: AppTheme.dark(
            dynamicScheme: useDynamicColor ? darkDynamic : null,
          ),
          themeMode: themeMode,
          // Routing
          routerConfig: appRouter,
          // Localization
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
