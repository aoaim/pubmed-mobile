import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pubmed_mobile/core/l10n/app_localizations.dart';
import 'package:pubmed_mobile/core/database/app_database.dart';
import 'package:pubmed_mobile/features/settings/data/settings_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _deeplApiController;
  late TextEditingController _easyScholarController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsRepositoryProvider);
    _apiKeyController = TextEditingController(text: settings.apiKey ?? '');
    _deeplApiController = TextEditingController(text: settings.deeplApiKey ?? '');
    _easyScholarController = TextEditingController(text: settings.easyScholarKey ?? '');
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _deeplApiController.dispose();
    _easyScholarController.dispose();
    super.dispose();
  }

  void _saveApiKey() {
    final key = _apiKeyController.text.trim();
    ref.read(settingsRepositoryProvider).setApiKey(key);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).save)),
    );
    FocusScope.of(context).unfocus();
  }

  void _saveDeeplKey() {
    final key = _deeplApiController.text.trim();
    ref.read(settingsRepositoryProvider).setDeeplApiKey(key);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).save)),
    );
    FocusScope.of(context).unfocus();
  }

  void _saveEasyScholarKey() {
    final key = _easyScholarController.text.trim();
    ref.read(settingsRepositoryProvider).setEasyScholarKey(key);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).save)),
    );
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final useDynamicColor = ref.watch(useDynamicColorProvider);
    final pageSize = ref.watch(pageSizeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
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
                  Text(l10n.apiKeyHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKeyController,
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

          // DeepL API Key
          _SectionTitle(title: l10n.deeplApiKeyTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.deeplApiKeyHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _deeplApiController,
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

          // easyScholar Key
          _SectionTitle(title: l10n.easyScholarTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.easyScholarHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _easyScholarController,
                    decoration: InputDecoration(
                      hintText: 'easyScholar SecretKey',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: _saveEasyScholarKey,
                      ),
                    ),
                    onSubmitted: (_) => _saveEasyScholarKey(),
                  ),
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
                  if (v != null) ref.read(themeModeProvider.notifier).setThemeMode(v);
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
                      ref.read(useDynamicColorProvider.notifier).setUseDynamicColor(v);
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
                if (v != null) ref.read(pageSizeProvider.notifier).setPageSize(v);
              },
              child: Column(
                children: [
                  RadioListTile<int>(
                    title: const Text('10'),
                    value: 10,
                  ),
                  RadioListTile<int>(
                    title: const Text('20'),
                    value: 20,
                  ),
                  RadioListTile<int>(
                    title: const Text('50'),
                    value: 50,
                  ),
                  RadioListTile<int>(
                    title: const Text('100'),
                    value: 100,
                  ),
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
                ref.read(localeProvider.notifier).setLocale(newLocale);
              },
              child: Column(
                children: [
                   RadioListTile<String>(
                    title: const Text('简体中文'),
                    value: 'zh',
                  ),
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
                ref.read(simplifyPmcReaderProvider.notifier).setSimplifyPmcReader(v);
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
                  future: () async {
                    final db = ref.read(databaseProvider);
                    final articleCount = await db.getCacheCount();
                    final pmcCount = await db.getPmcCacheCount();
                    final pmcMb = await db.getPmcCacheSizeMb();
                    final totalMb = await db.getDatabaseFileSizeMb();
                    return (articleCount, pmcCount, pmcMb, totalMb);
                  }(),
                  builder: (context, snapshot) {
                    final articleCount = snapshot.data?.$1 ?? 0;
                    final pmcCount = snapshot.data?.$2 ?? 0;
                    final pmcMb = snapshot.data?.$3 ?? 0.0;
                    final totalMb = snapshot.data?.$4 ?? 0.0;
                    final isZh = locale.languageCode == 'zh';
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
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
                  leading: Icon(Icons.delete_sweep,
                      color: theme.colorScheme.error),
                  title: Text(l10n.clearCache),
                  onTap: () async {
                    final db = ref.read(databaseProvider);
                    await db.clearAllCache();
                    await db.clearAllPmcCache();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.cacheCleared)),
                      );
                      setState(() {});
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
                  subtitle: Text('Unofficial Mobile App for PubMed\n${l10n.version} 0.1.0'),
                  isThreeLine: true,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('GitHub'),
                  subtitle: const Text('https://github.com/aoaim/pubmed-mobile'),
                  onTap: () {
                    launchUrl(
                      Uri.parse('https://github.com/aoaim/pubmed-mobile'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.auto_awesome),
                  title: Text(locale.languageCode == 'zh'
                      ? '由 Claude Opus 4.6 & Gemini 3.1 Pro 生成'
                      : 'Generated by Claude Opus 4.6 & Gemini 3.1 Pro'),
                  subtitle: const Text('AI-Assisted Development'),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.5,
                          ),
                          children: locale.languageCode == 'zh' ? const [
                            TextSpan(text: '作为一名在读的免疫学博士研究生，致敬每一位在免疫学与生命科学领域默默耕耘、拓展人类认知边界的探索者。也再次感谢 '),
                            TextSpan(text: 'PubMed', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ' 为这一切开源与可及所做出的卓越贡献。\n\n'),
                            TextSpan(text: '此外，也要特别感谢当今卓越的 '),
                            TextSpan(text: 'AI 技术', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '的发展，让我得以通过自然语言的交互对话便完成了这个项目的全量架构与所有的代码编写，将设想变为了现实。'),
                          ] : const [
                            TextSpan(text: 'As an immunology PhD candidate, I pay tribute to every explorer working silently in the fields of immunology and life sciences to expand the boundaries of human knowledge. I also thank '),
                            TextSpan(text: 'PubMed', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ' again for making all this open and accessible.\n\n'),
                            TextSpan(text: 'Furthermore, a special thanks to the advancement of modern '),
                            TextSpan(text: 'AI technologies', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ', which empowered me to architect and write the entire codebase of this project simply through natural language interactions, turning vision into reality.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          locale.languageCode == 'zh' ? '免责与版权声明' : 'Disclaimer & Copyright',
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
                          children: locale.languageCode == 'zh' ? const [
                            TextSpan(text: '• 本应用为'),
                            TextSpan(text: '非官方', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '第三方研究工具，与美国国家生物技术信息中心 ('),
                            TextSpan(text: 'NCBI', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ') 或国家医学图书馆 ('),
                            TextSpan(text: 'NLM', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ') 无任何附属关系。\n• 应用中出现的所有 "'),
                            TextSpan(text: 'PubMed', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '" 名称及相关标识归 NLM 或该注册商标的所有者拥有，本应用仅作合法合理使用或描述用途。\n• 本应用'),
                            TextSpan(text: '不提供任何医疗诊断和建议', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '，医疗决策请务必咨询专业医师。文献数据均源自 NCBI E-utilities 公开接口。\n• 应用代码基于 '),
                            TextSpan(text: 'MIT 协议', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '完全开源。'),
                          ] : const [
                            TextSpan(text: '• This is an '),
                            TextSpan(text: 'unofficial', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ' third-party research tool, not affiliated with, endorsed by, or officially connected to the '),
                            TextSpan(text: 'NCBI', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ' or the '),
                            TextSpan(text: 'NLM', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ' in any way.\n• All "'),
                            TextSpan(text: 'PubMed', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '" names and associated logos appearing in this app are the intellectual property of NLM or their respective trademark holders. They are used here solely for descriptive and fair-use purposes.\n• This application does '),
                            TextSpan(text: 'not provide any medical advice or diagnosis', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '. Always consult qualified healthcare professionals for medical decisions. Literature data is sourced from NCBI E-utilities public APIs.\n• This project is completely open source under the '),
                            TextSpan(text: 'MIT License', style: TextStyle(fontWeight: FontWeight.bold)),
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
