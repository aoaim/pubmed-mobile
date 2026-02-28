import 'package:flutter/material.dart';

/// Simple localization support for zh-CN and en-US.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'GB'),
  ];

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
  String resultCount(int count) =>
      _isZh ? '共 $count 条结果' : '$count results';
  String get sortByRelevance => _isZh ? '按相关性' : 'Relevance';
  String get sortByDate => _isZh ? '按日期' : 'Date';
  String get loading => _isZh ? '加载中...' : 'Loading...';
  String get loadMore => _isZh ? '加载更多' : 'Load more';

  // Article detail
  String get abstract_ => _isZh ? '摘要' : 'Abstract';
  String get authors => _isZh ? '作者' : 'Authors';
  String get meshTerms => _isZh ? 'MeSH 关键词' : 'MeSH Terms';
  String get relatedArticles => _isZh ? '相关文献' : 'Related Articles';
  String get viewFullText => _isZh ? '查看全文' : 'View Full Text';
  String get addToFavorites => _isZh ? '收藏' : 'Add to Favorites';
  String get removeFromFavorites => _isZh ? '取消收藏' : 'Remove from Favorites';
  String get share => _isZh ? '分享' : 'Share';
  String get copied => _isZh ? '已复制' : 'Copied';
  String get openAccess => _isZh ? '开放获取' : 'Open Access';
  String get translate => _isZh ? '翻译' : 'Translate';
  String get translating => _isZh ? '正在翻译...' : 'Translating...';
  String get translationError => _isZh ? '翻译失败' : 'Translation failed';

  // Reader
  String get readerTitle => _isZh ? '全文阅读' : 'Full Text';
  String get loadingPage => _isZh ? '正在加载页面...' : 'Loading page...';
  String get pageLoadError => _isZh ? '页面加载失败' : 'Failed to load page';
  String get retry => _isZh ? '重试' : 'Retry';
  String get simplifyReader => _isZh ? '沉浸式 PMC 阅读' : 'Immersive PMC Reader';
  String get simplifyReaderHint => _isZh ? '注入脚本自动隐藏 PMC 顶栏与侧边栏，铺满全屏' : 'Hide PMC headers and sidebars for an immersive reading experience';

  // Favorites
  String get noFavorites => _isZh ? '暂无收藏' : 'No favorites yet';
  String get deleteFavorite => _isZh ? '删除收藏' : 'Remove favorite';
  String get favoriteAdded => _isZh ? '已添加到收藏' : 'Added to favorites';
  String get favoriteRemoved => _isZh ? '已取消收藏' : 'Removed from favorites';
  String get export => _isZh ? '导出' : 'Export';
  String get exportSuccess => _isZh ? '已复制到剪贴板' : 'Copied to clipboard';

  // Settings
  String get apiKeyTitle => _isZh ? 'NCBI API Key' : 'NCBI API Key';
  String get apiKeyHint =>
      _isZh ? '未配置时 3 次/秒，配置后最高 10 次/秒' : 'Without key: 3 requests/sec. With key: 10 requests/sec.';
  String get deeplApiKeyTitle => _isZh ? 'DeepL API Key' : 'DeepL API Key';
  String get deeplApiKeyHint =>
      _isZh ? '支持 DeepL Free API 密钥 (每月免费 50 万字符翻译额度，需前往 deepl.com 获取)。不填会回退至微软免费接口。' : 'Supports DeepL Free Auth Key (500k characters/month for free). Leave empty to use Microsoft free API.';
  String get themeTitle => _isZh ? '主题' : 'Theme';
  String get themeSystem => _isZh ? '跟随系统' : 'System';
  String get themeLight => _isZh ? '浅色' : 'Light';
  String get themeDark => _isZh ? '深色' : 'Dark';
  String get useDynamicColor => _isZh ? '使用壁纸动态取色 (Android 12+)' : 'Use Dynamic Color (Android 12+)';
  String get languageTitle => _isZh ? '语言' : 'Language';
  String get cacheTitle => _isZh ? '缓存管理' : 'Cache Management';
  String get clearCache => _isZh ? '清除缓存' : 'Clear Cache';
  String get cacheCleared => _isZh ? '缓存已清除' : 'Cache cleared';
  String cacheSize(String size) =>
      _isZh ? '当前缓存：$size' : 'Cache size: $size';
  String get maxCacheSize => _isZh ? '缓存上限' : 'Max Cache Size';
  String get pageSizeTitle => _isZh ? '每次加载条数' : 'Results per Page';
  String get easyScholarTitle => _isZh ? 'easyScholar' : 'easyScholar';
  String get easyScholarHint =>
      _isZh ? '配置后可查看期刊 JCR 分区、中科院分区和影响因子。前往 easyscholar.cc 获取 SecretKey（免费开放）。' : 'Shows JCR partition, CAS partition, and Impact Factor. Get SecretKey at easyscholar.cc (free).';
  String get journalRanking => _isZh ? '期刊分区' : 'Journal Ranking';
  String get impactFactor => _isZh ? '影响因子' : 'Impact Factor';
  String get about => _isZh ? '关于' : 'About';
  String get version => _isZh ? '版本' : 'Version';

  // Connectivity
  String get offline => _isZh ? '当前处于离线状态' : 'You are offline';
  String get offlineData =>
      _isZh ? '正在显示缓存数据' : 'Showing cached data';

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
  bool isSupported(Locale locale) =>
      ['zh', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
