import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pubmed_mobile/features/search/data/datasources/pubmed_api_datasource.dart';

void main() {
  test('ESearch sends the search query unchanged to PubMed', () async {
    String? sentTerm;
    final dio = Dio(BaseOptions(baseUrl: 'https://example.org/'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          sentTerm = options.queryParameters['term'] as String?;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              data: {
                'esearchresult': {
                  'count': '0',
                  'idlist': <String>[],
                  'querytranslation': '',
                },
              },
            ),
          );
        },
      ),
    );

    await PubmedApiDataSource(dio).search(query: 'cancer OR tumor');
    expect(sentTerm, 'cancer OR tumor');
  });

  test('EFetch collects unique author affiliations', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.org/'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response<String>(
            requestOptions: options,
            data: '''<PubmedArticleSet><PubmedArticle><MedlineCitation>
          <Article><ArticleTitle>Sample title</ArticleTitle><AuthorList>
            <Author><LastName>Li</LastName><ForeName>Wei</ForeName>
              <AffiliationInfo><Affiliation>University A, China</Affiliation></AffiliationInfo>
            </Author>
            <Author><LastName>Chen</LastName><ForeName>Min</ForeName>
              <AffiliationInfo><Affiliation>University A, China</Affiliation></AffiliationInfo>
              <AffiliationInfo><Affiliation>Institute B, Germany</Affiliation></AffiliationInfo>
            </Author>
          </AuthorList></Article></MedlineCitation></PubmedArticle></PubmedArticleSet>''',
          ),
        ),
      ),
    );

    final article = await PubmedApiDataSource(dio).fetchDetail(123);
    expect(article.authors, ['Li Wei', 'Chen Min']);
    expect(article.affiliations, [
      'University A, China',
      'Institute B, Germany',
    ]);
  });
}
