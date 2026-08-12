import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import 'size_guide_sheet.dart';

/// Size chooser row with a "size guide" link that opens a localized sheet.
class SizeSelector extends StatelessWidget {
  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selected,
    required this.onSelected,
  });

  final List<String> sizes;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'المقاس',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: () => showSizeGuideSheet(context),
              icon: const Icon(Icons.straighten, size: 16),
              label: const Text('دليل المقاسات'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onSurfaceVariant,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.stackBase),
        Wrap(
          spacing: AppDimensions.componentPadding,
          runSpacing: AppDimensions.stackBase,
          children: <Widget>[
            for (final String size in sizes)
              _SizeChip(
                label: size,
                selected: size == selected,
                onTap: () => onSelected(size),
              ),
          ],
        ),
      ],
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Container(
        constraints: const BoxConstraints(minWidth: 56),
        height: 48,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondaryContainer : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: selected ? AppColors.secondary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color:
                selected ? AppColors.onSurface : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
