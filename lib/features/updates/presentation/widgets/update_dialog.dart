import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pubmed_mobile/core/l10n/app_localizations.dart';
import 'package:pubmed_mobile/features/updates/data/update_check_service.dart';
import 'package:pubmed_mobile/features/updates/domain/changelog_entry.dart';
import 'package:pubmed_mobile/features/updates/presentation/providers/update_check_provider.dart';

/// GitHub Releases page — where the "更新" button leads.
const _releasesUrl = 'https://github.com/aoaim/pubmed-mobile/releases';

/// Shows the "update available" dialog with the changelog from the latest
/// version down to the current one. Buttons: 更新 / 本次忽略此提示.
Future<void> showUpdateAvailableDialog(
  BuildContext context,
  UpdateCheckResult result,
) async {
  final l10n = AppLocalizations.of(context);
  final isZh = Localizations.localeOf(context).languageCode == 'zh';

  final action = await showDialog<_UpdateAction>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        isZh ? '发现新版本 v${result.latestVersion}' : 'Update available v${result.latestVersion}',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _ChangelogView(entries: result.entries),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(_UpdateAction.ignore),
          child: Text(l10n.ignoreThisVersion),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(_UpdateAction.update),
          child: Text(l10n.updateNow),
        ),
      ],
    ),
  );

  if (action == _UpdateAction.ignore) {
    await setIgnoredUpdateVersion(result.latestVersion);
  } else if (action == _UpdateAction.update) {
    await launchUrl(
      Uri.parse(_releasesUrl),
      mode: LaunchMode.externalApplication,
    );
  }
}

/// Shows the "already up to date" dialog (manual check only), including the
/// changelog of the latest version.
Future<void> showUpToDateDialog(
  BuildContext context,
  UpdateCheckResult result,
) async {
  final l10n = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.upToDate),
      content: SizedBox(
        width: double.maxFinite,
        child: _ChangelogView(entries: [result.latestEntry]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}

/// Shows the failure dialog with the reason (manual check only).
Future<void> showUpdateCheckFailedDialog(
  BuildContext context,
  UpdateCheckException error,
) async {
  final l10n = AppLocalizations.of(context);
  final isZh = Localizations.localeOf(context).languageCode == 'zh';
  final reason = switch (error.kind) {
    UpdateCheckFailureKind.network => isZh
        ? '无法连接到更新服务器，请检查网络连接后重试。'
        : 'Could not reach the update server. Check your network and try again.',
    UpdateCheckFailureKind.parse => isZh
        ? '更新日志格式异常，无法解析。'
        : 'The changelog format is invalid and could not be parsed.',
  };

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.checkFailed),
      content: Text(reason),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}

enum _UpdateAction { update, ignore }

/// Scrollable changelog body: renders entries newest-first as markdown.
class _ChangelogView extends StatelessWidget {
  const _ChangelogView({required this.entries});

  final List<ChangelogEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = entries.map((e) => e.toMarkdown()).join('\n\n');
    return SingleChildScrollView(
      child: SelectableText(
        text,
        style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
      ),
    );
  }
}
