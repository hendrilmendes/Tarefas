import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:tarefas/utils/app_strings.dart';

import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_localizations;
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tarefas/l10n/app_localizations.dart';
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

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final themeModel = ThemeModel();
  await themeModel.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS) {
    try {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()!
          .requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      if (kDebugMode) {
        print("Error requesting notification permission: $e");
      }
    }
  }

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()!
      .requestNotificationsPermission();

  if (Platform.isAndroid) {
    try {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    } catch (e) {
      if (kDebugMode) {
        print("Error disabling battery optimization: $e");
      }
    }
  }

  tz.initializeTimeZones();

  runApp(MyApp(themeModel: themeModel));
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
  final ThemeModel themeModel;
  const MyApp({super.key, required this.themeModel});

  static final AuthService authService = AuthService();
  static bool _updateChecked = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeModel,
      child: Consumer<ThemeModel>(
        builder: (_, currentThemeModel, _) {
          final lightColorScheme = ColorScheme.fromSeed(
            seedColor: currentThemeModel.primaryColor,
            brightness: Brightness.light,
          );
          final darkColorScheme = ColorScheme.fromSeed(
            seedColor: currentThemeModel.primaryColor,
            brightness: Brightness.dark,
          );

          final actionIconTheme = ActionIconThemeData(
            backButtonIconBuilder: (BuildContext context) =>
                const Icon(Icons.arrow_back_ios_new, size: 20),
          );

          const chipTheme = ChipThemeData(shape: StadiumBorder());

          const pageTransitionsTheme = PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          );

          return MaterialApp(
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: lightColorScheme,
              useMaterial3: true,
              actionIconTheme: actionIconTheme,
              chipTheme: chipTheme,
              pageTransitionsTheme: pageTransitionsTheme,
              textTheme: Typography().black.apply(
                fontFamily: GoogleFonts.inter().fontFamily,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: darkColorScheme,
              useMaterial3: true,
              actionIconTheme: actionIconTheme,
              chipTheme: chipTheme,
              pageTransitionsTheme: pageTransitionsTheme,
              textTheme: Typography().white.apply(
                fontFamily: GoogleFonts.inter().fontFamily,
              ),
            ),
            themeMode: _getThemeMode(currentThemeModel.themeMode),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
              flutter_localizations.GlobalMaterialLocalizations.delegate,
              flutter_localizations.GlobalWidgetsLocalizations.delegate,
              flutter_localizations.GlobalCupertinoLocalizations.delegate,
            ],
            locale: currentThemeModel.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              final l10n = AppLocalizations.of(context);
              if (l10n != null) S.update(l10n);
              return child ?? const SizedBox.shrink();
            },
            home: _buildHome(context),
            routes: {
              '/login': (context) => LoginScreen(authService: authService),
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
