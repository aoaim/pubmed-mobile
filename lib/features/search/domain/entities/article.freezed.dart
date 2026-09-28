// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Article {
  int get pmid;
  String get title;
  List<String> get authors;
  List<String> get affiliations;
  String get journal;
  String get pubDate;
  String? get doi;
  String? get pmcid;
  String get abstract_;
  String? get translatedTitle;
  String? get translatedAbstract;
  List<String> get meshTerms;
  bool get hasFullDetail;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ArticleCopyWith<Article> get copyWith =>
      _$ArticleCopyWithImpl<Article>(this as Article, _$identity);

  @override
  bool operator ==(Object other) {
    final _this = this as Article;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Article &&
            (identical(other.pmid, _this.pmid) || other.pmid == _this.pmid) &&
            (identical(other.title, _this.title) ||
                other.title == _this.title) &&
            const DeepCollectionEquality().equals(
              other.authors,
              _this.authors,
            ) &&
            const DeepCollectionEquality().equals(
              other.affiliations,
              _this.affiliations,
            ) &&
            (identical(other.journal, _this.journal) ||
                other.journal == _this.journal) &&
            (identical(other.pubDate, _this.pubDate) ||
                other.pubDate == _this.pubDate) &&
            (identical(other.doi, _this.doi) || other.doi == _this.doi) &&
            (identical(other.pmcid, _this.pmcid) ||
                other.pmcid == _this.pmcid) &&
            (identical(other.abstract_, _this.abstract_) ||
                other.abstract_ == _this.abstract_) &&
            (identical(other.translatedTitle, _this.translatedTitle) ||
                other.translatedTitle == _this.translatedTitle) &&
            (identical(other.translatedAbstract, _this.translatedAbstract) ||
                other.translatedAbstract == _this.translatedAbstract) &&
            const DeepCollectionEquality().equals(
              other.meshTerms,
              _this.meshTerms,
            ) &&
            (identical(other.hasFullDetail, _this.hasFullDetail) ||
                other.hasFullDetail == _this.hasFullDetail));
  }

  @override
  int get hashCode {
    final _this = this as Article;
    return Object.hash(
      runtimeType,
      _this.pmid,
      _this.title,
      const DeepCollectionEquality().hash(_this.authors),
      const DeepCollectionEquality().hash(_this.affiliations),
      _this.journal,
      _this.pubDate,
      _this.doi,
      _this.pmcid,
      _this.abstract_,
      _this.translatedTitle,
      _this.translatedAbstract,
      const DeepCollectionEquality().hash(_this.meshTerms),
      _this.hasFullDetail,
    );
  }

  @override
  String toString() {
    final _this = this as Article;
    return 'Article(pmid: ${_this.pmid}, title: ${_this.title}, authors: ${_this.authors}, affiliations: ${_this.affiliations}, journal: ${_this.journal}, pubDate: ${_this.pubDate}, doi: ${_this.doi}, pmcid: ${_this.pmcid}, abstract_: ${_this.abstract_}, translatedTitle: ${_this.translatedTitle}, translatedAbstract: ${_this.translatedAbstract}, meshTerms: ${_this.meshTerms}, hasFullDetail: ${_this.hasFullDetail})';
  }
}

/// @nodoc
abstract mixin class $ArticleCopyWith<$Res> {
  factory $ArticleCopyWith(Article value, $Res Function(Article) _then) =
      _$ArticleCopyWithImpl;
  @useResult
  $Res call({
    int pmid,
    String title,
    List<String> authors,
    List<String> affiliations,
    String journal,
    String pubDate,
    String? doi,
    String? pmcid,
    String abstract_,
    String? translatedTitle,
    String? translatedAbstract,
    List<String> meshTerms,
    bool hasFullDetail,
  });
}

/// @nodoc
class _$ArticleCopyWithImpl<$Res> implements $ArticleCopyWith<$Res> {
  _$ArticleCopyWithImpl(this._self, this._then);

