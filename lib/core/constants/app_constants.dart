/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'PubMed Mobile';

  // NCBI E-utilities
  static const String ncbiBaseUrl =
      'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
  static const String toolName = 'pubmed_mobile';
  static const String contactEmail = 'pubmedmobile@example.com';

  // Rate limiting
  static const int rateLimitWithoutKey = 3; // requests per second
  static const int rateLimitWithKey = 10;

  // Pagination
  static const int defaultPageSize = 20;

  // Cache
  static const int searchCacheDays = 7;
  static const int detailCacheDays = 30;
  static const int defaultMaxCacheMB = 200;

  // History
  static const int maxHistoryItems = 50;

  // Debounce
  static const Duration searchDebounceDuration = Duration(milliseconds: 500);
}
