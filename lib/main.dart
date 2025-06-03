import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:tarefas/auth/auth.dart';
import 'package:tarefas/firebase_options.dart';
import 'package:tarefas/screens/login/login.dart';
import 'package:tarefas/theme/theme.dart';
import 'package:tarefas/updater/updater.dart';
import 'package:tarefas/widgets/bottom_navigation.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização do Firebase e Crashlytics
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Shorebird
  await ShorebirdUpdater().checkForUpdate();

  // Permissões para notificações
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS) {
    try {
      // Solicitar permissão para notificações no iOS
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()!
          .requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao solicitar permissão de notificação: $e");
      }
    }
  }

  // Solicitar permissão para notificações no Android
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()!
      .requestNotificationsPermission();

  // Desabilitar otimização de bateria
  if (Platform.isAndroid) {
    try {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao desabilitar otimização de bateria: $e");
      }
    }
  }

  // Inicialização do fuso horário
  tz.initializeTimeZones();

  runApp(
    BetterFeedback(
      theme: FeedbackThemeData.light(),
      darkTheme: FeedbackThemeData.dark(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalFeedbackLocalizationsDelegate(),
      ],
      localeOverride: const Locale('pt'),
      child: const MyApp(),
    ),
  );
}

ThemeMode _getThemeMode(ThemeModeType mode) {
  switch (mode) {
    case ThemeModeType.light:
      return ThemeMode.light;
    case ThemeModeType.dark:
      return ThemeMode.dark;
    case ThemeModeType.system:
      return ThemeMode.system;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final AuthService authService = AuthService();
  static bool _updateChecked = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
        builder: (_, themeModel, _) {
          return DynamicColorBuilder(
            builder: (lightColorScheme, darkColorScheme) {
              if (!themeModel.isDynamicColorsEnabled) {
                lightColorScheme = null;
                darkColorScheme = null;
              }

              return MaterialApp(
                theme: ThemeData(
                  brightness: Brightness.light,
                  colorScheme: lightColorScheme?.copyWith(
                    primary:
                        themeModel.isDarkMode ? Colors.black : Colors.black,
                  ),
                  useMaterial3: true,
                  textTheme: Typography().black.apply(
                    fontFamily: GoogleFonts.openSans().fontFamily,
                  ),
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  colorScheme: darkColorScheme?.copyWith(
                    primary:
                        themeModel.isDarkMode ? Colors.white : Colors.black,
                  ),
                  useMaterial3: true,
                  textTheme: Typography().white.apply(
                    fontFamily: GoogleFonts.openSans().fontFamily,
                  ),
                ),
                themeMode: _getThemeMode(themeModel.themeMode),
                debugShowCheckedModeBanner: false,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: _buildHome(context),
                routes: {
                  '/login': (context) => LoginScreen(authService: authService),
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    return FutureBuilder<User?>(
      future: MyApp.authService.currentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!MyApp._updateChecked) {
            MyApp._updateChecked = true;
            Updater.checkUpdateApp(context);
          }

          if (snapshot.hasData) {
            return const BottomNavigationContainer();
          } else {
            return LoginScreen(authService: MyApp.authService);
          }
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
      },
    );
  }
}
