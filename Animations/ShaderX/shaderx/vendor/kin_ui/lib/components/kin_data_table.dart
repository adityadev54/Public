import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kin_press.dart';
import 'kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

/// Sort direction for [KinDataColumn].
enum KinSortDirection { ascending, descending, none }

/// Column definition for [KinDataTable].
class KinDataColumn {
  final String label;

  /// Fixed width. If null the column flexes to fill available space.
  final double? width;

  /// Flex factor when [width] is null. Defaults to 1.
  final int flex;
  final Alignment alignment;
  final bool sortable;

  const KinDataColumn({
    required this.label,
    this.width,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
    this.sortable = false,
  });
}

/// Row definition for [KinDataTable].
class KinDataRow {
  final List<KinDataCell> cells;
  final VoidCallback? onTap;
  final bool selected;

  const KinDataRow({
    required this.cells,
    this.onTap,
    this.selected = false,
  });
}

/// Cell content wrapper.
class KinDataCell {
  final Widget? child;
  final String? text;

  const KinDataCell({this.child, this.text})
      : assert(child != null || text != null);

  const KinDataCell.text(String this.text) : child = null;

  const KinDataCell.widget(Widget this.child) : text = null;
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET
// ─────────────────────────────────────────────────────────────────────────────

/// A themed, responsive data table.
///
/// Features:
/// * Column sorting with animated icons
/// * Row selection highlight
/// * Alternating row tinting
/// * Horizontal scrolling when content exceeds width
/// * Responsive – adapts padding and font density in landscape / large screens
/// * Sticky header during vertical scroll
/// * Works in portrait, landscape, and any display size
/// * Empty-state widget
class KinDataTable extends StatefulWidget {
  final List<KinDataColumn> columns;
  final List<KinDataRow> rows;
  final int? sortColumnIndex;
  final KinSortDirection sortDirection;
  final ValueChanged<int>? onSort;
  final bool alternateRowColor;
  final bool showBorder;
  final double rowHeight;
  final EdgeInsetsGeometry? padding;

  /// Maximum height before vertical scrolling kicks in.
  /// When null the table sizes to its content.
  final double? maxHeight;

  /// If true the header sticks at the top while the body scrolls.
  final bool stickyHeader;

  /// Optional empty-state widget shown when [rows] is empty.
  final Widget? emptyWidget;

  const KinDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortColumnIndex,
    this.sortDirection = KinSortDirection.none,
    this.onSort,
    this.alternateRowColor = true,
    this.showBorder = true,
    this.rowHeight = 48,
    this.padding,
    this.maxHeight,
    this.stickyHeader = true,
    this.emptyWidget,
  });

  @override
  State<KinDataTable> createState() => _KinDataTableState();
}

