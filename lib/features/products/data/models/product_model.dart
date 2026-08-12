import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';

/// Serialisable [Product] for the data layer (API / cart caching).
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.imageUrl,
    required super.category,
    super.description,
    super.images,
    super.sizes,
    super.rating,
    super.ratingCount,
    super.oldPrice,
    super.isLocal,
    super.inStock,
    super.storeName,
  });

  factory ProductModel.fromEntity(Product p) => ProductModel(
        id: p.id,
        name: p.name,
        price: p.price,
        imageUrl: p.imageUrl,
        category: p.category,
        description: p.description,
        images: p.images,
        sizes: p.sizes,
        rating: p.rating,
        ratingCount: p.ratingCount,
        oldPrice: p.oldPrice,
        isLocal: p.isLocal,
        inStock: p.inStock,
        storeName: p.storeName,
      );

  factory ProductModel.fromMap(Map<String, dynamic> map) => ProductModel(
        id: map['id'] as String,
        name: map['name'] as String,
        price: (map['price'] as num).toDouble(),
        imageUrl: map['imageUrl'] as String,
        category: ProductCategory.values.byName(map['category'] as String),
        description: (map['description'] as String?) ?? '',
        images:
            (map['images'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
        sizes:
            (map['sizes'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
        rating: (map['rating'] as num?)?.toDouble() ?? 0,
        ratingCount: (map['ratingCount'] as int?) ?? 0,
        oldPrice: (map['oldPrice'] as num?)?.toDouble(),
        isLocal: (map['isLocal'] as bool?) ?? false,
        inStock: (map['inStock'] as bool?) ?? true,
        storeName: map['storeName'] as String?,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'category': category.name,
        'description': description,
        'images': images,
        'sizes': sizes,
        'rating': rating,
        'ratingCount': ratingCount,
        'oldPrice': oldPrice,
        'isLocal': isLocal,
        'inStock': inStock,
        'storeName': storeName,
      };
}
