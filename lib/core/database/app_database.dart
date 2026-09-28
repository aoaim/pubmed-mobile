import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:pubmed_mobile/core/constants/app_constants.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Table definitions
// ---------------------------------------------------------------------------

/// Cached article summaries from search results.
class CachedArticles extends Table {
  IntColumn get pmid => integer()();
  TextColumn get title => text()();
  TextColumn get authors =>
      text().withDefault(const Constant(''))(); // JSON list
  TextColumn get affiliations =>
      text().withDefault(const Constant('[]'))(); // JSON list
  TextColumn get journal => text().withDefault(const Constant(''))();
  TextColumn get pubDate => text().withDefault(const Constant(''))();
  TextColumn get doi => text().nullable()();
  TextColumn get pmcid => text().nullable()();
  TextColumn get abstract_ =>
      text().named('abstract').withDefault(const Constant(''))();
  TextColumn get translatedTitle => text().nullable()();
  TextColumn get translatedAbstract => text().nullable()();
  TextColumn get meshTerms =>
      text().withDefault(const Constant('[]'))(); // JSON list
  BoolColumn get hasFullDetail =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {pmid};
}

/// Favorite articles.
class Favorites extends Table {
  IntColumn get pmid => integer()();
  TextColumn get title => text()();
  TextColumn get authors => text().withDefault(const Constant(''))();
  TextColumn get journal => text().withDefault(const Constant(''))();
  TextColumn get pubDate => text().withDefault(const Constant(''))();
  TextColumn get doi => text().nullable()();
  TextColumn get pmcid => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {pmid};
}

/// Search history.
class SearchHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text()();
  IntColumn get resultCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get searchedAt => dateTime()();
  TextColumn get pmids =>
      text().nullable()(); // JSON list of PMIDs for offline list
  // Kept for old search history rows; the filter is no longer exposed.
  BoolColumn get pmcOnly => boolean().withDefault(const Constant(false))();
  TextColumn get sort => text().withDefault(const Constant('relevance'))();
}

