import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Loads the persisted session on app start (`null` when signed out).
class GetCachedUser implements UseCase<AuthUser?, NoParams> {
  const GetCachedUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthUser?>> call(NoParams params) =>
      _repository.getCachedUser();
}
