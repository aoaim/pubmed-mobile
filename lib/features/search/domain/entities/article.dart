import 'package:freezed_annotation/freezed_annotation.dart';

part 'article.freezed.dart';

/// Domain entity for a PubMed article.
@freezed
class Article with _$Article {
  const factory Article({
    required int pmid,
    required String title,
    @Default([]) List<String> authors,
    @Default('') String journal,
    @Default('') String pubDate,
    String? doi,
    String? pmcid,
    @Default('') String abstract_,
    String? translatedTitle,
    String? translatedAbstract,
    @Default([]) List<String> meshTerms,
    @Default(false) bool hasFullDetail,
  }) = _Article;
}

/// Whether this article has PMC full text available.
extension ArticleX on Article {
  bool get hasFullText => pmcid != null && pmcid!.isNotEmpty;
  String get pmcUrl => 'https://www.ncbi.nlm.nih.gov/pmc/articles/$pmcid/';
  String get pubmedUrl => 'https://pubmed.ncbi.nlm.nih.gov/$pmid/';
  String get doiUrl => doi != null ? 'https://doi.org/$doi' : '';
}
