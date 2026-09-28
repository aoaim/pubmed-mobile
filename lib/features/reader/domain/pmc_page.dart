class PmcPage {
  PmcPage._();

  static String canonicalUrl(String pmcid) =>
      'https://pmc.ncbi.nlm.nih.gov/articles/$pmcid/';

  static bool isReadableArticle(String html) {
    if (html.length < 1000) return false;

    final normalized = html.toLowerCase();
    if (normalized.contains('checking your browser') ||
        normalized.contains('recaptcha') ||
        normalized.contains('access denied') ||
        normalized.contains('cf-chl-')) {
      return false;
    }

    return normalized.contains('pmc-article-section') &&
        (normalized.contains('main-article-body') ||
            normalized.contains('pmc_sec_title') ||
            normalized.contains('<article'));
  }
}
