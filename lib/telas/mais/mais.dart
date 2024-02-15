import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tarefas/updater/updater.dart';
import 'package:url_launcher/url_launcher.dart';

class MaisScreen extends StatefulWidget {
  const MaisScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MaisScreenState createState() => _MaisScreenState();
}

class AccountUser extends StatelessWidget {
  final User? user;

  const AccountUser({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(user!.photoURL ?? ''),
              ),
            ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user!.displayName ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    user!.email ?? '',
                    style: const TextStyle(
                      color: Colors.grey,
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

class _MaisScreenState extends State<MaisScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  String appVersion = '';
  String appBuild = '';

  // Metodo para exibir a versao
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
        appBuild = packageInfo.buildNumber;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mais'),
      ),
      body: ListView(
        children: [
          AccountUser(user: _user),
          const Divider(),
          // Versao
          ListTile(
            title: const Text('Versão'),
            subtitle: Text('v$appVersion Build: ($appBuild)'),
            onTap: () {
              Updater.checkForUpdates(context);
            },
          ),
          ListTile(
            title: const Text(
              'Suporte',
            ),
            subtitle: const Text(
              'Encontrou um bug ou deseja sugerir algo? Entre em contato com a gente 😁',
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 140,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                MdiIcons.gmail,
                              ),
                              iconSize: 40,
                              tooltip: 'Gmail',
                              onPressed: () {
                                Navigator.pop(context);
                                launchUrl(
                                  Uri.parse(
                                    'mailto:hendrilmendes2015@gmail.com?subject=Tarefas&body=Gostaria%20de%20sugerir%20um%20recurso%20ou%20informar%20um%20bug.',
                                  ),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                            ),
                            const Text(
                              'Gmail',
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                MdiIcons.telegram,
                              ),
                              iconSize: 40,
                              tooltip: 'Telegram',
                              onPressed: () {
                                Navigator.pop(context);
                                launchUrl(
                                  Uri.parse(
                                    'https://t.me/hendril_mendes',
                                  ),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                            ),
                            const Text(
                              'Telegram',
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          // Licencas
          ListTile(
            title: const Text('Licenças de Código Aberto'),
            subtitle: const Text("Softwares usados na construção do app"),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Tarefas',
                applicationIcon: const Card(
                  elevation: 15,
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: 80,
                    child: Image(
                      image: AssetImage('assets/img/ic_launcher.png'),
                    ),
                  ),
                ),
              );
            },
          ),
          const Text(
            "Feito com ♥ por Hendril Mendes",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
