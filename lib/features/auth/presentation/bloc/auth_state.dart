part of 'auth_bloc.dart';

/// High-level authentication status used to drive routing.
enum AuthStatus {
  /// Startup — cached session not yet resolved.
  unknown,

  /// No session — show login.
  unauthenticated,

  /// OTP sent — show the code entry screen.
  codeSent,

  /// Signed in (real user or guest) — show the app.
  authenticated,
}

/// Immutable auth state. A single class (rather than many) keeps the router's
/// redirect logic and the screens' `BlocListener`s simple.
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.pendingPhoneNumber,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final AuthStatus status;

  /// The signed-in user (present when [status] is [AuthStatus.authenticated]).
  final AuthUser? user;

  /// The phone number awaiting verification (present when [AuthStatus.codeSent]).
  final String? pendingPhoneNumber;

  /// Whether an async request (send OTP / verify / guest) is in flight.
  final bool isSubmitting;

  /// A transient, user-facing error message, or `null`.
  final String? errorMessage;

  const AuthState.unknown() : this();

  /// Builds the next state. `errorMessage` is intentionally NOT carried over by
  /// default — pass it explicitly to show an error, omit it to clear.
  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? pendingPhoneNumber,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      pendingPhoneNumber: pendingPhoneNumber ?? this.pendingPhoneNumber,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        user,
        pendingPhoneNumber,
        isSubmitting,
        errorMessage,
      ];
}
