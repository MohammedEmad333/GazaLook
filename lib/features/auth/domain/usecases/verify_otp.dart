import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Verifies the OTP code and returns the authenticated user.
class VerifyOtp implements UseCase<AuthUser, VerifyOtpParams> {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthUser>> call(VerifyOtpParams params) =>
      _repository.verifyOtp(params.phoneNumberE164, params.code);
}

class VerifyOtpParams extends Equatable {
  const VerifyOtpParams({
    required this.phoneNumberE164,
    required this.code,
  });

  final String phoneNumberE164;
  final String code;

  @override
  List<Object?> get props => <Object?>[phoneNumberE164, code];
}
