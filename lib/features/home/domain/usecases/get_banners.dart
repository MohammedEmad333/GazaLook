import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/promo_banner.dart';
import '../repositories/home_repository.dart';

/// Loads the home carousel banners.
class GetBanners implements UseCase<List<PromoBanner>, NoParams> {
  const GetBanners(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, List<PromoBanner>>> call(NoParams params) =>
      _repository.getBanners();
}
