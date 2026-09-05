import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        await _ensureUserProfile(user);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Google Sign-In Auth Error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unexpected Sign-In Error: $e');
      return null;
    }
  }

  Future<void> _ensureUserProfile(User user) async {
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await _db.collection('users').doc(user.uid).set(UserProfile(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName?.isNotEmpty == true ? user.displayName! : 'Athlete',
          photoUrl: user.photoURL,
          role: UserRole.athlete,
          createdAt: DateTime.now(),
        ).toMap());
      }
    } catch (e) {
      debugPrint('Error creating user profile document: $e');
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