import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pubmed_mobile/core/router/app_router.dart';
import 'package:pubmed_mobile/core/l10n/app_localizations.dart';
import 'package:pubmed_mobile/features/search/presentation/screens/search_screen.dart';

/// Bottom navigation shell wrapping the main tabs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    AppRoutes.search,
    AppRoutes.favorites,
    AppRoutes.settings,
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (i == index && i == 0) {
            // Already on search tab — reset to home view
            SearchScreen.resetToHome(context);
          }
          context.go(_tabs[i]);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.search),
            selectedIcon: const Icon(Icons.search_rounded),
            label: l10n.search,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_border),
            selectedIcon: const Icon(Icons.bookmark),
            label: l10n.favorites,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
