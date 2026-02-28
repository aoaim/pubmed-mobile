// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedArticlesTable extends CachedArticles
    with TableInfo<$CachedArticlesTable, CachedArticle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedArticlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pmidMeta = const VerificationMeta('pmid');
  @override
  late final GeneratedColumn<int> pmid = GeneratedColumn<int>(
    'pmid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorsMeta = const VerificationMeta(
    'authors',
  );
  @override
  late final GeneratedColumn<String> authors = GeneratedColumn<String>(
    'authors',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _journalMeta = const VerificationMeta(
    'journal',
  );
  @override
  late final GeneratedColumn<String> journal = GeneratedColumn<String>(
    'journal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pubDateMeta = const VerificationMeta(
    'pubDate',
  );
  @override
  late final GeneratedColumn<String> pubDate = GeneratedColumn<String>(
    'pub_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _doiMeta = const VerificationMeta('doi');
  @override
  late final GeneratedColumn<String> doi = GeneratedColumn<String>(
    'doi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pmcidMeta = const VerificationMeta('pmcid');
  @override
  late final GeneratedColumn<String> pmcid = GeneratedColumn<String>(
    'pmcid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _abstract_Meta = const VerificationMeta(
    'abstract_',
  );
  @override
  late final GeneratedColumn<String> abstract_ = GeneratedColumn<String>(
    'abstract',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _translatedTitleMeta = const VerificationMeta(
    'translatedTitle',
  );
  @override
  late final GeneratedColumn<String> translatedTitle = GeneratedColumn<String>(
    'translated_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _translatedAbstractMeta =
      const VerificationMeta('translatedAbstract');
  @override
  late final GeneratedColumn<String> translatedAbstract =
      GeneratedColumn<String>(
        'translated_abstract',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _meshTermsMeta = const VerificationMeta(
    'meshTerms',
  );
  @override
  late final GeneratedColumn<String> meshTerms = GeneratedColumn<String>(
    'mesh_terms',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _hasFullDetailMeta = const VerificationMeta(
    'hasFullDetail',
  );
  @override
  late final GeneratedColumn<bool> hasFullDetail = GeneratedColumn<bool>(
    'has_full_detail',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_full_detail" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    pmid,
    title,
    authors,
    journal,
    pubDate,
    doi,
    pmcid,
    abstract_,
    translatedTitle,
    translatedAbstract,
    meshTerms,
    hasFullDetail,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_articles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedArticle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pmid')) {
      context.handle(
        _pmidMeta,
        pmid.isAcceptableOrUnknown(data['pmid']!, _pmidMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('authors')) {
      context.handle(
        _authorsMeta,
        authors.isAcceptableOrUnknown(data['authors']!, _authorsMeta),
      );
    }
    if (data.containsKey('journal')) {
      context.handle(
        _journalMeta,
        journal.isAcceptableOrUnknown(data['journal']!, _journalMeta),
      );
    }
    if (data.containsKey('pub_date')) {
      context.handle(
        _pubDateMeta,
        pubDate.isAcceptableOrUnknown(data['pub_date']!, _pubDateMeta),
      );
    }
    if (data.containsKey('doi')) {
      context.handle(
        _doiMeta,
        doi.isAcceptableOrUnknown(data['doi']!, _doiMeta),
      );
    }
    if (data.containsKey('pmcid')) {
      context.handle(
        _pmcidMeta,
        pmcid.isAcceptableOrUnknown(data['pmcid']!, _pmcidMeta),
      );
    }
    if (data.containsKey('abstract')) {
      context.handle(
        _abstract_Meta,
        abstract_.isAcceptableOrUnknown(data['abstract']!, _abstract_Meta),
      );
    }
    if (data.containsKey('translated_title')) {
      context.handle(
        _translatedTitleMeta,
        translatedTitle.isAcceptableOrUnknown(
          data['translated_title']!,
          _translatedTitleMeta,
        ),
      );
    }
    if (data.containsKey('translated_abstract')) {
      context.handle(
        _translatedAbstractMeta,
        translatedAbstract.isAcceptableOrUnknown(
          data['translated_abstract']!,
          _translatedAbstractMeta,
        ),
      );
    }
    if (data.containsKey('mesh_terms')) {
      context.handle(
        _meshTermsMeta,
        meshTerms.isAcceptableOrUnknown(data['mesh_terms']!, _meshTermsMeta),
      );
    }
    if (data.containsKey('has_full_detail')) {
      context.handle(
        _hasFullDetailMeta,
        hasFullDetail.isAcceptableOrUnknown(
          data['has_full_detail']!,
          _hasFullDetailMeta,
        ),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pmid};
  @override
  CachedArticle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedArticle(
      pmid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pmid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      authors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authors'],
      )!,
      journal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal'],
      )!,
      pubDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pub_date'],
      )!,
      doi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doi'],
      ),
      pmcid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pmcid'],
      ),
      abstract_: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}abstract'],
      )!,
      translatedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translated_title'],
      ),
      translatedAbstract: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translated_abstract'],
      ),
      meshTerms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mesh_terms'],
      )!,
      hasFullDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_full_detail'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedArticlesTable createAlias(String alias) {
    return $CachedArticlesTable(attachedDatabase, alias);
  }
}

