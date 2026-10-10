import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_typography.dart';

/// A single data point in a [KinHeatmap].
class KinHeatmapCell {
  /// The intensity value, typically 0.0 (none) to 1.0 (max).
  final double value;

  /// Optional tooltip text shown on long-press.
  final String? tooltip;

  const KinHeatmapCell({required this.value, this.tooltip});
}

/// Configuration for heatmap color mapping.
class KinHeatmapColorScale {
  final Color emptyColor;
  final List<Color> gradient;

  const KinHeatmapColorScale({
    required this.emptyColor,
    required this.gradient,
  });

  Color colorFor(double value) {
    if (value <= 0) return emptyColor;
    final clamped = value.clamp(0.0, 1.0);
    if (gradient.length == 1) return gradient.first;
    final segment = (gradient.length - 1) * clamped;
    final lower = segment.floor().clamp(0, gradient.length - 2);
    final t = segment - lower;
    return Color.lerp(gradient[lower], gradient[lower + 1], t)!;
  }
}

/// A GitHub-style contribution heatmap / activity grid.
///
/// Renders a grid of cells coloured by intensity, with optional
/// row/column labels. Supports both matrix and flat list data modes.
class KinHeatmap extends StatelessWidget {
  /// Each inner list is a row in the heatmap.
  final List<List<KinHeatmapCell>> data;

  /// Labels for each column (e.g. day names or week numbers).
  final List<String>? columnLabels;

  /// Labels for each row (e.g. month names).
  final List<String>? rowLabels;

  /// Cell size including gap.
  final double cellSize;

  /// Gap between cells.
  final double cellGap;

  /// Corner radius of each cell.
  final double cellRadius;

  /// Color scale mapping values to colors.
  final KinHeatmapColorScale? colorScale;

  /// Called when a cell is tapped.
  final void Function(int row, int col, KinHeatmapCell cell)? onCellTap;

  const KinHeatmap({
    super.key,
    required this.data,
    this.columnLabels,
    this.rowLabels,
    this.cellSize = 14,
    this.cellGap = 3,
    this.cellRadius = 3,
    this.colorScale,
    this.onCellTap,
  });

  /// Convenience factory: flat list of values mapped into a grid
  /// with [columns] per row.
  factory KinHeatmap.flat({
    Key? key,
    required List<double> values,
    required int columns,
    List<String>? columnLabels,
    List<String>? rowLabels,
    double cellSize = 14,
    double cellGap = 3,
    double cellRadius = 3,
    KinHeatmapColorScale? colorScale,
    void Function(int row, int col, KinHeatmapCell cell)? onCellTap,
  }) {
    final rows = <List<KinHeatmapCell>>[];
    for (int i = 0; i < values.length; i += columns) {
      final end = (i + columns).clamp(0, values.length);
      rows.add([
        for (int j = i; j < end; j++) KinHeatmapCell(value: values[j]),
      ]);
    }
    return KinHeatmap(
      key: key,
      data: rows,
      columnLabels: columnLabels,
      rowLabels: rowLabels,
      cellSize: cellSize,
      cellGap: cellGap,
      cellRadius: cellRadius,
      colorScale: colorScale,
      onCellTap: onCellTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scale = colorScale ??
        KinHeatmapColorScale(
          emptyColor: isDark
              ? theme.outline.withValues(alpha: 0.15)
              : theme.outline.withValues(alpha: 0.12),
          gradient: [
            theme.primary.withValues(alpha: 0.15),
            theme.primary.withValues(alpha: 0.35),
            theme.primary.withValues(alpha: 0.6),
            theme.primary,
          ],
        );

    final hasRowLabels = rowLabels != null && rowLabels!.isNotEmpty;
    final hasColLabels = columnLabels != null && columnLabels!.isNotEmpty;
    final labelStyle = KinTypography.captionSmall.copyWith(
      color: theme.onSurfaceVariant.withValues(alpha: 0.6),
      fontSize: 10,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Column labels row
          if (hasColLabels)
            Padding(
              padding: EdgeInsets.only(
                left: hasRowLabels ? 32 : 0,
                bottom: 4,
              ),
              child: Row(
                children: [
                  for (int c = 0; c < columnLabels!.length; c++)
                    SizedBox(
                      width: cellSize + cellGap,
                      child: Text(
                        columnLabels![c],
                        style: labelStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),

          // Data rows
          for (int r = 0; r < data.length; r++)
            Row(
              children: [
                if (hasRowLabels)
                  SizedBox(
                    width: 28,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        r < rowLabels!.length ? rowLabels![r] : '',
                        style: labelStyle,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                for (int c = 0; c < data[r].length; c++)
                  Padding(
                    padding: EdgeInsets.all(cellGap / 2),
                    child: _HeatmapCellWidget(
                      cell: data[r][c],
                      size: cellSize,
                      radius: cellRadius,
                      color: scale.colorFor(data[r][c].value),
                      onTap: onCellTap != null
                          ? () => onCellTap!(r, c, data[r][c])
                          : null,
                      theme: theme,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _HeatmapCellWidget extends StatelessWidget {
  final KinHeatmapCell cell;
  final double size;
  final double radius;
  final Color color;
  final VoidCallback? onTap;
  final KinTheme theme;

  const _HeatmapCellWidget({
    required this.cell,
    required this.size,
    required this.radius,
    required this.color,
    this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    Widget box = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    if (cell.tooltip != null) {
      box = Tooltip(
        message: cell.tooltip!,
        preferBelow: false,
        child: box,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: box,
      );
    }

    return box;
  }
}
