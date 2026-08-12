import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Sends an OTP to the given phone number.
class RequestOtp implements UseCase<Unit, RequestOtpParams> {
  const RequestOtp(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(RequestOtpParams params) =>
      _repository.requestOtp(params.phoneNumberE164);
}

class RequestOtpParams extends Equatable {
  const RequestOtpParams({required this.phoneNumberE164});

  final String phoneNumberE164;

  @override
  List<Object?> get props => <Object?>[phoneNumberE164];
}
