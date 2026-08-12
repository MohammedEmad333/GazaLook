/// Catalog categories a product can belong to.
enum ProductCategory {
  women,
  men,
  kids,
  accessories;

  /// Arabic display label used on category strips and badges.
  String get labelAr => switch (this) {
        ProductCategory.women => 'نساء',
        ProductCategory.men => 'رجال',
        ProductCategory.kids => 'أطفال',
        ProductCategory.accessories => 'إكسسوارات',
      };
}

/// The chips shown under the home search bar. Unlike [ProductCategory] this
/// includes cross-cutting views ([all], [offers]) used purely for filtering.
enum CatalogFilter {
  all,
  women,
  men,
  kids,
  accessories,
  offers;

  /// Arabic label shown on the filter chip / category tap.
  String get labelAr => switch (this) {
        CatalogFilter.all => 'الكل',
        CatalogFilter.women => 'نساء',
        CatalogFilter.men => 'رجال',
        CatalogFilter.kids => 'أطفال',
        CatalogFilter.accessories => 'إكسسوارات',
        CatalogFilter.offers => 'عروض',
      };

  /// The subset shown as chips under the search bar (per the design).
  static const List<CatalogFilter> chips = <CatalogFilter>[
    CatalogFilter.all,
    CatalogFilter.women,
    CatalogFilter.men,
    CatalogFilter.kids,
    CatalogFilter.offers,
  ];

  /// The [CatalogFilter] that selects a given product [category].
  static CatalogFilter fromCategory(ProductCategory category) =>
      switch (category) {
        ProductCategory.women => CatalogFilter.women,
        ProductCategory.men => CatalogFilter.men,
        ProductCategory.kids => CatalogFilter.kids,
        ProductCategory.accessories => CatalogFilter.accessories,
      };
}
