import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Fetches a single product (used by the detail page in Phase 4).
class GetProductById implements UseCase<Product, GetProductByIdParams> {
  const GetProductById(this._repository);

  final ProductRepository _repository;

  @override
  Future<Either<Failure, Product>> call(GetProductByIdParams params) =>
      _repository.getProductById(params.id);
}

class GetProductByIdParams extends Equatable {
  const GetProductByIdParams({required this.id});

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
