import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Falha ao inicializar o Google Sign-In: $e');
      }
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  // Função para autenticação com Google
  Future<UserCredential?> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();
    try {
      final GoogleSignInAccount googleSignInAccount = await _googleSignIn
          .authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleSignInAccount.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Não foi possível obter o token de ID do Google.');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      if (kDebugMode) print('Erro na autenticação com Google: $e');
      await signOut();
      rethrow;
    }
  }

  // Função para logout do usuário
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      if (kDebugMode) print("Usuário desconectado com sucesso.");
    } catch (e) {
      if (kDebugMode) print("Erro ao desconectar usuário: $e");
    }
  }

  // Função para obter o usuário atualmente autenticado
  Future<User?> currentUser() async {
    return _auth.currentUser;
  }

  // Stream para monitorar alterações no estado de autenticação do usuário
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
