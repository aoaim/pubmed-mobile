import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pubmed_mobile/features/search/data/repositories/article_repository.dart';
import 'package:pubmed_mobile/features/search/domain/entities/article.dart';
import 'package:pubmed_mobile/features/settings/data/settings_repository.dart';

/// Search state.
class SearchState {
  const SearchState({
    this.query = '',
    this.articles = const [],
    this.totalCount = 0,
    this.currentPage = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRevalidating = false,
    this.error,
    this.spellingSuggestion,
    this.sort = 'relevance',
  });

  final String query;
  final List<Article> articles;
  final int totalCount;
  final int currentPage;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRevalidating;
  final String? error;
  final String? spellingSuggestion;
  final String sort;

  bool get hasMore => articles.length < totalCount;

  SearchState copyWith({
    String? query,
    List<Article>? articles,
    int? totalCount,
    int? currentPage,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRevalidating,
    String? error,
    String? spellingSuggestion,
    String? sort,
    bool clearError = false,
    bool clearSuggestion = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      articles: articles ?? this.articles,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRevalidating: isRevalidating ?? this.isRevalidating,
      error: clearError ? null : (error ?? this.error),
      spellingSuggestion: clearSuggestion
          ? null
          : (spellingSuggestion ?? this.spellingSuggestion),
      sort: sort ?? this.sort,
    );
  }
}

/// Search notifier.
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._repository, this._settings) : super(const SearchState());

  final ArticleRepository _repository;
  final SettingsRepository _settings;

  /// In-memory search result cache (key: "query|sort").
  final Map<String, _CachedSearch> _cache = {};

  /// Update query text without triggering search.
  void onQueryChanged(String query) {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }
    state = state.copyWith(query: query);
  }

  /// Execute search immediately with stale-while-revalidate caching.
  Future<void> search(String query, {String? sort}) async {
    if (query.trim().isEmpty) return;

    final sortBy = sort ?? state.sort;
    final cacheKey = '$query|$sortBy';

    // 1. Check in-memory session cache
    final memoryCached = _cache[cacheKey];
    if (memoryCached != null) {
      state = state.copyWith(
        query: query,
        articles: memoryCached.articles,
        totalCount: memoryCached.totalCount,
        currentPage: 0,
        sort: sortBy,
        isLoading: false,
        isRevalidating: true,
        clearError: true,
        clearSuggestion: true,
      );
    } else {
      // 2. Fallback to 7-day SQLite cache if no memory cache
      final dbCached = await _repository.searchArticlesCached(query: query, pageSize: _settings.pageSize);
      if (dbCached != null) {
        state = state.copyWith(
          query: query,
          articles: dbCached.$1,
          totalCount: dbCached.$2,
          currentPage: 0,
          sort: sortBy,
          isLoading: false,
          isRevalidating: true,
          clearError: true,
          clearSuggestion: true,
        );
      } else {
        // 3. No cache available, show skeleton screen
        state = state.copyWith(
          query: query,
          isLoading: true,
          currentPage: 0,
          sort: sortBy,
          clearError: true,
          clearSuggestion: true,
        );
      }
    }

    // Always fetch fresh data from network in the background (Stale-While-Revalidate).
    try {
      final (articles, total) = await _repository.searchArticles(
        query: query,
        page: 0,
        pageSize: _settings.pageSize,
        sort: sortBy,
      );

      // Update in-memory session cache.
      _cache[cacheKey] = _CachedSearch(articles: articles, totalCount: total);

      // Only update state if user hasn't navigated away to a different query.
      if (state.query == query && state.sort == sortBy) {
        state = state.copyWith(
          articles: articles,
          totalCount: total,
          isLoading: false,
          isRevalidating: false,
        );
      }

      // Check spelling in background
      _checkSpelling(query);
    } catch (e) {
      // If we already showed cached data, don't overwrite with error.
      if (state.articles.isNotEmpty && state.query == query) {
        // Silently ignore – user sees stale data, but stop revalidating indicator.
        state = state.copyWith(isRevalidating: false);
        return;
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load next page.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    try {
      final (articles, total) = await _repository.searchArticles(
        query: state.query,
        page: nextPage,
        pageSize: _settings.pageSize,
        sort: state.sort,
      );

      state = state.copyWith(
        articles: [...state.articles, ...articles],
        totalCount: total,
        currentPage: nextPage,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Change sort order and re-search.
  Future<void> setSort(String sort) async {
    if (state.query.isEmpty) return;
    await search(state.query, sort: sort);
  }

  Future<void> _checkSpelling(String query) async {
    try {
      final suggestion = await _repository.spellCheck(query);
      if (suggestion != null && state.query == query) {
        state = state.copyWith(spellingSuggestion: suggestion);
      }
    } catch (_) {
      // Ignore spell check errors
    }
  }
}

/// Provider for search state.
final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(
    ref.watch(articleRepositoryProvider),
    ref.watch(settingsRepositoryProvider),
  );
});

/// Simple in-memory cache entry for search results.
class _CachedSearch {
  _CachedSearch({required this.articles, required this.totalCount});
  final List<Article> articles;
  final int totalCount;
}
