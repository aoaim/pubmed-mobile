import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pubmed_mobile/core/router/app_router.dart';
import 'package:pubmed_mobile/core/l10n/app_localizations.dart';
import 'package:pubmed_mobile/features/search/presentation/screens/search_screen.dart';
import 'package:pubmed_mobile/features/updates/presentation/providers/update_check_provider.dart';
import 'package:pubmed_mobile/features/updates/presentation/widgets/update_dialog.dart';

/// Bottom navigation shell wrapping the main tabs.
///
/// Also performs the automatic update check on startup (silent on failure).
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    AppRoutes.search,
    AppRoutes.favorites,
    AppRoutes.settings,
  ];

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  /// Startup update check: fetch changelog, compare versions, and show the
  /// dialog when a newer version exists and was not ignored by the user.
  /// All failures are silent (per product decision).
  Future<void> _checkForUpdates() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final result = await ref
          .read(updateCheckServiceProvider)
          .checkForUpdate(info.version);
      if (!mounted || !result.hasUpdate) return;

      final ignored = await readIgnoredUpdateVersion();
      if (!mounted || ignored == result.latestVersion) return;

      await showUpdateAvailableDialog(context, result);
    } catch (_) {
      // Silent: no network / parse failure → no prompt.
    }
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (var i = 0; i < AppShell._tabs.length; i++) {
      if (location.startsWith(AppShell._tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final index = _currentIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (i == index && i == 0) {
            // Already on search tab — reset to home view
            SearchScreen.resetToHome(context);
          }
          context.go(AppShell._tabs[i]);
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
