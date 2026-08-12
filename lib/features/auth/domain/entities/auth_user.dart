import 'package:equatable/equatable.dart';

/// An authenticated context for the app — either a real, phone-verified user
/// or an anonymous guest who chose "Browse as Guest".
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    this.phoneNumber,
    this.displayName,
    this.isGuest = false,
  });

  /// Stable identifier. For guests this is a constant sentinel.
  final String id;

  /// E.164 phone number (e.g. `+970591234567`). `null` for guests.
  final String? phoneNumber;

  /// Optional display name (set later from the profile).
  final String? displayName;

  /// Whether this is an anonymous guest session.
  final bool isGuest;

  /// Sentinel id used for guest sessions.
  static const String guestId = 'guest';

  /// Convenience factory for an anonymous guest.
  factory AuthUser.guest() => const AuthUser(id: guestId, isGuest: true);

  @override
  List<Object?> get props => <Object?>[id, phoneNumber, displayName, isGuest];
}
