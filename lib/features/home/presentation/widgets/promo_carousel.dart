import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/cached_product_image.dart';
import '../../domain/entities/promo_banner.dart';
import '../bloc/home_bloc.dart';

/// Auto-playing promo banner carousel with a page indicator.
///
/// Handles loading (skeleton) and failure (hidden) states so the home screen
/// stays clean regardless of banner availability.
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  int _current = 0;

  static const double _height = 180;

  @override
  Widget build(BuildContext context) {
    final HomeState state = context.watch<HomeBloc>().state;

    if (state.status == HomeStatus.loading ||
        state.status == HomeStatus.initial) {
      return const _CarouselSkeleton(height: _height);
    }
    // On failure we simply omit the carousel rather than block the feed.
    if (state.banners.isEmpty) return const SizedBox.shrink();

    final List<PromoBanner> banners = state.banners;

    return Column(
      children: <Widget>[
        CarouselSlider.builder(
          itemCount: banners.length,
          options: CarouselOptions(
            height: _height,
            viewportFraction: 0.86,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (int index, _) =>
                setState(() => _current = index),
          ),
          itemBuilder: (BuildContext context, int index, __) =>
              _BannerCard(banner: banners[index]),
        ),
        const SizedBox(height: AppDimensions.stackBase),
        _Dots(count: banners.length, active: _current),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: AppDimensions.borderRadiusXl,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CachedProductImage(imageUrl: banner.imageUrl),
          // Legibility gradient (start side is the text side in RTL).
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: <Color>[
                  AppColors.onBackground.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.containerMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    banner.tag,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.stackBase),
                Text(
                  banner.title,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: 200,
                  child: Text(
                    banner.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onPrimary.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == active
                  ? AppColors.primary
                  : AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
          ),
      ],
    );
  }
}

class _CarouselSkeleton extends StatelessWidget {
  const _CarouselSkeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.containerMargin,
      ),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: AppDimensions.borderRadiusXl,
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
