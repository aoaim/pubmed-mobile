import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pubmed_mobile/core/l10n/app_localizations.dart';
import 'package:pubmed_mobile/core/database/app_database.dart';

/// Provider for reactive favorites list.
final favoritesStreamProvider = StreamProvider<List<Favorite>>((ref) {
  return ref.watch(databaseProvider).watchFavorites();
});

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final favAsync = ref.watch(favoritesStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favorites),
        actions: [
          favAsync.maybeWhen(
            data: (favorites) {
              if (favorites.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.copy_all),
                tooltip: l10n.export,
                onPressed: () async {
                  final buffer = StringBuffer();
                  for (final fav in favorites) {
                    final doi = fav.doi != null ? 'DOI: ${fav.doi}' : '';
                    buffer.writeln('${fav.title} | PMID: ${fav.pmid} | $doi');
                  }
                  await Clipboard.setData(ClipboardData(text: buffer.toString()));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.exportSuccess)),
                    );
                  }
                },
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: favAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border,
                      size: 64,
                      color: theme.colorScheme.primary
                          .withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(l10n.noFavorites,
                      style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final fav = favorites[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Dismissible(
                  key: ValueKey(fav.pmid),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.delete,
                        color: theme.colorScheme.onErrorContainer),
                  ),
                  onDismissed: (_) async {
                    await ref
                        .read(databaseProvider)
                        .removeFavorite(fav.pmid);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(l10n.favoriteRemoved)),
                      );
                    }
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      title: Text(
                        fav.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${fav.journal} · ${fav.pubDate}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: fav.pmcid != null
                          ? Icon(Icons.article,
                              color: theme.colorScheme.tertiary,
                              size: 20)
                          : null,
                      onTap: () =>
                          context.push('/article/${fav.pmid}'),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
