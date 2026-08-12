import '../models/promo_banner_model.dart';

/// Source of home-screen content.
///
/// [MockHomeRemoteDataSource] serves the banners from the approved design.
/// Replace with a CMS/API source later without touching the repository.
abstract interface class HomeRemoteDataSource {
  Future<List<PromoBannerModel>> fetchBanners();
}

class MockHomeRemoteDataSource implements HomeRemoteDataSource {
  const MockHomeRemoteDataSource();

  static const Duration _latency = Duration(milliseconds: 500);

  @override
  Future<List<PromoBannerModel>> fetchBanners() async {
    await Future<void>.delayed(_latency);
    return _banners;
  }

  static const List<PromoBannerModel> _banners = <PromoBannerModel>[
    PromoBannerModel(
      id: 'b1',
      tag: 'جديدنا',
      title: 'وصل حديثاً',
      subtitle: 'اكتشف أحدث تشكيلات الموسم بألوان دافئة.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB7lv3DMgLuOmekpU5OHv6hZHEJgkFF26mITMBV_r5Zmi8ZUo4w33LXe_4umS63NTUN84gTTLnhoSUZcU-d18oKFcUKbiao_Y2-nJMMQGmTBCaas8rz7Fg4PuXyK1PM6UtybkKdFlPLHzeq7B6fQsrMeQOnV1IvijA7k-xhBOF9wIjxoXKOQOjljxN80hy31NzXBSDFz3WMQcCpmHvNX7NLDpdQFfVKfDNiLb_GmSR7xvWKxQUMAMFi',
    ),
    PromoBannerModel(
      id: 'b2',
      tag: 'تريند',
      title: 'صيحات الأسبوع',
      subtitle: 'القطع الأكثر مبيعاً هذا الأسبوع.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDXzw5aVi0vfOfQbwbscU_SkvE4hg1pM6uIttm0psJS1_ySp8l-Tv9H9MNioP9QRVT2MoxiX-1IpcvSaASB-HTKKuDLvh10li5CHFYMdOVCmzWOZPaqj3YSTXPkhXkQC4AcE6dawGieWVy33LRy5uueuU7aX9vEm-ac3UfMKwphMGrTigG-MvgncjIX9ViOJqQIujvBqQzYqSiADFhzBcyBdzdh-FM8b86qXZaFPaajGiAopmKNiznN',
    ),
    PromoBannerModel(
      id: 'b3',
      tag: 'فن محلي',
      title: 'مصممون محليون',
      subtitle: 'ادعم المواهب المحلية وتألق بلمستهم.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBj8gi5yTobNsq9nQbuTBSIW4VGaS5ZTVJa2vsKE01_q59RmcwqmW2AKCUSg5BcAFCzAHHyL_OfrfrAXaqyhPiTWjodM8vmSRSCD8F_wNDaiN1Yn2YUW1nftmlt4Kb0JvfNx-9xHquqQG1yEYWpB1YTQnkIZXQr0LDf2Z54so0qFafLCMP2HU6_udq61liE-jWSnxaf3H0X6D2DUlNMteqjHsdu_Hds3ZDas4wO2iVQX1MMon4lPFEM',
    ),
  ];
}
