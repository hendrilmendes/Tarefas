import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Função para autenticação com Google
  Future<User?> signInWithGoogle() async {
    try {
      // Verificação de conectividade
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.contains(ConnectivityResult.none)) {
        if (kDebugMode) print("Sem conexão com a internet");
        return null;
      }

      // Realizar login com Google
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        if (kDebugMode) print("Login cancelado pelo usuário.");
        return null;
      }

      // Autenticação no Firebase com as credenciais do Google
      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        if (kDebugMode) {
          print('Usuário autenticado com sucesso: ${user.displayName}');
        }
      } else {
        if (kDebugMode) print('Erro: Autenticação retornou usuário nulo.');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Erro do Firebase na autenticação: ${e.message}');
      return null;
    } on Exception catch (e) {
      if (kDebugMode) print('Erro desconhecido na autenticação: $e');
      return null;
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
