import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/seed_data_service.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _db;
  final SeedDataService _seedService;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? db,
    SeedDataService? seedService,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _db = db ?? FirebaseFirestore.instance,
       _seedService = seedService ?? SeedDataService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        final userCredential = await _auth.signInWithPopup(googleProvider);
        if (userCredential.user != null) {
          await _ensureUserProfile(userCredential.user!);
        }
        return userCredential.user;
      }

      await _googleSignIn.initialize();

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user != null) {
        await _ensureUserProfile(user);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) debugPrint('Google Sign-In Auth Error: ${e.message}');
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Unexpected Sign-In Error: $e');
      return null;
    }
  }

  Future<void> _ensureUserProfile(User user) async {
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await _seedService.seedNewUser(
          user.uid,
          displayName: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
        );
      }
    } catch (e) {
      if (kDebugMode)
        debugPrint('Error provisioning starting profile & workouts: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  Future<bool> isSignedIn() async {
    return _auth.currentUser != null;
  }

  static String getHumanReadableAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account exists with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please check your credentials.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'Password should be at least 6 characters long.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a moment and try again.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
