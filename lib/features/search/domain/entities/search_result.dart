import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result.freezed.dart';

/// Encapsulates a page of search results.
@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult({
    required int totalCount,
    required List<int> pmids,
    @Default('') String queryTranslation,
  }) = _SearchResult;
}
