import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// A themed, flexible grid with optional section headers and adaptive columns.
///
/// Automatically calculates column count based on [minItemWidth] or uses
/// a fixed [crossAxisCount]. Supports section-based layouts with titles.
class KinGridView extends StatelessWidget {
  /// Items to display.
  final List<Widget> children;

  /// Minimum width per item. Columns are auto-calculated.
  /// Ignored if [crossAxisCount] is set.
  final double minItemWidth;

  /// Fixed column count. Overrides [minItemWidth].
  final int? crossAxisCount;

  /// Spacing between items.
  final double spacing;

  /// Cross-axis spacing. Defaults to [spacing].
  final double? crossAxisSpacing;

  /// Child aspect ratio (width / height).
  final double childAspectRatio;

  /// Optional section title above the grid.
  final String? title;

  /// Scroll padding.
  final EdgeInsetsGeometry? padding;

  /// Whether this grid scrolls. If false, wraps with shrinkWrap
  /// for use inside other scrollable parents.
  final bool shrinkWrap;

  /// Scroll physics.
  final ScrollPhysics? physics;

  const KinGridView({
    super.key,
    required this.children,
    this.minItemWidth = 160,
    this.crossAxisCount,
    this.spacing = KinSpacing.sm,
    this.crossAxisSpacing,
    this.childAspectRatio = 1.0,
    this.title,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  /// Creates a grid from a list of data with a builder.
  static Widget builder<T>({
    Key? key,
    required List<T> items,
    required Widget Function(BuildContext context, T item, int index) itemBuilder,
    double minItemWidth = 160,
    int? crossAxisCount,
    double spacing = KinSpacing.sm,
    double? crossAxisSpacing,
    double childAspectRatio = 1.0,
    String? title,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    return _KinGridViewBuilder<T>(
      key: key,
      items: items,
      itemBuilder: itemBuilder,
      minItemWidth: minItemWidth,
      crossAxisCount: crossAxisCount,
      spacing: spacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
      title: title,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
    );
  }

  /// Creates a masonry-style grid with variable-height items (no fixed aspect ratio).
  static Widget masonry({
    Key? key,
    required List<Widget> children,
    int crossAxisCount = 2,
    double spacing = KinSpacing.sm,
    double? crossAxisSpacing,
    String? title,
    EdgeInsetsGeometry? padding,
  }) {
    return _KinMasonryGrid(
      key: key,
      crossAxisCount: crossAxisCount,
      spacing: spacing,
      crossAxisSpacing: crossAxisSpacing,
      title: title,
      padding: padding,
      children: children,
    );
  }

  /// Creates a bento-style grid where each item can span multiple rows/columns.
  ///
  /// Each child is wrapped in a [KinBentoItem] that defines its column and
  /// row span. The grid uses a slot-filling algorithm to pack items tightly.
  static Widget bento({
    Key? key,
    required List<KinBentoItem> items,
    int columns = 4,
    double spacing = KinSpacing.sm,
    double cellAspectRatio = 1.0,
    String? title,
    EdgeInsetsGeometry? padding,
  }) {
    return _KinBentoGrid(
      key: key,
      items: items,
      columns: columns,
      spacing: spacing,
      cellAspectRatio: cellAspectRatio,
      title: title,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Text(
              title!,
              style: KinTypography.titleMedium.copyWith(
                color: theme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: KinSpacing.sm),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = crossAxisCount ??
                (constraints.maxWidth / minItemWidth).floor().clamp(1, 12);
            return GridView.count(
              crossAxisCount: cols,
              mainAxisSpacing: spacing,
              crossAxisSpacing: crossAxisSpacing ?? spacing,
              childAspectRatio: childAspectRatio,
              padding: padding,
              shrinkWrap: shrinkWrap || true,
              physics: physics ?? const NeverScrollableScrollPhysics(),
              children: children,
            );
          },
        ),
      ],
    );
  }
}

// ── Builder variant ──

class _KinGridViewBuilder<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final double minItemWidth;
  final int? crossAxisCount;
  final double spacing;
  final double? crossAxisSpacing;
  final double childAspectRatio;
  final String? title;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const _KinGridViewBuilder({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.minItemWidth,
    this.crossAxisCount,
    required this.spacing,
    this.crossAxisSpacing,
    required this.childAspectRatio,
    this.title,
    this.padding,
    required this.shrinkWrap,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return KinGridView(
      title: title,
      minItemWidth: minItemWidth,
      crossAxisCount: crossAxisCount,
      spacing: spacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      children: [
        for (int i = 0; i < items.length; i++)
          itemBuilder(context, items[i], i),
      ],
    );
  }
}

// ── Masonry variant (column-based layout) ──

class _KinMasonryGrid extends StatelessWidget {
  final int crossAxisCount;
  final double spacing;
  final double? crossAxisSpacing;
  final String? title;
  final EdgeInsetsGeometry? padding;
  final List<Widget> children;

