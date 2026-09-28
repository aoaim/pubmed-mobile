import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pubmed_mobile/core/l10n/app_localizations.dart';
import 'package:pubmed_mobile/core/constants/app_constants.dart';
import 'package:pubmed_mobile/core/database/app_database.dart';
import 'package:pubmed_mobile/core/analytics/analytics.dart';
import 'package:pubmed_mobile/features/settings/data/settings_repository.dart';
import 'package:pubmed_mobile/features/article_detail/data/services/translation_service.dart';
import 'package:pubmed_mobile/features/article_detail/domain/journal_metric.dart';
import 'package:pubmed_mobile/features/updates/data/update_check_service.dart';
import 'package:pubmed_mobile/features/updates/presentation/providers/update_check_provider.dart';
import 'package:pubmed_mobile/features/updates/presentation/widgets/update_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _deeplApiController;
  late TextEditingController _openaiBaseUrlController;
  late TextEditingController _openaiApiController;
  late TextEditingController _openaiModelController;
  late TextEditingController _easyScholarController;

  List<String> _models = [];
  bool _isLoadingModels = false;
  bool _isCheckingUpdate = false;
  String _appVersion = '';
  late Future<(int, int, double, double)> _cacheStatsFuture;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    final settings = ref.read(settingsRepositoryProvider);
    _apiKeyController = TextEditingController(text: settings.apiKey ?? '');
    _deeplApiController = TextEditingController(
      text: settings.deeplApiKey ?? '',
    );
    _openaiBaseUrlController = TextEditingController(
      text: settings.openaiBaseUrl,
    );
    _openaiApiController = TextEditingController(
      text: settings.openaiApiKey ?? '',
    );
    _openaiModelController = TextEditingController(text: settings.openaiModel);
    _easyScholarController = TextEditingController(
      text: settings.easyScholarKey ?? '',
    );
    _cacheStatsFuture = _loadCacheStats();
  }

  Future<(int, int, double, double)> _loadCacheStats() async {
    final db = ref.read(databaseProvider);
    final articleCount = await db.getCacheCount();
    final pmcCount = await db.getPmcCacheCount();
    final pmcMb = await db.getPmcCacheSizeMb();
    final totalMb = await db.getDatabaseFileSizeMb();
    return (articleCount, pmcCount, pmcMb, totalMb);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _deeplApiController.dispose();
    _openaiBaseUrlController.dispose();
    _openaiApiController.dispose();
    _openaiModelController.dispose();
    _easyScholarController.dispose();
    super.dispose();
  }

  /// Reads the real installed version at runtime so the update row never
  /// drifts from pubspec.yaml (single source of truth).
  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = info.version);
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    await ref.read(settingsRepositoryProvider).setApiKey(key);
    if (!mounted) return;
    _markCredentialsChanged();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).save)));
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveDeeplKey() async {
    final key = _deeplApiController.text.trim();
    await ref.read(settingsRepositoryProvider).setDeeplApiKey(key);
    if (!mounted) return;
    _markCredentialsChanged();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).save)));
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveOpenaiBaseUrl() async {
    await ref
        .read(settingsRepositoryProvider)
        .setOpenaiBaseUrl(_openaiBaseUrlController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).save)));
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveOpenaiKey() async {
    final key = _openaiApiController.text.trim();
    await ref.read(settingsRepositoryProvider).setOpenaiApiKey(key);
    if (!mounted) return;
    _markCredentialsChanged();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).save)));
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveOpenaiModel() async {
    await ref
        .read(settingsRepositoryProvider)
        .setOpenaiModel(_openaiModelController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).save)));
    FocusScope.of(context).unfocus();
  }

  Future<void> _loadModels() async {
    if (_isLoadingModels) return;
    final l10n = AppLocalizations.of(context);
    final baseUrl = _openaiBaseUrlController.text;
    final apiKey = _openaiApiController.text;
    setState(() => _isLoadingModels = true);
    try {
      final models = await ref
          .read(translationServiceProvider)
          .fetchModels(baseUrl: baseUrl, apiKey: apiKey);
      if (!mounted) return;
      setState(() {
        _models =
            baseUrl == _openaiBaseUrlController.text &&
                apiKey == _openaiApiController.text
            ? models
            : [];
        _isLoadingModels = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingModels = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.modelLoadFailed)));
    }
  }

  void _clearModels() {
    if (_models.isNotEmpty) setState(() => _models = []);
  }

  Future<void> _saveEasyScholarKey() async {
    final key = _easyScholarController.text.trim();
    await ref.read(settingsRepositoryProvider).setEasyScholarKey(key);
    if (!mounted) return;
    _markCredentialsChanged();
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).save)));
    FocusScope.of(context).unfocus();
  }

  /// Manual update check from the Settings page.
  /// Unlike the silent startup check, failures are surfaced to the user.
  Future<void> _checkForUpdates() async {
    if (_isCheckingUpdate) return;
    setState(() => _isCheckingUpdate = true);
    try {
      final info = await PackageInfo.fromPlatform();
      final result = await ref
          .read(updateCheckServiceProvider)
          .checkForUpdate(info.version);
      if (!mounted) return;
      setState(() => _isCheckingUpdate = false);
      if (result.hasUpdate) {
        await showUpdateAvailableDialog(context, result);
      } else {
        await showUpToDateDialog(context, result);
      }
    } on UpdateCheckException catch (e) {
      if (!mounted) return;
      setState(() => _isCheckingUpdate = false);
      await showUpdateCheckFailedDialog(context, e);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCheckingUpdate = false);
      await showUpdateCheckFailedDialog(
        context,
        const UpdateCheckException(UpdateCheckFailureKind.network),
      );
    }
  }

  void _markCredentialsChanged() {
    final notifier = ref.read(credentialsRevisionProvider.notifier);
    notifier.state++;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final useDynamicColor = ref.watch(useDynamicColorProvider);
    final pageSize = ref.watch(pageSizeProvider);
    final locale = ref.watch(localeProvider);
    final translationChannel = ref.watch(translationChannelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // NCBI API Key
          _SectionTitle(title: l10n.apiKeyTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.apiKeyHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: 'NCBI API Key',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: _saveApiKey,
                      ),
                    ),
                    onSubmitted: (_) => _saveApiKey(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Translation channel
          _SectionTitle(title: l10n.translationChannelTitle),
          Card(
            child: RadioGroup<TranslationChannel>(
              groupValue: translationChannel,
              onChanged: (v) {
                if (v != null) {
                  ref.read(translationChannelProvider.notifier).setChannel(v);
                }
              },
              child: Column(
                children: [
                  RadioListTile<TranslationChannel>(
                    title: Text(l10n.translationChannelDeepl),
                    value: TranslationChannel.deepl,
                  ),
                  RadioListTile<TranslationChannel>(
                    title: Text(l10n.translationChannelOpenai),
                    value: TranslationChannel.openai,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // DeepL API Key (only when DeepL channel is selected)
          if (translationChannel == TranslationChannel.deepl) ...[
            _SectionTitle(title: l10n.deeplApiKeyTitle),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.deeplApiKeyHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _deeplApiController,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'DeepL API Key',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: _saveDeeplKey,
                        ),
                      ),
                      onSubmitted: (_) => _saveDeeplKey(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // OpenAI-compatible API (only when OpenAI channel is selected)
          if (translationChannel == TranslationChannel.openai) ...[
            _SectionTitle(title: l10n.openaiApiKeyTitle),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.openaiApiKeyHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Base URL
                    TextField(
                      controller: _openaiBaseUrlController,
                      onChanged: (_) => _clearModels(),
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: l10n.openaiBaseUrlTitle,
                        hintText: AppConstants.defaultOpenaiBaseUrl,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: _saveOpenaiBaseUrl,
                        ),
                      ),
                      onSubmitted: (_) => _saveOpenaiBaseUrl(),
                    ),
                    const SizedBox(height: 12),
                    // API Key
                    TextField(
                      controller: _openaiApiController,
                      onChanged: (_) => _clearModels(),
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: l10n.openaiApiKeyTitle,
                        hintText: 'sk-...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: _saveOpenaiKey,
                        ),
                      ),
                      onSubmitted: (_) => _saveOpenaiKey(),
                    ),
                    const SizedBox(height: 12),
                    // Model name + refresh
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Focus(
                            onFocusChange: (hasFocus) {
                              // Save a manually typed model name on blur.
                              if (!hasFocus) _saveOpenaiModel();
                            },
                            child: LayoutBuilder(
                              builder: (context, constraints) =>
                                  DropdownMenu<String>(
                                    width: constraints.maxWidth,
                                    controller: _openaiModelController,
                                    enableFilter: true,
                                    requestFocusOnTap: true,
                                    label: Text(l10n.openaiModelTitle),
                                    hintText: AppConstants.defaultOpenaiModel,
                                    dropdownMenuEntries: _models
                                        .map(
                                          (m) => DropdownMenuEntry(
                                            value: m,
                                            label: m,
                                          ),
                                        )
                                        .toList(),
                                    onSelected: (value) {
                                      if (value != null) {
                                        _openaiModelController.text = value;
                                        _saveOpenaiModel();
                                      }
                                    },
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _openaiBaseUrlController,
                            _openaiApiController,
                          ]),
                          builder: (context, _) {
                            final ready = _openaiApiController.text
                                .trim()
                                .isNotEmpty;
                            return IconButton(
                              tooltip: l10n.refreshModels,
                              onPressed: ready && !_isLoadingModels
                                  ? _loadModels
                                  : null,
                              icon: _isLoadingModels
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.refresh),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.openaiModelHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // easyScholar Key
          _SectionTitle(title: l10n.easyScholarTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.easyScholarHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _easyScholarController,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: 'easyScholar SecretKey',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: _saveEasyScholarKey,
                      ),
                    ),
                    onSubmitted: (_) => _saveEasyScholarKey(),
                  ),
                  if (ref
                          .watch(settingsRepositoryProvider)
                          .easyScholarKey
                          ?.isNotEmpty ==
                      true) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.journalMetricsToShow,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final metric in JournalMetric.values)
                          FilterChip(
                            label: Text(l10n.journalMetricLabel(metric)),
                            selected: ref
                                .watch(journalMetricsProvider)
                                .contains(metric),
                            onSelected: (_) => ref
                                .read(journalMetricsProvider.notifier)
                                .toggle(metric),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.journalMetricsHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.casRankingNotice,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Theme
          _SectionTitle(title: l10n.themeTitle),
          Card(
            child: RadioGroup<ThemeMode>(
              groupValue: themeMode,
              onChanged: (v) {
                if (v != null) {
                  Analytics.track(AnalyticsEvents.themeChanged, {
                    'mode': v.name,
                  });
                  ref.read(themeModeProvider.notifier).setThemeMode(v);
                }
              },
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.themeSystem),
                    value: ThemeMode.system,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.themeLight),
                    value: ThemeMode.light,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.themeDark),
                    value: ThemeMode.dark,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.useDynamicColor),
                    value: useDynamicColor,
                    onChanged: (v) {
                      ref
                          .read(useDynamicColorProvider.notifier)
                          .setUseDynamicColor(v);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Page Size
          _SectionTitle(title: l10n.pageSizeTitle),
          Card(
            child: RadioGroup<int>(
              groupValue: pageSize,
              onChanged: (v) {
                if (v != null) {
                  Analytics.track(AnalyticsEvents.pageSizeChanged, {'size': v});
                  ref.read(pageSizeProvider.notifier).setPageSize(v);
                }
              },
              child: Column(
                children: [
                  RadioListTile<int>(title: const Text('10'), value: 10),
                  RadioListTile<int>(title: const Text('20'), value: 20),
                  RadioListTile<int>(title: const Text('50'), value: 50),
                  RadioListTile<int>(title: const Text('100'), value: 100),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Language
          _SectionTitle(title: l10n.languageTitle),
          Card(
            child: RadioGroup<String>(
              groupValue: locale.languageCode,
              onChanged: (v) {
                final newLocale = v == 'zh'
                    ? const Locale('zh', 'CN')
                    : const Locale('en', 'GB');
                Analytics.track(AnalyticsEvents.localeChanged, {
                  'locale': newLocale.languageCode,
                });
                ref.read(localeProvider.notifier).setLocale(newLocale);
              },
              child: Column(
                children: [
                  RadioListTile<String>(title: const Text('简体中文'), value: 'zh'),
                  RadioListTile<String>(
                    title: const Text('English (UK)'),
                    value: 'en',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Reader Experience
          _SectionTitle(title: l10n.readerTitle),
          Card(
            child: SwitchListTile(
              title: Text(l10n.simplifyReader),
              subtitle: Text(l10n.simplifyReaderHint),
              value: ref.watch(simplifyPmcReaderProvider),
              onChanged: (v) {
                Analytics.track(AnalyticsEvents.simplifyReaderChanged, {
                  'enabled': v,
                });
                ref
                    .read(simplifyPmcReaderProvider.notifier)
                    .setSimplifyPmcReader(v);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Cache management
          _SectionTitle(title: l10n.cacheTitle),
          Card(
            child: Column(
              children: [
                FutureBuilder<(int, int, double, double)>(
                  future: _cacheStatsFuture,
                  builder: (context, snapshot) {
                    final articleCount = snapshot.data?.$1 ?? 0;
                    final pmcCount = snapshot.data?.$2 ?? 0;
                    final pmcMb = snapshot.data?.$3 ?? 0.0;
                    final totalMb = snapshot.data?.$4 ?? 0.0;
                    final isZh = locale.languageCode == 'zh';
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          _CacheStat(
                            icon: Icons.storage_rounded,
                            label: isZh ? '文献缓存' : 'Articles',
                            value: isZh ? '$articleCount 条' : '$articleCount',
                          ),
                          _CacheStat(
                            icon: Icons.article_outlined,
                            label: isZh ? 'PMC 全文' : 'PMC Full-text',
                            value: isZh
                                ? '$pmcCount 篇\n${pmcMb.toStringAsFixed(1)} MB'
                                : '$pmcCount articles\n${pmcMb.toStringAsFixed(1)} MB',
                          ),
                          _CacheStat(
                            icon: Icons.pie_chart_outline_rounded,
                            label: isZh ? '总占用' : 'Total',
                            value: '${totalMb.toStringAsFixed(1)} MB',
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.delete_sweep,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(l10n.clearCache),
                  onTap: () async {
                    final db = ref.read(databaseProvider);
                    await db.clearAllCache();
                    await db.clearAllPmcCache();
                    Analytics.track(AnalyticsEvents.cacheCleared);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.cacheCleared)),
                      );
                      setState(() => _cacheStatsFuture = _loadCacheStats());
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About
          _SectionTitle(title: l10n.about),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('PubMed'),
                  subtitle: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Unofficial Mobile App for PubMed'),
                      SizedBox(height: 2),
                      Text('Made with ❤️ by aoaim'),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.system_update_alt),
                  title: Text(l10n.checkForUpdates),
                  subtitle: Text(
                    l10n.currentVersion(
                      _appVersion.isEmpty ? '…' : _appVersion,
                    ),
                  ),
                  trailing: _isCheckingUpdate
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onTap: _isCheckingUpdate ? null : _checkForUpdates,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('GitHub'),
                  subtitle: const Text(
                    'https://github.com/aoaim/pubmed-mobile',
                  ),
                  onTap: () {
                    launchUrl(
                      Uri.parse('https://github.com/aoaim/pubmed-mobile'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.languageCode == 'zh'
                            ? '作为一名在读的免疫学博士研究生，致敬每一位在免疫学与生命科学领域默默耕耘、拓展人类认知边界的探索者。也再次感谢 PubMed 为这一切开源与可及所做出的卓越贡献。'
                            : 'As an immunology PhD candidate, I pay tribute to every explorer working silently in the fields of immunology and life sciences to expand the boundaries of human knowledge. I also thank PubMed for making all this open and accessible.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          locale.languageCode == 'zh'
                              ? '免责与版权声明'
                              : 'Disclaimer & Copyright',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                          children: locale.languageCode == 'zh'
                              ? const [
                                  TextSpan(text: '• 本应用为'),
                                  TextSpan(
                                    text: '非官方',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: '第三方研究工具，与美国国家生物技术信息中心 ('),
                                  TextSpan(
                                    text: 'NCBI',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: ') 或国家医学图书馆 ('),
                                  TextSpan(
                                    text: 'NLM',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: ') 无任何附属关系。\n• 应用中出现的所有 "'),
                                  TextSpan(
                                    text: 'PubMed',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '" 名称及相关标识归 NLM 或该注册商标的所有者拥有，本应用仅作合法合理使用或描述用途。\n• 本应用',
                                  ),
                                  TextSpan(
                                    text: '不提供任何医疗诊断和建议',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '，医疗决策请务必咨询专业医师。文献数据均源自 NCBI E-utilities 公开接口。\n• 应用代码基于 ',
                                  ),
                                  TextSpan(
                                    text: 'MIT 协议',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: '完全开源。'),
                                ]
                              : const [
                                  TextSpan(text: '• This is an '),
                                  TextSpan(
                                    text: 'unofficial',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' third-party research tool, not affiliated with, endorsed by, or officially connected to the ',
                                  ),
                                  TextSpan(
                                    text: 'NCBI',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: ' or the '),
                                  TextSpan(
                                    text: 'NLM',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: ' in any way.\n• All "'),
                                  TextSpan(
                                    text: 'PubMed',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '" names and associated logos appearing in this app are the intellectual property of NLM or their respective trademark holders. They are used here solely for descriptive and fair-use purposes.\n• This application does ',
                                  ),
                                  TextSpan(
                                    text: 'not provide any medical advice or diagnosis',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '. Always consult qualified healthcare professionals for medical decisions. Literature data is sourced from NCBI E-utilities public APIs.\n• This project is completely open source under the ',
                                  ),
                                  TextSpan(
                                    text: 'MIT License',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: '.'),
                                ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// A single stat column used in the cache management row.
class _CacheStat extends StatelessWidget {
  const _CacheStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
