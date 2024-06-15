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
import 'package:provider/provider.dart';
import 'package:tarefas/auth/auth.dart';
import 'package:tarefas/firebase_options.dart';
import 'package:tarefas/screens/login/login.dart';
import 'package:tarefas/theme/theme.dart';
import 'package:tarefas/widgets/botton_navigation.dart';
import 'package:timezone/data/latest_all.dart' as tz;

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
      .requestNotificationsPermission();

  await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
  
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return ChangeNotifierProvider(
        create: (_) => ThemeModel(),
        child: Consumer<ThemeModel>(builder: (_, themeModel, __) {
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
                  textTheme: Typography().black.apply(fontFamily: 'OpenSans'),
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  colorScheme: darkColorScheme?.copyWith(
                    primary:
                        themeModel.isDarkMode ? Colors.white : Colors.black,
                  ),
                  useMaterial3: true,
                  textTheme: Typography().white.apply(fontFamily: 'OpenSans'),
                ),
                themeMode: _getThemeMode(themeModel.themeMode),
                debugShowCheckedModeBanner: false,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: FutureBuilder(
                  future: authService.currentUser(),
                  builder: (context, AsyncSnapshot<User?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return const BottomNavigationContainer();
                      } else {
                        return LoginScreen(
                          authService: authService,
                        );
                      }
                    } else {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
                    }
                  },
                ),
                routes: {
                  '/login': (context) => LoginScreen(authService: authService),
                });
          });
        }),
      );
    });
  }
}