  const _KinMasonryGrid({
    super.key,
    required this.crossAxisCount,
    required this.spacing,
    this.crossAxisSpacing,
    this.title,
    this.padding,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final hSpacing = crossAxisSpacing ?? spacing;

    // Distribute children across columns round-robin
    final columns = List.generate(crossAxisCount, (_) => <Widget>[]);
    for (int i = 0; i < children.length; i++) {
      columns[i % crossAxisCount].add(children[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Text(
              title!,
              style: KinTypography.titleMedium.copyWith(
                color: theme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: KinSpacing.sm),
        ],
        Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int c = 0; c < crossAxisCount; c++) ...[
                if (c > 0) SizedBox(width: hSpacing),
                Expanded(
                  child: Column(
                    children: [
                      for (int r = 0; r < columns[c].length; r++) ...[
                        if (r > 0) SizedBox(height: spacing),
                        columns[c][r],
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Bento variant (span-based layout) ──

/// Defines a child's span in a [KinGridView.bento] layout.
class KinBentoItem {
  final Widget child;

  /// How many columns this item spans.
  final int colSpan;

  /// How many rows this item spans.
  final int rowSpan;

  const KinBentoItem({
    required this.child,
    this.colSpan = 1,
    this.rowSpan = 1,
  });
}

class _KinBentoGrid extends StatelessWidget {
  final List<KinBentoItem> items;
  final int columns;
  final double spacing;
  final double cellAspectRatio;
  final String? title;
  final EdgeInsetsGeometry? padding;

  const _KinBentoGrid({
    super.key,
    required this.items,
    required this.columns,
    required this.spacing,
    required this.cellAspectRatio,
    this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Text(
              title!,
              style: KinTypography.titleMedium.copyWith(color: theme.onSurface),
            ),
          ),
          const SizedBox(height: KinSpacing.sm),
        ],
        Padding(
          padding: padding ?? EdgeInsets.zero,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final cellWidth =
                  (totalWidth - spacing * (columns - 1)) / columns;
              final cellHeight = cellWidth / cellAspectRatio;

              // Slot-fill algorithm: track occupied cells in a 2D grid
              final occupied = <int, Set<int>>{}; // row → set of cols

              bool isOccupied(int r, int c) =>
                  occupied[r]?.contains(c) ?? false;

              void occupy(int r, int c, int rs, int cs) {
                for (int dr = 0; dr < rs; dr++) {
                  occupied.putIfAbsent(r + dr, () => <int>{});
                  for (int dc = 0; dc < cs; dc++) {
                    occupied[r + dr]!.add(c + dc);
                  }
                }
              }

              (int, int) findSlot(int cs, int rs) {
                for (int r = 0;; r++) {
                  for (int c = 0; c <= columns - cs; c++) {
                    bool fits = true;
                    for (int dr = 0; dr < rs && fits; dr++) {
                      for (int dc = 0; dc < cs && fits; dc++) {
                        if (isOccupied(r + dr, c + dc)) fits = false;
                      }
                    }
                    if (fits) return (r, c);
                  }
                }
              }

              // Place all items
              final placements = <(int row, int col, KinBentoItem item)>[];
              int maxRow = 0;

              for (final item in items) {
                final cs = item.colSpan.clamp(1, columns);
                final rs = item.rowSpan.clamp(1, 100);
                final (r, c) = findSlot(cs, rs);
                occupy(r, c, rs, cs);
                placements.add((r, c, item));
                if (r + rs > maxRow) maxRow = r + rs;
              }

              final totalHeight =
                  maxRow * cellHeight + (maxRow - 1).clamp(0, 999) * spacing;

              return SizedBox(
                height: totalHeight,
                child: Stack(
                  children: [
                    for (final (r, c, item) in placements)
                      Positioned(
                        left: c * (cellWidth + spacing),
                        top: r * (cellHeight + spacing),
                        width: item.colSpan * cellWidth +
                            (item.colSpan - 1) * spacing,
                        height: item.rowSpan * cellHeight +
                            (item.rowSpan - 1) * spacing,
                        child: item.child,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
