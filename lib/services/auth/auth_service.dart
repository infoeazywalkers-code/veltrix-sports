import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../core/seed_data_service.dart';

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

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
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
      throw AuthException(
        message: e.code,
        userMessage: ErrorHandler.getUserMessage(e),
        code: e.code,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Unexpected Sign-In Error: $e');
      throw AuthException(
        message: e.toString(),
        userMessage: ErrorHandler.getUserMessage(e),
      );
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _ensureUserProfile(userCredential.user!);
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.code,
        userMessage: ErrorHandler.getUserMessage(e),
        code: e.code,
      );
    }
  }

  Future<User?> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        if (displayName != null && displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
        }
        await _ensureUserProfile(userCredential.user!);
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.code,
        userMessage: ErrorHandler.getUserMessage(e),
        code: e.code,
      );
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
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
      } else {
        // Backfill real identity when the doc has dummy/missing fields
        // (e.g. created by onboarding before auth profile was known).
        final data = doc.data() ?? {};
        final patch = <String, dynamic>{};
        if ((data['displayName'] as String?)?.isNotEmpty != true &&
            (user.displayName?.isNotEmpty == true)) {
          patch['displayName'] = user.displayName;
        }
        if ((data['email'] as String?)?.isNotEmpty != true &&
            (user.email?.isNotEmpty == true)) {
          patch['email'] = user.email;
        }
        if (data['photoUrl'] == null && user.photoURL != null) {
          patch['photoUrl'] = user.photoURL;
        }
        if (patch.isNotEmpty) {
          await _db
              .collection('users')
              .doc(user.uid)
              .set(patch, SetOptions(merge: true));
        }
      }
    } catch (e) {
      if (kDebugMode)
        debugPrint('Error provisioning starting profile & workouts: $e');
    }
  }

  Future<void> signOut() async {
    // Provider sign-out must never block or fail the Firebase sign-out
    // (e.g. GoogleSignIn was never initialized in this session on web and
    // can hang). Time-box it, then always sign out of Firebase.
    try {
      await _googleSignIn.signOut().timeout(const Duration(seconds: 4));
    } catch (_) {}
    try {
      await _auth.signOut().timeout(const Duration(seconds: 8));
    } catch (e) {
      throw AuthException(
        message: e.toString(),
        userMessage: ErrorHandler.getUserMessage(e),
      );
    }
  }

  Future<bool> isSignedIn() async {
    return _auth.currentUser != null;
  }

  static String getHumanReadableAuthError(Object error) {
    return ErrorHandler.getUserMessage(error);
  }
}
