import '../../../../core/error/exceptions.dart';
import '../models/auth_user_model.dart';

/// Sends and verifies OTP codes.
///
/// The current implementation ([MockAuthRemoteDataSource]) simulates an SMS
/// provider so the full flow works end-to-end without a backend. Swap it for a
/// Firebase Auth phone provider (or the store's SMS gateway) later — the
/// repository and everything above it stay unchanged.
abstract interface class AuthRemoteDataSource {
  /// "Sends" an OTP to [phoneNumberE164].
  Future<void> requestOtp(String phoneNumberE164);

  /// Verifies [code]; returns the authenticated user on success.
  Future<AuthUserModel> verifyOtp(String phoneNumberE164, String code);
}

/// A backend-free mock. Accepts a fixed demo code and simulates latency.
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  const MockAuthRemoteDataSource();

  /// The code accepted while running against the mock provider.
  /// Surfaced as a hint on the OTP screen in debug builds.
  static const String demoCode = '0000';

  static const Duration _latency = Duration(milliseconds: 900);

  @override
  Future<void> requestOtp(String phoneNumberE164) async {
    await Future<void>.delayed(_latency);
    // A real provider would enqueue an SMS here and could throw on failure.
    if (phoneNumberE164.replaceAll(RegExp(r'[^0-9]'), '').length < 11) {
      throw const ServerException('Invalid phone number');
    }
  }

  @override
  Future<AuthUserModel> verifyOtp(String phoneNumberE164, String code) async {
    await Future<void>.delayed(_latency);
    if (code != demoCode) {
      throw const InvalidOtpException();
    }
    return AuthUserModel(
      id: phoneNumberE164,
      phoneNumber: phoneNumberE164,
    );
  }
}
