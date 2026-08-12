import 'package:equatable/equatable.dart';

/// Base type for all recoverable, user-facing failures.
///
/// The domain/data layers return `Either<Failure, T>` (via dartz) instead of
/// throwing, so the presentation layer always has a typed, message-bearing
/// error to render gracefully.
sealed class Failure extends Equatable {
  const Failure(this.message);

  /// Human-readable, localisation-ready message (Arabic by default).
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// A remote/server-side problem (network, backend, OTP provider…).
final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الاتصال. حاول مرة أخرى.']);
}

/// A local cache/storage problem (reading or writing the session).
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'تعذّر الوصول إلى البيانات المحفوظة.']);
}

/// Invalid user input (e.g. malformed phone number or wrong OTP).
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Authentication-specific failure (wrong code, expired session…).
final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'فشلت عملية المصادقة.']);
}
