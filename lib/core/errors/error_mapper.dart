import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'failures.dart';

class ErrorMapper {
  static Failure map(Object error) {
    if (error is Failure) return error;

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return const AuthFailure('No account found with these details.');
        case 'wrong-password':
          return const AuthFailure('Incorrect password.');
        case 'invalid-phone-number':
          return const AuthFailure('Invalid mobile number format.');
        case 'invalid-verification-code':
          return const AuthFailure('Invalid OTP entered.');
        case 'session-expired':
          return const AuthFailure('OTP has expired. Please request a new one.');
        case 'too-many-requests':
          return const AuthFailure(
            'Too many attempts. Please wait a few moments.',
          );
        default:
          return AuthFailure(error.message ?? 'Authentication error.');
      }
    }

    if (error is FirebaseException) {
      return ServerFailure(error.message ?? 'Database operation failed.');
    }

    if (error is PlatformException) {
      return ServerFailure(error.message ?? 'A platform error occurred.');
    }

    return ServerFailure(error.toString());
  }
}
