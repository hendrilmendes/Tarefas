import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tarefas/auth/auth.dart';
import 'package:tarefas/theme/theme.dart';
import 'package:tarefas/widgets/settings/about.dart';
import 'package:tarefas/widgets/settings/accounts.dart';
import 'package:tarefas/widgets/settings/category.dart';
import 'package:tarefas/widgets/settings/dynamic_colors.dart';
import 'package:tarefas/widgets/settings/notification.dart';
import 'package:tarefas/widgets/settings/review.dart';
import 'package:tarefas/widgets/settings/support.dart';
import 'package:tarefas/widgets/settings/theme.dart';
import 'package:tarefas/widgets/settings/update.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final User? _user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        actions: [
          IconButton(
            color: Colors.blue,
            icon: const Icon(Icons.exit_to_app_outlined),
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: AppLocalizations.of(context)!.desconect,
          ),
        ],
      ),
      body: ListView(
        children: [
          AccountUser(user: _user),
          const Divider(),
          buildCategoryHeader(AppLocalizations.of(context)!.notification,
              Icons.notifications_outlined),
          const NotificationSettings(),
          buildCategoryHeader(
              AppLocalizations.of(context)!.interface, Icons.palette_outlined),
          ThemeSettings(themeModel: themeModel),
          const DynamicColorsSettings(),
          buildCategoryHeader(
              AppLocalizations.of(context)!.outhers, Icons.more_horiz_outlined),
          buildUpdateSettings(context),
          buildReviewSettings(context),
          buildSupportSettings(context),
          buildAboutSettings(context),
        ],
      ),
    );
  }
}
