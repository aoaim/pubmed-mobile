import 'package:flutter_test/flutter_test.dart';
import 'package:pubmed_mobile/features/article_detail/data/services/easyscholar_service.dart';
import 'package:pubmed_mobile/features/article_detail/domain/journal_metric.dart';

void main() {
  test(
    'easyScholar documented fields map to independently selectable metrics',
    () {
      final ranking = JournalRanking.fromOfficialRank({
        'sci': 'Q1',
        'jci': '2.3',
        'sciUp': '医学2区',
        'sciUpSmall': '免疫学1区', // Not offered in the app.
        'xr': '1区',
        'xrSmall': '免疫学2区',
        'xrTop': 'TOP',
        'unused': 'ignored',
      });

      expect(ranking.valueFor(JournalMetric.jcr), 'Q1');
      expect(ranking.valueFor(JournalMetric.jci), '2.3');
      expect(ranking.valueFor(JournalMetric.casMajor), '医学2区');
      expect(ranking.valueFor(JournalMetric.xrMajor), '1区');
      expect(ranking.valueFor(JournalMetric.xrMinor), '免疫学2区');
      expect(ranking.valueFor(JournalMetric.xrTop), 'TOP');
      expect(ranking.valueFor(JournalMetric.impactFactor), isNull);
      expect(ranking.values.length, 6);
    },
  );
}
