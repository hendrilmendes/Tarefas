import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Permissões para notificações
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
      .requestNotificationsPermission();

  // Desabilitar otimização de bateria
  await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();

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

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
        builder: (_, themeModel, __) {
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
                  textTheme: Typography()
                      .black
                      .apply(fontFamily: GoogleFonts.openSans().fontFamily),
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  colorScheme: darkColorScheme?.copyWith(
                    primary:
                        themeModel.isDarkMode ? Colors.white : Colors.black,
                  ),
                  useMaterial3: true,
                  textTheme: Typography()
                      .white
                      .apply(fontFamily: GoogleFonts.openSans().fontFamily),
                ),
                themeMode: _getThemeMode(themeModel.themeMode),
                debugShowCheckedModeBanner: false,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: _buildHome(authService),
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

  Widget _buildHome(AuthService authService) {
    return FutureBuilder<User?>(
      future: authService.currentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            Updater.checkUpdateApp(context);
            return const BottomNavigationContainer();
          } else {
            Updater.checkUpdateApp(context);
            return LoginScreen(authService: authService);
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }
      },
    );
  }
}
