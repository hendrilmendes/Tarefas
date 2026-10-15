// ignore_for_file: deprecated_member_use
import 'package:tarefas/utils/app_strings.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'dart:convert';

import 'package:tarefas/widgets/settings_group.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String appVersion = '';
  String appBuild = '';
  String releaseNotes = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      appBuild = packageInfo.buildNumber;
    });
    _fetchReleaseInfo();
  }

  Future<void> _fetchReleaseInfo() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/hendrilmendes/Tarefas/releases',
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> releases = jsonDecode(response.body);
        String body = '';
        for (var release in releases) {
          if (release['tag_name'] == appVersion) {
            body = release['body'] ?? '';
            break;
          }
        }
        setState(() {
          releaseNotes = body.isNotEmpty
              ? body
              : S.current.releaseNotesEmpty;
        });
      } else {
        setState(
          () => releaseNotes =
              S.current.releaseNotesError(response.statusCode),
        );
      }
    } catch (_) {
      setState(
        () => releaseNotes =
            S.current.releaseNotesConnection,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showReleaseInfo() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('${l10n.version} • $appVersion'),
        content: SizedBox(
          width: double.maxFinite,
          child: isLoading
              ? const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              : SingleChildScrollView(
                  child: Text(
                    releaseNotes,
                    style: const TextStyle(fontSize: 14, height: 1.55),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final year = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.about,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/img/ic_launcher.png',
                      width: 88,
                      height: 88,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Copyright © Hendevs $year • ${l10n.copyright}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: scheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SettingsGroup(
            title: l10n.information,
            children: [
              SettingsTile(
                icon: Icons.tag_outlined,
                title: l10n.version,
                subtitle: 'v$appVersion • Build $appBuild',
                onTap: _showReleaseInfo,
              ),
              SettingsTile(
                icon: Icons.shield_outlined,
                title: l10n.privacy,
                subtitle: l10n.privacySub,
                onTap: () => launchUrl(
                  Uri.parse(
                    'https://br-newsdroid.blogspot.com/p/politica-de-privacidade-tarefas.html',
                  ),
                  mode: LaunchMode.inAppBrowserView,
                ),
              ),
              SettingsTile(
                icon: Icons.code,
                title: l10n.sourceCode,
                subtitle: l10n.sourceCodeSub,
                onTap: () => launchUrl(
                  Uri.parse('https://github.com/hendrilmendes/Tarefas/'),
                  mode: LaunchMode.inAppBrowserView,
                ),
              ),
              SettingsTile(
                icon: Icons.folder_outlined,
                title: l10n.openSource,
                subtitle: l10n.openSourceSub,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LicensePage(applicationName: l10n.appName),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
