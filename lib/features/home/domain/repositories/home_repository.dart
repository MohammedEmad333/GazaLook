import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/promo_banner.dart';

/// Contract for home-screen content (promo banners).
abstract interface class HomeRepository {
  Future<Either<Failure, List<PromoBanner>>> getBanners();
}
