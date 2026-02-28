import 'package:go_router/go_router.dart';
import 'package:pubmed_mobile/features/search/presentation/screens/search_screen.dart';
import 'package:pubmed_mobile/features/article_detail/presentation/screens/article_detail_screen.dart';
import 'package:pubmed_mobile/features/reader/presentation/screens/reader_screen.dart';
import 'package:pubmed_mobile/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:pubmed_mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:pubmed_mobile/features/splash/presentation/screens/splash_screen.dart';
import 'package:pubmed_mobile/core/widgets/app_shell.dart';

/// App route paths.
class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const search = '/search';
  static const favorites = '/favorites';
  static const settings = '/settings';
  static const articleDetail = '/article/:pmid';
  static const reader = '/reader/:pmcid';
}

/// GoRouter configuration.
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SplashScreen(),
      ),
    ),
    // Shell route for bottom navigation
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.search,
          pageBuilder: (context, state) => NoTransitionPage(
            child: SearchScreen(key: SearchScreen.globalKey),
          ),
        ),
        GoRoute(
          path: AppRoutes.favorites,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FavoritesScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    // Full-screen routes
    GoRoute(
      path: AppRoutes.articleDetail,
      builder: (context, state) {
        final pmid = int.parse(state.pathParameters['pmid']!);
        return ArticleDetailScreen(pmid: pmid);
      },
    ),
    GoRoute(
      path: AppRoutes.reader,
      builder: (context, state) {
        final pmcid = state.pathParameters['pmcid']!;
        return ReaderScreen(pmcid: pmcid);
      },
    ),
  ],
);
