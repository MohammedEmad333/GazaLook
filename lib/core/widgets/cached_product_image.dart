import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Network image wrapper tuned for low-bandwidth connections.
///
/// Uses [CachedNetworkImage] (disk + memory cache) with a soft shimmer-free
/// placeholder and a graceful fallback icon, so slow or failed image loads
/// never break the layout. Downscales in memory to the display size to keep
/// memory light on modest devices.
class CachedProductImage extends StatelessWidget {
  const CachedProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: const Duration(milliseconds: 250),
      // Cap decoded resolution to reduce memory on low-end phones.
      memCacheWidth: 600,
      placeholder: (BuildContext context, String url) => const ColoredBox(
        color: AppColors.surfaceContainer,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (BuildContext context, String url, Object error) =>
          const ColoredBox(
        color: AppColors.surfaceContainer,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.outline,
          ),
        ),
      ),
    );
  }
}
