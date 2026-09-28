import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pubmed_mobile/features/updates/data/update_check_service.dart';

/// Key under which the user-ignored update version is persisted.
const ignoredUpdateVersionKey = 'ignored_update_version';

final updateCheckServiceProvider = Provider<UpdateCheckService>((ref) {
  return UpdateCheckService();
});

/// Reads the version the user chose to ignore ("本次忽略此提示").
Future<String?> readIgnoredUpdateVersion() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(ignoredUpdateVersionKey);
}

/// Persists the version the user chose to ignore.
Future<void> setIgnoredUpdateVersion(String version) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(ignoredUpdateVersionKey, version);
}
