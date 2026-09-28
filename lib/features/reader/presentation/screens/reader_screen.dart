import 'dart:convert';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pubmed_mobile/core/l10n/app_localizations.dart';
import 'package:pubmed_mobile/core/analytics/analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pubmed_mobile/features/settings/data/settings_repository.dart';
import 'package:pubmed_mobile/core/database/app_database.dart';
import 'package:pubmed_mobile/features/reader/domain/pmc_page.dart';
import 'package:pubmed_mobile/features/article_detail/data/services/translation_service.dart';
import 'package:pubmed_mobile/features/article_detail/domain/translation_failure.dart';

/// PMC full-text reader using InAppWebView.
///
/// Cache policy (PMC HTML):
///   - On open: check [PmcFullTextCache] in SQLite first.
///     If found, load the stored HTML locally (no network).
///     If not found, load the live URL, then cache the result.
///   - Manual refresh (↺ button): clears the DB row for this PMCID, then
///     re-fetches from network and caches the new version.
///   - No automatic expiry; the oldest entries are evicted when the configured
///     cache size limit is exceeded.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.pmcid});

  final String pmcid;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  double _progress = 0;
  bool _hasError = false;
  InAppWebViewController? _controller;
  late final FindInteractionController _findController;

  // Immersive: AppBar visibility
  bool _appBarVisible = true;

  // Hysteresis for scroll-up detection
  double _scrollUpAccum = 0;
  static const double _hideThreshold = 80; // px down to hide
  static const double _showThreshold = 40; // px up to show

  // TOC buttons (only active in simplify mode)
  bool _showTocFabs = false;

  // Whether we are currently fetching from DB
  bool _isCheckingCache = true;
  String? _cachedHtml;
  bool _loadedFromCache = false;
  bool _didCacheCurrentPage = false;
  int _webViewGeneration = 0;
  bool _readerTranslationEnabled = false;
  bool _isTranslatingParagraph = false;
  bool _readerWaitingHintShown = false;
  Timer? _translationDebounce;
  CancelToken? _paragraphCancelToken;
  int _translationRevision = 0;
  final Map<String, String> _paragraphTranslations = {};

  String get _url => PmcPage.canonicalUrl(widget.pmcid);

  AppDatabase get _db => ref.read(databaseProvider);

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _findController = FindInteractionController();
    _checkCache();
  }

  @override
  void dispose() {
    _cancelParagraphTranslation(refresh: false);
    super.dispose();
  }

  void _cancelParagraphTranslation({bool refresh = true}) {
    _translationRevision++;
    _translationDebounce?.cancel();
    _paragraphCancelToken?.cancel('Paragraph left the viewport');
    _paragraphCancelToken = null;
    if (_isTranslatingParagraph) {
      _isTranslatingParagraph = false;
      if (refresh && mounted) setState(() {});
    }
  }

  void _scheduleVisibleTranslation() {
    if (!_readerTranslationEnabled || !_showTocFabs) return;
    _cancelParagraphTranslation();
    final revision = _translationRevision;
    _translationDebounce = Timer(const Duration(milliseconds: 650), () {
      _translateVisibleParagraphs(revision);
    });
  }

  Future<void> _toggleReaderTranslation() async {
    final settings = ref.read(settingsRepositoryProvider);
    if (!_readerTranslationEnabled) {
      final hasKey = settings.translationChannel == TranslationChannel.deepl
          ? settings.deeplApiKey?.isNotEmpty == true
          : settings.openaiApiKey?.isNotEmpty == true;
      if (!hasKey) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translationNoProvider),
          ),
        );
        return;
      }
    }
    _cancelParagraphTranslation();
    setState(() => _readerTranslationEnabled = !_readerTranslationEnabled);
    final ctrl = _controller;
    if (ctrl == null) return;
    if (_readerTranslationEnabled) {
      await ctrl.evaluateJavascript(source: _readerTranslationSetupJs);
      if (mounted) _scheduleVisibleTranslation();
    } else {
      _readerWaitingHintShown = false;
      await ctrl.evaluateJavascript(source: _readerTranslationClearJs);
    }
  }

  Future<bool> _isParagraphVisible(
    InAppWebViewController ctrl,
    String id,
  ) async {
    final raw = await ctrl.evaluateJavascript(
      source:
          '''
      (function() {
        var p = document.querySelector('[data-pubmed-translate-id="' + ${jsonEncode(id)} + '"]');
        if (!p) return false;
        var r = p.getBoundingClientRect();
        return r.bottom > 0 && r.top < window.innerHeight;
      })();
    ''',
    );
    return raw == true || raw?.toString() == 'true';
  }

  Future<void> _translateVisibleParagraphs(int revision) async {
    final ctrl = _controller;
    if (ctrl == null ||
        !mounted ||
        !_readerTranslationEnabled ||
        revision != _translationRevision) {
      return;
    }
    try {
      final raw = await ctrl.evaluateJavascript(
        source: _readerVisibleParagraphsJs,
      );
      if (!mounted || revision != _translationRevision) return;
      final json = _normalizeEvaluatedHtml(raw);
      final paragraphs = (jsonDecode(json ?? '[]') as List)
          .cast<Map<String, dynamic>>();
      if (paragraphs.isEmpty && !_readerWaitingHintShown) {
        _readerWaitingHintShown = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).readerTranslationWaiting,
            ),
          ),
        );
      }
      for (final paragraph in paragraphs) {
        if (!mounted ||
            revision != _translationRevision ||
            !_readerTranslationEnabled) {
          return;
        }
        final id = paragraph['id'] as String?;
        final source = paragraph['text'] as String?;
        if (id == null || source == null || source.isEmpty) continue;
        if (!await _isParagraphVisible(ctrl, id)) continue;
        if (revision != _translationRevision) return;
        var translated = _paragraphTranslations[source];
        if (translated == null) {
          final token = CancelToken();
          _paragraphCancelToken = token;
          setState(() => _isTranslatingParagraph = true);
          translated = await ref
              .read(translationServiceProvider)
              .translate(source, cancelToken: token);
          if (!mounted ||
              revision != _translationRevision ||
              token.isCancelled) {
            return;
          }
          _paragraphTranslations[source] = translated;
          _paragraphCancelToken = null;
          setState(() => _isTranslatingParagraph = false);
        }
        if (!await _isParagraphVisible(ctrl, id)) continue;
        if (revision != _translationRevision) return;
        await ctrl.evaluateJavascript(
          source:
              '''
          (function() {
            var p = document.querySelector('[data-pubmed-translate-id="' + ${jsonEncode(id)} + '"]');
            if (!p) return;
            var next = p.nextElementSibling;
            if (next && next.dataset.pubmedTranslationFor === ${jsonEncode(id)}) return;
            var translation = document.createElement('p');
            translation.className = p.className;
            translation.style.cssText = p.style.cssText;
            translation.dataset.pubmedTranslationFor = ${jsonEncode(id)};
            translation.lang = 'zh-CN';
            translation.textContent = ${jsonEncode(translated)};
            p.insertAdjacentElement('afterend', translation);
          })();
        ''',
        );
      }
    } on DioException catch (error) {
      if (error.type != DioExceptionType.cancel) _showReaderTranslationError();
    } on TranslationFailure catch (failure) {
      debugPrint('Reader translation failed: ${failure.kind.name}');
      _showReaderTranslationError(failure);
    } catch (error) {
      debugPrint('Reader translation failed: $error');
      _showReaderTranslationError();
    } finally {
      if (revision == _translationRevision) {
        _paragraphCancelToken = null;
        if (_isTranslatingParagraph && mounted) {
          setState(() => _isTranslatingParagraph = false);
        }
      }
    }
  }

  void _showReaderTranslationError([TranslationFailure? failure]) {
    if (!mounted || !_readerTranslationEnabled) return;
    final l10n = AppLocalizations.of(context);
    final reason = switch (failure?.kind) {
      TranslationFailureKind.invalidApiKey => l10n.translationInvalidApiKey,
      TranslationFailureKind.quotaExceeded => l10n.translationQuotaExceeded,
      TranslationFailureKind.rateLimited => l10n.translationRateLimited,
      TranslationFailureKind.network => l10n.translationNetworkError,
      TranslationFailureKind.serviceUnavailable =>
        l10n.translationServiceUnavailable,
      TranslationFailureKind.invalidResponse => l10n.translationInvalidResponse,
      TranslationFailureKind.noProviderConfigured => l10n.translationNoProvider,
      _ => l10n.translationError,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(reason)));
  }

  Future<void> _checkCache() async {
    Analytics.track(AnalyticsEvents.readerOpened, {'pmcid': widget.pmcid});

    final cached = await ref.read(databaseProvider).getPmcHtml(widget.pmcid);
    var cachedHtml = cached?.html;

    if (cachedHtml != null && !PmcPage.isReadableArticle(cachedHtml)) {
      await _db.deletePmcHtml(widget.pmcid);
      cachedHtml = null;
    }

    // Fetch the document with Dart before handing it to WebView. Loading the
    // public PMC URL directly can leave an empty surface when an Android
    // System WebView renderer crashes during network-page initialization.
    // Supplying verified HTML as initialData also lets us reject browser-check
    // pages before they reach the reader.
    if (cachedHtml == null) {
      try {
        final response = await Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            responseType: ResponseType.plain,
            headers: const {
              'User-Agent':
                  'PubMedMobile/0.1 (+https://github.com/aoaim/pubmed-mobile)',
            },
          ),
        ).get<String>(_url);
        final downloadedHtml = response.data;
        if (downloadedHtml != null &&
            PmcPage.isReadableArticle(downloadedHtml)) {
          cachedHtml = downloadedHtml;
          await _storePmcHtml(downloadedHtml);
        }
      } catch (error) {
        debugPrint('PMC HTML download failed for ${widget.pmcid}: $error');
      }
    }

    if (mounted) {
      setState(() {
        _cachedHtml = cachedHtml;
        _loadedFromCache = cachedHtml != null;
        _isCheckingCache = false;
      });
    }
  }

  // ── AppBar animation ─────────────────────────────────────────────────────────

  void _setAppBarVisible(bool visible) {
    if (visible == _appBarVisible) return;
    setState(() => _appBarVisible = visible);
  }

  // ── Cache helpers ────────────────────────────────────────────────────────────

  String? _normalizeEvaluatedHtml(dynamic raw) {
    if (raw == null) return null;

    if (raw is String) {
      final text = raw.trim();
      if (text.isEmpty || text == 'null') return null;

      // Some WebView versions return a JSON-encoded string for JS results.
      if ((text.startsWith('"') && text.endsWith('"')) ||
          (text.startsWith("'") && text.endsWith("'"))) {
        try {
          final decoded = jsonDecode(text);
          if (decoded is String) {
            final decodedText = decoded.trim();
            if (decodedText.isNotEmpty) return decodedText;
          }
        } catch (_) {
          // Fall back to raw string.
        }
      }

      return text;
    }

    final text = raw.toString().trim();
    if (text.isEmpty || text == 'null') return null;
    return text;
  }

  Future<void> _storePmcHtml(String html) async {
    await _db.upsertPmcHtml(widget.pmcid, html);
    final maxSizeMb = ref.read(settingsRepositoryProvider).maxCacheMB;
    await _db.trimPmcCacheToSizeMb(maxSizeMb);
  }

  /// Capture outerHTML and save to DB (called after live network load).
  Future<bool> _saveCacheFromPage(InAppWebViewController ctrl) async {
    String? bestHtml;

    void collectBest(String? candidate) {
      if (candidate == null) return;
      final normalized = candidate.trim();
      if (normalized.isEmpty || normalized == 'null') return;
      if (bestHtml == null || normalized.length > bestHtml!.length) {
        bestHtml = normalized;
      }
    }

    try {
      for (var i = 0; i < 8; i++) {
        final htmlFromApi = await ctrl.getHtml();
        collectBest(htmlFromApi);
        if (htmlFromApi != null && PmcPage.isReadableArticle(htmlFromApi)) {
          await _storePmcHtml(htmlFromApi);
          return true;
        }

        final raw = await ctrl.evaluateJavascript(
          source: '''
          (function() {
            var clone = document.documentElement.cloneNode(true);
            var scripts = clone.querySelectorAll('script');
            for (var i = 0; i < scripts.length; i++) {
              if (scripts[i].parentNode) {
                scripts[i].parentNode.removeChild(scripts[i]);
              }
            }
            return '<!DOCTYPE html>\\n' + clone.outerHTML;
          })();
        ''',
        );

        final html = _normalizeEvaluatedHtml(raw);
        collectBest(html);
        if (html != null && PmcPage.isReadableArticle(html)) {
          await _storePmcHtml(html);
          return true;
        }

        await Future.delayed(const Duration(milliseconds: 250));
      }
    } catch (e) {
      debugPrint('PMC cache save failed for ${widget.pmcid}: $e');
    }

    if (bestHtml != null && PmcPage.isReadableArticle(bestHtml!)) {
      await _storePmcHtml(bestHtml!);
      return true;
    }

    return false;
  }

  // ── JS snippets ──────────────────────────────────────────────────────────────

  static const String _readerTranslationSetupJs = r"""
  (function() {
    document.querySelectorAll('.pmc-article-section section.abstract p, .pmc-article-section .main-article-body p').forEach(function(p, index) {
      if (p.hasAttribute('data-pubmed-translation-for')) return;
      if (!p.dataset.pubmedTranslateId) p.dataset.pubmedTranslateId = String(index);
      if (p.__pubmedOriginalText === undefined) p.__pubmedOriginalText = p.textContent.replace(/\s+/g, ' ').trim();
    });
  })();
  """;

  static const String _readerVisibleParagraphsJs = r"""
  (function() {
    var visible = [];
    document.querySelectorAll('[data-pubmed-translate-id]').forEach(function(p) {
      var next = p.nextElementSibling;
      if (next && next.dataset.pubmedTranslationFor === p.dataset.pubmedTranslateId) return;
      var r = p.getBoundingClientRect();
      if (r.bottom <= 0 || r.top >= window.innerHeight) return;
      var text = p.__pubmedOriginalText || p.textContent.replace(/\s+/g, ' ').trim();
      if (text) visible.push({id: p.dataset.pubmedTranslateId, text: text});
    });
    return JSON.stringify(visible);
  })();
  """;

  static const String _readerTranslationClearJs = r"""
  document.querySelectorAll('[data-pubmed-translation-for]').forEach(function(p) { p.remove(); });
  """;

  static const String _immersiveJs = r"""
  (function() {
    var article = document.querySelector('.pmc-article-section');
    if (!article) return;

    var parent = article.parentNode;
    parent.removeChild(article);
    document.body.innerHTML = '';

    article.style.cssText += ';padding:0;margin:0;max-width:100%;width:100%;';

    var actionsBar = article.querySelector('.pmc-actions-bar');
    if (actionsBar) actionsBar.style.display = 'none';

    // Hide disclaimer box
    var disclaimer = article.querySelector('.pmc-layout__disclaimer');
    if (disclaimer) disclaimer.style.display = 'none';

    document.body.appendChild(article);

    // Scroll-direction detector
    var lastY = 0;
    var ticking = false;
    window.addEventListener('scroll', function() {
      if (!ticking) {
        window.requestAnimationFrame(function() {
          var y = window.scrollY;
          var dir = y > lastY ? 'down' : 'up';
          lastY = y;
          ticking = false;
          try {
            window.flutter_inappwebview.callHandler('onScroll', dir, y);
          } catch(e) {}
        });
        ticking = true;
      }
    }, {passive: true});
  })();
  """;

  static const String _scrollListenerJs = r"""
  (function() {
    var lastY = 0;
    var ticking = false;
    window.addEventListener('scroll', function() {
      if (!ticking) {
        window.requestAnimationFrame(function() {
          var y = window.scrollY;
          var dir = y > lastY ? 'down' : 'up';
          lastY = y;
          ticking = false;
          try {
            window.flutter_inappwebview.callHandler('onScroll', dir, y);
          } catch(e) {}
        });
        ticking = true;
      }
    }, {passive: true});
  })();
  """;

  static const String _disableLinksJs = r"""
  (function() {
    if (window.__pubmedLinkBlockInstalled) return;
    window.__pubmedLinkBlockInstalled = true;
    document.addEventListener('click', function(e) {
      var a = e.target.closest('a');
      if (a) {
        e.preventDefault();
        e.stopPropagation();
      }
    }, true);
  })();
  """;

  static const String _tocJs = r"""
  (function() {
    var results = [];
    // Collect h2 and h3 from the main article body
    var elements = document.querySelectorAll(
      '.pmc-article-section section.abstract h2, ' +
      '.pmc-article-section h2.pmc_sec_title, ' +
      '.pmc-article-section h3.pmc_sec_title'
    );
    elements.forEach(function(el) {
      var text = el.textContent.trim();
      if (!text) return;
      var level = el.tagName === 'H2' ? 2 : 3;
      var sec = el.closest('section');
      results.push({id: sec ? (sec.id || '') : '', text: text, level: level});
    });
    return JSON.stringify(results);
  })();
  """;

  static const String _darkModeJs = r"""
  (function() {
    if (document.getElementById('pubmed-mobile-dark-mode')) return;
    var style = document.createElement('style');
    style.id = 'pubmed-mobile-dark-mode';
    style.innerHTML = `
      html, body {
        background-color: #121212 !important;
        color: #E0E0E0 !important;
      }
      * {
        color: inherit !important;
        background-color: transparent !important;
        border-color: #333333 !important;
      }
      a, a:link, a:visited, a:hover, a:active {
        color: #64B5F6 !important;
        text-decoration: none !important;
      }
      .pmc-article-section, article, main, header, footer, section, div, p, span, h1, h2, h3, h4, h5, h6, table, th, td, tr, tbody, thead, tfoot {
        background-color: transparent !important;
        color: #E0E0E0 !important;
        border-color: #333333 !important;
      }
      img, svg, video, iframe, canvas, figure, .figure {
        background-color: transparent !important;
        filter: brightness(0.9) contrast(1.1) !important;
      }
      pre, code, kbd, samp {
        background-color: #1E1E1E !important;
        color: #E1E1E6 !important;
        border: 1px solid #333333 !important;
      }
      input, button, select, textarea {
        background-color: #2D2D2D !important;
        color: #E0E0E0 !important;
        border: 1px solid #4D4D4D !important;
      }
      ::selection {
        background-color: #315C87 !important;
        color: #FFFFFF !important;
      }
      hr {
        border-color: #444444 !important;
      }
      /* Specific PMC Elements Overrides */
      .pmc-footnote, .pmc_reference, .ref-list, .half_out, .back-matter {
        background-color: transparent !important;
      }
      .fm-sec, .abstract, .kwd-group, .custom-meta-group {
        background-color: rgba(255, 255, 255, 0.03) !important;
        border: 1px solid #333 !important;
      }
      .pmc-icon {
        filter: invert(1) hue-rotate(180deg) brightness(0.8) !important;
      }
      .tsec {
        background-color: #1a1a1a !important;
      }
    `;
    document.head.appendChild(style);
  })();
  """;

  // ── TOC bottom sheet ─────────────────────────────────────────────────────────

  Future<void> _showToc() async {
    final ctrl = _controller;
    if (ctrl == null) return;

    final raw = await ctrl.evaluateJavascript(source: _tocJs);
    if (!mounted) return;

    List<Map<String, dynamic>> items = [];
    try {
      final decoded = raw is String ? jsonDecode(raw) : raw;
      items = (decoded as List).cast<Map<String, dynamic>>();
    } catch (_) {}

    if (items.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No headings found')));
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Table of Contents',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: items.length,
                itemBuilder: (context, idx) {
                  final item = items[idx];
                  final level = (item['level'] as int?) ?? 2;
                  final isH3 = level == 3;
                  return ListTile(
                    contentPadding: EdgeInsets.only(
                      left: isH3 ? 40.0 : 16.0,
                      right: 16.0,
                    ),
                    dense: isH3,
                    title: Text(
                      item['text'] as String,
                      style: TextStyle(
                        fontSize: isH3 ? 13.5 : 15.0,
                        color: isH3
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    leading: Icon(
                      isH3
                          ? Icons.subdirectory_arrow_right_rounded
                          : Icons.article_outlined,
                      size: isH3 ? 16 : 18,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      final id = item['id'] as String;
                      if (id.isNotEmpty) {
                        ctrl.evaluateJavascript(
                          source:
                              "(function(){var el=document.getElementById('$id');if(!el)return;var rect=el.getBoundingClientRect();var y=rect.top+window.scrollY-window.innerHeight*0.22;window.scrollTo({top:Math.max(0,y),behavior:'smooth'});})();",
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Refresh ──────────────────────────────────────────────────────────────────

  Future<void> _refresh() async {
    _cancelParagraphTranslation();
    _paragraphTranslations.clear();
    await _db.deletePmcHtml(widget.pmcid);
    if (!mounted) return;
    _controller = null;
    setState(() {
      _hasError = false;
      _progress = 0;
      _isCheckingCache = true;
      _cachedHtml = null;
      _loadedFromCache = false;
      _didCacheCurrentPage = false;
      _showTocFabs = false;
      _webViewGeneration++;
    });
    await _checkCache();
  }

  Future<bool> _pageContainsArticle(InAppWebViewController controller) async {
    try {
      final result = await controller.evaluateJavascript(
        source:
            "Boolean(document.querySelector('.pmc-article-section') && "
            "(document.querySelector('.main-article-body') || "
            "document.querySelector('.pmc_sec_title') || "
            "document.querySelector('article')));",
      );
      return result == true || result?.toString() == 'true';
    } catch (_) {
      return false;
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final shouldSimplify = ref.watch(simplifyPmcReaderProvider);

    // Build the actual AppBar widget (reused in the PreferredSize slot)
    final appBarWidget = AppBar(
      title: Text(l10n.readerTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.copy),
          tooltip: 'Copy URL',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _url));
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(l10n.copied)));
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Share',
          onPressed: () => Share.share(_url), // ignore: deprecated_member_use
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh (clears cache)',
          onPressed: _refresh,
        ),
      ],
      bottom: _progress < 1.0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.transparent,
              ),
            )
          : null,
    );

    // Top safe-area height (status bar)
    final topPadding = MediaQuery.of(context).padding.top;
    // Effective AppBar height including status bar
    final appBarHeight =
        kToolbarHeight + topPadding + (_progress < 1.0 ? 3.0 : 0.0);

    return Scaffold(
      // No Scaffold.appBar — we overlay it inside the Stack so it truly
      // takes zero space when hidden (AnimatedContainer collapses to 0).
      body: Stack(
        children: [
          // ── WebView ───────────────────────────────────────────────────────
          Positioned.fill(
            child: _isCheckingCache
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.pageLoadError,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                        ),
                      ],
                    ),
                  )
                : InAppWebView(
                    key: ValueKey(_webViewGeneration),
                    initialUrlRequest: _cachedHtml != null
                        ? null
                        : URLRequest(url: WebUri(_url)),
                    initialData: _cachedHtml != null
                        ? InAppWebViewInitialData(
                            data: _cachedHtml!,
                            baseUrl: WebUri(_url),
                            encoding: 'utf-8',
                            mimeType: 'text/html',
                          )
                        : null,
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      useShouldOverrideUrlLoading: true,
                      // Virtual-display composition avoids renderer crashes seen
                      // with hybrid composition on some Android/WebView builds.
                      useHybridComposition: false,
                      // Keep this reader on a software layer. Android 16
                      // emulator images shipping WebView 133 can terminate the
                      // renderer while compositing a full PMC article.
                      hardwareAcceleration: false,
                      mediaPlaybackRequiresUserGesture: true,
                      allowsInlineMediaPlayback: true,
                      // Keep browser-level cache active for sub-resources
                      // (images, CSS, JS). Full-page HTML is handled by our DB.
                      cacheEnabled: true,
                    ),
                    findInteractionController: _findController,
                    onWebViewCreated: (controller) {
                      _controller = controller;

                      // Register scroll handler
                      controller.addJavaScriptHandler(
                        handlerName: 'onScroll',
                        callback: (args) {
                          if (_readerTranslationEnabled) {
                            _scheduleVisibleTranslation();
                          }
                          final dir = args.isNotEmpty ? args[0] as String : '';
                          final y = args.length > 1
                              ? (args[1] as num).toDouble()
                              : 0.0;
                          if (dir == 'down') {
                            _scrollUpAccum = 0;
                            if (y > _hideThreshold) _setAppBarVisible(false);
                          } else {
                            // y <= 0 means at the very top
                            if (y <= 0) {
                              _scrollUpAccum = 0;
                              _setAppBarVisible(true);
                            } else {
                              _scrollUpAccum +=
                                  1; // each rAF tick ~= a small delta
                              if (_scrollUpAccum >= _showThreshold) {
                                _scrollUpAccum = 0;
                                _setAppBarVisible(true);
                              }
                            }
                          }
                        },
                      );
                    },
                    onLoadStop: (controller, url) async {
                      if (!mounted) return;

                      // Fetch context-dependent values BEFORE any async gaps
                      final topPadding = MediaQuery.of(context).padding.top;
                      final bottomPadding = MediaQuery.of(context)
                          .padding
                          .bottom;
                      final shouldSimplify = ref.read(
                        simplifyPmcReaderProvider,
                      );
                      final brightness = Theme.of(context).brightness;

                      final containsArticle = await _pageContainsArticle(
                        controller,
                      );
                      if (!mounted) return;
                      if (!containsArticle) {
                        if (_loadedFromCache) {
                          await _db.deletePmcHtml(widget.pmcid);
                          if (!mounted) return;
                        }
                        setState(() {
                          _hasError = true;
                          _showTocFabs = false;
                        });
                        return;
                      }

                      // Save HTML to DB only on live network loads, BEFORE modifying the DOM
                      if (!_loadedFromCache && !_didCacheCurrentPage) {
                        await _saveCacheFromPage(controller);
                        if (!mounted) return;
                        _didCacheCurrentPage = true;
                      }

                      if (shouldSimplify) {
                        await controller.evaluateJavascript(
                          source: _immersiveJs,
                        );
                        if (!mounted) return;
                        setState(() => _showTocFabs = true);
                      } else {
                        await controller.evaluateJavascript(
                          source: _scrollListenerJs,
                        );
                        if (!mounted) return;
                        setState(() => _showTocFabs = false);
                      }

                      // Disable accidental link jumps in reader mode.
                      await controller.evaluateJavascript(
                        source: _disableLinksJs,
                      );
                      if (!mounted) return;

                      // Inject dark mode CSS before content becomes visible if needed
                      if (brightness == Brightness.dark) {
                        await controller.evaluateJavascript(
                          source: _darkModeJs,
                        );
                        if (!mounted) return;
                      }

                      // Apply padding to push content below the overlapping AppBar and above the bottom nav bar
                      final baseAppBarHeight = kToolbarHeight + topPadding;
                      await controller.evaluateJavascript(
                        source:
                            "document.body.style.paddingTop = '${baseAppBarHeight}px'; document.body.style.paddingBottom = '${bottomPadding + 16}px';",
                      );
                      if (!mounted) return;

                      if (shouldSimplify && _readerTranslationEnabled) {
                        await controller.evaluateJavascript(
                          source: _readerTranslationSetupJs,
                        );
                        if (!mounted) return;
                        _scheduleVisibleTranslation();
                      }

                      _setAppBarVisible(true);
                    },
                    onProgressChanged: (controller, progress) {
                      if (!mounted) return;
                      setState(() => _progress = progress / 100);
                    },
                    onReceivedError: (controller, request, error) {
                      if (mounted && (request.isForMainFrame ?? false)) {
                        setState(() => _hasError = true);
                      }
                    },
                    onReceivedHttpError: (controller, request, response) {
                      final status = response.statusCode ?? 0;
                      if (mounted &&
                          (request.isForMainFrame ?? false) &&
                          status >= 400) {
                        setState(() => _hasError = true);
                      }
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                          final requestUrl = navigationAction.request.url;
                          if (requestUrl == null) {
                            return NavigationActionPolicy.ALLOW;
                          }

                          final scheme = requestUrl.scheme.toLowerCase();
                          // Cached HTML from initialData is loaded as about:/data: URL.
                          // Blocking these schemes causes a white screen on second open.
                          if (scheme == 'about' ||
                              scheme == 'data' ||
                              scheme == 'file' ||
                              scheme == 'blob') {
                            return NavigationActionPolicy.ALLOW;
                          }

                          final host = requestUrl.host.toLowerCase();
                          if (host.endsWith('ncbi.nlm.nih.gov') ||
                              host.endsWith('nih.gov')) {
                            return NavigationActionPolicy.ALLOW;
                          }
                          return NavigationActionPolicy.CANCEL;
                        },
                  ),
          ),

          // ── AppBar overlay (collapses to height 0 when hidden) ──────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              height: _appBarVisible ? appBarHeight : 0,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: appBarWidget,
            ),
          ),

          // ── Floating action buttons (TOC / Top / Bottom) ───────────────────
          if (shouldSimplify && _showTocFabs)
            Positioned(
              right: 12,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FabButton(
                    tooltip: _readerTranslationEnabled
                        ? l10n.readerTranslationOff
                        : l10n.readerTranslationOn,
                    icon: Icons.translate_rounded,
                    active: _readerTranslationEnabled,
                    busy: _isTranslatingParagraph,
                    onPressed: _toggleReaderTranslation,
                  ),
                  const SizedBox(height: 8),
                  _FabButton(
                    tooltip: 'Table of Contents',
                    icon: Icons.list_alt_rounded,
                    onPressed: _showToc,
                  ),
                  const SizedBox(height: 8),
                  _FabButton(
                    tooltip: 'Scroll to top',
                    icon: Icons.keyboard_double_arrow_up_rounded,
                    onPressed: () => _controller?.evaluateJavascript(
                      source: "window.scrollTo({top:0,behavior:'smooth'});",
                    ),
                  ),
                  const SizedBox(height: 8),
                  _FabButton(
                    tooltip: 'Scroll to bottom',
                    icon: Icons.keyboard_double_arrow_down_rounded,
                    onPressed: () => _controller?.evaluateJavascript(
                      source: "window.scrollTo({top:document.body.scrollHeight,behavior:'smooth'});",
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Small FAB helper ──────────────────────────────────────────────────────────

class _FabButton extends StatelessWidget {
  const _FabButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
    this.busy = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool active;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHigh.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: busy
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.primary,
                    ),
                  )
                : Icon(
                    icon,
                    size: 22,
                    color: active ? colorScheme.primary : colorScheme.onSurface,
                  ),
          ),
        ),
      ),
    );
  }
}
