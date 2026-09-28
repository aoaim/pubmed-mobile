import 'package:flutter_test/flutter_test.dart';
import 'package:pubmed_mobile/features/reader/domain/pmc_page.dart';

void main() {
  test('builds the canonical PMC URL', () {
    expect(
      PmcPage.canonicalUrl('PMC10691338'),
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC10691338/',
    );
  });

  test('accepts a PMC article page', () {
    final html =
        '''
      <html><body>
        <section class="pmc-article-section">
          <main class="main-article-body">
            <h2 class="pmc_sec_title">Results</h2>
            ${List.filled(100, 'Article content. ').join()}
          </main>
        </section>
      </body></html>
    ''';

    expect(PmcPage.isReadableArticle(html), isTrue);
  });

  test('rejects browser checks and unrelated long pages', () {
    final filler = List.filled(1200, 'x').join();
    final browserCheck =
        '<html>Checking your browser before accessing PMC $filler</html>';
    final unrelated = '<html><main>$filler</main></html>';

    expect(PmcPage.isReadableArticle(browserCheck), isFalse);
    expect(PmcPage.isReadableArticle(unrelated), isFalse);
  });
}
