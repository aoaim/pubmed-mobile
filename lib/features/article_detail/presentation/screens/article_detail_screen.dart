import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pubmed_mobile/core/l10n/app_localizations.dart';
import 'package:pubmed_mobile/core/database/app_database.dart';
import 'package:pubmed_mobile/core/analytics/analytics.dart';
import 'package:pubmed_mobile/features/search/data/repositories/article_repository.dart';
import 'package:pubmed_mobile/features/search/domain/entities/article.dart';
import 'package:pubmed_mobile/features/article_detail/data/services/translation_service.dart';
import 'package:pubmed_mobile/features/article_detail/domain/translation_failure.dart';
import 'package:pubmed_mobile/features/article_detail/domain/journal_metric.dart';
import 'package:pubmed_mobile/features/article_detail/data/services/easyscholar_service.dart';
import 'package:pubmed_mobile/features/settings/data/settings_repository.dart';
import 'package:drift/drift.dart' hide Column;

import 'dart:convert';

/// Provider for favorite status.
final isFavoriteProvider = FutureProvider.family<bool, int>((ref, pmid) async {
  return ref.read(databaseProvider).isFavorite(pmid);
});

class ArticleDetailScreen extends ConsumerStatefulWidget {
  const ArticleDetailScreen({super.key, required this.pmid});

  final int pmid;

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  Article? _article;
  bool _isOffline = true; // Start assuming offline data
  bool _isRefreshing = false;
  String? _error;

  // Translation state
  bool _isTranslating = false;
  bool _isTranslated = false;
  bool _showTranslated = false;
  String? _translatedTitle;
  String? _translatedAbstract;

