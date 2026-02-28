import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pubmed_mobile/core/l10n/app_localizations.dart';
import 'package:pubmed_mobile/core/database/app_database.dart';
import 'package:pubmed_mobile/features/search/presentation/providers/search_provider.dart';
import 'package:pubmed_mobile/features/search/presentation/widgets/article_card.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  /// Global key allowing external reset to home view.
  static final globalKey = GlobalKey<_SearchScreenState>();

  /// Reset search screen back to home view (with logo).
  static void resetToHome(BuildContext context) {
    globalKey.currentState?._exitSearchMode();
  }

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _homeFocusNode = FocusNode();
  final _searchFocusNode = FocusNode();

  /// Whether the user has initiated a search (show results view vs home view)
  bool _isInSearchMode = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _homeFocusNode.addListener(() {
      // Entering focus implies user wants to search
      if (_homeFocusNode.hasFocus && !_isInSearchMode) {
        _homeFocusNode.unfocus();
        setState(() => _isInSearchMode = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      ref.read(searchProvider.notifier).loadMore();
    }
  }

  void _exitSearchMode() {
    _searchController.clear();
    _homeFocusNode.unfocus();
    _searchFocusNode.unfocus();
    ref.read(searchProvider.notifier).onQueryChanged('');
    setState(() => _isInSearchMode = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _homeFocusNode.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    // If there are results, loading, a query, or error, stay in search mode
    if (state.articles.isNotEmpty || state.isLoading || state.query.isNotEmpty || state.error != null) {
      _isInSearchMode = true;
    }

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: _isInSearchMode
              ? _buildSearchView(context, state)
              : _buildHomeView(context),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Home view: PubMed logo + search bar + slogan
  // ---------------------------------------------------------------------------
  Widget _buildHomeView(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      key: const ValueKey('homeView'),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 3),

          // PubMed Logo
          SvgPicture.asset(
            'assets/pubmed_logo.svg',
            width: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 48),

          // Search bar (flat, no shadow)
          TextField(
            controller: _searchController,
            focusNode: _homeFocusNode,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerLow,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                setState(() => _isInSearchMode = true);
                ref.read(searchProvider.notifier).search(value);
              }
            },
          ),

          const Spacer(flex: 4),

          // Slogan
          Text(
            Localizations.localeOf(context).languageCode == 'zh'
                ? '我们站在巨人的肩膀上'
                : 'Standing on the shoulders of giants',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search results view: search bar at top + results
  // ---------------------------------------------------------------------------
  Widget _buildSearchView(BuildContext context, SearchState state) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      key: const ValueKey('searchView'),
      children: [
        // Top search bar with back button (flat, no shadow)
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
          child: Row(
            children: [
              // Back to home
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _exitSearchMode,
              ),
              // Search field
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(searchProvider.notifier)
                                  .onQueryChanged('');
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.6),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      ref.read(searchProvider.notifier).search(value);
                    }
                  },
                ),
              ),
              // Search button
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: l10n.search,
                onPressed: () {
                  final query = _searchController.text.trim();
                  if (query.isNotEmpty) {
                    _searchFocusNode.unfocus();
                    ref.read(searchProvider.notifier).search(query);
                  }
                },
              ),
            ],
          ),
        ),

        // Revalidating indicator (stale-while-revalidate)
        if (state.isRevalidating)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: theme.colorScheme.primaryContainer,
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  Localizations.localeOf(context).languageCode == 'zh'
                      ? '正在获取最新数据…'
                      : 'Fetching latest data…',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

        // Sort & result count row
        if (state.articles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  l10n.resultCount(state.totalCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                SegmentedButton<String>(
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    textStyle: WidgetStatePropertyAll(
                      theme.textTheme.labelSmall,
                    ),
                  ),
                  segments: [
                    ButtonSegment(
                      value: 'relevance',
                      label: Text(l10n.sortByRelevance),
                    ),
                    ButtonSegment(
                      value: 'date',
                      label: Text(l10n.sortByDate),
                    ),
                  ],
                  selected: {state.sort},
                  onSelectionChanged: (set) {
                    ref.read(searchProvider.notifier).setSort(set.first);
                  },
                ),
              ],
            ),
          ),

        // Spelling suggestion
        if (state.spellingSuggestion != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                _searchController.text = state.spellingSuggestion!;
                ref
                    .read(searchProvider.notifier)
                    .search(state.spellingSuggestion!);
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Icon(Icons.auto_fix_high,
                        size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text.rich(
                      TextSpan(
                        text: 'Did you mean: ',
                        children: [
                          TextSpan(
                            text: state.spellingSuggestion,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Content
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            child: _buildContent(context, state, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
      BuildContext context, SearchState state, AppLocalizations l10n) {
    if (state.isLoading) {
      return _buildShimmer(context);
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(l10n.searchError,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(state.error!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () =>
                    ref.read(searchProvider.notifier).search(state.query),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (state.query.isEmpty && !state.isLoading) {
      return _buildHistory(context, l10n);
    }

    if (state.articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(l10n.noResults,
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      key: ValueKey('list_${state.query}'),
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.articles.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.articles.length) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: state.isLoadingMore
                  ? const CircularProgressIndicator()
                  : Text(l10n.loadMore),
            ),
          );
        }

        final article = state.articles[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ArticleCard(
            article: article,
            onTap: () => context.push('/article/${article.pmid}'),
          ),
        );
      },
    );
  }

  Widget _buildHistory(BuildContext context, AppLocalizations l10n) {
    final db = ref.watch(databaseProvider);
    return FutureBuilder<List<SearchHistoryData>>(
      future: db.getRecentHistory(),
      builder: (context, snapshot) {
        final history = snapshot.data ?? [];
        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.manage_search,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text(l10n.searchHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Text(l10n.recentSearches,
                      style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      await db.clearHistory();
                      setState(() {});
                    },
                    child: Text(l10n.clearAll),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.history, size: 20),
                    title: Text(item.query),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () async {
                        await db.removeHistoryItem(item.id);
                        setState(() {});
                      },
                    ),
                    onTap: () {
                      _searchController.text = item.query;
                      ref.read(searchProvider.notifier).search(item.query);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      key: const ValueKey('shimmer'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            // Ensure Card itself is clearly visible with normal surface color
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: theme.colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Shimmer.fromColors(
                baseColor: theme.colorScheme.surfaceContainerHighest,
                highlightColor: theme.colorScheme.surfaceContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        )),
                    const SizedBox(height: 8),
                    Container(
                        height: 16,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        )),
                    const SizedBox(height: 12),
                    Container(
                        height: 12,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        )),
                    const SizedBox(height: 4),
                    Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
