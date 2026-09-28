import 'package:flutter/material.dart';
import 'package:pubmed_mobile/features/article_detail/domain/journal_metric.dart';

/// Simple localization support for zh-CN and en-US.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('zh', 'CN'), Locale('en', 'GB')];

  bool get _isZh => locale.languageCode == 'zh';

  // Navigation
  String get search => _isZh ? '搜索' : 'Search';
  String get favorites => _isZh ? '收藏' : 'Favorites';
  String get settings => _isZh ? '设置' : 'Settings';

  // Search
  String get searchHint => _isZh ? '搜索 PubMed 文献...' : 'Search PubMed...';
  String get recentSearches => _isZh ? '最近搜索' : 'Recent Searches';
  String get clearAll => _isZh ? '清除全部' : 'Clear All';
  String get noResults => _isZh ? '未找到结果' : 'No results found';
  String get searchError => _isZh ? '搜索出错' : 'Search error';
  String resultCount(int count) => _isZh ? '共 $count 条结果' : '$count results';
  String get sortByRelevance => _isZh ? '按相关性' : 'Relevance';
  String get sortByDate => _isZh ? '按日期' : 'Date';
  String get loading => _isZh ? '加载中...' : 'Loading...';
  String get loadMore => _isZh ? '加载更多' : 'Load more';
  String get searching => _isZh ? '正在检索…' : 'Searching…';

  // Article detail
  String get abstract_ => _isZh ? '摘要' : 'Abstract';
  String get authors => _isZh ? '作者' : 'Authors';
  String get affiliations => _isZh ? '作者单位' : 'Affiliations';
  String get meshTerms => _isZh ? 'MeSH 关键词' : 'MeSH Terms';
  String get relatedArticles => _isZh ? '相关文献' : 'Related Articles';
  String get viewFullText => _isZh ? '查看全文' : 'View Full Text';
  String get addToFavorites => _isZh ? '收藏' : 'Add to Favorites';
  String get removeFromFavorites => _isZh ? '取消收藏' : 'Remove from Favorites';
  String get share => _isZh ? '分享' : 'Share';
  String get copied => _isZh ? '已复制' : 'Copied';
  String get pmcFullText => _isZh ? 'PMC 免费全文' : 'Free in PMC';
  String get translate => _isZh ? '翻译' : 'Translate';
  String get translating => _isZh ? '正在翻译...' : 'Translating...';
  String get translationError => _isZh ? '翻译失败' : 'Translation failed';
  String get translationInvalidApiKey => _isZh
      ? 'API 密钥无效或没有调用权限。'
      : 'The API key is invalid or lacks API access.';
  String get translationNetworkError =>
      _isZh ? '网络连接失败，请稍后重试' : 'Network error. Try again later';
  String get translationQuotaExceeded =>
      _isZh ? '翻译额度已用完' : 'Translation quota exceeded';
  String get translationRateLimited =>
      _isZh ? '请求过于频繁，请稍后重试' : 'Too many requests. Try again later';
  String get translationServiceUnavailable =>
      _isZh ? '翻译服务暂时不可用' : 'Translation service unavailable';
  String get translationInvalidResponse =>
      _isZh ? '翻译服务返回了无效内容' : 'Invalid translation response';
  String get translationInterface => _isZh ? '当前接口' : 'Current API';
  String get translationReason => _isZh ? '失败原因' : 'Reason';
  String get translationSuggestion => _isZh ? '建议' : 'What to do';
  String get translationHttpStatus => _isZh ? 'HTTP 状态码' : 'HTTP status';
  String get translationClose => _isZh ? '知道了' : 'Close';
  String get translationNoProvider => _isZh
      ? '当前翻译通道未配置 API Key，请在设置中填写。'
      : 'The current translation channel has no API key configured. Add one in Settings.';
  String get translationRequestRejected =>
      _isZh ? '接口拒绝了这次请求。' : 'The API rejected this request.';
  String get translationTimeout =>
      _isZh ? '连接或响应超时。' : 'The connection or response timed out.';
  String get translationConnectionFailed => _isZh
      ? '无法连接到翻译接口，请检查网络或代理。'
      : 'Could not connect to the translation API. Check your network or proxy.';
  String get translationCertificateFailed => _isZh
      ? '翻译接口的安全证书校验失败。'
      : 'The translation API certificate check failed.';
  String get translationCheckKey => _isZh
      ? '在设置中检查 API Key 和套餐类型。'
      : 'Check the API key and plan type in Settings.';
  String get translationCheckQuota => _isZh
      ? '检查翻译服务账户额度，额度恢复后再试。'
      : 'Check your translation service quota and retry when it resets.';
  String get translationBadRequest => _isZh
      ? '接口认为请求参数或格式无效。'
      : 'The API rejected the request parameters or format.';
  String get translationEndpointMissing =>
      _isZh ? '接口地址不存在或已变更。' : 'The API endpoint was not found or has changed.';
  String get translationTryLater => _isZh
      ? '请稍后重试；如果持续发生，可更换网络后再试。'
      : 'Try again later. If it persists, try another network.';
  String get translationCheckService => _isZh
      ? '请稍后重试；如果持续发生，请检查接口是否仍可用。'
      : 'Try again later. If it persists, check whether the API is still available.';
  String get translationCheckResponse => _isZh
      ? '请稍后重试；如果持续发生，请记录接口和状态码以便排查。'
      : 'Try again later. If it persists, note the API and status for troubleshooting.';
  String get translationUnknownReason => _isZh
      ? '发生了未识别的错误，暂时无法确定具体原因。'
      : 'An unexpected error occurred; the exact cause is unknown.';

  // Reader
  String get readerTitle => _isZh ? '全文阅读' : 'Full Text';
  String get readerTranslationOn =>
      _isZh ? '按屏幕逐段翻译' : 'Translate visible paragraphs';
  String get readerTranslationOff =>
      _isZh ? '关闭逐段翻译' : 'Turn off paragraph translation';
  String get readerTranslationWaiting => _isZh
      ? '已开启翻译；滚动到正文段落后会自动翻译当前屏幕。'
      : 'Translation is on. Scroll to a paragraph to translate what is visible.';
  String get loadingPage => _isZh ? '正在加载页面...' : 'Loading page...';
  String get pageLoadError => _isZh ? '页面加载失败' : 'Failed to load page';
  String get retry => _isZh ? '重试' : 'Retry';
  String get simplifyReader => _isZh ? '沉浸式 PMC 阅读' : 'Immersive PMC Reader';
  String get simplifyReaderHint => _isZh
      ? '注入脚本自动隐藏 PMC 顶栏与侧边栏，铺满全屏'
      : 'Hide PMC headers and sidebars for an immersive reading experience';

  // Favorites
  String get noFavorites => _isZh ? '暂无收藏' : 'No favorites yet';
  String get deleteFavorite => _isZh ? '删除收藏' : 'Remove favorite';
  String get favoriteAdded => _isZh ? '已添加到收藏' : 'Added to favorites';
  String get favoriteRemoved => _isZh ? '已取消收藏' : 'Removed from favorites';
  String get export => _isZh ? '导出' : 'Export';
  String get exportSuccess => _isZh ? '已复制到剪贴板' : 'Copied to clipboard';

  // Settings
  String get apiKeyTitle => _isZh ? 'NCBI API Key' : 'NCBI API Key';
  String get apiKeyHint => _isZh
      ? '未配置时 3 次/秒，配置后最高 10 次/秒'
      : 'Without key: 3 requests/sec. With key: 10 requests/sec.';
  String get deeplApiKeyTitle => _isZh ? 'DeepL API Key' : 'DeepL API Key';
  String get deeplApiKeyHint => _isZh
      ? '支持 DeepL Free API 密钥 (每月免费 50 万字符翻译额度，需前往 deepl.com 获取)。'
      : 'Supports DeepL Free Auth Key (500k characters/month for free, get it at deepl.com).';
  String get translationChannelTitle => _isZh ? '翻译通道' : 'Translation Channel';
  String get translationChannelDeepl => _isZh ? 'DeepL' : 'DeepL';
  String get translationChannelOpenai =>
      _isZh ? 'OpenAI 兼容接口' : 'OpenAI Compatible';
  String get openaiApiKeyTitle => _isZh ? 'API Key' : 'API Key';
  String get openaiApiKeyHint => _isZh
      ? 'OpenAI 兼容接口的 API Key。默认使用 DeepSeek 官方接口，请填写 DeepSeek API Key。'
      : 'API key for an OpenAI-compatible endpoint. The default is the official DeepSeek API; enter a DeepSeek API key.';
  String get openaiBaseUrlTitle => _isZh ? 'Base URL' : 'Base URL';
  String get openaiBaseUrlHint => _isZh
      ? '接口地址，默认 https://api.deepseek.com，可换成其他 OpenAI 兼容服务'
      : 'Endpoint URL. Defaults to https://api.deepseek.com. Other OpenAI-compatible services also work.';
  String get openaiModelTitle => _isZh ? '模型' : 'Model';
  String get openaiModelHint => _isZh
      ? '默认 deepseek-flash。填写 API Key 后点击刷新图标获取可用模型，也可手动输入模型 ID'
      : 'Defaults to deepseek-flash. Enter an API key and tap refresh to list available models, or type a model ID.';
  String get refreshModels => _isZh ? '获取可用模型' : 'Fetch available models';
  String get modelLoadFailed => _isZh
      ? '获取模型列表失败，请检查 Base URL 和 API Key'
      : 'Failed to fetch models. Check Base URL and API Key.';
  String get themeTitle => _isZh ? '主题' : 'Theme';
  String get themeSystem => _isZh ? '跟随系统' : 'System';
  String get themeLight => _isZh ? '浅色' : 'Light';
  String get themeDark => _isZh ? '深色' : 'Dark';
  String get useDynamicColor =>
      _isZh ? '使用壁纸动态取色 (Android 12+)' : 'Use Dynamic Color (Android 12+)';
  String get languageTitle => _isZh ? '语言' : 'Language';
  String get cacheTitle => _isZh ? '缓存管理' : 'Cache Management';
  String get clearCache => _isZh ? '清除缓存' : 'Clear Cache';
  String get cacheCleared => _isZh ? '缓存已清除' : 'Cache cleared';
  String cacheSize(String size) => _isZh ? '当前缓存：$size' : 'Cache size: $size';
  String get maxCacheSize => _isZh ? '缓存上限' : 'Max Cache Size';
  String get pageSizeTitle => _isZh ? '每次加载条数' : 'Results per Page';
  String get easyScholarTitle => _isZh ? 'easyScholar' : 'easyScholar';
  String get easyScholarHint => _isZh
      ? '配置后可查看期刊 JCR 分区、中科院分区和影响因子。前往 easyscholar.cc 获取 SecretKey（免费开放）。'
      : 'Shows JCR partition, CAS partition, and Impact Factor. Get SecretKey at easyscholar.cc (free).';
  String get journalMetricsToShow =>
      _isZh ? '在文献详情中显示' : 'Show in article details';
  String get journalMetricsHint => _isZh
      ? '仅展示 easyScholar 实际返回且已勾选的指标；IF 是接口返回的最新年份影响因子。'
      : 'Only selected metrics returned by easyScholar are shown. IF is the latest-year impact factor returned by the API.';
  String get casRankingNotice => _isZh
      ? '中科院文献情报中心自 2026 年起不再更新与发布分区表；此处为 easyScholar 返回的历史数据。'
      : 'The CAS National Science Library stopped updating and publishing journal partition tables in 2026. These are historical values returned by easyScholar.';
  String journalMetricLabel(JournalMetric metric) => switch (metric) {
    JournalMetric.jcr => 'JCR',
    JournalMetric.impactFactor => 'IF',
    JournalMetric.jci => 'JCI',
    JournalMetric.casMajor => _isZh ? '中科院升级版大类' : 'CAS major',
    JournalMetric.casTop => _isZh ? '中科院 Top' : 'CAS Top',
    JournalMetric.xrMajor => _isZh ? '新锐学术' : 'Xinrui',
    JournalMetric.xrMinor => _isZh ? '新锐小类' : 'Xinrui minor',
    JournalMetric.xrTop => _isZh ? '新锐 Top' : 'Xinrui Top',
    JournalMetric.xrWarning => _isZh ? '新锐预警' : 'Xinrui warning',
    JournalMetric.esi => 'ESI',
  };
  String get journalRanking => _isZh ? '期刊分区' : 'Journal Ranking';
  String get impactFactor => _isZh ? '影响因子' : 'Impact Factor';
  String get about => _isZh ? '关于' : 'About';
  String currentVersion(String version) =>
      _isZh ? '当前版本 $version' : 'Current version $version';

  // Update check
  String get checkForUpdates => _isZh ? '检查更新' : 'Check for Updates';
  String get checkingForUpdates => _isZh ? '正在检查更新…' : 'Checking for updates…';
  String get updateNow => _isZh ? '更新' : 'Update';
  String get ignoreThisVersion => _isZh ? '本次忽略此提示' : 'Ignore this version';
  String get upToDate => _isZh ? '已是最新版本' : "You're up to date";
  String get checkFailed => _isZh ? '检查更新失败' : 'Update check failed';
  String get close => _isZh ? '关闭' : 'Close';

  // Connectivity
  String get offline => _isZh ? '当前处于离线状态' : 'You are offline';
  String get offlineData => _isZh ? '正在显示缓存数据' : 'Showing cached data';

  // General
  String get cancel => _isZh ? '取消' : 'Cancel';
  String get confirm => _isZh ? '确认' : 'Confirm';
  String get save => _isZh ? '保存' : 'Save';
  String get delete => _isZh ? '删除' : 'Delete';
  String get error => _isZh ? '出错了' : 'Error';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['zh', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
