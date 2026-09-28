// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchResult {
  int get totalCount;
  List<int> get pmids;
  String get queryTranslation;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SearchResultCopyWith<SearchResult> get copyWith =>
      _$SearchResultCopyWithImpl<SearchResult>(
        this as SearchResult,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    final _this = this as SearchResult;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SearchResult &&
            (identical(other.totalCount, _this.totalCount) ||
                other.totalCount == _this.totalCount) &&
            const DeepCollectionEquality().equals(other.pmids, _this.pmids) &&
            (identical(other.queryTranslation, _this.queryTranslation) ||
                other.queryTranslation == _this.queryTranslation));
  }

  @override
  int get hashCode {
    final _this = this as SearchResult;
    return Object.hash(
      runtimeType,
      _this.totalCount,
      const DeepCollectionEquality().hash(_this.pmids),
      _this.queryTranslation,
    );
  }

  @override
  String toString() {
    final _this = this as SearchResult;
    return 'SearchResult(totalCount: ${_this.totalCount}, pmids: ${_this.pmids}, queryTranslation: ${_this.queryTranslation})';
  }
}

/// @nodoc
abstract mixin class $SearchResultCopyWith<$Res> {
  factory $SearchResultCopyWith(
    SearchResult value,
    $Res Function(SearchResult) _then,
  ) = _$SearchResultCopyWithImpl;
  @useResult
  $Res call({int totalCount, List<int> pmids, String queryTranslation});
}

/// @nodoc
class _$SearchResultCopyWithImpl<$Res> implements $SearchResultCopyWith<$Res> {
  _$SearchResultCopyWithImpl(this._self, this._then);

  final SearchResult _self;
  final $Res Function(SearchResult) _then;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCount = null,
    Object? pmids = null,
    Object? queryTranslation = null,
  }) {
    return _then(
      SearchResult(
        totalCount: null == totalCount
            ? _self.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pmids: null == pmids
            ? _self.pmids
            : pmids // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        queryTranslation: null == queryTranslation
            ? _self.queryTranslation
            : queryTranslation // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [SearchResult].
extension SearchResultPatterns on SearchResult {
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
    TResult Function(_SearchResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SearchResult() when $default != null:
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
    TResult Function(_SearchResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchResult():
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
    TResult? Function(_SearchResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchResult() when $default != null:
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
    TResult Function(int totalCount, List<int> pmids, String queryTranslation)?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SearchResult() when $default != null:
        return $default(_that.totalCount, _that.pmids, _that.queryTranslation);
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
    TResult Function(int totalCount, List<int> pmids, String queryTranslation)
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchResult():
        return $default(_that.totalCount, _that.pmids, _that.queryTranslation);
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
    TResult? Function(int totalCount, List<int> pmids, String queryTranslation)?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchResult() when $default != null:
        return $default(_that.totalCount, _that.pmids, _that.queryTranslation);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SearchResult implements SearchResult {
  const _SearchResult({
    required this.totalCount,
    required List<int> pmids,
    this.queryTranslation = '',
  }) : _pmids = pmids;

  @override
  final int totalCount;
  final List<int> _pmids;
  @override
  List<int> get pmids {
    if (_pmids is EqualUnmodifiableListView) return _pmids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pmids);
  }

  @override
  @JsonKey()
  final String queryTranslation;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SearchResultCopyWith<_SearchResult> get copyWith =>
      __$SearchResultCopyWithImpl<_SearchResult>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SearchResult &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            const DeepCollectionEquality().equals(other.pmids, _pmids) &&
            (identical(other.queryTranslation, queryTranslation) ||
                other.queryTranslation == queryTranslation));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      totalCount,
      const DeepCollectionEquality().hash(_pmids),
      queryTranslation,
    );
  }

  @override
  String toString() {
    return 'SearchResult(totalCount: $totalCount, pmids: $pmids, queryTranslation: $queryTranslation)';
  }
}

/// @nodoc
abstract mixin class _$SearchResultCopyWith<$Res>
    implements $SearchResultCopyWith<$Res> {
  factory _$SearchResultCopyWith(
    _SearchResult value,
    $Res Function(_SearchResult) _then,
  ) = __$SearchResultCopyWithImpl;
  @override
  @useResult
  $Res call({int totalCount, List<int> pmids, String queryTranslation});
}

/// @nodoc
class __$SearchResultCopyWithImpl<$Res>
    implements _$SearchResultCopyWith<$Res> {
  __$SearchResultCopyWithImpl(this._self, this._then);

  final _SearchResult _self;
  final $Res Function(_SearchResult) _then;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? totalCount = null,
    Object? pmids = null,
    Object? queryTranslation = null,
  }) {
    return _then(
      _SearchResult(
        totalCount: null == totalCount
            ? _self.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pmids: null == pmids
            ? _self._pmids
            : pmids // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        queryTranslation: null == queryTranslation
            ? _self.queryTranslation
            : queryTranslation // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}
