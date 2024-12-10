import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(AppLocalizations.of(context)!.notification),
        subtitle: Text(AppLocalizations.of(context)!.notificationSub),
        tileColor: Theme.of(context).listTileTheme.tileColor,
        onTap: () {
          AppSettings.openAppSettings(type: AppSettingsType.notification);
        });
  }
}
