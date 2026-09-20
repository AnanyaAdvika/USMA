abstract class Failure implements Exception {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

class ServerFailure extends Failure {
  const ServerFailure([
    String message = 'Server error occurred. Please try again.',
  ]) : super(message, 'SERVER_ERROR');
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    String message = 'No internet connection. Please check your network.',
  ]) : super(message, 'NO_INTERNET');
}

class AuthFailure extends Failure {
  const AuthFailure([
    String message = 'Authentication failed. Please verify credentials.',
  ]) : super(message, 'AUTH_FAILED');
}

class ValidationFailure extends Failure {
  const ValidationFailure([
    String message = 'Please check the entered information.',
  ]) : super(message, 'VALIDATION_ERROR');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([
    String message = 'Requested resource not found.',
  ]) : super(message, 'NOT_FOUND');
}

class ConflictFailure extends Failure {
  const ConflictFailure([
    String message = 'A student may hold only one scholarship or fellowship at a time.',
  ]) : super(message, 'CONFLICT');
}

/// External or government system is not callable from this client.
class IntegrationFailure extends Failure {
  const IntegrationFailure([
    String message =
        'This integration is not available from the mobile app. Use the USMA backend.',
  ]) : super(message, 'INTEGRATION_UNAVAILABLE');
}

class ParseFailure extends Failure {
  const ParseFailure([
    String message = 'Could not read scheme or application data.',
  ]) : super(message, 'PARSE_ERROR');
}