  final Article _self;
  final $Res Function(Article) _then;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pmid = null,
    Object? title = null,
    Object? authors = null,
    Object? affiliations = null,
    Object? journal = null,
    Object? pubDate = null,
    Object? doi = freezed,
    Object? pmcid = freezed,
    Object? abstract_ = null,
    Object? translatedTitle = freezed,
    Object? translatedAbstract = freezed,
    Object? meshTerms = null,
    Object? hasFullDetail = null,
  }) {
    return _then(
      Article(
        pmid: null == pmid
            ? _self.pmid
            : pmid // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        authors: null == authors
            ? _self.authors
            : authors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        affiliations: null == affiliations
            ? _self.affiliations
            : affiliations // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        journal: null == journal
            ? _self.journal
            : journal // ignore: cast_nullable_to_non_nullable
                  as String,
        pubDate: null == pubDate
            ? _self.pubDate
            : pubDate // ignore: cast_nullable_to_non_nullable
                  as String,
        doi: freezed == doi
            ? _self.doi
            : doi // ignore: cast_nullable_to_non_nullable
                  as String?,
        pmcid: freezed == pmcid
            ? _self.pmcid
            : pmcid // ignore: cast_nullable_to_non_nullable
                  as String?,
        abstract_: null == abstract_
            ? _self.abstract_
            : abstract_ // ignore: cast_nullable_to_non_nullable
                  as String,
        translatedTitle: freezed == translatedTitle
            ? _self.translatedTitle
            : translatedTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        translatedAbstract: freezed == translatedAbstract
            ? _self.translatedAbstract
            : translatedAbstract // ignore: cast_nullable_to_non_nullable
                  as String?,
        meshTerms: null == meshTerms
            ? _self.meshTerms
            : meshTerms // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        hasFullDetail: null == hasFullDetail
            ? _self.hasFullDetail
            : hasFullDetail // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [Article].
extension ArticlePatterns on Article {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Article value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Article() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Article value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Article():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Article value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Article() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int pmid,
      String title,
      List<String> authors,
      List<String> affiliations,
      String journal,
      String pubDate,
      String? doi,
      String? pmcid,
      String abstract_,
      String? translatedTitle,
      String? translatedAbstract,
      List<String> meshTerms,
      bool hasFullDetail,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Article() when $default != null:
        return $default(
          _that.pmid,
          _that.title,
          _that.authors,
          _that.affiliations,
          _that.journal,
          _that.pubDate,
          _that.doi,
          _that.pmcid,
          _that.abstract_,
          _that.translatedTitle,
          _that.translatedAbstract,
          _that.meshTerms,
          _that.hasFullDetail,
        );
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int pmid,
      String title,
      List<String> authors,
      List<String> affiliations,
      String journal,
      String pubDate,
      String? doi,
      String? pmcid,
      String abstract_,
      String? translatedTitle,
      String? translatedAbstract,
      List<String> meshTerms,
      bool hasFullDetail,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Article():
        return $default(
          _that.pmid,
          _that.title,
          _that.authors,
          _that.affiliations,
          _that.journal,
          _that.pubDate,
          _that.doi,
          _that.pmcid,
          _that.abstract_,
          _that.translatedTitle,
          _that.translatedAbstract,
          _that.meshTerms,
          _that.hasFullDetail,
        );
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int pmid,
      String title,
      List<String> authors,
      List<String> affiliations,
      String journal,
      String pubDate,
      String? doi,
      String? pmcid,
      String abstract_,
      String? translatedTitle,
      String? translatedAbstract,
      List<String> meshTerms,
      bool hasFullDetail,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Article() when $default != null:
        return $default(
          _that.pmid,
          _that.title,
          _that.authors,
          _that.affiliations,
          _that.journal,
          _that.pubDate,
          _that.doi,
          _that.pmcid,
          _that.abstract_,
          _that.translatedTitle,
          _that.translatedAbstract,
          _that.meshTerms,
          _that.hasFullDetail,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Article implements Article {
  const _Article({
    required this.pmid,
    required this.title,
    List<String> authors = const [],
    List<String> affiliations = const [],
    this.journal = '',
    this.pubDate = '',
    this.doi,
    this.pmcid,
    this.abstract_ = '',
    this.translatedTitle,
    this.translatedAbstract,
    List<String> meshTerms = const [],
    this.hasFullDetail = false,
  }) : _authors = authors,
       _affiliations = affiliations,
       _meshTerms = meshTerms;

  @override
  final int pmid;
  @override
  final String title;
  final List<String> _authors;
  @override
  @JsonKey()
  List<String> get authors {
    if (_authors is EqualUnmodifiableListView) return _authors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_authors);
  }

  final List<String> _affiliations;
  @override
  @JsonKey()
  List<String> get affiliations {
    if (_affiliations is EqualUnmodifiableListView) return _affiliations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_affiliations);
  }

  @override
  @JsonKey()
  final String journal;
  @override
  @JsonKey()
  final String pubDate;
  @override
  final String? doi;
  @override
  final String? pmcid;
  @override
  @JsonKey()
  final String abstract_;
  @override
  final String? translatedTitle;
  @override
  final String? translatedAbstract;
  final List<String> _meshTerms;
  @override
  @JsonKey()
  List<String> get meshTerms {
    if (_meshTerms is EqualUnmodifiableListView) return _meshTerms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meshTerms);
  }

  @override
  @JsonKey()
  final bool hasFullDetail;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ArticleCopyWith<_Article> get copyWith =>
      __$ArticleCopyWithImpl<_Article>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Article &&
            (identical(other.pmid, pmid) || other.pmid == pmid) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other.authors, _authors) &&
            const DeepCollectionEquality().equals(
              other.affiliations,
              _affiliations,
            ) &&
            (identical(other.journal, journal) || other.journal == journal) &&
            (identical(other.pubDate, pubDate) || other.pubDate == pubDate) &&
            (identical(other.doi, doi) || other.doi == doi) &&
            (identical(other.pmcid, pmcid) || other.pmcid == pmcid) &&
            (identical(other.abstract_, abstract_) ||
                other.abstract_ == abstract_) &&
            (identical(other.translatedTitle, translatedTitle) ||
                other.translatedTitle == translatedTitle) &&
            (identical(other.translatedAbstract, translatedAbstract) ||
                other.translatedAbstract == translatedAbstract) &&
            const DeepCollectionEquality().equals(
              other.meshTerms,
              _meshTerms,
            ) &&
            (identical(other.hasFullDetail, hasFullDetail) ||
                other.hasFullDetail == hasFullDetail));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      pmid,
      title,
      const DeepCollectionEquality().hash(_authors),
      const DeepCollectionEquality().hash(_affiliations),
      journal,
      pubDate,
      doi,
      pmcid,
      abstract_,
      translatedTitle,
      translatedAbstract,
      const DeepCollectionEquality().hash(_meshTerms),
      hasFullDetail,
    );
  }

  @override
  String toString() {
    return 'Article(pmid: $pmid, title: $title, authors: $authors, affiliations: $affiliations, journal: $journal, pubDate: $pubDate, doi: $doi, pmcid: $pmcid, abstract_: $abstract_, translatedTitle: $translatedTitle, translatedAbstract: $translatedAbstract, meshTerms: $meshTerms, hasFullDetail: $hasFullDetail)';
  }
}

