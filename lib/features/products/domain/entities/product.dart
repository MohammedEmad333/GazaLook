import 'package:equatable/equatable.dart';

import 'product_category.dart';

/// A catalog product.
///
/// Shared across the home grid (Phase 3) and the product detail page
/// (Phase 4), so it carries both list-level fields (price, thumbnail, rating)
/// and detail-level fields (image gallery, sizes, availability).
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.description = '',
    this.images = const <String>[],
    this.sizes = const <String>[],
    this.rating = 0,
    this.ratingCount = 0,
    this.oldPrice,
    this.isLocal = false,
    this.inStock = true,
    this.storeName,
  });

  final String id;
  final String name;

  /// Current price in Israeli Shekels (₪).
  final double price;

  /// Pre-discount price, when the item is on offer. `null` otherwise.
  final double? oldPrice;

  /// Primary thumbnail (used in the grid and cart).
  final String imageUrl;

  /// Full image gallery for the detail page. Falls back to [imageUrl].
  final List<String> images;

  final ProductCategory category;
  final String description;

  /// Available sizes (e.g. `['S','M','L','XL']`). Empty for one-size items.
  final List<String> sizes;

  final double rating;
  final int ratingCount;

  /// Whether to show the "محلي" (locally made) badge.
  final bool isLocal;

  /// Availability — drives the in-stock badge and add-to-cart affordance.
  final bool inStock;

  /// Optional local store name shown on the detail page.
  final String? storeName;

  /// Whether the product is currently discounted.
  bool get isOnOffer => oldPrice != null && oldPrice! > price;

  /// Gallery for the detail page, guaranteeing at least the thumbnail.
  List<String> get gallery => images.isNotEmpty ? images : <String>[imageUrl];

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        price,
        oldPrice,
        imageUrl,
        images,
        category,
        description,
        sizes,
        rating,
        ratingCount,
        isLocal,
        inStock,
        storeName,
      ];
}
