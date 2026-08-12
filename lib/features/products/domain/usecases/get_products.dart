import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../entities/product_category.dart';
import '../repositories/product_repository.dart';

/// Fetches the catalog, optionally filtered by category / offers.
class GetProducts implements UseCase<List<Product>, GetProductsParams> {
  const GetProducts(this._repository);

  final ProductRepository _repository;

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsParams params) =>
      _repository.getProducts(filter: params.filter);
}

class GetProductsParams extends Equatable {
  const GetProductsParams({this.filter = CatalogFilter.all});

  final CatalogFilter filter;

  @override
  List<Object?> get props => <Object?>[filter];
}