/// PMC full-text HTML cache.
/// No automatic expiry; old entries are evicted when the configured size limit
/// is exceeded.
class PmcFullTextCache extends Table {
  TextColumn get pmcid => text()();
  TextColumn get html => text()(); // raw page outerHTML
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {pmcid};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [CachedArticles, Favorites, SearchHistory, PmcFullTextCache],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from <= 1) {
          await m.addColumn(cachedArticles, cachedArticles.translatedTitle);
          await m.addColumn(cachedArticles, cachedArticles.translatedAbstract);
        }
        if (from < 3) {
          await m.addColumn(searchHistory, searchHistory.pmids);
        }
        if (from < 4) {
          await m.createTable(pmcFullTextCache);
        }
        if (from < 5) {
          await m.addColumn(cachedArticles, cachedArticles.affiliations);
          await m.addColumn(searchHistory, searchHistory.pmcOnly);
          await m.addColumn(searchHistory, searchHistory.sort);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ---- Cached Articles ----

  Future<CachedArticle?> getCachedArticle(int pmid) => (select(
    cachedArticles,
  )..where((t) => t.pmid.equals(pmid))).getSingleOrNull();

  /// Loads one search page in a single database query.
  Future<Map<int, CachedArticle>> getCachedArticles(Iterable<int> pmids) async {
    final ids = pmids.toList();
    if (ids.isEmpty) return {};
    final rows = await (select(
      cachedArticles,
    )..where((t) => t.pmid.isIn(ids))).get();
    return {for (final row in rows) row.pmid: row};
  }

  Future<void> upsertCachedArticle(CachedArticlesCompanion entry) =>
      into(cachedArticles).insertOnConflictUpdate(entry);

  Future<int> clearExpiredCache(Duration maxAge) {
    final cutoff = DateTime.now().subtract(maxAge);
    return (delete(
      cachedArticles,
    )..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
  }

  Future<int> clearAllCache() => delete(cachedArticles).go();

  // ---- PMC Full-Text Cache ----

  Future<PmcFullTextCacheData?> getPmcHtml(String pmcid) => (select(
    pmcFullTextCache,
  )..where((t) => t.pmcid.equals(pmcid))).getSingleOrNull();

  Future<void> upsertPmcHtml(String pmcid, String html) =>
      into(pmcFullTextCache).insertOnConflictUpdate(
        PmcFullTextCacheCompanion.insert(
          pmcid: pmcid,
          html: html,
          cachedAt: DateTime.now(),
        ),
      );

  Future<int> deletePmcHtml(String pmcid) =>
      (delete(pmcFullTextCache)..where((t) => t.pmcid.equals(pmcid))).go();

  Future<int> clearAllPmcCache() => delete(pmcFullTextCache).go();

  Future<int> getPmcCacheCount() async {
    final countExp = pmcFullTextCache.pmcid.count();
    final query = selectOnly(pmcFullTextCache)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  /// Returns the approximate size of PMC full-text HTML cache in Megabytes.
  Future<double> getPmcCacheSizeMb() async =>
      await _getPmcCacheBytes() / (1024 * 1024);

  Future<int> _getPmcCacheBytes() async {
    final row = await customSelect(
      'SELECT COALESCE(SUM(LENGTH(CAST(html AS BLOB))), 0) AS total '
      'FROM pmc_full_text_cache',
    ).getSingle();
    return row.read<int>('total');
  }

  Future<void> trimPmcCacheToSizeMb(int maxSizeMb) async {
    if (maxSizeMb <= 0) return;
    final maxBytes = maxSizeMb * 1024 * 1024;
    await transaction(() async {
      var totalBytes = await _getPmcCacheBytes();
      if (totalBytes <= maxBytes) return;
      // Only on overflow, read entry sizes without loading HTML into Dart.
      final rows = await customSelect(
        'SELECT pmcid, LENGTH(CAST(html AS BLOB)) AS size_bytes '
        'FROM pmc_full_text_cache ORDER BY cached_at ASC',
      ).get();
      for (final row in rows) {
        if (totalBytes <= maxBytes) break;
        await deletePmcHtml(row.read<String>('pmcid'));
        totalBytes -= row.read<int>('size_bytes');
      }
    });
  }

  /// Returns the total SQLite database file size in Megabytes.
  Future<double> getDatabaseFileSizeMb() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'pubmed_mobile.sqlite'));
    if (!file.existsSync()) return 0.0;
    return file.lengthSync() / (1024 * 1024);
  }

  // ---- Favorites ----

  Stream<List<Favorite>> watchFavorites() => (select(
    favorites,
  )..orderBy([(t) => OrderingTerm.desc(t.addedAt)])).watch();

  Future<List<Favorite>> getAllFavorites() =>
      (select(favorites)..orderBy([(t) => OrderingTerm.desc(t.addedAt)])).get();

  Future<bool> isFavorite(int pmid) async {
    final row = await (select(
      favorites,
    )..where((t) => t.pmid.equals(pmid))).getSingleOrNull();
    return row != null;
  }

  Future<void> addFavorite(FavoritesCompanion entry) =>
      into(favorites).insertOnConflictUpdate(entry);

  Future<int> removeFavorite(int pmid) =>
      (delete(favorites)..where((t) => t.pmid.equals(pmid))).go();

  Future<int> clearAllFavorites() => delete(favorites).go();

  // ---- Search History ----

  Future<List<SearchHistoryData>> getRecentHistory({
    int limit = AppConstants.maxHistoryItems,
  }) =>
      (select(searchHistory)
            ..orderBy([(t) => OrderingTerm.desc(t.searchedAt)])
            ..limit(limit))
          .get();

  Future<SearchHistoryData?> getHistory(
    String query, {
    bool pmcOnly = false,
    String sort = 'relevance',
  }) =>
      (select(searchHistory)
            ..where(
              (t) =>
                  t.query.equals(query) &
                  t.pmcOnly.equals(pmcOnly) &
                  t.sort.equals(sort),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.searchedAt)]))
          .getSingleOrNull();

  Future<void> addHistory(
    String query,
    int resultCount, {
    String? pmids,
    bool pmcOnly = false,
    String sort = 'relevance',
  }) async {
    // Remove duplicate first
    await (delete(searchHistory)..where(
          (t) =>
              t.query.equals(query) &
              t.pmcOnly.equals(pmcOnly) &
              t.sort.equals(sort),
        ))
        .go();
    await into(searchHistory).insert(
      SearchHistoryCompanion.insert(
        query: query,
        resultCount: Value(resultCount),
        searchedAt: DateTime.now(),
        pmids: Value(pmids),
        pmcOnly: Value(pmcOnly),
        sort: Value(sort),
      ),
    );
    // Keep only latest N entries
    final all = await getRecentHistory(limit: 999);
    if (all.length > AppConstants.maxHistoryItems) {
      final toDelete = all.sublist(AppConstants.maxHistoryItems);
      for (final item in toDelete) {
        await (delete(searchHistory)..where((t) => t.id.equals(item.id))).go();
      }
    }
  }

  Future<int> removeHistoryItem(int id) =>
      (delete(searchHistory)..where((t) => t.id.equals(id))).go();

  Future<int> clearHistory() => delete(searchHistory).go();

  Future<int> clearExpiredSearchHistory(Duration maxAge) {
    final cutoff = DateTime.now().subtract(maxAge);
    return (delete(
      searchHistory,
    )..where((t) => t.searchedAt.isSmallerThanValue(cutoff))).go();
  }

  // ---- Cache size ----

  Future<int> getCacheCount() async {
    final countExp = cachedArticles.pmid.count();
    final query = selectOnly(cachedArticles)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final cacheDir = await getTemporaryDirectory();
    sqlite3.tempDirectory = cacheDir.path;

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'pubmed_mobile.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Global database provider.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  // Force 7-day age limit for search caches on startup
  db.clearExpiredCache(const Duration(days: AppConstants.searchCacheDays));
  db.clearExpiredSearchHistory(
    const Duration(days: AppConstants.searchCacheDays),
  );

  ref.onDispose(() => db.close());
  return db;
});
