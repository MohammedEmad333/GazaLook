import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

/// Contract for authentication + session persistence.
///
/// Implemented in the data layer; the current implementation uses a mocked OTP
/// provider that can be swapped for Firebase Auth / a real backend later.
abstract interface class AuthRepository {
  /// Requests an OTP be sent to [phoneNumberE164].
  Future<Either<Failure, Unit>> requestOtp(String phoneNumberE164);

  /// Verifies [code] for [phoneNumberE164]; on success caches + returns the user.
  Future<Either<Failure, AuthUser>> verifyOtp(
    String phoneNumberE164,
    String code,
  );

  /// Starts (and caches) an anonymous guest session.
  Future<Either<Failure, AuthUser>> continueAsGuest();

  /// Returns the cached session, or `null` if none exists.
  Future<Either<Failure, AuthUser?>> getCachedUser();

  /// Clears the cached session (sign out).
  Future<Either<Failure, Unit>> signOut();
}
