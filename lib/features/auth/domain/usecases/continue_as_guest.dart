import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Starts an anonymous guest session.
class ContinueAsGuest implements UseCase<AuthUser, NoParams> {
  const ContinueAsGuest(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthUser>> call(NoParams params) =>
      _repository.continueAsGuest();
}
