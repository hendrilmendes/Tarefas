// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:ui'; // Necessário para ImageFilter

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AboutPageState createState() => _AboutPageState();
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
    // Busca as informações de release após obter a versão
    _fetchReleaseInfo();
  }

  // Função para buscar as informações de release do GitHub
  Future<void> _fetchReleaseInfo() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/hendrilmendes/Tarefas/releases',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> releases = jsonDecode(response.body);
        String versionRelease = '';

        for (var release in releases) {
          if (release['tag_name'] == appVersion) {
            versionRelease = release['body'];
            break;
          }
        }
        setState(() {
          releaseNotes = versionRelease.isNotEmpty
              ? versionRelease
              : 'Nenhuma nota de versão encontrada para esta versão.';
        });
      } else {
        setState(() {
          releaseNotes =
              'Erro ao carregar as notas da versão. Código: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        releaseNotes =
            'Erro ao carregar. Verifique sua conexão com a internet.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para exibir as informações de release no Dialog
  void _showReleaseInfo(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${AppLocalizations.of(context)!.version} - $appVersion',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 0.5),

                      Flexible(
                        child: isLoading
                            ? const SizedBox(
                                height: 150,
                                child: Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  releaseNotes,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: AppBar(
              backgroundColor: colors.surface.withOpacity(0.8),
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              title: Text(
                AppLocalizations.of(context)!.about,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: colors.onSurface,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                children: [
                  _buildAppInfoCard(context),
                  const SizedBox(height: 16),
                  _buildInfoList(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final int currentYear = DateTime.now().year;
    final appName = AppLocalizations.of(context)!.appName;

    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                const Card(
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: 100,
                    child: Image(
                      image: AssetImage('assets/img/ic_launcher.png'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  appName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Copyright © Hendril Mendes $currentYear',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.copyright,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.appDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: colors.onSurface.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoList(BuildContext context) {
    return _buildSettingsCategory(
      context,
      title: AppLocalizations.of(context)!.information.toUpperCase(),
      items: [
        SettingsItem(
          icon: CupertinoIcons.tag_fill,
          title: AppLocalizations.of(context)!.version,
          subtitle: 'v$appVersion | Build: $appBuild',
          onTap: () => _showReleaseInfo(context),
        ),
        SettingsItem(
          icon: CupertinoIcons.shield_fill,
          title: AppLocalizations.of(context)!.privacy,
          subtitle: AppLocalizations.of(context)!.privacySub,
          onTap: () {
            launchUrl(
              Uri.parse(
                'https://br-newsdroid.blogspot.com/p/politica-de-privacidade-tarefas.html',
              ),
              mode: LaunchMode.inAppBrowserView,
            );
          },
        ),
        SettingsItem(
          icon: CupertinoIcons.chevron_left_slash_chevron_right,
          title: AppLocalizations.of(context)!.sourceCode,
          subtitle: AppLocalizations.of(context)!.sourceCodeSub,
          onTap: () {
            launchUrl(
              Uri.parse('https://github.com/hendrilmendes/Tarefas/'),
              mode: LaunchMode.inAppBrowserView,
            );
          },
        ),
        SettingsItem(
          icon: CupertinoIcons.folder_fill,
          title: AppLocalizations.of(context)!.openSource,
          subtitle: AppLocalizations.of(context)!.openSourceSub,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LicensePage(
                  applicationName: AppLocalizations.of(context)!.appName,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsCategory(
    BuildContext context, {
    required String title,
    required List<SettingsItem> items,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.8),
                    height: 1.2,
                  ),
                ),
              ),
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == items.length - 1;

                return Column(
                  children: [
                    _buildSettingsItem(context, item),
                    if (!isLast)
                      Container(
                        height: 0.5,
                        margin: const EdgeInsets.only(left: 56),
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.08),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, SettingsItem item) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, size: 18, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface,
                        height: 1.2,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurface.withOpacity(0.6),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: colors.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
