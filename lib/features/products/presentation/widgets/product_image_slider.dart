import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cached_product_image.dart';

/// Swipeable product image gallery with page dots and pinch-to-zoom.
///
/// Tapping an image opens a full-screen [InteractiveViewer] for zoom/pan —
/// satisfying the PDP's "image slider with zoom capability".
class ProductImageSlider extends StatefulWidget {
  const ProductImageSlider({super.key, required this.images});

  final List<String> images;

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openZoom(int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) =>
            _FullScreenGallery(images: widget.images, initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ColoredBox(
        color: AppColors.surfaceContainer,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (int i) => setState(() => _current = i),
              itemBuilder: (BuildContext context, int index) => GestureDetector(
                onTap: () => _openZoom(index),
                child: Hero(
                  tag: 'pdp-image-$index',
                  child: CachedProductImage(imageUrl: widget.images[index]),
                ),
              ),
            ),

            // Zoom affordance hint.
            const PositionedDirectional(
              top: 12,
              end: 12,
              child: _ZoomChip(),
            ),

            // Page dots.
            if (widget.images.length > 1)
              PositionedDirectional(
                bottom: 16,
                start: 0,
                end: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (int i = 0; i < widget.images.length; i++)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _current
                              ? AppColors.onSurface
                              : AppColors.onSurface.withOpacity(0.3),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ZoomChip extends StatelessWidget {
  const _ZoomChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.zoom_in, size: 16, color: AppColors.onSurfaceVariant),
          SizedBox(width: 4),
          Text('تكبير', style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

/// Full-screen, zoomable gallery pushed on image tap.
class _FullScreenGallery extends StatelessWidget {
  const _FullScreenGallery({required this.images, required this.initialIndex});

  final List<String> images;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: images.length,
            itemBuilder: (BuildContext context, int index) => Center(
              child: Hero(
                tag: 'pdp-image-$index',
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: CachedProductImage(
                    imageUrl: images[index],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: MediaQuery.of(context).padding.top + 8,
            end: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
