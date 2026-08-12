import '../../../../core/error/exceptions.dart';
import '../../domain/entities/product_category.dart';
import '../models/product_model.dart';

/// Source of catalog products.
///
/// [MockProductRemoteDataSource] serves a hand-authored catalog (with real
/// imagery from the design) so the whole app is demoable offline. Replace it
/// with an API/Firestore-backed source later — the repository is unaffected.
abstract interface class ProductRemoteDataSource {
  Future<List<ProductModel>> fetchProducts();
  Future<ProductModel> fetchProductById(String id);
}

class MockProductRemoteDataSource implements ProductRemoteDataSource {
  const MockProductRemoteDataSource();

  static const Duration _latency = Duration(milliseconds: 700);

  @override
  Future<List<ProductModel>> fetchProducts() async {
    await Future<void>.delayed(_latency);
    return _catalog;
  }

  @override
  Future<ProductModel> fetchProductById(String id) async {
    await Future<void>.delayed(_latency);
    final matches = _catalog.where((ProductModel p) => p.id == id);
    if (matches.isEmpty) {
      throw const ServerException('Product not found');
    }
    return matches.first;
  }

  // ---------------------------------------------------------------------------
  // Demo catalog — imagery reused from the approved design mock-ups.
  // ---------------------------------------------------------------------------
  static const List<ProductModel> _catalog = <ProductModel>[
    ProductModel(
      id: 'p1',
      name: 'فستان صيفي حريري',
      price: 120,
      category: ProductCategory.women,
      description:
          'فستان صيفي انسيابي من الحرير بألوان دافئة، مثالي للإطلالات النهارية.',
      rating: 4.8,
      ratingCount: 124,
      isLocal: true,
      sizes: <String>['S', 'M', 'L', 'XL'],
      storeName: 'متجر خيوط، مدينة غزة',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCY97bZpTGs7HxBwOvhwOWHH6cFtAP1lRIPm2KAZf4upTol9It-8lCUpU21treg5Sj03yf99MQ0g_0F6Q5ewzIZwKRAM_lEpNMKv1ZjM1ipqcLuL-TBAAwNktXX0_2SrzJv36aUBANcJ0H8SWDPNQOkNR-yrFIrM0k2_Ov-W3bBeuCi4-156wj71vE2kOWe7aEIQznSrzuwBjpRmWkashMnVtfNAlb1qdBDnrjlIUEixRmJ_laSxMmG',
    ),
    ProductModel(
      id: 'p2',
      name: 'حقيبة جلد كلاسيكية',
      price: 250,
      category: ProductCategory.accessories,
      description: 'حقيبة يد من الجلد الطبيعي بتصميم كلاسيكي أنيق ومساحة واسعة.',
      rating: 4.6,
      ratingCount: 88,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBcjHtacD2VxZcUjv76ky7as1W6aWJ7_TCgtfTWA6CrwgP7YDftu0ihK1aKpFOyWFbJGAwqEtpy5dJeLZEs6G5fC7kN6bgD56UdPkcmpeWzjCvQxzRSpDEMbuvb37N52Go_vlnaF7gPNDh9GtoLKZqZ7_l7QneL8wAZ7M4_LTPcG5DN-4QAW-35QEY20nWOEEkmVuNvLYlTkFseSP5Rr4ny-Wp59enoIBZtkypoW0Ag9Gi_Ey8Jk50G',
    ),
    ProductModel(
      id: 'p3',
      name: 'قميص كتان خفيف',
      price: 95,
      oldPrice: 130,
      category: ProductCategory.men,
      description: 'قميص كتان خفيف ومريح مناسب لأجواء الصيف، بقصة عصرية.',
      rating: 4.4,
      ratingCount: 61,
      sizes: <String>['M', 'L', 'XL'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDV9g4PrdXvWeZkgMdk1HKvUIMLtGyKBVF8tfGLrLr0-n7H29651ByzDTausHJ1g1bUO94PuTq0Oy903giH-yI1rMbUeieu9N8t0H9M90UE9A16nJ5lNO_vptPYocOyCzMzd0pGvtXfqQNgei_Tq9pSaTU8Uh-0j5AEA6k8SONKvV07xbkmQaIst1nMTQB15XfoQkNHSiQY5FzyN3w1lFuHCFR4pT2vG7FKxkacnUfhag3_Nub31ZXS',
    ),
    ProductModel(
      id: 'p4',
      name: 'أقراط سيراميك يدوية',
      price: 45,
      category: ProductCategory.accessories,
      description: 'أقراط سيراميك مصنوعة يدوياً بألوان باستيلية هادئة.',
      rating: 4.9,
      ratingCount: 203,
      isLocal: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBwIvwOJ2bD9ms-VyX6TR42A2POTUgQTNGAUNZoekEgugxpLy9iuPEZZXgvhtgS79Op14Es__1tA556p8why9MwTJyufY28wcP7HIeEx5g9x8ohRuG4STfoCJPAV_7zX4asv898giPdOImoCydmki8dAkyjJ_DBClfUtGD3Jt4vYwZFphxqVc_NXIfna1FnC98676lMEqL8hvfOtrGldPRDrUyNHMW1PgmQAmf9EZVq0xqsEmE1N-V0',
    ),
    ProductModel(
      id: 'p5',
      name: 'فستان تطريز عصري - يافا',
      price: 350,
      category: ProductCategory.women,
      description:
          'فستان يافا يجمع بين الأصالة والحداثة، كتان مريح مع تطريز يدوي متقن.',
      rating: 5.0,
      ratingCount: 47,
      isLocal: true,
      sizes: <String>['S', 'M', 'L', 'XL'],
      storeName: 'متجر خيوط، مدينة غزة',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAJWsVwQfc9o3QwNgs9_NXZPm72jeONNHA2-ZL45-_7GeByomKXNy7zproG5G2B-rN6JNeXQeFmX1d2dnWD7ewqkbh0n01Zf4PYuBEzXmFp91M0XObm_XKoko1nU4I7Ky4PcLPzAu9iK-yYnX2hLYJeEhHaul1eYGqoxlcu7CF1uXXwGjaNDyyUPApq48kFG-Uul4bfaELfS6IIolteTBBrQker9QEiWxM9QJfkg3m8WGNAHA1lzBMB',
    ),
    ProductModel(
      id: 'p6',
      name: 'ثوب مطرز كلاسيكي',
      price: 250,
      category: ProductCategory.women,
      description: 'ثوب فلسطيني مطرز بغرزة الصليب التقليدية بألوان حمراء وسوداء.',
      rating: 4.7,
      ratingCount: 156,
      isLocal: true,
      sizes: <String>['M', 'L', 'XL'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCTFtVz69h2t8iamgbYyxX8B-bbmiq5yMw_CkMUVyF_oXfirA_kuvi-cV0bTm-VxcFLjc0_PshsYLcrSIB831UuL2WOjcbii77TSbyrj17FSX0lp5-InnXLeLJJTK3NNNExgjbIVgD2m_P2cXh-1cD_3h2PFClyJvv_dzYMAdidIUR28Db3GjHmcQpr0SRVgFt96sOYiEyzbpwui7Zhli9LYeI6ImtQOQO6xJbBWTDeu9d-gURWMsjV',
    ),
    ProductModel(
      id: 'p7',
      name: 'حقيبة قماشية بتطريز حديث',
      price: 120,
      oldPrice: 160,
      category: ProductCategory.accessories,
      description: 'حقيبة يد قماشية بيج مع تطريز فلسطيني عصري وردي وبني.',
      rating: 4.5,
      ratingCount: 72,
      isLocal: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDVd67T6-UpWupmv9Vf-sXtTl_tGxhGvhSrubqAQCPKW1o-FWS5_B90byko9RwmI9LB-3t-xKSFsDhnBtbcJMQHoLCSXzKBO9XhU6Gpt4xx-wbtxxsYaHfcwGUROsoswBVCrJ64EFv8qCXy_VT-P2HZeEMrY-H8PyH-o4XIlPS1oTpZdtbqMbQQH6keMeUPayebb1qWgxOCNX_oxH-M37ajI-OUQJVjWmnQudZd2zStwamT_R0ySdKe',
    ),
    ProductModel(
      id: 'p8',
      name: 'بلوزة حرير وردية',
      price: 140,
      category: ProductCategory.women,
      description: 'بلوزة حرير ناعمة بلون وردي باستيلي بقصة أنيقة ومريحة.',
      rating: 4.3,
      ratingCount: 39,
      sizes: <String>['S', 'M', 'L'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCt4YXtXixrL2joNCvGdju19WPt4iKc3XGRVtiRD62qgVQmZYmtsP5w1NjbyxYrYfZVYocJZc1mPhjzYyXmKKHhDwnU06m5YVXwbF0mA9WXXx3I1FI21AUaxmJov-tVgLFS-B8EemehKiBZjWqpRP2o9-npEn913aZrhY_AdpOT5JswYBE4-OTWMJmqUB-w4sN1uGcJX_vQNzbCwDZPT5sUP8iUKe4WCuZTCHVN-a1uDOeBTlB5uFGv',
    ),
    ProductModel(
      id: 'p9',
      name: 'قميص كتان بيج للرجال',
      price: 110,
      category: ProductCategory.men,
      description: 'قميص كتان بلون بيج فاتح بملمس ناعم وإطلالة كلاسيكية.',
      rating: 4.2,
      ratingCount: 28,
      sizes: <String>['M', 'L', 'XL'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD-sfwgEBMuXdl55-ziy-vWAueIFyBU0BeZwQo4LTr00CiRkcHCaRDhJlnB1Wm93DK1IeDfj73_d6za-8htIBmVns5Q01pTY7HgMfN_g8MlWF0wredZqMosWrs_288AuSjJtxnOGnFVG0Ay_EtbFz_sONQni2VonzjXDFa-zFlLTPunKoh6iGkLZCIVFdTRgZZiesbHNq70yOfK7XqChi2hFB3fmnfrsJ0g0Bf1baPHk3Q1B4YFACq5',
    ),
    ProductModel(
      id: 'p10',
      name: 'كنزة أطفال صوفية',
      price: 75,
      oldPrice: 95,
      category: ProductCategory.kids,
      description: 'كنزة صوفية دافئة للأطفال بلون أصفر ناعم وملمس مريح.',
      rating: 4.8,
      ratingCount: 54,
      sizes: <String>['2-3Y', '4-5Y', '6-7Y'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB0K1w0lONBZGzqFBjKfQmYqvO0EtvhYNmDPi5y1TORFwNBxvEzdU02pfl44sweyA_FhNgQR7QomNiUEoZy15a3K7BeJyt5QAptexvZX_NpI2pebmmZPx3JhK6rKYS6P1dDIf9I7Gf9gn-tMMQ0gLORee-sG4KHUxFU1HQMuDMbrEnC0F3CLku8ddRPicydDbO1QBY1Rv1G8WM0P_-XZ51CwFJBw4rMERPh0CslepQU3wyjWJU955Xz',
    ),
    ProductModel(
      id: 'p11',
      name: 'قلادة ذهبية بسيطة',
      price: 60,
      category: ProductCategory.accessories,
      description: 'قلادة ذهبية بتصميم مينيمال أنيق يناسب كل الإطلالات.',
      rating: 4.6,
      ratingCount: 91,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBbqA-QhwczwyPyByCa3ap-UkZs4O0lK_osAFBFX1WqA0KSmiQ39WgakzexF2DBMdTfTmd-UBcsflLogoRGwld-38DPkyyQsj6n5ETueU2M-dC856OS2FowRulut5MTNtAUcvWIKS2IO1ymKyKsPPRcNkndf5V5icH7X328TRRUm1hwJ7vZOlFNoS-9bmwfUVk1Shi9s2D7IDHtsdZtVGGIOJfyAngH2iFVVCA3XOIRIenejBeE3YLm',
    ),
    ProductModel(
      id: 'p12',
      name: 'فستان أطفال قطني',
      price: 85,
      category: ProductCategory.kids,
      description: 'فستان قطني ناعم للأطفال بألوان زاهية مريح للحركة واللعب.',
      rating: 4.5,
      ratingCount: 33,
      inStock: false,
      sizes: <String>['2-3Y', '4-5Y'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCt4YXtXixrL2joNCvGdju19WPt4iKc3XGRVtiRD62qgVQmZYmtsP5w1NjbyxYrYfZVYocJZc1mPhjzYyXmKKHhDwnU06m5YVXwbF0mA9WXXx3I1FI21AUaxmJov-tVgLFS-B8EemehKiBZjWqpRP2o9-npEn913aZrhY_AdpOT5JswYBE4-OTWMJmqUB-w4sN1uGcJX_vQNzbCwDZPT5sUP8iUKe4WCuZTCHVN-a1uDOeBTlB5uFGv',
    ),
  ];
}