/// @nodoc
abstract mixin class _$ArticleCopyWith<$Res> implements $ArticleCopyWith<$Res> {
  factory _$ArticleCopyWith(_Article value, $Res Function(_Article) _then) =
      __$ArticleCopyWithImpl;
  @override
  @useResult
  $Res call({
    int pmid,
    String title,
    List<String> authors,
    List<String> affiliations,
    String journal,
    String pubDate,
    String? doi,
    String? pmcid,
    String abstract_,
    String? translatedTitle,
    String? translatedAbstract,
    List<String> meshTerms,
    bool hasFullDetail,
  });
}

/// @nodoc
class __$ArticleCopyWithImpl<$Res> implements _$ArticleCopyWith<$Res> {
  __$ArticleCopyWithImpl(this._self, this._then);

  final _Article _self;
  final $Res Function(_Article) _then;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? pmid = null,
    Object? title = null,
    Object? authors = null,
    Object? affiliations = null,
    Object? journal = null,
    Object? pubDate = null,
    Object? doi = freezed,
    Object? pmcid = freezed,
    Object? abstract_ = null,
    Object? translatedTitle = freezed,
    Object? translatedAbstract = freezed,
    Object? meshTerms = null,
    Object? hasFullDetail = null,
  }) {
    return _then(
      _Article(
        pmid: null == pmid
            ? _self.pmid
            : pmid // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        authors: null == authors
            ? _self._authors
            : authors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        affiliations: null == affiliations
            ? _self._affiliations
            : affiliations // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        journal: null == journal
            ? _self.journal
            : journal // ignore: cast_nullable_to_non_nullable
                  as String,
        pubDate: null == pubDate
            ? _self.pubDate
            : pubDate // ignore: cast_nullable_to_non_nullable
                  as String,
        doi: freezed == doi
            ? _self.doi
            : doi // ignore: cast_nullable_to_non_nullable
                  as String?,
        pmcid: freezed == pmcid
            ? _self.pmcid
            : pmcid // ignore: cast_nullable_to_non_nullable
                  as String?,
        abstract_: null == abstract_
            ? _self.abstract_
            : abstract_ // ignore: cast_nullable_to_non_nullable
                  as String,
        translatedTitle: freezed == translatedTitle
            ? _self.translatedTitle
            : translatedTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        translatedAbstract: freezed == translatedAbstract
            ? _self.translatedAbstract
            : translatedAbstract // ignore: cast_nullable_to_non_nullable
                  as String?,
        meshTerms: null == meshTerms
            ? _self._meshTerms
            : meshTerms // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        hasFullDetail: null == hasFullDetail
            ? _self.hasFullDetail
            : hasFullDetail // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}
