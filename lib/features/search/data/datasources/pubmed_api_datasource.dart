import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;
import 'package:pubmed_mobile/features/search/domain/entities/article.dart';
import 'package:pubmed_mobile/features/search/domain/entities/search_result.dart';

/// Remote data source for NCBI E-utilities.
class PubmedApiDataSource {
  PubmedApiDataSource(this._dio);

  final Dio _dio;

  /// ESearch: keyword → PMID list.
  Future<SearchResult> search({
    required String query,
    int retStart = 0,
    int retMax = 20,
    String sort = 'relevance',
  }) async {
    final response = await _dio.get(
      'esearch.fcgi',
      queryParameters: {
        'db': 'pubmed',
        'term': query,
        'retstart': retStart,
        'retmax': retMax,
        'sort': sort,
        'retmode': 'json',
      },
    );

    final data = response.data['esearchresult'] as Map<String, dynamic>;
    final count = int.parse(data['count'] as String);
    final idList = (data['idlist'] as List<dynamic>)
        .map((e) => int.parse(e as String))
        .toList();
    final translation = data['querytranslation'] as String? ?? '';

    return SearchResult(
      totalCount: count,
      pmids: idList,
      queryTranslation: translation,
    );
  }

  /// ESummary: PMID list → article summaries.
  Future<List<Article>> fetchSummaries(List<int> pmids) async {
    if (pmids.isEmpty) return [];

    final response = await _dio.get(
      'esummary.fcgi',
      queryParameters: {
        'db': 'pubmed',
        'id': pmids.join(','),
        'retmode': 'json',
      },
    );

    final result = response.data['result'] as Map<String, dynamic>;
    final articles = <Article>[];

    for (final pmid in pmids) {
      final key = pmid.toString();
      if (!result.containsKey(key)) continue;

      final item = result[key] as Map<String, dynamic>;

      final authorList = (item['authors'] as List<dynamic>?)
              ?.map((a) => (a as Map<String, dynamic>)['name'] as String? ?? '')
              .where((n) => n.isNotEmpty)
              .toList() ??
          [];

      final doi = _extractDoi(item);
      final pmcid = _extractPmcid(item);

      articles.add(Article(
        pmid: pmid,
        title: item['title'] as String? ?? '',
        authors: authorList,
        journal: item['fulljournalname'] as String? ??
            item['source'] as String? ??
            '',
        pubDate: item['pubdate'] as String? ?? '',
        doi: doi,
        pmcid: pmcid,
      ));
    }

    return articles;
  }

  /// EFetch: PMID → full article detail (XML).
  Future<Article> fetchDetail(int pmid) async {
    final response = await _dio.get(
      'efetch.fcgi',
      queryParameters: {
        'db': 'pubmed',
        'id': pmid,
        'rettype': 'xml',
        'retmode': 'xml',
      },
    );

    final document = xml.XmlDocument.parse(response.data as String);
    final article = document.findAllElements('PubmedArticle').first;

    // Title
    final title =
        article.findAllElements('ArticleTitle').firstOrNull?.innerText ?? '';

    // Authors
    final authorElements = article.findAllElements('Author');
    final authors = authorElements.map((a) {
      final lastName = a.findElements('LastName').firstOrNull?.innerText ?? '';
      final foreName = a.findElements('ForeName').firstOrNull?.innerText ?? '';
      return '$lastName $foreName'.trim();
    }).where((n) => n.isNotEmpty).toList();

    // Journal
    final journal =
        article.findAllElements('Journal').firstOrNull
            ?.findElements('Title').firstOrNull?.innerText ?? '';

    // PubDate
    final pubDateEl = article.findAllElements('PubDate').firstOrNull;
    final year = pubDateEl?.findElements('Year').firstOrNull?.innerText ?? '';
    final month = pubDateEl?.findElements('Month').firstOrNull?.innerText ?? '';
    final pubDate = '$year $month'.trim();

    // Abstract
    final abstractTexts = article.findAllElements('AbstractText');
    final abstractParts = abstractTexts.map((el) {
      final label = el.getAttribute('Label');
      final text = el.innerText;
      return label != null ? '$label: $text' : text;
    }).toList();
    final abstractText = abstractParts.join('\n\n');

    // DOI
    final doiEl = article.findAllElements('ArticleId')
        .where((el) => el.getAttribute('IdType') == 'doi')
        .firstOrNull;
    final doi = doiEl?.innerText;

    // PMC ID
    final pmcEl = article.findAllElements('ArticleId')
        .where((el) => el.getAttribute('IdType') == 'pmc')
        .firstOrNull;
    final pmcid = pmcEl?.innerText;

    // MeSH terms
    final meshTerms = article
        .findAllElements('MeshHeading')
        .map((m) =>
            m.findElements('DescriptorName').firstOrNull?.innerText ?? '')
        .where((t) => t.isNotEmpty)
        .toList();

    return Article(
      pmid: pmid,
      title: title,
      authors: authors,
      journal: journal,
      pubDate: pubDate,
      doi: doi,
      pmcid: pmcid,
      abstract_: abstractText,
      meshTerms: meshTerms,
      hasFullDetail: true,
    );
  }

  /// ESpell: spelling suggestion.
  Future<String?> spellCheck(String query) async {
    final response = await _dio.get(
      'espell.fcgi',
      queryParameters: {
        'db': 'pubmed',
        'term': query,
        'retmode': 'json',
      },
    );

    final data = response.data['espellresult'] as Map<String, dynamic>?;
    final corrected = data?['correctedquery'] as String?;
    return (corrected != null && corrected.isNotEmpty && corrected != query)
        ? corrected
        : null;
  }

  String? _extractDoi(Map<String, dynamic> item) {
    final articleIds = item['articleids'] as List<dynamic>?;
    if (articleIds == null) return null;
    for (final id in articleIds) {
      final idMap = id as Map<String, dynamic>;
      if (idMap['idtype'] == 'doi') return idMap['value'] as String?;
    }
    return null;
  }

  String? _extractPmcid(Map<String, dynamic> item) {
    final articleIds = item['articleids'] as List<dynamic>?;
    if (articleIds == null) return null;
    for (final id in articleIds) {
      final idMap = id as Map<String, dynamic>;
      if (idMap['idtype'] == 'pmc') return idMap['value'] as String?;
    }
    return null;
  }
}
