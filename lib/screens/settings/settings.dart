// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:app_settings/app_settings.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarefas/auth/auth.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tarefas/screens/about/about.dart';
import 'package:tarefas/screens/login/login.dart';
import 'package:tarefas/screens/settings/personalization/personalization.dart';
import 'package:tarefas/theme/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  final User? _user = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();
  final AuthService _authService = AuthService();

  Future<String> writeImageToStorage(Uint8List feedbackScreenshot) async {
    final Directory output = await getTemporaryDirectory();
    final String screenshotFilePath = '${output.path}/feedback.png';
    final File screenshotFile = File(screenshotFilePath);
    await screenshotFile.writeAsBytes(feedbackScreenshot);
    return screenshotFilePath;
  }

  Future<bool> checkReviewed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasReviewed') ?? false;
  }

  Future<void> markReviewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasReviewed', true);
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final colors = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final safeAreaBottom = mediaQuery.padding.bottom;

    final bottomNavHeight = 70.0 + 32.0 + safeAreaBottom;

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
                AppLocalizations.of(context)!.settings,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    CupertinoIcons.square_arrow_right,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  tooltip: AppLocalizations.of(context)!.logout,
                  onPressed: () async {
                    final confirmed = await _showLogoutConfirmationDialog(
                      context,
                    );
                    if (confirmed == true) {
                      await _authService.signOut();
                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(authService: _authService),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      }
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, bottomNavHeight + 20),
              child: Column(
                children: [
                  _buildProfileCard(context),

                  const SizedBox(height: 24),

                  _buildQuickActionsGrid(context, themeModel),

                  const SizedBox(height: 32),

                  _buildSettingsCategories(context, themeModel),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = _user;
    final photoUrl = user?.photoURL;
    final displayName =
        user?.displayName ?? (user?.email?.split('@')[0]) ?? 'Usuário';
    final email = user?.email ?? 'email@exemplo.com';

    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  children: [
                    if (photoUrl != null && photoUrl.isNotEmpty)
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colors.primary.withOpacity(0.2),
                        backgroundImage: NetworkImage(photoUrl),
                      )
                    else
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [colors.primary, colors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.person_fill,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, ThemeModel themeModel) {
    final String themeSubtitle;
    switch (themeModel.themeMode) {
      case ThemeModeType.light:
        themeSubtitle = AppLocalizations.of(context)!.lightMode;
        break;
      case ThemeModeType.dark:
        themeSubtitle = AppLocalizations.of(context)!.darkMode;
        break;
      case ThemeModeType.system:
        themeSubtitle = AppLocalizations.of(context)!.systemMode;
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: themeModel.isDarkMode
                    ? CupertinoIcons.moon_fill
                    : CupertinoIcons.sun_max_fill,
                title: AppLocalizations.of(context)!.theme,
                subtitle: themeSubtitle,
                color: Theme.of(context).colorScheme.primary,
                onTap: () {
                  _showThemeChooserDialog(context, themeModel);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: CupertinoIcons.bell_fill,
                title: AppLocalizations.of(context)!.notification,
                subtitle: AppLocalizations.of(context)!.notificationSub,
                color: Theme.of(context).colorScheme.secondary,
                onTap: () {
                  AppSettings.openAppSettings(
                    type: AppSettingsType.notification,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2), width: 1),
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
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCategories(BuildContext context, ThemeModel themeModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            AppLocalizations.of(context)!.settings,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
            ),
          ),
        ),
        _buildSettingsCategory(
          context,
          title: AppLocalizations.of(context)!.personalization,
          items: [
            SettingsItem(
              icon: CupertinoIcons.paintbrush_fill,
              title: AppLocalizations.of(context)!.personalization,
              subtitle: AppLocalizations.of(context)!.personalizationSub,
              onTap: () {
                _showThemeSettings(context, themeModel);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsCategory(
          context,
          title: AppLocalizations.of(context)!.support,
          items: [
            SettingsItem(
              icon: CupertinoIcons.star_fill,
              title: AppLocalizations.of(context)!.review,
              subtitle: AppLocalizations.of(context)!.reviewSub,
              onTap: () {
                _showRateApp(context);
              },
            ),
            SettingsItem(
              icon: CupertinoIcons.chat_bubble_2_fill,
              title: AppLocalizations.of(context)!.support,
              subtitle: AppLocalizations.of(context)!.supportSub,
              onTap: () {
                _showSupport(context);
              },
            ),
            SettingsItem(
              icon: CupertinoIcons.info_circle_fill,
              title: AppLocalizations.of(context)!.about,
              subtitle: AppLocalizations.of(context)!.supportSub,
              onTap: () {
                _showAbout(context);
              },
            ),
          ],
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

  void _showThemeChooserDialog(BuildContext context, ThemeModel themeModel) {
    final localizations = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Text(
                        localizations.displayMode,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    // Usamos um Consumer aqui para que o diálogo se reconstrua
                    // ao selecionar uma opção, mostrando a seleção na hora.
                    Consumer<ThemeModel>(
                      builder: (context, model, child) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<ThemeModeType>(
                              title: Text(localizations.lightMode),
                              value: ThemeModeType.light,
                              groupValue: model.themeMode,
                              onChanged: (value) {
                                model.changeThemeMode(value!);
                                Navigator.pop(context);
                              },
                            ),
                            RadioListTile<ThemeModeType>(
                              title: Text(localizations.darkMode),
                              value: ThemeModeType.dark,
                              groupValue: model.themeMode,
                              onChanged: (value) {
                                model.changeThemeMode(value!);
                                Navigator.pop(context);
                              },
                            ),
                            RadioListTile<ThemeModeType>(
                              title: Text(localizations.systemMode),
                              value: ThemeModeType.system,
                              groupValue: model.themeMode,
                              onChanged: (value) {
                                model.changeThemeMode(value!);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showThemeSettings(BuildContext context, ThemeModel themeModel) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PersonalizationScreen()),
    );
  }

  Future<void> _showRateApp(BuildContext context) async {
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      final hasReviewed = await checkReviewed();
      if (hasReviewed) {
        Fluttertoast.showToast(
          // ignore: use_build_context_synchronously
          msg: AppLocalizations.of(context)!.alreadyReviewed,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[700],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        inAppReview.requestReview();
        await markReviewed();
      }
    }
  }

  void _showSupport(BuildContext context) {
    BetterFeedback.of(context).show((feedback) async {
      final screenshotFilePath = await writeImageToStorage(feedback.screenshot);

      final Email email = Email(
        body: feedback.text,
        // ignore: use_build_context_synchronously
        subject: AppLocalizations.of(context)!.appName,
        recipients: ['hendrilmendes2015@gmail.com'],
        attachmentPaths: [screenshotFilePath],
        isHTML: false,
      );
      await FlutterEmailSender.send(email);
    });
  }

  void _showAbout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutPage()),
    );
  }

  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizations.logoutConfirm,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localizations.logoutConfirmSub,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(localizations.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.error,
                              foregroundColor: colors.onError,
                            ),
                            child: Text(localizations.logout),
                          ),
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
