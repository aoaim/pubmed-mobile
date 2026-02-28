import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:pubmed_mobile/core/constants/app_constants.dart';
import 'package:pubmed_mobile/core/database/app_database.dart';
import 'package:pubmed_mobile/features/search/data/datasources/pubmed_api_datasource.dart';
import 'package:pubmed_mobile/features/search/domain/entities/article.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pubmed_mobile/core/network/dio_client.dart';

/// Repository bridging API data source and local cache.
class ArticleRepository {
  ArticleRepository({
    required this.api,
    required this.db,
  });

  final PubmedApiDataSource api;
  final AppDatabase db;

  /// Try to fetch articles from SQLite cache (valid for 7 days).
  /// Returns null if cache miss.
  Future<(List<Article>, int totalCount)?> searchArticlesCached({
    required String query,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    final history = await db.getHistory(query);
    if (history != null && history.pmids != null) {
      final age = DateTime.now().difference(history.searchedAt);
      if (age.inDays <= AppConstants.searchCacheDays) {
        try {
          final pmids = (jsonDecode(history.pmids!) as List<dynamic>)
              .map((e) => e as int)
              .toList();
              
          // Fetch cached articles for these PMIDs
          final cachedArticles = <Article>[];
          for (final pmid in pmids.take(pageSize)) {
            final cached = await db.getCachedArticle(pmid);
            if (cached != null) {
              cachedArticles.add(_cachedToArticle(cached));
            }
          }
          
          if (cachedArticles.isNotEmpty) {
            return (cachedArticles, history.resultCount);
          }
        } catch (_) {
          // Ignore
        }
      }
    }
    return null;
  }

  /// Search articles; always hits API, saves results to cache.
  Future<(List<Article>, int totalCount)> searchArticles({
    required String query,
    int page = 0,
    int pageSize = AppConstants.defaultPageSize,
    String sort = 'relevance',
  }) async {

    final searchResult = await api.search(
      query: query,
      retStart: page * pageSize,
      retMax: pageSize,
      sort: sort,
    );

    if (searchResult.pmids.isEmpty) {
      return (const <Article>[], searchResult.totalCount);
    }

    final articles = await api.fetchSummaries(searchResult.pmids);

    // Cache results
    for (final article in articles) {
      await _cacheArticle(article);
    }

    // Save search to history with PMIDs (only for first page to define the "cache")
    if (page == 0) {
      await db.addHistory(query, searchResult.totalCount, pmids: jsonEncode(searchResult.pmids));
    } else {
      await db.addHistory(query, searchResult.totalCount);
    }

    return (articles, searchResult.totalCount);
  }

  /// Get full article detail; tries cache first.
  /// If [forceRefresh] is true, always fetch from API.
  Future<Article> getArticleDetail(int pmid, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      // Check cache
      final cached = await db.getCachedArticle(pmid);
      if (cached != null && cached.hasFullDetail) {
        final age = DateTime.now().difference(cached.cachedAt);
        if (age.inDays < AppConstants.detailCacheDays) {
          return _cachedToArticle(cached);
        }
      }
    }

    // Fetch from API
    final article = await api.fetchDetail(pmid);
    await _cacheArticle(article);
    return article;
  }

  /// Spell check.
  Future<String?> spellCheck(String query) => api.spellCheck(query);

  /// Get cached article if available.
  Future<Article?> getCachedArticle(int pmid) async {
    final cached = await db.getCachedArticle(pmid);
    return cached != null ? _cachedToArticle(cached) : null;
  }

  Future<void> _cacheArticle(Article article) async {
    final existing = await db.getCachedArticle(article.pmid);
    String? existingTranslatedTitle;
    String? existingTranslatedAbstract;
    
    if (existing != null) {
      existingTranslatedTitle = existing.translatedTitle;
      existingTranslatedAbstract = existing.translatedAbstract;
    }

    await db.upsertCachedArticle(CachedArticlesCompanion(
      pmid: Value(article.pmid),
      title: Value(article.title),
      authors: Value(jsonEncode(article.authors)),
      journal: Value(article.journal),
      pubDate: Value(article.pubDate),
      doi: Value(article.doi),
      pmcid: Value(article.pmcid),
      abstract_: Value(article.abstract_),
      translatedTitle: Value(article.translatedTitle ?? existingTranslatedTitle),
      translatedAbstract: Value(article.translatedAbstract ?? existingTranslatedAbstract),
      meshTerms: Value(jsonEncode(article.meshTerms)),
      hasFullDetail: Value(article.hasFullDetail),
      cachedAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateArticleTranslation(int pmid, String translatedTitle, String translatedAbstract) async {
    await (db.update(db.cachedArticles)..where((t) => t.pmid.equals(pmid))).write(
      CachedArticlesCompanion(
        translatedTitle: Value(translatedTitle),
        translatedAbstract: Value(translatedAbstract),
      ),
    );
  }

  Article _cachedToArticle(CachedArticle cached) {
    return Article(
      pmid: cached.pmid,
      title: cached.title,
      authors: (jsonDecode(cached.authors) as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      journal: cached.journal,
      pubDate: cached.pubDate,
      doi: cached.doi,
      pmcid: cached.pmcid,
      abstract_: cached.abstract_,
      translatedTitle: cached.translatedTitle,
      translatedAbstract: cached.translatedAbstract,
      meshTerms: (jsonDecode(cached.meshTerms) as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      hasFullDetail: cached.hasFullDetail,
    );
  }
}

/// Provider for PubmedApiDataSource.
final pubmedApiDataSourceProvider = Provider<PubmedApiDataSource>((ref) {
  return PubmedApiDataSource(ref.watch(dioProvider));
});

/// Provider for ArticleRepository.
final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository(
    api: ref.watch(pubmedApiDataSourceProvider),
    db: ref.watch(databaseProvider),
  );
});
