import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../products/domain/entities/product_category.dart';
import '../../../products/presentation/bloc/products_bloc.dart';

/// Circular category shortcuts (نساء / رجال / أطفال / إكسسوارات).
///
/// Tapping a category applies the matching catalog filter, keeping the grid
/// and chips in sync.
class CategoryStrip extends StatelessWidget {
  const CategoryStrip({super.key});

  /// Representative imagery per category (from the design mock-up).
  static const Map<ProductCategory, String> _images =
      <ProductCategory, String>{
    ProductCategory.women:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCt4YXtXixrL2joNCvGdju19WPt4iKc3XGRVtiRD62qgVQmZYmtsP5w1NjbyxYrYfZVYocJZc1mPhjzYyXmKKHhDwnU06m5YVXwbF0mA9WXXx3I1FI21AUaxmJov-tVgLFS-B8EemehKiBZjWqpRP2o9-npEn913aZrhY_AdpOT5JswYBE4-OTWMJmqUB-w4sN1uGcJX_vQNzbCwDZPT5sUP8iUKe4WCuZTCHVN-a1uDOeBTlB5uFGv',
    ProductCategory.men:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuD-sfwgEBMuXdl55-ziy-vWAueIFyBU0BeZwQo4LTr00CiRkcHCaRDhJlnB1Wm93DK1IeDfj73_d6za-8htIBmVns5Q01pTY7HgMfN_g8MlWF0wredZqMosWrs_288AuSjJtxnOGnFVG0Ay_EtbFz_sONQni2VonzjXDFa-zFlLTPunKoh6iGkLZCIVFdTRgZZiesbHNq70yOfK7XqChi2hFB3fmnfrsJ0g0Bf1baPHk3Q1B4YFACq5',
    ProductCategory.kids:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB0K1w0lONBZGzqFBjKfQmYqvO0EtvhYNmDPi5y1TORFwNBxvEzdU02pfl44sweyA_FhNgQR7QomNiUEoZy15a3K7BeJyt5QAptexvZX_NpI2pebmmZPx3JhK6rKYS6P1dDIf9I7Gf9gn-tMMQ0gLORee-sG4KHUxFU1HQMuDMbrEnC0F3CLku8ddRPicydDbO1QBY1Rv1G8WM0P_-XZ51CwFJBw4rMERPh0CslepQU3wyjWJU955Xz',
    ProductCategory.accessories:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBbqA-QhwczwyPyByCa3ap-UkZs4O0lK_osAFBFX1WqA0KSmiQ39WgakzexF2DBMdTfTmd-UBcsflLogoRGwld-38DPkyyQsj6n5ETueU2M-dC856OS2FowRulut5MTNtAUcvWIKS2IO1ymKyKsPPRcNkndf5V5icH7X328TRRUm1hwJ7vZOlFNoS-9bmwfUVk1Shi9s2D7IDHtsdZtVGGIOJfyAngH2iFVVCA3XOIRIenejBeE3YLm',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.containerMargin,
        ),
        itemCount: ProductCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (BuildContext context, int index) {
          final ProductCategory category = ProductCategory.values[index];
          return _CategoryItem(
            category: category,
            imageUrl: _images[category]!,
            onTap: () => context.read<ProductsBloc>().add(
                  ProductsFilterSelected(CatalogFilter.fromCategory(category)),
                ),
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.imageUrl,
    required this.onTap,
  });

  final ProductCategory category;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainer,
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                opacity: 0.9,
              ),
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.2),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.labelAr,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
