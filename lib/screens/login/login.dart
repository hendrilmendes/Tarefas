// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:tarefas/auth/auth.dart';
import 'package:tarefas/widgets/bottom_navigation.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  const LoginScreen({required this.authService, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _introAnimationController;
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _introAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    );
    _introAnimationController.forward();
    _backgroundAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _introAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final user = await widget.authService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavigationContainer(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Falha ao fazer login: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Animation<T> _createAnimation<T>(
    T begin,
    T end,
    double start,
    double duration,
  ) {
    return Tween<T>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: _introAnimationController,
        curve: Interval(start, start + duration, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_backgroundAnimationController.value * 0.1),
                child: Transform.translate(
                  offset: Offset(_backgroundAnimationController.value * -20, 0),
                  child: child,
                ),
              );
            },
            child: SizedBox(
              height: screenHeight,
              width: screenWidth,
              child: Image.asset(
                'assets/img/login_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _createAnimation(0.0, 1.0, 0.2, 0.4),
                    child: SlideTransition(
                      position: _createAnimation(
                        const Offset(0, 0.5),
                        Offset.zero,
                        0.4,
                        0.6,
                      ),
                      child: Text(
                        localizations.appName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: _createAnimation(0.0, 1.0, 0.3, 0.5),
                    child: SlideTransition(
                      position: _createAnimation(
                        const Offset(0, 0.5),
                        Offset.zero,
                        0.4,
                        0.6,
                      ),
                      child: Text(
                        localizations.welcomeMessageTitle,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: -1,
                          shadows: [
                            Shadow(color: Colors.black38, blurRadius: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: _createAnimation(0.0, 1.0, 0.4, 0.6),
                    child: SlideTransition(
                      position: _createAnimation(
                        const Offset(0, 0.5),
                        Offset.zero,
                        0.4,
                        0.6,
                      ),
                      child: Text(
                        localizations.welcomeMessageSub,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.2,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.1),
                  FadeTransition(
                    opacity: _createAnimation(0.0, 1.0, 0.5, 0.5),
                    child: SlideTransition(
                      position: _createAnimation(
                        const Offset(0, 0.5),
                        Offset.zero,
                        0.4,
                        0.6,
                      ),
                      child: _buildActionSheet(context, colors),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSheet(BuildContext context, ColorScheme colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            24,
            32,
            24,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: colors.surface.withOpacity(0.1),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGoogleSignInButton(context),
              const SizedBox(height: 20),
              _buildPrivacyPolicyLink(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _handleSignIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        elevation: 0,
        minimumSize: const Size(double.infinity, 54),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/img/google_logo.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    AppLocalizations.of(context)!.googleLogin,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPrivacyPolicyLink(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Text.rich(
      TextSpan(
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        children: [
          TextSpan(text: "${localizations.acceptTerms} "),
          TextSpan(
            text: localizations.privacy,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final Uri url = Uri.parse(
                  'https://br-newsdroid.blogspot.com/p/politica-de-privacidade-tarefas.html',
                );
                try {
                  await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Não foi possível abrir o link: $e'),
                    ),
                  );
                }
              },
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
