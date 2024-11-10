import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tarefas/screens/about/about.dart';

Widget buildAboutSettings(BuildContext context) {
  return Card(
    elevation: 3,
    clipBehavior: Clip.hardEdge,
    margin: const EdgeInsets.all(8.0),
    child: ListTile(
      title: Text(AppLocalizations.of(context)!.about),
      subtitle: Text(AppLocalizations.of(context)!.aboutSub),
      leading: const Icon(Icons.info_outlined),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutPage()),
        );
      },
    ),
  );
}
