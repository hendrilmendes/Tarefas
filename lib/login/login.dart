import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tarefas/auth/auth.dart';
import 'package:tarefas/home/home.dart';

class LoginScreen extends StatelessWidget {
  final AuthService authService;

  const LoginScreen({required this.authService, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.teal],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/img/google_logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final user = await authService.signInWithGoogle();
                  if (user != null) {
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const HomeScreen(),
                      ),
                    );
                    if (kDebugMode) {
                      print('Usuário autenticado: ${user.displayName}');
                    }
                  } else {
                    // Tratar falha na autenticação
                    if (kDebugMode) {
                      print('Falha na autenticação');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/img/google_logo.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Login com o Google',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
