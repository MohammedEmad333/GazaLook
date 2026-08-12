import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Opens the localized size guide as a modal bottom sheet.
Future<void> showSizeGuideSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surfaceContainerLowest,
    builder: (BuildContext context) => const _SizeGuideSheet(),
  );
}

/// A single size row: label + chest/length measurements in centimetres.
class _SizeRow {
  const _SizeRow(this.size, this.chestCm, this.lengthCm);
  final String size;
  final String chestCm;
  final String lengthCm;
}

class _SizeGuideSheet extends StatelessWidget {
  const _SizeGuideSheet();

  static const List<_SizeRow> _rows = <_SizeRow>[
    _SizeRow('S', '86 - 90', '58'),
    _SizeRow('M', '90 - 94', '60'),
    _SizeRow('L', '94 - 98', '62'),
    _SizeRow('XL', '98 - 102', '64'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.containerMargin,
          0,
          AppDimensions.containerMargin,
          AppDimensions.sectionGap,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.straighten, color: AppColors.primary),
                const SizedBox(width: AppDimensions.stackBase),
                Text('دليل المقاسات', style: theme.textTheme.headlineMedium),
              ],
            ),
            const SizedBox(height: AppDimensions.stackTight),
            Text(
              'القياسات بالسنتيمتر (CM). اختر المقاس الأقرب لقياساتك.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppDimensions.componentPadding),

            // Header row
            _TableRow(
              cells: const <String>['المقاس', 'الصدر (CM)', 'الطول (CM)'],
              isHeader: true,
            ),
            const Divider(height: 1),
            for (final _SizeRow row in _rows) ...<Widget>[
              _TableRow(
                cells: <String>[row.size, row.chestCm, row.lengthCm],
              ),
              const Divider(height: 1),
            ],

            const SizedBox(height: AppDimensions.componentPadding),
            Container(
              padding: const EdgeInsets.all(AppDimensions.componentPadding),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppDimensions.borderRadiusLg,
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.check_circle,
                      color: AppColors.tertiary, size: 20),
                  const SizedBox(width: AppDimensions.stackBase),
                  Expanded(
                    child: Text(
                      'يناسب القياس الحقيقي (Fits true to size)',
                      style: theme.textTheme.bodyMedium,
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

class _TableRow extends StatelessWidget {
  const _TableRow({required this.cells, this.isHeader = false});

  final List<String> cells;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextStyle? style = isHeader
        ? theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          )
        : theme.textTheme.bodyMedium
            ?.copyWith(color: AppColors.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.componentPadding),
      child: Row(
        children: <Widget>[
          for (final String cell in cells)
            Expanded(child: Text(cell, style: style)),
        ],
      ),
    );
  }
}
