/// Supported keys in easyScholar's officialRank.all response.
/// Keep the API mapping here so new ranking sources can be added independently.
enum JournalMetric {
  jcr('sci'),
  impactFactor('sciif'),
  jci('jci'),
  casMajor('sciUp'),
  casTop('sciUpTop'),
  xrMajor('xr'),
  xrMinor('xrSmall'),
  xrTop('xrTop'),
  xrWarning('xrWarn'),
  esi('esi');

  const JournalMetric(this.apiKey);
  final String apiKey;

  bool get isCas => this == casMajor || this == casTop;
}
