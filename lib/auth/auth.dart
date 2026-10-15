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
        print('Failed to initialize Google Sign-In: $e');
      }
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();
    try {
      final GoogleSignInAccount googleSignInAccount = await _googleSignIn
          .authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleSignInAccount.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Could not obtain the Google ID token.');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      if (kDebugMode) print('Google authentication error: $e');
      await signOut();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      if (kDebugMode) print("User signed out successfully.");
    } catch (e) {
      if (kDebugMode) print("Error signing out user: $e");
    }
  }

  Future<User?> currentUser() async {
    return _auth.currentUser;
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
