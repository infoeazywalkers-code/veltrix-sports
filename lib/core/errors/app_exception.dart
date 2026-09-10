sealed class AppException implements Exception {
  final String message;
  final String userMessage;
  final String? code;

  const AppException({
    required this.message,
    required this.userMessage,
    this.code,
  });

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  const NetworkException({
    String message = 'No internet connection',
    String userMessage = 'Please check your internet connection and try again.',
    String? code,
  }) : super(message: message, userMessage: userMessage, code: code);
}

class FirestoreException extends AppException {
  const FirestoreException({
    String message = 'Firestore operation failed',
    String userMessage =
        'Something went wrong saving your data. Please try again.',
    String? code,
  }) : super(message: message, userMessage: userMessage, code: code);
}

class AuthException extends AppException {
  const AuthException({
    String message = 'Authentication failed',
    String userMessage = 'Please sign in again.',
    String? code,
  }) : super(message: message, userMessage: userMessage, code: code);
}

class PermissionException extends AppException {
  const PermissionException({
    String message = 'Permission denied',
    String userMessage =
        'This feature requires permission. Please grant it in settings.',
    String? code,
  }) : super(message: message, userMessage: userMessage, code: code);
}

class ValidationException extends AppException {
  const ValidationException({
    String message = 'Validation failed',
    String userMessage = 'Please check your input and try again.',
    String? code,
  }) : super(message: message, userMessage: userMessage, code: code);
}

class PaymentException extends AppException {
  const PaymentException({
    String message = 'Payment failed',
    String userMessage =
        'Your payment could not be processed. Please try again.',
    String? code,
  }) : super(message: message, userMessage: userMessage, code: code);
}

class CacheException extends AppException {
  const CacheException({
    String message = 'Cache operation failed',
    String userMessage = 'Data could not be loaded from cache.',
    String? code,
  }) : super(message: message, userMessage: userMessage, code: code);
}
