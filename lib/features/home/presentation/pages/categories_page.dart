import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/cached_product_image.dart';
import '../../../products/domain/entities/product_category.dart';

/// The "التصنيفات" tab: a browsable grid of catalog sections. Tapping a card
/// opens [AppRoutes.categoryProducts] with the matching filter, so shoppers can
/// dive straight into نساء / رجال / أطفال / إكسسوارات or the عروض view.
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  /// The sections shown on this screen, in display order.
  static const List<_CategoryCardData> _sections = <_CategoryCardData>[
    _CategoryCardData(
      filter: CatalogFilter.women,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCt4YXtXixrL2joNCvGdju19WPt4iKc3XGRVtiRD62qgVQmZYmtsP5w1NjbyxYrYfZVYocJZc1mPhjzYyXmKKHhDwnU06m5YVXwbF0mA9WXXx3I1FI21AUaxmJov-tVgLFS-B8EemehKiBZjWqpRP2o9-npEn913aZrhY_AdpOT5JswYBE4-OTWMJmqUB-w4sN1uGcJX_vQNzbCwDZPT5sUP8iUKe4WCuZTCHVN-a1uDOeBTlB5uFGv',
    ),
    _CategoryCardData(
      filter: CatalogFilter.men,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD-sfwgEBMuXdl55-ziy-vWAueIFyBU0BeZwQo4LTr00CiRkcHCaRDhJlnB1Wm93DK1IeDfj73_d6za-8htIBmVns5Q01pTY7HgMfN_g8MlWF0wredZqMosWrs_288AuSjJtxnOGnFVG0Ay_EtbFz_sONQni2VonzjXDFa-zFlLTPunKoh6iGkLZCIVFdTRgZZiesbHNq70yOfK7XqChi2hFB3fmnfrsJ0g0Bf1baPHk3Q1B4YFACq5',
    ),
    _CategoryCardData(
      filter: CatalogFilter.kids,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB0K1w0lONBZGzqFBjKfQmYqvO0EtvhYNmDPi5y1TORFwNBxvEzdU02pfl44sweyA_FhNgQR7QomNiUEoZy15a3K7BeJyt5QAptexvZX_NpI2pebmmZPx3JhK6rKYS6P1dDIf9I7Gf9gn-tMMQ0gLORee-sG4KHUxFU1HQMuDMbrEnC0F3CLku8ddRPicydDbO1QBY1Rv1G8WM0P_-XZ51CwFJBw4rMERPh0CslepQU3wyjWJU955Xz',
    ),
    _CategoryCardData(
      filter: CatalogFilter.accessories,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBbqA-QhwczwyPyByCa3ap-UkZs4O0lK_osAFBFX1WqA0KSmiQ39WgakzexF2DBMdTfTmd-UBcsflLogoRGwld-38DPkyyQsj6n5ETueU2M-dC856OS2FowRulut5MTNtAUcvWIKS2IO1ymKyKsPPRcNkndf5V5icH7X328TRRUm1hwJ7vZOlFNoS-9bmwfUVk1Shi9s2D7IDHtsdZtVGGIOJfyAngH2iFVVCA3XOIRIenejBeE3YLm',
    ),
    _CategoryCardData(
      filter: CatalogFilter.offers,
      icon: Icons.local_offer_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التصنيفات')),
      bottomNavigationBar: const AppBottomNavBar(current: AppTab.categories),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppDimensions.containerMargin),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.gutter,
          mainAxisSpacing: AppDimensions.gutter,
          childAspectRatio: 0.9,
        ),
        itemCount: _sections.length,
        itemBuilder: (BuildContext context, int index) {
          final _CategoryCardData data = _sections[index];
          return _CategoryCard(
            data: data,
            onTap: () => context.push(
              AppRoutes.categoryProductsPath(data.filter.name),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCardData {
  const _CategoryCardData({
    required this.filter,
    this.imageUrl,
    this.icon,
  });

  final CatalogFilter filter;
  final String? imageUrl;
  final IconData? icon;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.data, required this.onTap});

  final _CategoryCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: AppDimensions.borderRadiusLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Imagery (network image for categories, tinted icon for عروض).
            if (data.imageUrl != null)
              CachedProductImage(imageUrl: data.imageUrl!)
            else
              Container(
                color: AppColors.primaryContainer,
                alignment: Alignment.center,
                child: Icon(
                  data.icon ?? Icons.category_outlined,
                  size: 48,
                  color: AppColors.onPrimaryContainer,
                ),
              ),

            // Legibility scrim behind the label.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: <Color>[Colors.black54, Colors.transparent],
                ),
              ),
            ),

            // Label.
            Padding(
              padding: const EdgeInsets.all(AppDimensions.componentPadding),
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Text(
                  data.filter.labelAr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
