import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pubmed_mobile/core/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pubmed_mobile/features/settings/data/settings_repository.dart';
import 'package:pubmed_mobile/core/database/app_database.dart';

/// PMC full-text reader using InAppWebView.
///
/// Cache policy (PMC HTML):
///   - On open: check [PmcFullTextCache] in SQLite first.
///     If found, load the stored HTML locally (no network).
///     If not found, load the live URL, then cache the result.
///   - Manual refresh (↺ button): clears the DB row for this PMCID, then
///     re-fetches from network and caches the new version.
///   - No automatic expiry — PMC articles don't change after publication.
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

  String get _url =>
      'https://www.ncbi.nlm.nih.gov/pmc/articles/${widget.pmcid}/';

  AppDatabase get _db => ref.read(databaseProvider);

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _findController = FindInteractionController();
    _checkCache();
  }

  Future<void> _checkCache() async {
    final cached = await ref.read(databaseProvider).getPmcHtml(widget.pmcid);
    var cachedHtml = cached?.html;

    if (cachedHtml != null && !_looksLikeUsableCachedHtml(cachedHtml)) {
      await _db.deletePmcHtml(widget.pmcid);
      cachedHtml = null;
    }

    if (mounted) {
      setState(() {
        _cachedHtml = cachedHtml;
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

  bool _looksLikeReadablePmcHtml(String html) {
    if (html.length < 1000) return false;
    if (html.length >= 8000) return true;
    return html.contains('pmc-article-section') ||
        html.contains('<article') ||
        html.contains('<main');
  }

  bool _looksLikeUsableCachedHtml(String html) {
    if (_looksLikeReadablePmcHtml(html)) return true;
    return html.length >= 2000;
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
        if (htmlFromApi != null && _looksLikeReadablePmcHtml(htmlFromApi)) {
          await _db.upsertPmcHtml(widget.pmcid, htmlFromApi);
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
        if (html != null && _looksLikeReadablePmcHtml(html)) {
          await _db.upsertPmcHtml(widget.pmcid, html);
          return true;
        }

        await Future.delayed(const Duration(milliseconds: 250));
      }
    } catch (e) {
      debugPrint('PMC cache save failed for ${widget.pmcid}: $e');
    }

    if (bestHtml != null && _looksLikeUsableCachedHtml(bestHtml!)) {
      await _db.upsertPmcHtml(widget.pmcid, bestHtml!);
      return true;
    }

    return false;
  }

  // ── JS snippets ──────────────────────────────────────────────────────────────

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

    // Disable ALL in-page hyperlinks (prevent accidental navigation in immersive mode)
    document.addEventListener('click', function(e) {
      var a = e.target.closest('a');
      if (a) {
        e.preventDefault();
        e.stopPropagation();
      }
    }, true);

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No headings found')));
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
    // Clear DB cache for this article so the next load fetches from network
    await _db.deletePmcHtml(widget.pmcid);
    setState(() {
      _hasError = false;
      _progress = 0;
      _cachedHtml = null;
    });
    // Load the live URL
    await _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(_url)));
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.copied)));
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
                    initialUrlRequest: _cachedHtml != null
                        ? null
                        : URLRequest(url: WebUri(_url)),
                    initialData: _cachedHtml != null
                        ? InAppWebViewInitialData(
                            data: _cachedHtml!,
                            baseUrl: WebUri('https://www.ncbi.nlm.nih.gov/'),
                            encoding: 'utf-8',
                            mimeType: 'text/html',
                          )
                        : null,
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      useShouldOverrideUrlLoading: true,
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
                      final bottomPadding = MediaQuery.of(
                        context,
                      ).padding.bottom;
                      final shouldSimplify = ref.read(
                        simplifyPmcReaderProvider,
                      );

                      // Save HTML to DB only on live network loads, BEFORE modifying the DOM
                      if (_cachedHtml == null) {
                        final saved = await _saveCacheFromPage(controller);
                        if (!mounted) return;
                        if (saved) {
                          // mark as cached to prevent multiple saves on same session
                          _cachedHtml = 'saved';
                        }
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

                      // Apply padding to push content below the overlapping AppBar and above the bottom nav bar
                      final baseAppBarHeight = kToolbarHeight + topPadding;
                      await controller.evaluateJavascript(
                        source:
                            "document.body.style.paddingTop = '${baseAppBarHeight}px'; document.body.style.paddingBottom = '${bottomPadding + 16}px';",
                      );
                      if (!mounted) return;

                      _setAppBarVisible(true);
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() => _progress = progress / 100);
                    },
                    onReceivedError: (controller, request, error) {
                      if (request.isForMainFrame ?? false) {
                        setState(() => _hasError = true);
                      }
                    },
                    shouldOverrideUrlLoading: (controller, navigationAction) async {
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
                      source:
                          "window.scrollTo({top:document.body.scrollHeight,behavior:'smooth'});",
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
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 22, color: colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}
