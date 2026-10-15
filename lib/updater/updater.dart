// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Updater {
  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      final releaseInfo = await _fetchLatestReleaseInfo();
      if (releaseInfo != null) {
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final String currentVersion = packageInfo.version;

        final String latestVersion = releaseInfo['tag_name'];
        if (_isNewerVersion(latestVersion, currentVersion)) {
          // ignore: use_build_context_synchronously
          _showUpdateAvailableDialog(
            // ignore: use_build_context_synchronously
            context,
            latestVersion,
            releaseInfo['body'],
          );
        } else {
          // ignore: use_build_context_synchronously
          _showNoUpdateDialog(context);
        }
      } else if (kDebugMode) {
        print("Error fetching version: no valid response from the server.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("An error occurred: $e");
      }
      // ignore: use_build_context_synchronously
      _showErrorDialog(context);
    }
  }

  static Future<Map<String, dynamic>?> _fetchLatestReleaseInfo() async {
    final response = await http.get(
      Uri.parse(
        'https://api.github.com/repos/hendrilmendes/Tarefas/releases/latest',
      ),
      headers: {'Accept': 'application/vnd.github.v3+json'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  static bool _isNewerVersion(String latestVersion, String currentVersion) {
    final cleanLatest = latestVersion.startsWith('v')
        ? latestVersion.substring(1)
        : latestVersion;
    final cleanCurrent = currentVersion.startsWith('v')
        ? currentVersion.substring(1)
        : currentVersion;

    List<int> latestParts = cleanLatest
        .split('.')
        .map(int.tryParse)
        .where((e) => e != null)
        .cast<int>()
        .toList();
    List<int> currentParts = cleanCurrent
        .split('.')
        .map(int.tryParse)
        .where((e) => e != null)
        .cast<int>()
        .toList();

    int len = latestParts.length > currentParts.length
        ? latestParts.length
        : currentParts.length;

    for (int i = 0; i < len; i++) {
      int latestPart = i < latestParts.length ? latestParts[i] : 0;
      int currentPart = i < currentParts.length ? currentParts[i] : 0;

      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }
    return false;
  }

  static void _showUpdateAvailableDialog(
    BuildContext context,
    String newVersion,
    String releaseNotes,
  ) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.system_update, color: scheme.primary, size: 28),
          ),
          title: Text('${localizations.newUpdate}\n${localizations.version} $newVersion',
              textAlign: TextAlign.center),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.news,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(releaseNotes,
                        style: TextStyle(
                          color: scheme.onSurface.withOpacity(0.8),
                          height: 1.5,
                        )),
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.after),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.download, size: 18),
              onPressed: () {
                final Uri uri = Platform.isAndroid
                    ? Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.github.hendrilmendes.tarefas',
                      )
                    : Uri.parse(
                        'https://github.com/hendrilmendes/Tarefas/releases/latest',
                      );
                launchUrl(uri);
                Navigator.pop(context);
              },
              label: Text(localizations.download),
            ),
          ],
        );
      },
    );
  }

  static void _showNoUpdateDialog(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_outlined, color: Colors.green, size: 28),
          ),
          title: Text(localizations.noUpdate, textAlign: TextAlign.center),
          content: Text(
            localizations.noUpdateSub,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.ok),
            ),
          ],
        );
      },
    );
  }

  static Future<void> checkUpdateApp(BuildContext context) async {
    try {
      final releaseInfo = await _fetchLatestReleaseInfo();
      if (releaseInfo != null) {
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final String currentVersion = packageInfo.version;

        final String latestVersion = releaseInfo['tag_name'];
        if (_isNewerVersion(latestVersion, currentVersion)) {
          // ignore: use_build_context_synchronously
          _showUpdateAvailableDialog(
            // ignore: use_build_context_synchronously
            context,
            latestVersion,
            releaseInfo['body'],
          );
        }
      } else if (kDebugMode) {
        print("Error fetching version: no valid response from the server.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("An error occurred: $e");
      }
      // ignore: use_build_context_synchronously
      _showErrorDialog(context);
    }
  }

  static void _showErrorDialog(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.error.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, color: scheme.error, size: 28),
          ),
          title: Text(localizations.error, textAlign: TextAlign.center),
          content: Text(
            localizations.errorUpdate,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.ok),
            ),
          ],
        );
      },
    );
  }
}
