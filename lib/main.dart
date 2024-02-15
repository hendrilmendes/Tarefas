import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarefas/auth/auth.dart';
import 'package:tarefas/firebase_options.dart';
import 'package:tarefas/telas/login/login.dart';
import 'package:tarefas/tema/tema.dart';
import 'package:tarefas/widgets/botton_navigation.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return ChangeNotifierProvider(
        create: (_) => ThemeModel(),
        child: Consumer<ThemeModel>(builder: (_, theme, __) {
          return MaterialApp(
              theme: ThemeData(
                brightness: Brightness.light,
                colorScheme: lightColorScheme?.copyWith(
                  primary: theme.isDarkMode ? Colors.black : Colors.black,
                ),
                useMaterial3: true,
                textTheme: Typography().black.apply(),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: darkColorScheme?.copyWith(
                  primary: theme.isDarkMode ? Colors.white : Colors.black,
                ),
                useMaterial3: true,
                textTheme: Typography().white.apply(),
              ),
              themeMode: theme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              debugShowCheckedModeBanner: false,
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
        }),
      );
    });
  }
}
