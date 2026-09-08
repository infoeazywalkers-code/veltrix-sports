import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_exception.dart';

class ErrorHandler {
  ErrorHandler._();

  static String getUserMessage(Object error) {
    if (error is AppException) return error.userMessage;
    if (error is FirebaseAuthException) return _mapAuthError(error);
    if (error is FirebaseException) return _mapFirestoreError(error);
    if (error is SocketException)
      return 'No internet connection. Please check your network.';
    if (error is TimeoutException)
      return 'Operation timed out. Please try again.';
    if (error is FormatException) return 'Data format error. Please try again.';
    return 'Something went wrong. Please try again.';
  }

  static AppException classify(Object error) {
    if (error is AppException) return error;
    if (error is FirebaseException) return _classifyFirestore(error);
    if (error is FirebaseAuthException) return _classifyAuth(error);
    if (error is SocketException) return const NetworkException();
    if (error is TimeoutException) {
      return const NetworkException(
        message: 'Timeout',
        userMessage: 'Operation timed out. Please try again.',
      );
    }
    return FirestoreException(
      message: error.toString(),
      userMessage: 'Something went wrong. Please try again.',
    );
  }

  static AppException _classifyFirestore(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const FirestoreException(
          message: 'Permission denied',
          userMessage: 'You don\'t have permission to access this data.',
          code: 'permission-denied',
        );
      case 'not-found':
        return const FirestoreException(
          message: 'Document not found',
          userMessage: 'The requested data was not found.',
          code: 'not-found',
        );
      case 'unavailable':
        return const NetworkException(
          message: 'Service unavailable',
          userMessage: 'Service is temporarily unavailable. Please try again.',
          code: 'unavailable',
        );
      case 'deadline-exceeded':
        return const NetworkException(
          message: 'Deadline exceeded',
          userMessage: 'Request timed out. Please try again.',
          code: 'deadline-exceeded',
        );
      default:
        return FirestoreException(
          message: e.message ?? 'Firestore error',
          code: e.code,
        );
    }
  }

  static AppException _classifyAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException(
          message: 'User not found',
          userMessage: 'No account found with this email.',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AuthException(
          message: 'Wrong password',
          userMessage: 'Incorrect password. Please try again.',
          code: 'wrong-password',
        );
      case 'email-already-in-use':
        return const AuthException(
          message: 'Email already in use',
          userMessage: 'An account already exists with this email.',
          code: 'email-already-in-use',
        );
      case 'invalid-email':
        return const AuthException(
          message: 'Invalid email',
          userMessage: 'Please enter a valid email address.',
          code: 'invalid-email',
        );
      case 'user-disabled':
        return const AuthException(
          message: 'User disabled',
          userMessage: 'This account has been disabled.',
          code: 'user-disabled',
        );
      case 'too-many-requests':
        return const AuthException(
          message: 'Too many requests',
          userMessage: 'Too many attempts. Please try again later.',
          code: 'too-many-requests',
        );
      case 'network-request-failed':
        return const NetworkException(
          message: 'Network error',
          userMessage: 'Please check your internet connection.',
          code: 'network-request-failed',
        );
      default:
        return AuthException(message: e.message ?? 'Auth error', code: e.code);
    }
  }

  static String _mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You don\'t have permission to access this data.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'deadline-exceeded':
        return 'Request timed out. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  static String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Please check your internet connection.';
      case 'weak-password':
        return 'Something went wrong. Please try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  static Future<T> run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      throw classify(e);
    }
  }

  static Future<T> runWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) throw classify(e);
        if (e is SocketException || e is TimeoutException) {
          await Future.delayed(delay * attempts);
          continue;
        }
        throw classify(e);
      }
    }
  }
}
