import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pubmed_mobile/core/database/app_database.dart';
import 'package:pubmed_mobile/features/search/data/datasources/pubmed_api_datasource.dart';
import 'package:pubmed_mobile/features/search/data/repositories/article_repository.dart';
import 'package:pubmed_mobile/features/search/domain/entities/article.dart';
import 'package:pubmed_mobile/features/search/domain/entities/search_result.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('favorites survive reopening the same app database', () async {
    final directory = await Directory.systemTemp.createTemp('pubmed-upgrade-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/pubmed_mobile.sqlite');
    final first = AppDatabase.withExecutor(NativeDatabase(file));
    await first.addFavorite(
      FavoritesCompanion.insert(
        pmid: const Value(123),
        title: 'Kept article',
        addedAt: DateTime(2026, 1, 1),
      ),
    );
    await first.close();

    final reopened = AppDatabase.withExecutor(NativeDatabase(file));
    addTearDown(reopened.close);
    expect(await reopened.isFavorite(123), isTrue);
    expect((await reopened.getAllFavorites()).single.title, 'Kept article');
  });

  test(
    'legacy PMC history stays separate from ordinary search history',
    () async {
      final db = AppDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(db.close);

      await db.addHistory('cancer', 10, pmids: '[1]', sort: 'relevance');
      await db.addHistory(
        'cancer',
        4,
        pmids: '[2]',
        pmcOnly: true,
        sort: 'relevance',
      );
      await db.addHistory('cancer', 6, pmids: '[3]', sort: 'date');

      expect((await db.getHistory('cancer'))?.pmids, '[1]');
      expect((await db.getHistory('cancer', pmcOnly: true))?.pmids, '[2]');
      expect((await db.getHistory('cancer', sort: 'date'))?.pmids, '[3]');
    },
  );

  test('version 4 databases gain metadata and search filter columns', () async {
    final sqlite = sqlite3.openInMemory();
    sqlite.execute(
      'CREATE TABLE cached_articles (pmid INTEGER PRIMARY KEY, title TEXT)',
    );
    sqlite.execute(
      'CREATE TABLE search_history (id INTEGER PRIMARY KEY, query TEXT)',
    );
    sqlite.execute('PRAGMA user_version = 4');
    final db = AppDatabase.withExecutor(NativeDatabase.opened(sqlite));
    addTearDown(db.close);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 5);
    final articleColumns = await db
        .customSelect('PRAGMA table_info(cached_articles)')
        .get();
    final searchColumns = await db
        .customSelect('PRAGMA table_info(search_history)')
        .get();
    expect(
      articleColumns.map((row) => row.read<String>('name')),
      contains('affiliations'),
    );
    expect(
      searchColumns.map((row) => row.read<String>('name')),
      containsAll(['pmc_only', 'sort']),
    );
  });

  test('loading another page preserves first-page offline cache', () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = ArticleRepository(api: _PagedSource(), db: db);

    await repository.searchArticles(query: 'cancer', pageSize: 1);
    await repository.searchArticles(query: 'cancer', page: 1, pageSize: 1);

    final cached = await repository.searchArticlesCached(
      query: 'cancer',
      pageSize: 1,
    );
    expect(cached?.$1.single.pmid, 1);
  });

  test('batched search cache keeps result order and saved detail', () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    await db.upsertCachedArticle(
      CachedArticlesCompanion.insert(
        pmid: const Value(2),
        title: 'Old title',
        abstract_: const Value('Saved abstract'),
        translatedTitle: const Value('Saved translation'),
        hasFullDetail: const Value(true),
        cachedAt: DateTime(2026, 1, 1),
      ),
    );
    final repository = ArticleRepository(api: _OrderedSource(), db: db);

    await repository.searchArticles(query: 'ordered', pageSize: 2);
    final cached = await repository.searchArticlesCached(
      query: 'ordered',
      pageSize: 2,
    );

    expect(cached?.$1.map((article) => article.pmid), [2, 1]);
    expect(cached?.$1.first.translatedTitle, 'Saved translation');
    expect(cached?.$1.first.abstract_, 'Saved abstract');
    expect(cached?.$1.first.hasFullDetail, isTrue);
  });

  test('PMC cache trimming removes enough entries to fit the limit', () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final html = 'x' * 600000;
    await db.upsertPmcHtml('PMC1', html);
    await db.upsertPmcHtml('PMC2', html);
    await db.upsertPmcHtml('PMC3', html);

    await db.trimPmcCacheToSizeMb(1);

    expect(await db.getPmcCacheCount(), 1);
    expect(await db.getPmcCacheSizeMb(), lessThanOrEqualTo(1));
  });
}

class _PagedSource extends PubmedApiDataSource {
  _PagedSource() : super(Dio());

  @override
  Future<SearchResult> search({
    required String query,
    int retStart = 0,
    int retMax = 20,
    String sort = 'relevance',
  }) async => SearchResult(totalCount: 2, pmids: [retStart + 1]);

  @override
  Future<List<Article>> fetchSummaries(List<int> pmids) async =>
      pmids.map((pmid) => Article(pmid: pmid, title: 'Article $pmid')).toList();
}

class _OrderedSource extends PubmedApiDataSource {
  _OrderedSource() : super(Dio());

  @override
  Future<SearchResult> search({
    required String query,
    int retStart = 0,
    int retMax = 20,
    String sort = 'relevance',
  }) async => SearchResult(totalCount: 2, pmids: [2, 1]);

  @override
  Future<List<Article>> fetchSummaries(List<int> pmids) async =>
      pmids.map((pmid) => Article(pmid: pmid, title: 'Article $pmid')).toList();
}
