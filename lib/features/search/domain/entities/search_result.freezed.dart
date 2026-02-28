// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SearchResult {
  int get totalCount => throw _privateConstructorUsedError;
  List<int> get pmids => throw _privateConstructorUsedError;
  String get queryTranslation => throw _privateConstructorUsedError;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchResultCopyWith<SearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResultCopyWith<$Res> {
  factory $SearchResultCopyWith(
    SearchResult value,
    $Res Function(SearchResult) then,
  ) = _$SearchResultCopyWithImpl<$Res, SearchResult>;
  @useResult
  $Res call({int totalCount, List<int> pmids, String queryTranslation});
}

/// @nodoc
class _$SearchResultCopyWithImpl<$Res, $Val extends SearchResult>
    implements $SearchResultCopyWith<$Res> {
  _$SearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
      _value.copyWith(
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            pmids: null == pmids
                ? _value.pmids
                : pmids // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            queryTranslation: null == queryTranslation
                ? _value.queryTranslation
                : queryTranslation // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchResultImplCopyWith<$Res>
    implements $SearchResultCopyWith<$Res> {
  factory _$$SearchResultImplCopyWith(
    _$SearchResultImpl value,
    $Res Function(_$SearchResultImpl) then,
  ) = __$$SearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int totalCount, List<int> pmids, String queryTranslation});
}

/// @nodoc
class __$$SearchResultImplCopyWithImpl<$Res>
    extends _$SearchResultCopyWithImpl<$Res, _$SearchResultImpl>
    implements _$$SearchResultImplCopyWith<$Res> {
  __$$SearchResultImplCopyWithImpl(
    _$SearchResultImpl _value,
    $Res Function(_$SearchResultImpl) _then,
  ) : super(_value, _then);

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
      _$SearchResultImpl(
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pmids: null == pmids
            ? _value._pmids
            : pmids // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        queryTranslation: null == queryTranslation
            ? _value.queryTranslation
            : queryTranslation // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SearchResultImpl implements _SearchResult {
  const _$SearchResultImpl({
    required this.totalCount,
    required final List<int> pmids,
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

  @override
  String toString() {
    return 'SearchResult(totalCount: $totalCount, pmids: $pmids, queryTranslation: $queryTranslation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResultImpl &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            const DeepCollectionEquality().equals(other._pmids, _pmids) &&
            (identical(other.queryTranslation, queryTranslation) ||
                other.queryTranslation == queryTranslation));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalCount,
    const DeepCollectionEquality().hash(_pmids),
    queryTranslation,
  );

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResultImplCopyWith<_$SearchResultImpl> get copyWith =>
      __$$SearchResultImplCopyWithImpl<_$SearchResultImpl>(this, _$identity);
}

abstract class _SearchResult implements SearchResult {
  const factory _SearchResult({
    required final int totalCount,
    required final List<int> pmids,
    final String queryTranslation,
  }) = _$SearchResultImpl;

  @override
  int get totalCount;
  @override
  List<int> get pmids;
  @override
  String get queryTranslation;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchResultImplCopyWith<_$SearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
