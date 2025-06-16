// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui'; // Importe para usar ImageFilter
import 'package:flutter/cupertino.dart'; // Importe para usar CupertinoIcons
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
        print("Erro ao buscar versão: Nenhuma resposta válida do servidor.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Ocorreu um erro: $e");
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
    final colors = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.arrow_down_circle_fill,
                          color: colors.primary,
                          size: 36,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.newUpdate,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${localizations.version} $newVersion",
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: colors.onSurface.withOpacity(0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      localizations.news,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Text(
                          releaseNotes,
                          style: TextStyle(
                            color: colors.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(localizations.after),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          icon: const Icon(CupertinoIcons.download_circle),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void _showNoUpdateDialog(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.checkmark_seal_fill,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.noUpdate,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.noUpdateSub,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(localizations.ok),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
        print("Erro ao buscar versão: Nenhuma resposta válida do servidor.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Ocorreu um erro: $e");
      }
      // ignore: use_build_context_synchronously
      _showErrorDialog(context);
    }
  }

  static void _showErrorDialog(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.xmark_octagon_fill,
                      color: colors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.error,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.errorUpdate,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.center,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(localizations.ok),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