  // Journal ranking state
  JournalRanking? _journalRanking;
  bool _isLoadingRanking = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Fetch journal ranking from easyScholar (if configured).
  Future<void> _loadJournalRanking(String journal) async {
    final service = ref.read(easyScholarServiceProvider);
    if (!service.isConfigured || journal.isEmpty) return;
    setState(() => _isLoadingRanking = true);
    try {
      final ranking = await service.getJournalRanking(journal);
      if (mounted) {
        setState(() {
          _journalRanking = ranking;
          _isLoadingRanking = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingRanking = false);
    }
  }

  void _toggleTranslation() {
    if (_isTranslating) return;
    if (_isTranslated) {
      // Toggle between translated and original
      setState(() => _showTranslated = !_showTranslated);
      return;
    }
    // Not translated yet — trigger translation
    _translateArticle();
  }

  Future<void> _translateArticle() async {
    if (_article == null || _isTranslating || _isTranslated) return;

    Analytics.track(AnalyticsEvents.translationRequested, {
      'pmid': widget.pmid,
      'provider': ref.read(translationServiceProvider).activeProvider.name,
    });

    setState(() => _isTranslating = true);
    try {
      final service = ref.read(translationServiceProvider);

      if (_article!.title.isNotEmpty && _translatedTitle == null) {
        final title = await service.translate(_article!.title);
        if (!mounted) return;
        setState(() {
          _translatedTitle = title;
          _showTranslated = true;
        });
        await ref
            .read(articleRepositoryProvider)
            .updateArticleTranslation(widget.pmid, translatedTitle: title);
      }

      if (_article!.abstract_.isNotEmpty && _translatedAbstract == null) {
        final abs = await service.translate(_article!.abstract_);
        if (!mounted) return;
        setState(() {
          _translatedAbstract = abs;
          _showTranslated = true;
        });
        await ref
            .read(articleRepositoryProvider)
            .updateArticleTranslation(widget.pmid, translatedAbstract: abs);
      }

      if (mounted) {
        setState(() {
          _isTranslated = true;
          _isTranslating = false;
        });

        Analytics.track(AnalyticsEvents.translationCompleted, {
          'pmid': widget.pmid,
          'provider': ref.read(translationServiceProvider).activeProvider.name,
        });
      }
    } on TranslationFailure catch (failure) {
      Analytics.track(AnalyticsEvents.translationFailed, {
        'pmid': widget.pmid,
        'provider': ref.read(translationServiceProvider).activeProvider.name,
        'kind': failure.kind.name,
      });
      if (mounted) {
        setState(() => _isTranslating = false);
        _showTranslationError(failure);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isTranslating = false);
      _showTranslationError(
        TranslationFailure(
          TranslationFailureKind.unknown,
          provider: ref.read(translationServiceProvider).activeProvider,
          stage: TranslationStage.translation,
        ),
      );
    }
  }

  void _showTranslationError(TranslationFailure failure) {
    final l10n = AppLocalizations.of(context);
    final provider = switch (failure.provider) {
      TranslationProvider.deeplFree => 'DeepL Free API',
      TranslationProvider.deeplPro => 'DeepL Pro API',
      TranslationProvider.openai => 'OpenAI Compatible',
    };
    final endpoint = switch (failure.provider) {
      TranslationProvider.deeplFree => 'api-free.deepl.com/v2/translate',
      TranslationProvider.deeplPro => 'api.deepl.com/v2/translate',
      TranslationProvider.openai =>
        '${ref.read(settingsRepositoryProvider).openaiBaseUrl}/chat/completions',
    };
    final reason = switch (failure.kind) {
      TranslationFailureKind.invalidApiKey => l10n.translationInvalidApiKey,
      TranslationFailureKind.network => switch (failure.networkType) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => l10n.translationTimeout,
        DioExceptionType.badCertificate => l10n.translationCertificateFailed,
        _ => l10n.translationConnectionFailed,
      },
      TranslationFailureKind.quotaExceeded => l10n.translationQuotaExceeded,
      TranslationFailureKind.rateLimited => l10n.translationRateLimited,
      TranslationFailureKind.serviceUnavailable =>
        l10n.translationServiceUnavailable,
      TranslationFailureKind.requestRejected => switch (failure.statusCode) {
        400 => l10n.translationBadRequest,
        404 => l10n.translationEndpointMissing,
        _ => l10n.translationRequestRejected,
      },
      TranslationFailureKind.invalidResponse => l10n.translationInvalidResponse,
      TranslationFailureKind.noProviderConfigured => l10n.translationNoProvider,
      TranslationFailureKind.unknown => l10n.translationUnknownReason,
    };
    final suggestion = switch (failure.kind) {
      TranslationFailureKind.invalidApiKey => l10n.translationCheckKey,
      TranslationFailureKind.quotaExceeded => l10n.translationCheckQuota,
      TranslationFailureKind.network ||
      TranslationFailureKind.rateLimited => l10n.translationTryLater,
      TranslationFailureKind.serviceUnavailable => l10n.translationCheckService,
      TranslationFailureKind.noProviderConfigured => l10n.translationCheckKey,
      _ => l10n.translationCheckResponse,
    };

    Widget detail(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          SelectableText(value),
        ],
      ),
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.translationError),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              detail(l10n.translationInterface, '$provider\n$endpoint'),
              detail(l10n.translationReason, reason),
              if (failure.statusCode != null)
                detail(l10n.translationHttpStatus, '${failure.statusCode}'),
              detail(l10n.translationSuggestion, suggestion),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.translationClose),
          ),
        ],
      ),
    );
  }

  Future<void> _loadData() async {
    Analytics.track(AnalyticsEvents.articleOpened, {'pmid': widget.pmid});

    final db = ref.read(databaseProvider);
    final repo = ref.read(articleRepositoryProvider);

    // Step 1: Try loading from cache immediately
    final cached = await db.getCachedArticle(widget.pmid);
    if (!mounted) return;
    if (cached != null) {
      setState(() {
        _article = _cachedToArticle(cached);
        _isOffline = true;

        if ((_article!.translatedTitle?.isNotEmpty ?? false) ||
            (_article!.translatedAbstract?.isNotEmpty ?? false)) {
          _translatedTitle = _article!.translatedTitle?.isNotEmpty == true
              ? _article!.translatedTitle
              : null;
          _translatedAbstract = _article!.translatedAbstract?.isNotEmpty == true
              ? _article!.translatedAbstract
              : null;
          _isTranslated =
              (_article!.title.isEmpty || _translatedTitle != null) &&
              (_article!.abstract_.isEmpty || _translatedAbstract != null);
          _showTranslated = true;
        }
      });

      // Load journal ranking
      _loadJournalRanking(_article!.journal);
    }

    // Step 2: Fetch fresh data from network in background
    setState(() => _isRefreshing = true);
    try {
      final fresh = await repo.getArticleDetail(
        widget.pmid,
        forceRefresh: true,
      );
      if (mounted) {
        setState(() {
          _article = fresh;
          _isOffline = false;
          _isRefreshing = false;
          _error = null;
        });
        // Load journal ranking if not already loaded
        if (_journalRanking == null && !_isLoadingRanking) {
          _loadJournalRanking(fresh.journal);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          // If we have cached data, just note the error silently
          if (_article == null) {
            _error = e.toString();
          }
        });
      }
    }
  }

  Article _cachedToArticle(CachedArticle cached) {
    List<String> authors = [];
    try {
      authors = (jsonDecode(cached.authors) as List).cast<String>();
    } catch (_) {
      if (cached.authors.isNotEmpty) {
        authors = cached.authors.split(', ');
      }
    }
    List<String> meshTerms = [];
    try {
      meshTerms = (jsonDecode(cached.meshTerms) as List).cast<String>();
    } catch (_) {}

    return Article(
      pmid: cached.pmid,
      title: cached.title,
      authors: authors,
      affiliations: (jsonDecode(cached.affiliations) as List).cast<String>(),
      journal: cached.journal,
      pubDate: cached.pubDate,
      doi: cached.doi,
      pmcid: cached.pmcid,
      abstract_: cached.abstract_,
      translatedTitle: cached.translatedTitle,
      translatedAbstract: cached.translatedAbstract,
      meshTerms: meshTerms,
      hasFullDetail: cached.hasFullDetail,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (_article == null && _error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(l10n.error, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_article == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar — use regular SliverAppBar to avoid title overlap
          SliverAppBar(
            pinned: true,
            title: Text(
              _article!.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                icon: _isTranslating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _showTranslated ? Icons.translate : Icons.translate,
                        color: _showTranslated
                            ? theme.colorScheme.primary
                            : null,
                      ),
                tooltip: _showTranslated
                    ? (Localizations.localeOf(context).languageCode == 'zh'
                          ? '显示原文'
                          : 'Show original')
                    : l10n.translate,
                onPressed: _isTranslating ? null : _toggleTranslation,
              ),
              IconButton(
                icon: const Icon(Icons.content_copy_outlined),
                tooltip: Localizations.localeOf(context).languageCode == 'zh'
                    ? '复制标题'
                    : 'Copy title',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _article!.title));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(l10n.copied)));
                },
              ),
              _FavoriteButton(pmid: widget.pmid, article: _article!),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  Analytics.track(AnalyticsEvents.articleShared, {
                    'pmid': widget.pmid,
                  });
                  SharePlus.instance.share(
                    ShareParams(
                      text: '${_article!.title}\n${_article!.pubmedUrl}',
                    ),
                  );
                },
              ),
            ],
          ),

          // Offline/Online status banner
          SliverToBoxAdapter(child: _buildDataSourceBanner(context, l10n)),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _buildDetailContent(context, _article!, l10n),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourceBanner(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isZh = Localizations.localeOf(context).languageCode == 'zh';

    if (_isRefreshing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        child: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isZh ? '正在获取最新数据…' : 'Fetching latest data…',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      );
    }

    if (_isOffline) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
        child: Row(
          children: [
            Icon(
              Icons.offline_bolt,
              size: 16,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isZh ? '当前显示离线缓存数据' : 'Showing offline cached data',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: _loadData,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(isZh ? '刷新' : 'Refresh'),
            ),
          ],
        ),
      );
    }

    // Online data loaded successfully
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Row(
        children: [
          Icon(
            Icons.cloud_done_outlined,
            size: 14,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            isZh ? '已加载最新数据' : 'Latest data loaded',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDetailContent(
    BuildContext context,
    Article article,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    return [
      // Title (Translated and Original)
      if (_translatedTitle != null && _showTranslated) ...[
        Text(
          _translatedTitle!,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          article.title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ] else ...[
        Text(
          article.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
      const SizedBox(height: 16),

      // Full text buttons
      // 1) DOI link
      if (article.doi != null) ...[
        OutlinedButton.icon(
          onPressed: () {
            Analytics.track(AnalyticsEvents.externalLinkOpened, {
              'type': 'doi',
              'pmid': widget.pmid,
            });
            launchUrl(
              Uri.parse(article.doiUrl),
              mode: LaunchMode.externalApplication,
            );
          },
          icon: const Icon(Icons.open_in_new),
          label: Text(isZh ? '在期刊查看全文' : 'View at Journal'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
        const SizedBox(height: 8),
      ],
      // 2) PMC link
      if (article.hasFullText) ...[
        FilledButton.icon(
          onPressed: () {
            Analytics.track(AnalyticsEvents.externalLinkOpened, {
              'type': 'pmc',
              'pmcid': article.pmcid ?? '',
            });
            context.push('/reader/${article.pmcid}');
          },
          icon: const Icon(Icons.article),
          label: Text(isZh ? '在 PMC 阅读全文' : 'Read on PMC'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
        const SizedBox(height: 16),
      ] else if (article.doi != null) ...[
        const SizedBox(height: 8),
      ],

      // Meta info chips
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (article.hasFullText)
            Chip(
              avatar: const Icon(Icons.lock_open, size: 16),
              label: Text(l10n.pmcFullText),
              backgroundColor: theme.colorScheme.tertiaryContainer,
            ),
          ActionChip(
            label: Text('PMID: ${widget.pmid}'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.pmid.toString()));
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l10n.copied)));
            },
          ),
          if (article.doi != null)
            ActionChip(
              label: Text('DOI: ${article.doi}'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: article.doi!));
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(l10n.copied)));
              },
            ),
          Chip(label: Text(article.pubDate)),
        ],
      ),
      const SizedBox(height: 16),

      // Journal
      Text(
        article.journal,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Journal Ranking (easyScholar)
      if (_journalRanking != null &&
          _journalRanking!.hasData &&
          ref
              .watch(journalMetricsProvider)
              .any((metric) => _journalRanking!.valueFor(metric) != null)) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final metric in JournalMetric.values)
              if (ref.watch(journalMetricsProvider).contains(metric) &&
                  _journalRanking!.valueFor(metric) != null)
                _RankingChip(
                  label:
                      '${l10n.journalMetricLabel(metric)} ${_journalRanking!.valueFor(metric)}',
                  color: metric.isCas
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.primary,
                ),
          ],
        ),
        if (ref
            .watch(journalMetricsProvider)
            .any(
              (metric) =>
                  metric.isCas && _journalRanking!.valueFor(metric) != null,
            )) ...[
          const SizedBox(height: 6),
          Text(
            l10n.casRankingNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
      const SizedBox(height: 16),

      // Authors
      if (article.authors.isNotEmpty) ...[
        Text(
          l10n.authors,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(article.authors.join(', '), style: theme.textTheme.bodyMedium),
        const SizedBox(height: 20),
      ],

      if (article.affiliations.isNotEmpty) ...[
        Text(
          l10n.affiliations,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SelectableText(
          article.affiliations.join('\n\n'),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
      ],

      // Abstract (Translated and Original)
      if (article.abstract_.isNotEmpty) ...[
        Text(
          l10n.abstract_,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (_translatedAbstract != null && _showTranslated) ...[
          SelectableText(
            _translatedAbstract!,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 16),
          SelectableText(
            article.abstract_,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ] else ...[
          SelectableText(
            article.abstract_,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
        const SizedBox(height: 20),
      ],

      // MeSH terms
      if (article.meshTerms.isNotEmpty) ...[
        Text(
          l10n.meshTerms,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: article.meshTerms
              .map(
                (t) => Chip(
                  label: Text(t),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
      ],

      const SizedBox(height: 40),
    ];
  }
}

class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.pmid, required this.article});

  final int pmid;
  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isFavAsync = ref.watch(isFavoriteProvider(pmid));

    return isFavAsync.when(
      loading: () =>
          const IconButton(onPressed: null, icon: Icon(Icons.bookmark_border)),
      error: (e, st) =>
          const IconButton(onPressed: null, icon: Icon(Icons.bookmark_border)),
      data: (isFav) => IconButton(
        icon: Icon(isFav ? Icons.bookmark : Icons.bookmark_border),
        onPressed: () async {
          final db = ref.read(databaseProvider);
          final messenger = ScaffoldMessenger.of(context);
          if (isFav) {
            await db.removeFavorite(pmid);
            Analytics.track(AnalyticsEvents.favoriteRemoved, {'pmid': pmid});
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.favoriteRemoved)),
            );
          } else {
            await db.addFavorite(
              FavoritesCompanion(
                pmid: Value(pmid),
                title: Value(article.title),
                authors: Value(article.authors.join(', ')),
                journal: Value(article.journal),
                pubDate: Value(article.pubDate),
                doi: Value(article.doi),
                pmcid: Value(article.pmcid),
                addedAt: Value(DateTime.now()),
              ),
            );
            Analytics.track(AnalyticsEvents.favoriteAdded, {'pmid': pmid});
            messenger.showSnackBar(SnackBar(content: Text(l10n.favoriteAdded)));
          }
          ref.invalidate(isFavoriteProvider(pmid));
        },
      ),
    );
  }
}

/// Small colored chip for journal ranking display.
class _RankingChip extends StatelessWidget {
  const _RankingChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
