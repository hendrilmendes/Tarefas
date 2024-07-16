import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;

  bool _isAndroid12 = false;

  @override
  void initState() {
    super.initState();
    _checkAndroidVersion();
  }

  Future<void> _checkAndroidVersion() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final version = androidInfo.version.sdkInt;
      setState(() {
        _isAndroid12 = version >= 31;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          AccountUser(user: _user),
          buildCategoryHeader(AppLocalizations.of(context)!.notification,
              Icons.notifications_outlined),
          const NotificationSettings(),
          buildCategoryHeader(
              AppLocalizations.of(context)!.interface, Icons.palette_outlined),
          ThemeSettings(themeModel: themeModel),
          if (_isAndroid12) const DynamicColorsSettings(),
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
