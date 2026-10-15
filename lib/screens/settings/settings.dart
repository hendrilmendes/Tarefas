// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:tarefas/utils/app_strings.dart';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tarefas/auth/auth.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tarefas/screens/about/about.dart';
import 'package:tarefas/screens/login/login.dart';
import 'package:tarefas/screens/settings/personalization/personalization.dart';
import 'package:tarefas/theme/theme.dart';
import 'package:tarefas/widgets/orb_glass.dart';
import 'package:tarefas/widgets/settings_group.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _languages = <String, String>{
    'pt': 'Português',
    'en': 'English',
    'es': 'Español',
  };

  String _languageLabel(AppLocalizations l10n, Locale? locale) {
    if (locale == null) return l10n.languageAuto;
    return _languages[locale.languageCode] ?? l10n.languageAuto;
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final current = themeModel.locale?.languageCode;
        Widget option(String? code, String label) {
          final selected = current == code;
          return ListTile(
            title: Text(label),
            trailing: selected ? const Icon(Icons.check) : null,
            onTap: () {
              themeModel.setLocale(code == null ? null : Locale(code));
              Navigator.pop(sheetContext);
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  l10n.languageSub,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              option(null, l10n.languageAuto),
              for (final e in _languages.entries) option(e.key, e.value),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendSupportEmail(BuildContext context) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'hendrilmendes2015@gmail.com',
      queryParameters: {'subject': S.current.supportEmailSubject},
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.current.emailOpenFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.logoutConfirm, textAlign: TextAlign.center),
        content: Text(l10n.logoutConfirmSub, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AuthService().signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(authService: AuthService()),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final displayName =
        user?.displayName ?? user?.email?.split('@').first ?? l10n.userFallback;
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;

    final String themeSubtitle;
    switch (themeModel.themeMode) {
      case ThemeModeType.light:
        themeSubtitle = l10n.lightMode;
        break;
      case ThemeModeType.dark:
        themeSubtitle = l10n.darkMode;
        break;
      case ThemeModeType.system:
        themeSubtitle = l10n.systemMode;
        break;
    }

    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 8;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: l10n.logout,
            icon: Icon(Icons.logout, color: scheme.error),
            onPressed: () => _logout(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, topPadding, 16, 110),
        children: [

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: scheme.brightness == Brightness.light
                  ? scheme.surface.withOpacity(0.70)
                  : scheme.surfaceContainerHighest.withOpacity(0.35),
              border: Border.all(
                color: scheme.brightness == Brightness.light
                    ? Colors.white.withOpacity(0.8)
                    : Colors.white.withOpacity(0.12),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    scheme.brightness == Brightness.light ? 0.04 : 0.2,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (photoUrl != null && photoUrl.isNotEmpty)
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(photoUrl),
                    )
                  else
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [scheme.primary, scheme.secondary],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _QuickCard(
                  icon: Icons.palette_outlined,
                  title: l10n.theme,
                  subtitle: themeSubtitle,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PersonalizationScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickCard(
                  icon: Icons.notifications_outlined,
                  title: l10n.notification,
                  subtitle: l10n.alerts,
                  onTap: () => AppSettings.openAppSettings(
                    type: AppSettingsType.notification,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SettingsGroup(
            title: l10n.language,
            children: [
              SettingsTile(
                icon: Icons.language,
                title: l10n.language,
                subtitle: _languageLabel(l10n, themeModel.locale),
                onTap: () => _showLanguagePicker(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SettingsGroup(
            title: l10n.personalization,
            children: [
              SettingsTile(
                icon: Icons.palette_outlined,
                title: l10n.personalization,
                subtitle: l10n.personalizationSub,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PersonalizationScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SettingsGroup(
            title: l10n.support,
            children: [
              SettingsTile(
                icon: Icons.mail_outline_rounded,
                title: l10n.sendEmail,
                subtitle: l10n.contactDeveloper,
                onTap: () => _sendSupportEmail(context),
              ),
              SettingsTile(
                icon: Icons.info_outline,
                title: l10n.about,
                subtitle: l10n.aboutSub,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = scheme.brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isLight
            ? scheme.surface.withOpacity(0.70)
            : scheme.surfaceContainerHighest.withOpacity(0.35),
        border: Border.all(
          color: isLight
              ? Colors.white.withOpacity(0.8)
              : Colors.white.withOpacity(0.12),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.04 : 0.20),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: scheme.primary, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
