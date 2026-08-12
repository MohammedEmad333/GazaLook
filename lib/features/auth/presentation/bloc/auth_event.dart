part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Emitted once on startup to restore any cached session.
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// User submitted their phone number; request an OTP.
final class AuthOtpRequested extends AuthEvent {
  const AuthOtpRequested({required this.phoneNumberE164});

  final String phoneNumberE164;

  @override
  List<Object?> get props => <Object?>[phoneNumberE164];
}

/// User submitted the OTP code they received.
final class AuthOtpSubmitted extends AuthEvent {
  const AuthOtpSubmitted({required this.code});

  final String code;

  @override
  List<Object?> get props => <Object?>[code];
}

/// User chose "Browse as Guest".
final class AuthGuestRequested extends AuthEvent {
  const AuthGuestRequested();
}

/// Returns from the OTP screen back to phone entry.
final class AuthPhoneEntryRequested extends AuthEvent {
  const AuthPhoneEntryRequested();
}

/// User signed out.
final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
