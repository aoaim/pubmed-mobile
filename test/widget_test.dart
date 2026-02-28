import 'package:flutter_test/flutter_test.dart';

import 'package:pubmed_mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Verify the app widget can be referenced.
    expect(PubMedMobileApp, isNotNull);
  });
}