class _KinDataTableState extends State<KinDataTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    final borderSide = widget.showBorder
        ? BorderSide(color: theme.outline, width: 0.5)
        : BorderSide.none;

    final cellPadH = isLandscape ? KinSpacing.sm : (KinSpacing.sm + 2);

    return Container(
      decoration: BoxDecoration(
        borderRadius: KinRadius.mdAll,
        border: widget.showBorder
            ? Border.all(color: theme.outline, width: 0.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: KinRadius.mdAll,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth = constraints.maxWidth;

            // Build header
            final header = Container(
              decoration: BoxDecoration(
                color: theme.surfaceVariant,
                border: Border(bottom: borderSide),
              ),
              height: widget.rowHeight,
              child: _buildRow(
                children: List.generate(widget.columns.length, (i) {
                  final col = widget.columns[i];
                  return _HeaderCell(
                    column: col,
                    index: i,
                    isSorted: widget.sortColumnIndex == i,
                    direction: widget.sortColumnIndex == i
                        ? widget.sortDirection
                        : KinSortDirection.none,
                    onTap: col.sortable && widget.onSort != null
                        ? () {
                            HapticFeedback.selectionClick();
                            widget.onSort!(i);
                          }
                        : null,
                    horizontalPadding: cellPadH,
                  );
                }),
                columns: widget.columns,
                tableWidth: tableWidth,
              ),
            );

            // Build body rows
            Widget body;
            if (widget.rows.isEmpty) {
              body = widget.emptyWidget ??
                  SizedBox(
                    height: widget.rowHeight * 2,
                    child: Center(
                      child: KinText.bodyMedium(
                        'No data',
                        color: theme.onSurfaceVariant,
                      ),
                    ),
                  );
            } else {
              body = Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.rows.length, (rowIndex) {
                  final row = widget.rows[rowIndex];
                  final isAlternate =
                      widget.alternateRowColor && rowIndex.isOdd;

                  Color bgColor;
                  if (row.selected) {
                    bgColor = theme.primaryContainer
                        .withValues(alpha: isDark ? 0.3 : 0.5);
                  } else if (isAlternate) {
                    bgColor = theme.surfaceVariant
                        .withValues(alpha: isDark ? 0.3 : 0.4);
                  } else {
                    bgColor = Colors.transparent;
                  }

                  return KinPress(
                    onTap: row.onTap,
                    enabled: row.onTap != null,
                    child: Container(
                      height: widget.rowHeight,
                      decoration: BoxDecoration(
                        color: bgColor,
                        border: rowIndex < widget.rows.length - 1
                            ? Border(bottom: borderSide)
                            : null,
                      ),
                      child: _buildRow(
                        children: List.generate(
                          widget.columns.length,
                          (colIndex) {
                            final col = widget.columns[colIndex];
                            final cell = colIndex < row.cells.length
                                ? row.cells[colIndex]
                                : const KinDataCell.text('');
                            return _DataCellWidget(
                              column: col,
                              cell: cell,
                              horizontalPadding: cellPadH,
                            );
                          },
                        ),
                        columns: widget.columns,
                        tableWidth: tableWidth,
                      ),
                    ),
                  );
                }),
              );
            }

            // Compose: sticky header + scrollable body
            Widget table;
            if (widget.stickyHeader && widget.maxHeight != null) {
              table = SizedBox(
                height: widget.maxHeight,
                child: Column(
                  children: [
                    header,
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _verticalController,
                        child: body,
                      ),
                    ),
                  ],
                ),
              );
            } else if (widget.maxHeight != null) {
              table = SizedBox(
                height: widget.maxHeight,
                child: SingleChildScrollView(
                  controller: _verticalController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [header, body],
                  ),
                ),
              );
            } else {
              table = Column(
                mainAxisSize: MainAxisSize.min,
                children: [header, body],
              );
            }

            // Horizontal scroll when needed
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalController,
              padding: widget.padding,
              child: SizedBox(
                width: tableWidth,
                child: table,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds a row with flex columns. Fixed-width columns get their width,
  /// the rest share remaining space by flex.
  Widget _buildRow({
    required List<Widget> children,
    required List<KinDataColumn> columns,
    required double tableWidth,
  }) {
    return Row(
      children: List.generate(columns.length, (i) {
        final col = columns[i];
        if (col.width != null) {
          return SizedBox(width: col.width, child: children[i]);
        }
        return Expanded(flex: col.flex, child: children[i]);
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER CELL
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderCell extends StatelessWidget {
  final KinDataColumn column;
  final int index;
  final bool isSorted;
  final KinSortDirection direction;
  final VoidCallback? onTap;
  final double horizontalPadding;

  const _HeaderCell({
    required this.column,
    required this.index,
    required this.isSorted,
    required this.direction,
    this.onTap,
    this.horizontalPadding = KinSpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    Widget label = KinText(
      column.label,
      style: KinTypography.labelLarge,
      color: theme.onSurface,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (column.sortable) {
      final iconData = switch (direction) {
        KinSortDirection.ascending => Icons.arrow_upward,
        KinSortDirection.descending => Icons.arrow_downward,
        KinSortDirection.none => Icons.unfold_more,
      };

      label = KinPress(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: KinSpacing.xs,
          children: [
            Flexible(child: label),
            AnimatedSwitcher(
              duration: KinMotion.fast,
              child: Icon(
                iconData,
                key: ValueKey(direction),
                size: 14,
                color: isSorted ? theme.primary : theme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      alignment: column.alignment,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: label,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA CELL
// ─────────────────────────────────────────────────────────────────────────────

class _DataCellWidget extends StatelessWidget {
  final KinDataColumn column;
  final KinDataCell cell;
  final double horizontalPadding;

  const _DataCellWidget({
    required this.column,
    required this.cell,
    this.horizontalPadding = KinSpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    final content = cell.child ??
        KinText.bodyMedium(
          cell.text ?? '',
          color: theme.onSurface,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );

    return Container(
      alignment: column.alignment,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: content,
    );
  }
}
