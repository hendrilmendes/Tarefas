// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:tarefas/utils/app_strings.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:tarefas/auth/auth.dart';
import 'package:tarefas/widgets/bottom_navigation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tarefas/widgets/orb_glass.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  const LoginScreen({required this.authService, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _intro;
  late Animation<double> _fade;
  late Animation<Offset> _rise;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    _rise = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));
    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    HapticFeedback.selectionClick();
    try {
      final user = await widget.authService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavigationContainer()),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.current.signInFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LiquidBackdrop(
        orbColors: [
          isDark
              ? const Color(0xFF1E3A8A).withOpacity(0.40)
              : const Color(0xFF60A5FA).withOpacity(0.35),
          isDark
              ? const Color(0xFF065F46).withOpacity(0.35)
              : const Color(0xFF34D399).withOpacity(0.35),
          isDark
              ? const Color(0xFF701A75).withOpacity(0.30)
              : const Color(0xFFF472B6).withOpacity(0.30),
        ],
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _rise,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Spacer(flex: 1),
                                const Padding(
                                  padding: EdgeInsets.only(top: 16, bottom: 8),
                                  child: _Illustration(),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Transform.translate(
                                    offset: const Offset(0, -8),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(36),
                                      ),
                                      child: OrbGlass(
                                        filter: OrbGlass.heroBlur,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(36),
                                            ),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: liquidGlassDecoration(
                                            theme,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(36),
                                                ),
                                            hero: true,
                                            opacityMultiplier: 1.1,
                                          ),
                                          padding: const EdgeInsets.fromLTRB(
                                            28,
                                            32,
                                            28,
                                            0,
                                          ),
                                          child: Column(
                                            children: [
                                              _LoginCard(
                                                isLoading: _isLoading,
                                                onSignIn: _handleSignIn,
                                              ),
                                              const Spacer(),
                                              const _PolicyFooter(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.appName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 8,
                  top: 18,
                  child: _Blob(
                    size: 92,
                    color: const Color(0xFFFFD9C2).withOpacity(0.9),
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 8,
                  child: _Blob(
                    size: 70,
                    color: const Color(0xFFCDE7D0).withOpacity(0.9),
                  ),
                ),
                Positioned(
                  right: 40,
                  bottom: 6,
                  child: _Blob(
                    size: 110,
                    color: const Color(0xFFD6E4FF).withOpacity(0.9),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: OrbGlass(
                    filter: OrbGlass.highBlur,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 240,
                      padding: const EdgeInsets.all(18),
                      decoration: liquidGlassDecoration(
                        Theme.of(context),
                        borderRadius: BorderRadius.circular(24),
                        hero: true,
                        opacityMultiplier: 1.1,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32)
                                      .withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF2E7D32)
                                        .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.loginToday,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.more_horiz,
                                size: 18,
                                color: scheme.onSurface.withOpacity(0.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _CheckRow(done: true, label: AppLocalizations.of(context)!.loginSample1),
                          const SizedBox(height: 10),
                          _CheckRow(done: true, label: AppLocalizations.of(context)!.loginSample2),
                          const SizedBox(height: 10),
                          _CheckRow(done: false, label: AppLocalizations.of(context)!.loginSample3),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: 0.66,
                              minHeight: 8,
                              backgroundColor: scheme.surfaceContainerHighest
                                  .withOpacity(0.4),
                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalizations.of(context)!.loginProgress,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: scheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 34,
                  child: Transform.rotate(
                    angle: 0.12,
                    child: _MiniBadge(
                      icon: Icons.calendar_month_rounded,
                      iconBg: const Color(0xFFD6E4FF).withOpacity(0.8),
                      iconColor: const Color(0xFF274690),
                      title: AppLocalizations.of(context)!.loginBadgeTime,
                      subtitle: AppLocalizations.of(context)!.loginBadgeMeeting,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 30,
                  child: Transform.rotate(
                    angle: -0.1,
                    child: _MiniBadge(
                      icon: Icons.notifications_rounded,
                      iconBg: const Color(0xFFFFE3C2).withOpacity(0.8),
                      iconColor: const Color(0xFFB25E09),
                      title: AppLocalizations.of(context)!.loginBadgeReminder,
                      subtitle: AppLocalizations.of(context)!.loginBadgeGym,
                    ),
                  ),
                ),
                Positioned(
                  left: 48,
                  top: 4,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 22,
                    ),
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

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: size * 0.4,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final bool done;
  final String label;
  const _CheckRow({required this.done, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? const Color(0xFF2E7D32) : Colors.transparent,
            border: Border.all(
              color: done
                  ? const Color(0xFF2E7D32)
                  : Theme.of(context).colorScheme.outlineVariant,
              width: 2,
            ),
          ),
          child: done
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              decoration: done ? TextDecoration.lineThrough : null,
              color: done
                  ? Colors.grey
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _MiniBadge({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: OrbGlass(
        filter: OrbGlass.medBlur,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: liquidGlassDecoration(
            theme,
            borderRadius: BorderRadius.circular(18),
            hero: false,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSignIn;
  const _LoginCard({required this.isLoading, required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isDark = scheme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n.welcomeBack,
          textAlign: TextAlign.center,
          style: text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.signInToSee,
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(
            color: scheme.onSurface.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 24),

        GlassPressable(
          onTap: isLoading ? null : onSignIn,
          borderRadius: BorderRadius.circular(20),
          hero: true,
          child: Container(
            height: 56,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.white.withOpacity(0.7),
                  isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.white.withOpacity(0.4),
                ],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.8),
                width: 1.2,
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/img/google_logo.png',
                        width: 22,
                        height: 22,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          l10n.googleLogin,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _PolicyFooter extends StatelessWidget {
  const _PolicyFooter();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        28,
        8,
        28,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Text.rich(
        TextSpan(
          style: text.labelSmall?.copyWith(
            color: scheme.onSurface.withOpacity(0.55),
            height: 1.6,
          ),
          children: [
            TextSpan(text: '${l10n.acceptTerms} '),
            TextSpan(
              text: l10n.privacy,
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final url = Uri.parse(
                    'https://br-newsdroid.blogspot.com/p/politica-de-privacidade-tarefas.html',
                  );
                  try {
                    await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                  } catch (_) {}
                },
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
