import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/continue_as_guest.dart';
import '../../domain/usecases/get_cached_user.dart';
import '../../domain/usecases/request_otp.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/verify_otp.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Orchestrates the authentication flow: session restore → phone entry →
/// OTP verification → authenticated, plus guest browsing and sign-out.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required RequestOtp requestOtp,
    required VerifyOtp verifyOtp,
    required ContinueAsGuest continueAsGuest,
    required GetCachedUser getCachedUser,
    required SignOut signOut,
  })  : _requestOtp = requestOtp,
        _verifyOtp = verifyOtp,
        _continueAsGuest = continueAsGuest,
        _getCachedUser = getCachedUser,
        _signOut = signOut,
        super(const AuthState.unknown()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthOtpRequested>(_onOtpRequested);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthGuestRequested>(_onGuestRequested);
    on<AuthPhoneEntryRequested>(_onPhoneEntryRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final RequestOtp _requestOtp;
  final VerifyOtp _verifyOtp;
  final ContinueAsGuest _continueAsGuest;
  final GetCachedUser _getCachedUser;
  final SignOut _signOut;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getCachedUser(const NoParams());
    result.fold(
      (_) => emit(const AuthState(status: AuthStatus.unauthenticated)),
      (AuthUser? user) => emit(
        user == null
            ? const AuthState(status: AuthStatus.unauthenticated)
            : AuthState(status: AuthStatus.authenticated, user: user),
      ),
    );
  }

  Future<void> _onOtpRequested(
    AuthOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    final result = await _requestOtp(
      RequestOtpParams(phoneNumberE164: event.phoneNumberE164),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isSubmitting: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        AuthState(
          status: AuthStatus.codeSent,
          pendingPhoneNumber: event.phoneNumberE164,
        ),
      ),
    );
  }

  Future<void> _onOtpSubmitted(
    AuthOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final String? phone = state.pendingPhoneNumber;
    if (phone == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    emit(state.copyWith(isSubmitting: true));
    final result = await _verifyOtp(
      VerifyOtpParams(phoneNumberE164: phone, code: event.code),
    );
    result.fold(
      // Stay on the OTP screen and surface the error so the user can retry.
      (failure) => emit(
        AuthState(
          status: AuthStatus.codeSent,
          pendingPhoneNumber: phone,
          errorMessage: failure.message,
        ),
      ),
      (AuthUser user) =>
          emit(AuthState(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> _onGuestRequested(
    AuthGuestRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    final result = await _continueAsGuest(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isSubmitting: false,
          errorMessage: failure.message,
        ),
      ),
      (AuthUser user) =>
          emit(AuthState(status: AuthStatus.authenticated, user: user)),
    );
  }

  void _onPhoneEntryRequested(
    AuthPhoneEntryRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _signOut(const NoParams());
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
