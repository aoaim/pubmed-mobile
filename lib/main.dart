import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:pubmed_mobile/core/theme/app_theme.dart';
import 'package:pubmed_mobile/core/router/app_router.dart';
import 'package:pubmed_mobile/core/l10n/app_localizations.dart';
import 'package:pubmed_mobile/features/settings/data/settings_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
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
          theme: AppTheme.light(dynamicScheme: useDynamicColor ? lightDynamic : null),
          darkTheme: AppTheme.dark(dynamicScheme: useDynamicColor ? darkDynamic : null),
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
