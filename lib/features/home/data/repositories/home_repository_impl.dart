import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/promo_banner.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

/// [HomeRepository] backed by a remote (currently mock) data source.
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({required HomeRemoteDataSource remote})
      : _remote = remote;

  final HomeRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<PromoBanner>>> getBanners() async {
    try {
      return Right(await _remote.fetchBanners());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