class CachedArticle extends DataClass implements Insertable<CachedArticle> {
  final int pmid;
  final String title;
  final String authors;
  final String journal;
  final String pubDate;
  final String? doi;
  final String? pmcid;
  final String abstract_;
  final String? translatedTitle;
  final String? translatedAbstract;
  final String meshTerms;
  final bool hasFullDetail;
  final DateTime cachedAt;
  const CachedArticle({
    required this.pmid,
    required this.title,
    required this.authors,
    required this.journal,
    required this.pubDate,
    this.doi,
    this.pmcid,
    required this.abstract_,
    this.translatedTitle,
    this.translatedAbstract,
    required this.meshTerms,
    required this.hasFullDetail,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pmid'] = Variable<int>(pmid);
    map['title'] = Variable<String>(title);
    map['authors'] = Variable<String>(authors);
    map['journal'] = Variable<String>(journal);
    map['pub_date'] = Variable<String>(pubDate);
    if (!nullToAbsent || doi != null) {
      map['doi'] = Variable<String>(doi);
    }
    if (!nullToAbsent || pmcid != null) {
      map['pmcid'] = Variable<String>(pmcid);
    }
    map['abstract'] = Variable<String>(abstract_);
    if (!nullToAbsent || translatedTitle != null) {
      map['translated_title'] = Variable<String>(translatedTitle);
    }
    if (!nullToAbsent || translatedAbstract != null) {
      map['translated_abstract'] = Variable<String>(translatedAbstract);
    }
    map['mesh_terms'] = Variable<String>(meshTerms);
    map['has_full_detail'] = Variable<bool>(hasFullDetail);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedArticlesCompanion toCompanion(bool nullToAbsent) {
    return CachedArticlesCompanion(
      pmid: Value(pmid),
      title: Value(title),
      authors: Value(authors),
      journal: Value(journal),
      pubDate: Value(pubDate),
      doi: doi == null && nullToAbsent ? const Value.absent() : Value(doi),
      pmcid: pmcid == null && nullToAbsent
          ? const Value.absent()
          : Value(pmcid),
      abstract_: Value(abstract_),
      translatedTitle: translatedTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(translatedTitle),
      translatedAbstract: translatedAbstract == null && nullToAbsent
          ? const Value.absent()
          : Value(translatedAbstract),
      meshTerms: Value(meshTerms),
      hasFullDetail: Value(hasFullDetail),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedArticle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedArticle(
      pmid: serializer.fromJson<int>(json['pmid']),
      title: serializer.fromJson<String>(json['title']),
      authors: serializer.fromJson<String>(json['authors']),
      journal: serializer.fromJson<String>(json['journal']),
      pubDate: serializer.fromJson<String>(json['pubDate']),
      doi: serializer.fromJson<String?>(json['doi']),
      pmcid: serializer.fromJson<String?>(json['pmcid']),
      abstract_: serializer.fromJson<String>(json['abstract_']),
      translatedTitle: serializer.fromJson<String?>(json['translatedTitle']),
      translatedAbstract: serializer.fromJson<String?>(
        json['translatedAbstract'],
      ),
      meshTerms: serializer.fromJson<String>(json['meshTerms']),
      hasFullDetail: serializer.fromJson<bool>(json['hasFullDetail']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pmid': serializer.toJson<int>(pmid),
      'title': serializer.toJson<String>(title),
      'authors': serializer.toJson<String>(authors),
      'journal': serializer.toJson<String>(journal),
      'pubDate': serializer.toJson<String>(pubDate),
      'doi': serializer.toJson<String?>(doi),
      'pmcid': serializer.toJson<String?>(pmcid),
      'abstract_': serializer.toJson<String>(abstract_),
      'translatedTitle': serializer.toJson<String?>(translatedTitle),
      'translatedAbstract': serializer.toJson<String?>(translatedAbstract),
      'meshTerms': serializer.toJson<String>(meshTerms),
      'hasFullDetail': serializer.toJson<bool>(hasFullDetail),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedArticle copyWith({
    int? pmid,
    String? title,
    String? authors,
    String? journal,
    String? pubDate,
    Value<String?> doi = const Value.absent(),
    Value<String?> pmcid = const Value.absent(),
    String? abstract_,
    Value<String?> translatedTitle = const Value.absent(),
    Value<String?> translatedAbstract = const Value.absent(),
    String? meshTerms,
    bool? hasFullDetail,
    DateTime? cachedAt,
  }) => CachedArticle(
    pmid: pmid ?? this.pmid,
    title: title ?? this.title,
    authors: authors ?? this.authors,
    journal: journal ?? this.journal,
    pubDate: pubDate ?? this.pubDate,
    doi: doi.present ? doi.value : this.doi,
    pmcid: pmcid.present ? pmcid.value : this.pmcid,
    abstract_: abstract_ ?? this.abstract_,
    translatedTitle: translatedTitle.present
        ? translatedTitle.value
        : this.translatedTitle,
    translatedAbstract: translatedAbstract.present
        ? translatedAbstract.value
        : this.translatedAbstract,
    meshTerms: meshTerms ?? this.meshTerms,
    hasFullDetail: hasFullDetail ?? this.hasFullDetail,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedArticle copyWithCompanion(CachedArticlesCompanion data) {
    return CachedArticle(
      pmid: data.pmid.present ? data.pmid.value : this.pmid,
      title: data.title.present ? data.title.value : this.title,
      authors: data.authors.present ? data.authors.value : this.authors,
      journal: data.journal.present ? data.journal.value : this.journal,
      pubDate: data.pubDate.present ? data.pubDate.value : this.pubDate,
      doi: data.doi.present ? data.doi.value : this.doi,
      pmcid: data.pmcid.present ? data.pmcid.value : this.pmcid,
      abstract_: data.abstract_.present ? data.abstract_.value : this.abstract_,
      translatedTitle: data.translatedTitle.present
          ? data.translatedTitle.value
          : this.translatedTitle,
      translatedAbstract: data.translatedAbstract.present
          ? data.translatedAbstract.value
          : this.translatedAbstract,
      meshTerms: data.meshTerms.present ? data.meshTerms.value : this.meshTerms,
      hasFullDetail: data.hasFullDetail.present
          ? data.hasFullDetail.value
          : this.hasFullDetail,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedArticle(')
          ..write('pmid: $pmid, ')
          ..write('title: $title, ')
          ..write('authors: $authors, ')
          ..write('journal: $journal, ')
          ..write('pubDate: $pubDate, ')
          ..write('doi: $doi, ')
          ..write('pmcid: $pmcid, ')
          ..write('abstract_: $abstract_, ')
          ..write('translatedTitle: $translatedTitle, ')
          ..write('translatedAbstract: $translatedAbstract, ')
          ..write('meshTerms: $meshTerms, ')
          ..write('hasFullDetail: $hasFullDetail, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    pmid,
    title,
    authors,
    journal,
    pubDate,
    doi,
    pmcid,
    abstract_,
    translatedTitle,
    translatedAbstract,
    meshTerms,
    hasFullDetail,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedArticle &&
          other.pmid == this.pmid &&
          other.title == this.title &&
          other.authors == this.authors &&
          other.journal == this.journal &&
          other.pubDate == this.pubDate &&
          other.doi == this.doi &&
          other.pmcid == this.pmcid &&
          other.abstract_ == this.abstract_ &&
          other.translatedTitle == this.translatedTitle &&
          other.translatedAbstract == this.translatedAbstract &&
          other.meshTerms == this.meshTerms &&
          other.hasFullDetail == this.hasFullDetail &&
          other.cachedAt == this.cachedAt);
}

class CachedArticlesCompanion extends UpdateCompanion<CachedArticle> {
  final Value<int> pmid;
  final Value<String> title;
  final Value<String> authors;
  final Value<String> journal;
  final Value<String> pubDate;
  final Value<String?> doi;
  final Value<String?> pmcid;
  final Value<String> abstract_;
  final Value<String?> translatedTitle;
  final Value<String?> translatedAbstract;
  final Value<String> meshTerms;
  final Value<bool> hasFullDetail;
  final Value<DateTime> cachedAt;
  const CachedArticlesCompanion({
    this.pmid = const Value.absent(),
    this.title = const Value.absent(),
    this.authors = const Value.absent(),
    this.journal = const Value.absent(),
    this.pubDate = const Value.absent(),
    this.doi = const Value.absent(),
    this.pmcid = const Value.absent(),
    this.abstract_ = const Value.absent(),
    this.translatedTitle = const Value.absent(),
    this.translatedAbstract = const Value.absent(),
    this.meshTerms = const Value.absent(),
    this.hasFullDetail = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedArticlesCompanion.insert({
    this.pmid = const Value.absent(),
    required String title,
    this.authors = const Value.absent(),
    this.journal = const Value.absent(),
    this.pubDate = const Value.absent(),
    this.doi = const Value.absent(),
    this.pmcid = const Value.absent(),
    this.abstract_ = const Value.absent(),
    this.translatedTitle = const Value.absent(),
    this.translatedAbstract = const Value.absent(),
    this.meshTerms = const Value.absent(),
    this.hasFullDetail = const Value.absent(),
    required DateTime cachedAt,
  }) : title = Value(title),
       cachedAt = Value(cachedAt);
  static Insertable<CachedArticle> custom({
    Expression<int>? pmid,
    Expression<String>? title,
    Expression<String>? authors,
    Expression<String>? journal,
    Expression<String>? pubDate,
    Expression<String>? doi,
    Expression<String>? pmcid,
    Expression<String>? abstract_,
    Expression<String>? translatedTitle,
    Expression<String>? translatedAbstract,
    Expression<String>? meshTerms,
    Expression<bool>? hasFullDetail,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (pmid != null) 'pmid': pmid,
      if (title != null) 'title': title,
      if (authors != null) 'authors': authors,
      if (journal != null) 'journal': journal,
      if (pubDate != null) 'pub_date': pubDate,
      if (doi != null) 'doi': doi,
      if (pmcid != null) 'pmcid': pmcid,
      if (abstract_ != null) 'abstract': abstract_,
      if (translatedTitle != null) 'translated_title': translatedTitle,
      if (translatedAbstract != null) 'translated_abstract': translatedAbstract,
      if (meshTerms != null) 'mesh_terms': meshTerms,
      if (hasFullDetail != null) 'has_full_detail': hasFullDetail,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedArticlesCompanion copyWith({
    Value<int>? pmid,
    Value<String>? title,
    Value<String>? authors,
    Value<String>? journal,
    Value<String>? pubDate,
    Value<String?>? doi,
    Value<String?>? pmcid,
    Value<String>? abstract_,
    Value<String?>? translatedTitle,
    Value<String?>? translatedAbstract,
    Value<String>? meshTerms,
    Value<bool>? hasFullDetail,
    Value<DateTime>? cachedAt,
  }) {
    return CachedArticlesCompanion(
      pmid: pmid ?? this.pmid,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      journal: journal ?? this.journal,
      pubDate: pubDate ?? this.pubDate,
      doi: doi ?? this.doi,
      pmcid: pmcid ?? this.pmcid,
      abstract_: abstract_ ?? this.abstract_,
      translatedTitle: translatedTitle ?? this.translatedTitle,
      translatedAbstract: translatedAbstract ?? this.translatedAbstract,
      meshTerms: meshTerms ?? this.meshTerms,
      hasFullDetail: hasFullDetail ?? this.hasFullDetail,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pmid.present) {
      map['pmid'] = Variable<int>(pmid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (authors.present) {
      map['authors'] = Variable<String>(authors.value);
    }
    if (journal.present) {
      map['journal'] = Variable<String>(journal.value);
    }
    if (pubDate.present) {
      map['pub_date'] = Variable<String>(pubDate.value);
    }
    if (doi.present) {
      map['doi'] = Variable<String>(doi.value);
    }
    if (pmcid.present) {
      map['pmcid'] = Variable<String>(pmcid.value);
    }
    if (abstract_.present) {
      map['abstract'] = Variable<String>(abstract_.value);
    }
    if (translatedTitle.present) {
      map['translated_title'] = Variable<String>(translatedTitle.value);
    }
    if (translatedAbstract.present) {
      map['translated_abstract'] = Variable<String>(translatedAbstract.value);
    }
    if (meshTerms.present) {
      map['mesh_terms'] = Variable<String>(meshTerms.value);
    }
    if (hasFullDetail.present) {
      map['has_full_detail'] = Variable<bool>(hasFullDetail.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedArticlesCompanion(')
          ..write('pmid: $pmid, ')
          ..write('title: $title, ')
          ..write('authors: $authors, ')
          ..write('journal: $journal, ')
          ..write('pubDate: $pubDate, ')
          ..write('doi: $doi, ')
          ..write('pmcid: $pmcid, ')
          ..write('abstract_: $abstract_, ')
          ..write('translatedTitle: $translatedTitle, ')
          ..write('translatedAbstract: $translatedAbstract, ')
          ..write('meshTerms: $meshTerms, ')
          ..write('hasFullDetail: $hasFullDetail, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, Favorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pmidMeta = const VerificationMeta('pmid');
  @override
  late final GeneratedColumn<int> pmid = GeneratedColumn<int>(
    'pmid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorsMeta = const VerificationMeta(
    'authors',
  );
  @override
  late final GeneratedColumn<String> authors = GeneratedColumn<String>(
    'authors',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _journalMeta = const VerificationMeta(
    'journal',
  );
  @override
  late final GeneratedColumn<String> journal = GeneratedColumn<String>(
    'journal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pubDateMeta = const VerificationMeta(
    'pubDate',
  );
  @override
  late final GeneratedColumn<String> pubDate = GeneratedColumn<String>(
    'pub_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _doiMeta = const VerificationMeta('doi');
  @override
  late final GeneratedColumn<String> doi = GeneratedColumn<String>(
    'doi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pmcidMeta = const VerificationMeta('pmcid');
  @override
  late final GeneratedColumn<String> pmcid = GeneratedColumn<String>(
    'pmcid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    pmid,
    title,
    authors,
    journal,
    pubDate,
    doi,
    pmcid,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<Favorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pmid')) {
      context.handle(
        _pmidMeta,
        pmid.isAcceptableOrUnknown(data['pmid']!, _pmidMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('authors')) {
      context.handle(
        _authorsMeta,
        authors.isAcceptableOrUnknown(data['authors']!, _authorsMeta),
      );
    }
    if (data.containsKey('journal')) {
      context.handle(
        _journalMeta,
        journal.isAcceptableOrUnknown(data['journal']!, _journalMeta),
      );
    }
    if (data.containsKey('pub_date')) {
      context.handle(
        _pubDateMeta,
        pubDate.isAcceptableOrUnknown(data['pub_date']!, _pubDateMeta),
      );
    }
    if (data.containsKey('doi')) {
      context.handle(
        _doiMeta,
        doi.isAcceptableOrUnknown(data['doi']!, _doiMeta),
      );
    }
    if (data.containsKey('pmcid')) {
      context.handle(
        _pmcidMeta,
        pmcid.isAcceptableOrUnknown(data['pmcid']!, _pmcidMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pmid};
  @override
  Favorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Favorite(
      pmid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pmid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      authors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authors'],
      )!,
      journal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal'],
      )!,
      pubDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pub_date'],
      )!,
      doi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doi'],
      ),
      pmcid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pmcid'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class Favorite extends DataClass implements Insertable<Favorite> {
  final int pmid;
  final String title;
  final String authors;
  final String journal;
  final String pubDate;
  final String? doi;
  final String? pmcid;
  final DateTime addedAt;
  const Favorite({
    required this.pmid,
    required this.title,
    required this.authors,
    required this.journal,
    required this.pubDate,
    this.doi,
    this.pmcid,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pmid'] = Variable<int>(pmid);
    map['title'] = Variable<String>(title);
    map['authors'] = Variable<String>(authors);
    map['journal'] = Variable<String>(journal);
    map['pub_date'] = Variable<String>(pubDate);
    if (!nullToAbsent || doi != null) {
      map['doi'] = Variable<String>(doi);
    }
    if (!nullToAbsent || pmcid != null) {
      map['pmcid'] = Variable<String>(pmcid);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      pmid: Value(pmid),
      title: Value(title),
      authors: Value(authors),
      journal: Value(journal),
      pubDate: Value(pubDate),
      doi: doi == null && nullToAbsent ? const Value.absent() : Value(doi),
      pmcid: pmcid == null && nullToAbsent
          ? const Value.absent()
          : Value(pmcid),
      addedAt: Value(addedAt),
    );
  }

  factory Favorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorite(
      pmid: serializer.fromJson<int>(json['pmid']),
      title: serializer.fromJson<String>(json['title']),
      authors: serializer.fromJson<String>(json['authors']),
      journal: serializer.fromJson<String>(json['journal']),
      pubDate: serializer.fromJson<String>(json['pubDate']),
      doi: serializer.fromJson<String?>(json['doi']),
      pmcid: serializer.fromJson<String?>(json['pmcid']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pmid': serializer.toJson<int>(pmid),
      'title': serializer.toJson<String>(title),
      'authors': serializer.toJson<String>(authors),
      'journal': serializer.toJson<String>(journal),
      'pubDate': serializer.toJson<String>(pubDate),
      'doi': serializer.toJson<String?>(doi),
      'pmcid': serializer.toJson<String?>(pmcid),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  Favorite copyWith({
    int? pmid,
    String? title,
    String? authors,
    String? journal,
    String? pubDate,
    Value<String?> doi = const Value.absent(),
    Value<String?> pmcid = const Value.absent(),
    DateTime? addedAt,
  }) => Favorite(
    pmid: pmid ?? this.pmid,
    title: title ?? this.title,
    authors: authors ?? this.authors,
    journal: journal ?? this.journal,
    pubDate: pubDate ?? this.pubDate,
    doi: doi.present ? doi.value : this.doi,
    pmcid: pmcid.present ? pmcid.value : this.pmcid,
    addedAt: addedAt ?? this.addedAt,
  );
  Favorite copyWithCompanion(FavoritesCompanion data) {
    return Favorite(
      pmid: data.pmid.present ? data.pmid.value : this.pmid,
      title: data.title.present ? data.title.value : this.title,
      authors: data.authors.present ? data.authors.value : this.authors,
      journal: data.journal.present ? data.journal.value : this.journal,
      pubDate: data.pubDate.present ? data.pubDate.value : this.pubDate,
      doi: data.doi.present ? data.doi.value : this.doi,
      pmcid: data.pmcid.present ? data.pmcid.value : this.pmcid,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorite(')
          ..write('pmid: $pmid, ')
          ..write('title: $title, ')
          ..write('authors: $authors, ')
          ..write('journal: $journal, ')
          ..write('pubDate: $pubDate, ')
          ..write('doi: $doi, ')
          ..write('pmcid: $pmcid, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(pmid, title, authors, journal, pubDate, doi, pmcid, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Favorite &&
          other.pmid == this.pmid &&
          other.title == this.title &&
          other.authors == this.authors &&
          other.journal == this.journal &&
          other.pubDate == this.pubDate &&
          other.doi == this.doi &&
          other.pmcid == this.pmcid &&
          other.addedAt == this.addedAt);
}

class FavoritesCompanion extends UpdateCompanion<Favorite> {
  final Value<int> pmid;
  final Value<String> title;
  final Value<String> authors;
  final Value<String> journal;
  final Value<String> pubDate;
  final Value<String?> doi;
  final Value<String?> pmcid;
  final Value<DateTime> addedAt;
  const FavoritesCompanion({
    this.pmid = const Value.absent(),
    this.title = const Value.absent(),
    this.authors = const Value.absent(),
    this.journal = const Value.absent(),
    this.pubDate = const Value.absent(),
    this.doi = const Value.absent(),
    this.pmcid = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  FavoritesCompanion.insert({
    this.pmid = const Value.absent(),
    required String title,
    this.authors = const Value.absent(),
    this.journal = const Value.absent(),
    this.pubDate = const Value.absent(),
    this.doi = const Value.absent(),
    this.pmcid = const Value.absent(),
    required DateTime addedAt,
  }) : title = Value(title),
       addedAt = Value(addedAt);
  static Insertable<Favorite> custom({
    Expression<int>? pmid,
    Expression<String>? title,
    Expression<String>? authors,
    Expression<String>? journal,
    Expression<String>? pubDate,
    Expression<String>? doi,
    Expression<String>? pmcid,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (pmid != null) 'pmid': pmid,
      if (title != null) 'title': title,
      if (authors != null) 'authors': authors,
      if (journal != null) 'journal': journal,
      if (pubDate != null) 'pub_date': pubDate,
      if (doi != null) 'doi': doi,
      if (pmcid != null) 'pmcid': pmcid,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  FavoritesCompanion copyWith({
    Value<int>? pmid,
    Value<String>? title,
    Value<String>? authors,
    Value<String>? journal,
    Value<String>? pubDate,
    Value<String?>? doi,
    Value<String?>? pmcid,
    Value<DateTime>? addedAt,
  }) {
    return FavoritesCompanion(
      pmid: pmid ?? this.pmid,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      journal: journal ?? this.journal,
      pubDate: pubDate ?? this.pubDate,
      doi: doi ?? this.doi,
      pmcid: pmcid ?? this.pmcid,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pmid.present) {
      map['pmid'] = Variable<int>(pmid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (authors.present) {
      map['authors'] = Variable<String>(authors.value);
    }
    if (journal.present) {
      map['journal'] = Variable<String>(journal.value);
    }
    if (pubDate.present) {
      map['pub_date'] = Variable<String>(pubDate.value);
    }
    if (doi.present) {
      map['doi'] = Variable<String>(doi.value);
    }
    if (pmcid.present) {
      map['pmcid'] = Variable<String>(pmcid.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('pmid: $pmid, ')
          ..write('title: $title, ')
          ..write('authors: $authors, ')
          ..write('journal: $journal, ')
          ..write('pubDate: $pubDate, ')
          ..write('doi: $doi, ')
          ..write('pmcid: $pmcid, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoryTable extends SearchHistory
    with TableInfo<$SearchHistoryTable, SearchHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultCountMeta = const VerificationMeta(
    'resultCount',
  );
  @override
  late final GeneratedColumn<int> resultCount = GeneratedColumn<int>(
    'result_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta(
    'searchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pmidsMeta = const VerificationMeta('pmids');
  @override
  late final GeneratedColumn<String> pmids = GeneratedColumn<String>(
    'pmids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    query,
    resultCount,
    searchedAt,
    pmids,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('result_count')) {
      context.handle(
        _resultCountMeta,
        resultCount.isAcceptableOrUnknown(
          data['result_count']!,
          _resultCountMeta,
        ),
      );
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    if (data.containsKey('pmids')) {
      context.handle(
        _pmidsMeta,
        pmids.isAcceptableOrUnknown(data['pmids']!, _pmidsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      resultCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}result_count'],
      )!,
      searchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}searched_at'],
      )!,
      pmids: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pmids'],
      ),
    );
  }

  @override
  $SearchHistoryTable createAlias(String alias) {
    return $SearchHistoryTable(attachedDatabase, alias);
  }
}

class SearchHistoryData extends DataClass
    implements Insertable<SearchHistoryData> {
  final int id;
  final String query;
  final int resultCount;
  final DateTime searchedAt;
  final String? pmids;
  const SearchHistoryData({
    required this.id,
    required this.query,
    required this.resultCount,
    required this.searchedAt,
    this.pmids,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query'] = Variable<String>(query);
    map['result_count'] = Variable<int>(resultCount);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    if (!nullToAbsent || pmids != null) {
      map['pmids'] = Variable<String>(pmids);
    }
    return map;
  }

  SearchHistoryCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryCompanion(
      id: Value(id),
      query: Value(query),
      resultCount: Value(resultCount),
      searchedAt: Value(searchedAt),
      pmids: pmids == null && nullToAbsent
          ? const Value.absent()
          : Value(pmids),
    );
  }

  factory SearchHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistoryData(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      resultCount: serializer.fromJson<int>(json['resultCount']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
      pmids: serializer.fromJson<String?>(json['pmids']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String>(query),
      'resultCount': serializer.toJson<int>(resultCount),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
      'pmids': serializer.toJson<String?>(pmids),
    };
  }

  SearchHistoryData copyWith({
    int? id,
    String? query,
    int? resultCount,
    DateTime? searchedAt,
    Value<String?> pmids = const Value.absent(),
  }) => SearchHistoryData(
    id: id ?? this.id,
    query: query ?? this.query,
    resultCount: resultCount ?? this.resultCount,
    searchedAt: searchedAt ?? this.searchedAt,
    pmids: pmids.present ? pmids.value : this.pmids,
  );
  SearchHistoryData copyWithCompanion(SearchHistoryCompanion data) {
    return SearchHistoryData(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      resultCount: data.resultCount.present
          ? data.resultCount.value
          : this.resultCount,
      searchedAt: data.searchedAt.present
          ? data.searchedAt.value
          : this.searchedAt,
      pmids: data.pmids.present ? data.pmids.value : this.pmids,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryData(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('resultCount: $resultCount, ')
          ..write('searchedAt: $searchedAt, ')
          ..write('pmids: $pmids')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query, resultCount, searchedAt, pmids);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistoryData &&
          other.id == this.id &&
          other.query == this.query &&
          other.resultCount == this.resultCount &&
          other.searchedAt == this.searchedAt &&
          other.pmids == this.pmids);
}

class SearchHistoryCompanion extends UpdateCompanion<SearchHistoryData> {
  final Value<int> id;
  final Value<String> query;
  final Value<int> resultCount;
  final Value<DateTime> searchedAt;
  final Value<String?> pmids;
  const SearchHistoryCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.resultCount = const Value.absent(),
    this.searchedAt = const Value.absent(),
    this.pmids = const Value.absent(),
  });
  SearchHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String query,
    this.resultCount = const Value.absent(),
    required DateTime searchedAt,
    this.pmids = const Value.absent(),
  }) : query = Value(query),
       searchedAt = Value(searchedAt);
  static Insertable<SearchHistoryData> custom({
    Expression<int>? id,
    Expression<String>? query,
    Expression<int>? resultCount,
    Expression<DateTime>? searchedAt,
    Expression<String>? pmids,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (resultCount != null) 'result_count': resultCount,
      if (searchedAt != null) 'searched_at': searchedAt,
      if (pmids != null) 'pmids': pmids,
    });
  }

  SearchHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? query,
    Value<int>? resultCount,
    Value<DateTime>? searchedAt,
    Value<String?>? pmids,
  }) {
    return SearchHistoryCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      resultCount: resultCount ?? this.resultCount,
      searchedAt: searchedAt ?? this.searchedAt,
      pmids: pmids ?? this.pmids,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (resultCount.present) {
      map['result_count'] = Variable<int>(resultCount.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    if (pmids.present) {
      map['pmids'] = Variable<String>(pmids.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('resultCount: $resultCount, ')
          ..write('searchedAt: $searchedAt, ')
          ..write('pmids: $pmids')
          ..write(')'))
        .toString();
  }
}

class $PmcFullTextCacheTable extends PmcFullTextCache
    with TableInfo<$PmcFullTextCacheTable, PmcFullTextCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PmcFullTextCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pmcidMeta = const VerificationMeta('pmcid');
  @override
  late final GeneratedColumn<String> pmcid = GeneratedColumn<String>(
    'pmcid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _htmlMeta = const VerificationMeta('html');
  @override
  late final GeneratedColumn<String> html = GeneratedColumn<String>(
    'html',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pmcid, html, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pmc_full_text_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<PmcFullTextCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pmcid')) {
      context.handle(
        _pmcidMeta,
        pmcid.isAcceptableOrUnknown(data['pmcid']!, _pmcidMeta),
      );
    } else if (isInserting) {
      context.missing(_pmcidMeta);
    }
    if (data.containsKey('html')) {
      context.handle(
        _htmlMeta,
        html.isAcceptableOrUnknown(data['html']!, _htmlMeta),
      );
    } else if (isInserting) {
      context.missing(_htmlMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pmcid};
  @override
  PmcFullTextCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PmcFullTextCacheData(
      pmcid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pmcid'],
      )!,
      html: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}html'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $PmcFullTextCacheTable createAlias(String alias) {
    return $PmcFullTextCacheTable(attachedDatabase, alias);
  }
}

class PmcFullTextCacheData extends DataClass
    implements Insertable<PmcFullTextCacheData> {
  final String pmcid;
  final String html;
  final DateTime cachedAt;
  const PmcFullTextCacheData({
    required this.pmcid,
    required this.html,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pmcid'] = Variable<String>(pmcid);
    map['html'] = Variable<String>(html);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  PmcFullTextCacheCompanion toCompanion(bool nullToAbsent) {
    return PmcFullTextCacheCompanion(
      pmcid: Value(pmcid),
      html: Value(html),
      cachedAt: Value(cachedAt),
    );
  }

  factory PmcFullTextCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PmcFullTextCacheData(
      pmcid: serializer.fromJson<String>(json['pmcid']),
      html: serializer.fromJson<String>(json['html']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pmcid': serializer.toJson<String>(pmcid),
      'html': serializer.toJson<String>(html),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  PmcFullTextCacheData copyWith({
    String? pmcid,
    String? html,
    DateTime? cachedAt,
  }) => PmcFullTextCacheData(
    pmcid: pmcid ?? this.pmcid,
    html: html ?? this.html,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  PmcFullTextCacheData copyWithCompanion(PmcFullTextCacheCompanion data) {
    return PmcFullTextCacheData(
      pmcid: data.pmcid.present ? data.pmcid.value : this.pmcid,
      html: data.html.present ? data.html.value : this.html,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PmcFullTextCacheData(')
          ..write('pmcid: $pmcid, ')
          ..write('html: $html, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pmcid, html, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PmcFullTextCacheData &&
          other.pmcid == this.pmcid &&
          other.html == this.html &&
          other.cachedAt == this.cachedAt);
}

class PmcFullTextCacheCompanion extends UpdateCompanion<PmcFullTextCacheData> {
  final Value<String> pmcid;
  final Value<String> html;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const PmcFullTextCacheCompanion({
    this.pmcid = const Value.absent(),
    this.html = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PmcFullTextCacheCompanion.insert({
    required String pmcid,
    required String html,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : pmcid = Value(pmcid),
       html = Value(html),
       cachedAt = Value(cachedAt);
  static Insertable<PmcFullTextCacheData> custom({
    Expression<String>? pmcid,
    Expression<String>? html,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pmcid != null) 'pmcid': pmcid,
      if (html != null) 'html': html,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PmcFullTextCacheCompanion copyWith({
    Value<String>? pmcid,
    Value<String>? html,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return PmcFullTextCacheCompanion(
      pmcid: pmcid ?? this.pmcid,
      html: html ?? this.html,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pmcid.present) {
      map['pmcid'] = Variable<String>(pmcid.value);
    }
    if (html.present) {
      map['html'] = Variable<String>(html.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PmcFullTextCacheCompanion(')
          ..write('pmcid: $pmcid, ')
          ..write('html: $html, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedArticlesTable cachedArticles = $CachedArticlesTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $SearchHistoryTable searchHistory = $SearchHistoryTable(this);
  late final $PmcFullTextCacheTable pmcFullTextCache = $PmcFullTextCacheTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedArticles,
    favorites,
    searchHistory,
    pmcFullTextCache,
  ];
}

typedef $$CachedArticlesTableCreateCompanionBuilder =
    CachedArticlesCompanion Function({
      Value<int> pmid,
      required String title,
      Value<String> authors,
      Value<String> journal,
      Value<String> pubDate,
      Value<String?> doi,
      Value<String?> pmcid,
      Value<String> abstract_,
      Value<String?> translatedTitle,
      Value<String?> translatedAbstract,
      Value<String> meshTerms,
      Value<bool> hasFullDetail,
      required DateTime cachedAt,
    });
typedef $$CachedArticlesTableUpdateCompanionBuilder =
    CachedArticlesCompanion Function({
      Value<int> pmid,
      Value<String> title,
      Value<String> authors,
      Value<String> journal,
      Value<String> pubDate,
      Value<String?> doi,
      Value<String?> pmcid,
      Value<String> abstract_,
      Value<String?> translatedTitle,
      Value<String?> translatedAbstract,
      Value<String> meshTerms,
      Value<bool> hasFullDetail,
      Value<DateTime> cachedAt,
    });

class $$CachedArticlesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedArticlesTable> {
  $$CachedArticlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pmid => $composableBuilder(
    column: $table.pmid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journal => $composableBuilder(
    column: $table.journal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pubDate => $composableBuilder(
    column: $table.pubDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doi => $composableBuilder(
    column: $table.doi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pmcid => $composableBuilder(
    column: $table.pmcid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get abstract_ => $composableBuilder(
    column: $table.abstract_,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translatedTitle => $composableBuilder(
    column: $table.translatedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translatedAbstract => $composableBuilder(
    column: $table.translatedAbstract,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meshTerms => $composableBuilder(
    column: $table.meshTerms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasFullDetail => $composableBuilder(
    column: $table.hasFullDetail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedArticlesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedArticlesTable> {
  $$CachedArticlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pmid => $composableBuilder(
    column: $table.pmid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journal => $composableBuilder(
    column: $table.journal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pubDate => $composableBuilder(
    column: $table.pubDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doi => $composableBuilder(
    column: $table.doi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pmcid => $composableBuilder(
    column: $table.pmcid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abstract_ => $composableBuilder(
    column: $table.abstract_,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translatedTitle => $composableBuilder(
    column: $table.translatedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translatedAbstract => $composableBuilder(
    column: $table.translatedAbstract,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meshTerms => $composableBuilder(
    column: $table.meshTerms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasFullDetail => $composableBuilder(
    column: $table.hasFullDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedArticlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedArticlesTable> {
  $$CachedArticlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pmid =>
      $composableBuilder(column: $table.pmid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get authors =>
      $composableBuilder(column: $table.authors, builder: (column) => column);

  GeneratedColumn<String> get journal =>
      $composableBuilder(column: $table.journal, builder: (column) => column);

  GeneratedColumn<String> get pubDate =>
      $composableBuilder(column: $table.pubDate, builder: (column) => column);

  GeneratedColumn<String> get doi =>
      $composableBuilder(column: $table.doi, builder: (column) => column);

  GeneratedColumn<String> get pmcid =>
      $composableBuilder(column: $table.pmcid, builder: (column) => column);

  GeneratedColumn<String> get abstract_ =>
      $composableBuilder(column: $table.abstract_, builder: (column) => column);

  GeneratedColumn<String> get translatedTitle => $composableBuilder(
    column: $table.translatedTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translatedAbstract => $composableBuilder(
    column: $table.translatedAbstract,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meshTerms =>
      $composableBuilder(column: $table.meshTerms, builder: (column) => column);

  GeneratedColumn<bool> get hasFullDetail => $composableBuilder(
    column: $table.hasFullDetail,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedArticlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedArticlesTable,
          CachedArticle,
          $$CachedArticlesTableFilterComposer,
          $$CachedArticlesTableOrderingComposer,
          $$CachedArticlesTableAnnotationComposer,
          $$CachedArticlesTableCreateCompanionBuilder,
          $$CachedArticlesTableUpdateCompanionBuilder,
          (
            CachedArticle,
            BaseReferences<_$AppDatabase, $CachedArticlesTable, CachedArticle>,
          ),
          CachedArticle,
          PrefetchHooks Function()
        > {
  $$CachedArticlesTableTableManager(
    _$AppDatabase db,
    $CachedArticlesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedArticlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> pmid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> authors = const Value.absent(),
                Value<String> journal = const Value.absent(),
                Value<String> pubDate = const Value.absent(),
                Value<String?> doi = const Value.absent(),
                Value<String?> pmcid = const Value.absent(),
                Value<String> abstract_ = const Value.absent(),
                Value<String?> translatedTitle = const Value.absent(),
                Value<String?> translatedAbstract = const Value.absent(),
                Value<String> meshTerms = const Value.absent(),
                Value<bool> hasFullDetail = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
              }) => CachedArticlesCompanion(
                pmid: pmid,
                title: title,
                authors: authors,
                journal: journal,
                pubDate: pubDate,
                doi: doi,
                pmcid: pmcid,
                abstract_: abstract_,
                translatedTitle: translatedTitle,
                translatedAbstract: translatedAbstract,
                meshTerms: meshTerms,
                hasFullDetail: hasFullDetail,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> pmid = const Value.absent(),
                required String title,
                Value<String> authors = const Value.absent(),
                Value<String> journal = const Value.absent(),
                Value<String> pubDate = const Value.absent(),
                Value<String?> doi = const Value.absent(),
                Value<String?> pmcid = const Value.absent(),
                Value<String> abstract_ = const Value.absent(),
                Value<String?> translatedTitle = const Value.absent(),
                Value<String?> translatedAbstract = const Value.absent(),
                Value<String> meshTerms = const Value.absent(),
                Value<bool> hasFullDetail = const Value.absent(),
                required DateTime cachedAt,
              }) => CachedArticlesCompanion.insert(
                pmid: pmid,
                title: title,
                authors: authors,
                journal: journal,
                pubDate: pubDate,
                doi: doi,
                pmcid: pmcid,
                abstract_: abstract_,
                translatedTitle: translatedTitle,
                translatedAbstract: translatedAbstract,
                meshTerms: meshTerms,
                hasFullDetail: hasFullDetail,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedArticlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedArticlesTable,
      CachedArticle,
      $$CachedArticlesTableFilterComposer,
      $$CachedArticlesTableOrderingComposer,
      $$CachedArticlesTableAnnotationComposer,
      $$CachedArticlesTableCreateCompanionBuilder,
      $$CachedArticlesTableUpdateCompanionBuilder,
      (
        CachedArticle,
        BaseReferences<_$AppDatabase, $CachedArticlesTable, CachedArticle>,
      ),
      CachedArticle,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableCreateCompanionBuilder =
    FavoritesCompanion Function({
      Value<int> pmid,
      required String title,
      Value<String> authors,
      Value<String> journal,
      Value<String> pubDate,
      Value<String?> doi,
      Value<String?> pmcid,
      required DateTime addedAt,
    });
typedef $$FavoritesTableUpdateCompanionBuilder =
    FavoritesCompanion Function({
      Value<int> pmid,
      Value<String> title,
      Value<String> authors,
      Value<String> journal,
      Value<String> pubDate,
      Value<String?> doi,
      Value<String?> pmcid,
      Value<DateTime> addedAt,
    });

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pmid => $composableBuilder(
    column: $table.pmid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journal => $composableBuilder(
    column: $table.journal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pubDate => $composableBuilder(
    column: $table.pubDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doi => $composableBuilder(
    column: $table.doi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pmcid => $composableBuilder(
    column: $table.pmcid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pmid => $composableBuilder(
    column: $table.pmid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journal => $composableBuilder(
    column: $table.journal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pubDate => $composableBuilder(
    column: $table.pubDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doi => $composableBuilder(
    column: $table.doi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pmcid => $composableBuilder(
    column: $table.pmcid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pmid =>
      $composableBuilder(column: $table.pmid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get authors =>
      $composableBuilder(column: $table.authors, builder: (column) => column);

  GeneratedColumn<String> get journal =>
      $composableBuilder(column: $table.journal, builder: (column) => column);

  GeneratedColumn<String> get pubDate =>
      $composableBuilder(column: $table.pubDate, builder: (column) => column);

  GeneratedColumn<String> get doi =>
      $composableBuilder(column: $table.doi, builder: (column) => column);

  GeneratedColumn<String> get pmcid =>
      $composableBuilder(column: $table.pmcid, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          Favorite,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
          Favorite,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> pmid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> authors = const Value.absent(),
                Value<String> journal = const Value.absent(),
                Value<String> pubDate = const Value.absent(),
                Value<String?> doi = const Value.absent(),
                Value<String?> pmcid = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => FavoritesCompanion(
                pmid: pmid,
                title: title,
                authors: authors,
                journal: journal,
                pubDate: pubDate,
                doi: doi,
                pmcid: pmcid,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> pmid = const Value.absent(),
                required String title,
                Value<String> authors = const Value.absent(),
                Value<String> journal = const Value.absent(),
                Value<String> pubDate = const Value.absent(),
                Value<String?> doi = const Value.absent(),
                Value<String?> pmcid = const Value.absent(),
                required DateTime addedAt,
              }) => FavoritesCompanion.insert(
                pmid: pmid,
                title: title,
                authors: authors,
                journal: journal,
                pubDate: pubDate,
                doi: doi,
                pmcid: pmcid,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      Favorite,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
      Favorite,
      PrefetchHooks Function()
    >;
typedef $$SearchHistoryTableCreateCompanionBuilder =
    SearchHistoryCompanion Function({
      Value<int> id,
      required String query,
      Value<int> resultCount,
      required DateTime searchedAt,
      Value<String?> pmids,
    });
typedef $$SearchHistoryTableUpdateCompanionBuilder =
    SearchHistoryCompanion Function({
      Value<int> id,
      Value<String> query,
      Value<int> resultCount,
      Value<DateTime> searchedAt,
      Value<String?> pmids,
    });

class $$SearchHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resultCount => $composableBuilder(
    column: $table.resultCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pmids => $composableBuilder(
    column: $table.pmids,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resultCount => $composableBuilder(
    column: $table.resultCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pmids => $composableBuilder(
    column: $table.pmids,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<int> get resultCount => $composableBuilder(
    column: $table.resultCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pmids =>
      $composableBuilder(column: $table.pmids, builder: (column) => column);
}

class $$SearchHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchHistoryTable,
          SearchHistoryData,
          $$SearchHistoryTableFilterComposer,
          $$SearchHistoryTableOrderingComposer,
          $$SearchHistoryTableAnnotationComposer,
          $$SearchHistoryTableCreateCompanionBuilder,
          $$SearchHistoryTableUpdateCompanionBuilder,
          (
            SearchHistoryData,
            BaseReferences<
              _$AppDatabase,
              $SearchHistoryTable,
              SearchHistoryData
            >,
          ),
          SearchHistoryData,
          PrefetchHooks Function()
        > {
  $$SearchHistoryTableTableManager(_$AppDatabase db, $SearchHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<int> resultCount = const Value.absent(),
                Value<DateTime> searchedAt = const Value.absent(),
                Value<String?> pmids = const Value.absent(),
              }) => SearchHistoryCompanion(
                id: id,
                query: query,
                resultCount: resultCount,
                searchedAt: searchedAt,
                pmids: pmids,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String query,
                Value<int> resultCount = const Value.absent(),
                required DateTime searchedAt,
                Value<String?> pmids = const Value.absent(),
              }) => SearchHistoryCompanion.insert(
                id: id,
                query: query,
                resultCount: resultCount,
                searchedAt: searchedAt,
                pmids: pmids,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchHistoryTable,
      SearchHistoryData,
      $$SearchHistoryTableFilterComposer,
      $$SearchHistoryTableOrderingComposer,
      $$SearchHistoryTableAnnotationComposer,
      $$SearchHistoryTableCreateCompanionBuilder,
      $$SearchHistoryTableUpdateCompanionBuilder,
      (
        SearchHistoryData,
        BaseReferences<_$AppDatabase, $SearchHistoryTable, SearchHistoryData>,
      ),
      SearchHistoryData,
      PrefetchHooks Function()
    >;
typedef $$PmcFullTextCacheTableCreateCompanionBuilder =
    PmcFullTextCacheCompanion Function({
      required String pmcid,
      required String html,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$PmcFullTextCacheTableUpdateCompanionBuilder =
    PmcFullTextCacheCompanion Function({
      Value<String> pmcid,
      Value<String> html,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$PmcFullTextCacheTableFilterComposer
    extends Composer<_$AppDatabase, $PmcFullTextCacheTable> {
  $$PmcFullTextCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pmcid => $composableBuilder(
    column: $table.pmcid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get html => $composableBuilder(
    column: $table.html,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PmcFullTextCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $PmcFullTextCacheTable> {
  $$PmcFullTextCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pmcid => $composableBuilder(
    column: $table.pmcid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get html => $composableBuilder(
    column: $table.html,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PmcFullTextCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $PmcFullTextCacheTable> {
  $$PmcFullTextCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pmcid =>
      $composableBuilder(column: $table.pmcid, builder: (column) => column);

  GeneratedColumn<String> get html =>
      $composableBuilder(column: $table.html, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$PmcFullTextCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PmcFullTextCacheTable,
          PmcFullTextCacheData,
          $$PmcFullTextCacheTableFilterComposer,
          $$PmcFullTextCacheTableOrderingComposer,
          $$PmcFullTextCacheTableAnnotationComposer,
          $$PmcFullTextCacheTableCreateCompanionBuilder,
          $$PmcFullTextCacheTableUpdateCompanionBuilder,
          (
            PmcFullTextCacheData,
            BaseReferences<
              _$AppDatabase,
              $PmcFullTextCacheTable,
              PmcFullTextCacheData
            >,
          ),
          PmcFullTextCacheData,
          PrefetchHooks Function()
        > {
  $$PmcFullTextCacheTableTableManager(
    _$AppDatabase db,
    $PmcFullTextCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PmcFullTextCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PmcFullTextCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PmcFullTextCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pmcid = const Value.absent(),
                Value<String> html = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PmcFullTextCacheCompanion(
                pmcid: pmcid,
                html: html,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pmcid,
                required String html,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => PmcFullTextCacheCompanion.insert(
                pmcid: pmcid,
                html: html,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PmcFullTextCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PmcFullTextCacheTable,
      PmcFullTextCacheData,
      $$PmcFullTextCacheTableFilterComposer,
      $$PmcFullTextCacheTableOrderingComposer,
      $$PmcFullTextCacheTableAnnotationComposer,
      $$PmcFullTextCacheTableCreateCompanionBuilder,
      $$PmcFullTextCacheTableUpdateCompanionBuilder,
      (
        PmcFullTextCacheData,
        BaseReferences<
          _$AppDatabase,
          $PmcFullTextCacheTable,
          PmcFullTextCacheData
        >,
      ),
      PmcFullTextCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedArticlesTableTableManager get cachedArticles =>
      $$CachedArticlesTableTableManager(_db, _db.cachedArticles);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$SearchHistoryTableTableManager get searchHistory =>
      $$SearchHistoryTableTableManager(_db, _db.searchHistory);
  $$PmcFullTextCacheTableTableManager get pmcFullTextCache =>
      $$PmcFullTextCacheTableTableManager(_db, _db.pmcFullTextCache);
}
