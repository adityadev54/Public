import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────

enum KinChartType { bar, line, area, pie, donut, horizontalBar }

enum KinChartLineStyle { sharp, smooth }

enum KinChartLegendPosition { bottom, top, left, right, none }

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class KinChartEntry {
  final String label;
  final double value;
  final Color? color;

  const KinChartEntry({required this.label, required this.value, this.color});
}

class KinChartSeries {
  final String name;
  final List<KinChartEntry> entries;
  final Color? color;
  final Gradient? gradient;
  final KinChartLineStyle lineStyle;
  final double strokeWidth;
  final bool showDots;
  final double dotRadius;
  final bool showArea;

  const KinChartSeries({
    required this.name,
    required this.entries,
    this.color,
    this.gradient,
    this.lineStyle = KinChartLineStyle.smooth,
    this.strokeWidth = 2.0,
    this.showDots = true,
    this.dotRadius = 3.5,
    this.showArea = false,
  });
}

class KinChartGridStyle {
  final bool showHorizontalLines;
  final bool showVerticalLines;
  final int horizontalLineCount;
  final double lineWidth;
  final bool dashed;

  const KinChartGridStyle({
    this.showHorizontalLines = true,
    this.showVerticalLines = false,
    this.horizontalLineCount = 4,
    this.lineWidth = 0.5,
    this.dashed = false,
  });

  static const none = KinChartGridStyle(
    showHorizontalLines: false,
    showVerticalLines: false,
  );
}

class KinChartAxisStyle {
  final bool showYAxisLabels;
  final bool showXAxisLabels;
  final String Function(double value)? yLabelFormatter;
  final String Function(String label)? xLabelFormatter;
  final double yAxisWidth;

  const KinChartAxisStyle({
    this.showYAxisLabels = false,
    this.showXAxisLabels = true,
    this.yLabelFormatter,
    this.xLabelFormatter,
    this.yAxisWidth = 40.0,
  });
}

class KinChartTooltipData {
  final String label;
  final double value;
  final Color color;
  final String? seriesName;
  final int index;
  /// Percentage of total — only set for pie/donut charts.
  final double? percentage;

  const KinChartTooltipData({
    required this.label,
    required this.value,
    required this.color,
    this.seriesName,
    required this.index,
    this.percentage,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class KinChart extends StatelessWidget {
  final List<KinChartEntry> entries;
  final List<KinChartSeries>? series;
  final KinChartType type;
  final double? height;
  final bool showLabels;
  final bool showValues;
  final bool animate;
  final KinChartGridStyle gridStyle;
  final KinChartAxisStyle axisStyle;
  final KinChartLegendPosition legendPosition;
  final KinChartLineStyle lineStyle;
  final double barSpacing;
  final double barRadius;
  final double donutWidth;
  final Widget? donutCenter;
  final Gradient? barGradient;
  final double? minValue;
  final double? maxValue;
  final ValueChanged<KinChartTooltipData>? onEntryTap;
  final Widget Function(KinChartTooltipData data)? tooltipBuilder;
  final Duration tooltipDuration;

  const KinChart({
    super.key,
    this.entries = const [],
    this.series,
    this.type = KinChartType.bar,
    this.height,
    this.showLabels = true,
    this.showValues = false,
    this.animate = true,
    this.gridStyle = const KinChartGridStyle(),
    this.axisStyle = const KinChartAxisStyle(),
    this.legendPosition = KinChartLegendPosition.none,
    this.lineStyle = KinChartLineStyle.sharp,
    this.barSpacing = KinSpacing.xs,
    this.barRadius = KinRadius.pill,
    this.donutWidth = 28.0,
    this.donutCenter,
    this.barGradient,
    this.minValue,
    this.maxValue,
    this.onEntryTap,
    this.tooltipBuilder,
    this.tooltipDuration = const Duration(seconds: 2),
  });

  const KinChart.bar({
    super.key,
    required this.entries,
    this.series,
    this.height,
    this.showLabels = true,
    this.showValues = false,
    this.animate = true,
    this.gridStyle = const KinChartGridStyle(),
    this.axisStyle = const KinChartAxisStyle(),
    this.legendPosition = KinChartLegendPosition.none,
    this.barSpacing = KinSpacing.xs,
    this.barRadius = KinRadius.pill,
    this.barGradient,
    this.minValue,
    this.maxValue,
    this.onEntryTap,
    this.tooltipBuilder,
    this.tooltipDuration = const Duration(seconds: 2),
  }) : type = KinChartType.bar,
       lineStyle = KinChartLineStyle.sharp,
       donutWidth = 28.0,
       donutCenter = null;

  const KinChart.horizontalBar({
    super.key,
    required this.entries,
    this.series,
    this.height,
    this.showLabels = true,
    this.showValues = true,
    this.animate = true,
    this.gridStyle = const KinChartGridStyle(
      showHorizontalLines: false,
      showVerticalLines: true,
    ),
    this.axisStyle = const KinChartAxisStyle(showYAxisLabels: true),
    this.legendPosition = KinChartLegendPosition.none,
    this.barSpacing = KinSpacing.xs,
    this.barRadius = KinRadius.pill,
    this.barGradient,
    this.minValue,
    this.maxValue,
    this.onEntryTap,
    this.tooltipBuilder,
    this.tooltipDuration = const Duration(seconds: 2),
  }) : type = KinChartType.horizontalBar,
       lineStyle = KinChartLineStyle.sharp,
       donutWidth = 28.0,
       donutCenter = null;

  const KinChart.line({
    super.key,
    required this.entries,
    this.series,
    this.height,
    this.showLabels = true,
    this.showValues = false,
    this.animate = true,
    this.gridStyle = const KinChartGridStyle(),
    this.axisStyle = const KinChartAxisStyle(),
    this.legendPosition = KinChartLegendPosition.none,
    this.lineStyle = KinChartLineStyle.smooth,
    this.minValue,
    this.maxValue,
    this.onEntryTap,
    this.tooltipBuilder,
    this.tooltipDuration = const Duration(seconds: 2),
  }) : type = KinChartType.line,
       barSpacing = KinSpacing.xs,
       barRadius = KinRadius.pill,
       barGradient = null,
       donutWidth = 28.0,
       donutCenter = null;

  const KinChart.area({
    super.key,
    required this.entries,
    this.series,
    this.height,
    this.showLabels = true,
    this.showValues = false,
    this.animate = true,
    this.gridStyle = const KinChartGridStyle(),
    this.axisStyle = const KinChartAxisStyle(),
    this.legendPosition = KinChartLegendPosition.none,
    this.lineStyle = KinChartLineStyle.smooth,
    this.minValue,
    this.maxValue,
    this.onEntryTap,
    this.tooltipBuilder,
    this.tooltipDuration = const Duration(seconds: 2),
  }) : type = KinChartType.area,
       barSpacing = KinSpacing.xs,
       barRadius = KinRadius.pill,
       barGradient = null,
       donutWidth = 28.0,
       donutCenter = null;

  const KinChart.pie({
    super.key,
    required this.entries,
    this.height,
    this.showLabels = true,
    this.showValues = false,
    this.animate = true,
    this.legendPosition = KinChartLegendPosition.bottom,
    this.onEntryTap,
    this.tooltipBuilder,
    this.tooltipDuration = const Duration(seconds: 2),
  }) : type = KinChartType.pie,
       series = null,
       gridStyle = const KinChartGridStyle(),
       axisStyle = const KinChartAxisStyle(),
       lineStyle = KinChartLineStyle.sharp,
       barSpacing = KinSpacing.xs,
       barRadius = KinRadius.pill,
       barGradient = null,
       donutWidth = 28.0,
       donutCenter = null,
       minValue = null,
       maxValue = null;

  const KinChart.donut({
    super.key,
    required this.entries,
    this.height,
    this.showLabels = true,
    this.showValues = false,
    this.animate = true,
    this.legendPosition = KinChartLegendPosition.bottom,
    this.donutWidth = 28.0,
    this.donutCenter,
    this.onEntryTap,
    this.tooltipBuilder,
    this.tooltipDuration = const Duration(seconds: 2),
  }) : type = KinChartType.donut,
       series = null,
       gridStyle = const KinChartGridStyle(),
       axisStyle = const KinChartAxisStyle(),
       lineStyle = KinChartLineStyle.sharp,
       barSpacing = KinSpacing.xs,
       barRadius = KinRadius.pill,
       barGradient = null,
       minValue = null,
       maxValue = null;

  @override
  Widget build(BuildContext context) {
    return _KinChartAnimationWrapper(
      animate: animate,
      entries: entries,
      series: series,
      type: type,
      height: height,
      showLabels: showLabels,
      showValues: showValues,
      gridStyle: gridStyle,
      axisStyle: axisStyle,
      legendPosition: legendPosition,
      lineStyle: lineStyle,
      barSpacing: barSpacing,
      barRadius: barRadius,
      donutWidth: donutWidth,
      donutCenter: donutCenter,
      barGradient: barGradient,
      minValue: minValue,
      maxValue: maxValue,
      onEntryTap: onEntryTap,
      tooltipBuilder: tooltipBuilder,
      tooltipDuration: tooltipDuration,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATION WRAPPER
// ─────────────────────────────────────────────────────────────────────────────

class _KinChartAnimationWrapper extends StatefulWidget {
  final bool animate;
  final List<KinChartEntry> entries;
  final List<KinChartSeries>? series;
  final KinChartType type;
  final double? height;
  final bool showLabels;
  final bool showValues;
  final KinChartGridStyle gridStyle;
  final KinChartAxisStyle axisStyle;
  final KinChartLegendPosition legendPosition;
  final KinChartLineStyle lineStyle;
  final double barSpacing;
  final double barRadius;
  final double donutWidth;
  final Widget? donutCenter;
  final Gradient? barGradient;
  final double? minValue;
  final double? maxValue;
  final ValueChanged<KinChartTooltipData>? onEntryTap;
  final Widget Function(KinChartTooltipData data)? tooltipBuilder;
  final Duration tooltipDuration;

  const _KinChartAnimationWrapper({
    required this.animate,
    required this.entries,
    this.series,
    required this.type,
    this.height,
    required this.showLabels,
    required this.showValues,
    required this.gridStyle,
    required this.axisStyle,
    required this.legendPosition,
    required this.lineStyle,
    required this.barSpacing,
    required this.barRadius,
    required this.donutWidth,
    this.donutCenter,
    this.barGradient,
    this.minValue,
    this.maxValue,
    this.onEntryTap,
    this.tooltipBuilder,
    required this.tooltipDuration,
  });

  @override
  State<_KinChartAnimationWrapper> createState() =>
      _KinChartAnimationWrapperState();
}

class _KinChartAnimationWrapperState extends State<_KinChartAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _KinChartAnimationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dataChanged =
        widget.entries != oldWidget.entries ||
        widget.series != oldWidget.series;
    if (dataChanged && widget.animate) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) => _KinChartBody(
        entries: widget.entries,
        series: widget.series,
        type: widget.type,
        height: widget.height,
        showLabels: widget.showLabels,
        showValues: widget.showValues,
        progress: _progress.value,
        gridStyle: widget.gridStyle,
        axisStyle: widget.axisStyle,
        legendPosition: widget.legendPosition,
        lineStyle: widget.lineStyle,
        barSpacing: widget.barSpacing,
        barRadius: widget.barRadius,
        donutWidth: widget.donutWidth,
        donutCenter: widget.donutCenter,
        barGradient: widget.barGradient,
        minValue: widget.minValue,
        maxValue: widget.maxValue,
        onEntryTap: widget.onEntryTap,
        tooltipBuilder: widget.tooltipBuilder,
        tooltipDuration: widget.tooltipDuration,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHART BODY
// ─────────────────────────────────────────────────────────────────────────────

class _KinChartBody extends StatefulWidget {
  final List<KinChartEntry> entries;
  final List<KinChartSeries>? series;
  final KinChartType type;
  final double? height;
  final bool showLabels;
  final bool showValues;
  final double progress;
  final KinChartGridStyle gridStyle;
  final KinChartAxisStyle axisStyle;
  final KinChartLegendPosition legendPosition;
  final KinChartLineStyle lineStyle;
  final double barSpacing;
  final double barRadius;
  final double donutWidth;
  final Widget? donutCenter;
  final Gradient? barGradient;
  final double? minValue;
  final double? maxValue;
  final ValueChanged<KinChartTooltipData>? onEntryTap;
  final Widget Function(KinChartTooltipData data)? tooltipBuilder;
  final Duration tooltipDuration;

  const _KinChartBody({
    required this.entries,
    this.series,
    required this.type,
    this.height,
    required this.showLabels,
    required this.showValues,
    required this.progress,
    required this.gridStyle,
    required this.axisStyle,
    required this.legendPosition,
    required this.lineStyle,
    required this.barSpacing,
    required this.barRadius,
    required this.donutWidth,
    this.donutCenter,
    this.barGradient,
    this.minValue,
    this.maxValue,
    this.onEntryTap,
    this.tooltipBuilder,
    required this.tooltipDuration,
  });

  @override
  State<_KinChartBody> createState() => _KinChartBodyState();
}

class _KinChartBodyState extends State<_KinChartBody> {
  int? _hoveredIndex;
  OverlayEntry? _tooltipOverlay;
  KinChartTooltipData? _tappedSlice;

  List<Color> _defaultColors(KinTheme theme) => [
    theme.primary,
    theme.onSurfaceVariant,
    theme.destructive,
    theme.primaryContainer,
    theme.outline,
    theme.primary.withValues(alpha: 0.6),
    theme.destructive.withValues(alpha: 0.6),
    theme.primaryContainer.withValues(alpha: 0.6),
  ];

  List<({KinChartEntry entry, Color color})> _coloredEntries(KinTheme theme) {
    final defaults = _defaultColors(theme);
    return widget.entries.asMap().entries.map((e) {
      final color = e.value.color ?? defaults[e.key % defaults.length];
      return (entry: e.value, color: color);
    }).toList();
  }

  void _handleEntryTap(KinChartTooltipData data) {
    HapticFeedback.lightImpact();
    widget.onEntryTap?.call(data);
  }

  void _showTooltip(
    BuildContext context,
    KinChartTooltipData data,
    Offset globalPosition,
  ) {
    _hideTooltip();

    final overlay = Overlay.of(context);
    final theme = KinTheme.of(context);

    final tooltipWidget = widget.tooltipBuilder != null
        ? widget.tooltipBuilder!(data)
        : _DefaultTooltip(data: data, theme: theme);

    // Get the chart's RenderBox to compute the line from tap to chart top
    final renderBox = context.findRenderObject() as RenderBox?;
    final chartTop = renderBox != null
        ? renderBox.localToGlobal(Offset.zero).dy
        : globalPosition.dy - 40;
    final lineHeight = globalPosition.dy - chartTop;
    final screenWidth = MediaQuery.sizeOf(context).width;

    _tooltipOverlay = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            // Dismiss on tap anywhere
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideTooltip,
              ),
            ),
            // Thin indicator line from chart top to tap point
            if (lineHeight > 4)
              Positioned(
                left: globalPosition.dx - 0.5,
                top: chartTop,
                child: Container(
                  width: 1,
                  height: lineHeight,
                  color: theme.onSurfaceVariant.withValues(alpha: 0.35),
                ),
              ),
            // Small dot at tap point
            Positioned(
              left: globalPosition.dx - 3,
              top: globalPosition.dy - 3,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: data.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Tooltip bubble – centered on the tap X, clamped to screen
            Positioned(
              top: chartTop - 36,
              left: 0,
              right: 0,
              child: Center(
                child: Transform.translate(
                  offset: Offset(
                    (globalPosition.dx - screenWidth / 2).clamp(-screenWidth / 3, screenWidth / 3),
                    0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: tooltipWidget,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_tooltipOverlay!);
    Future.delayed(widget.tooltipDuration, _hideTooltip);
  }

  void _hideTooltip() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    // Guard: no data
    final hasData = widget.entries.isNotEmpty ||
        (widget.series?.any((s) => s.entries.isNotEmpty) ?? false);
    if (!hasData) {
      return SizedBox(
        height: widget.height ?? 200,
        child: Center(
          child: Text(
            'No data',
            style: TextStyle(color: theme.onSurfaceVariant),
          ),
        ),
      );
    }

    // Guard: invalid range
    assert(
      widget.minValue == null ||
          widget.maxValue == null ||
          widget.minValue! < widget.maxValue!,
      'KinChart: minValue (${widget.minValue}) must be less than maxValue (${widget.maxValue})',
    );

    final colored = _coloredEntries(theme);

    final chart = switch (widget.type) {
      KinChartType.bar => _buildBar(context, theme, colored),
      KinChartType.horizontalBar => _buildHorizontalBar(
        context,
        theme,
        colored,
      ),
      KinChartType.line => _buildLine(context, theme, colored),
      KinChartType.area => _buildArea(context, theme, colored),
      KinChartType.pie => _buildPie(context, theme, colored),
      KinChartType.donut => _buildDonut(context, theme, colored),
    };

    if (widget.legendPosition == KinChartLegendPosition.none) return chart;

    return _wrapWithLegend(context, theme, colored, chart);
  }

  // ── Legend ──────────────────────────────────────────────────────────────

  Widget _wrapWithLegend(
    BuildContext context,
    KinTheme theme,
    List<({KinChartEntry entry, Color color})> data,
    Widget chart,
  ) {
    final legendItems = _buildLegendItems(theme, data);

    return switch (widget.legendPosition) {
      KinChartLegendPosition.bottom => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          chart,
          const SizedBox(height: KinSpacing.sm),
          legendItems,
        ],
      ),
      KinChartLegendPosition.top => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          legendItems,
          const SizedBox(height: KinSpacing.sm),
          chart,
        ],
      ),
      KinChartLegendPosition.left => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          legendItems,
          const SizedBox(width: KinSpacing.sm),
          Expanded(child: chart),
        ],
      ),
      KinChartLegendPosition.right => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: chart),
          const SizedBox(width: KinSpacing.sm),
          legendItems,
        ],
      ),
      KinChartLegendPosition.none => chart,
    };
  }

  Widget _buildLegendItems(
    KinTheme theme,
    List<({KinChartEntry entry, Color color})> data,
  ) {
    final isVertical =
        widget.legendPosition == KinChartLegendPosition.left ||
        widget.legendPosition == KinChartLegendPosition.right;

    final items = data.map((d) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isVertical ? 0 : KinSpacing.xs,
          vertical: isVertical ? KinSpacing.xs / 2 : 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 6,
              decoration: BoxDecoration(
                color: d.color,
                borderRadius: BorderRadius.circular(KinRadius.pill),
              ),
            ),
            const SizedBox(width: KinSpacing.xs),
            KinText(
              d.entry.label,
              style: KinTypography.labelSmall,
              color: theme.onSurfaceVariant,
            ),
          ],
        ),
      );
    }).toList();

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      );
    }
    return Wrap(
      spacing: KinSpacing.sm,
      runSpacing: KinSpacing.xs,
      alignment: WrapAlignment.center,
      children: items,
    );
  }

  // ── Staggered bar helper ───────────────────────────────────────────────

  /// Cascade delay per bar + easeOutBack overshoot for spring feel.
  double _staggeredBarProgress(int index, int count, double t) {
    if (count <= 1) return _easeOutBack(t);
    final delay = index / count * 0.35;
    final local = ((t - delay) / (1.0 - delay)).clamp(0.0, 1.0);
    return _easeOutBack(local);
  }

  double _easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    final tm1 = t - 1;
    return 1 + c3 * tm1 * tm1 * tm1 + c1 * tm1 * tm1;
  }

  // ── Y-axis labels helper ───────────────────────────────────────────────

  double _resolveMaxValue(List<({KinChartEntry entry, Color color})> data) {
    final dataMax = data.fold(0.0, (m, d) => math.max(m, d.entry.value));
    return widget.maxValue ?? dataMax;
  }

  double _resolveMinValue() => widget.minValue ?? 0.0;

  Widget _withYAxis(
    BuildContext context,
    KinTheme theme,
    double maxVal,
    Widget chart,
  ) {
    if (!widget.axisStyle.showYAxisLabels) return chart;

    final minVal = _resolveMinValue();
    final range = maxVal - minVal;
    final count = widget.gridStyle.horizontalLineCount;
    final formatter =
        widget.axisStyle.yLabelFormatter ??
        (v) => v >= 1000
            ? '${(v / 1000).toStringAsFixed(1)}k'
            : v.toStringAsFixed(0);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: widget.axisStyle.yAxisWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(count + 1, (i) {
                final val = maxVal - (range * i / count);
                return Padding(
                  padding: const EdgeInsets.only(right: KinSpacing.xs),
                  child: KinText(
                    formatter(val),
                    style: KinTypography.labelSmall,
                    color: theme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                );
              }),
            ),
          ),
          Expanded(child: chart),
        ],
      ),
    );
  }

  // ── Bar Chart ──────────────────────────────────────────────────────────

  Widget _buildBar(
    BuildContext context,
    KinTheme theme,
    List<({KinChartEntry entry, Color color})> data,
  ) {
    final maxVal = _resolveMaxValue(data);
    final chartHeight = widget.height ?? 160.0;
    final valuesSpace = widget.showValues ? 22.0 : 0.0;
    final labelsSpace = widget.showLabels ? 28.0 : 0.0;

    final barChart = SizedBox(
      height: chartHeight + labelsSpace + valuesSpace,
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _BarChartPainter(
                data: data,
                maxVal: maxVal,
                progress: widget.progress,
                gridStyle: widget.gridStyle,
                gridColor: theme.outline.withValues(alpha: 0.15),
                barRadius: widget.barRadius,
                barGradient: widget.barGradient,
                hoveredIndex: _hoveredIndex,
              ),
              child: _BarTouchDetector(
                data: data,
                maxVal: maxVal,
                onTap: widget.onEntryTap != null
                    ? (i) => _handleEntryTap(
                        KinChartTooltipData(
                          label: data[i].entry.label,
                          value: data[i].entry.value,
                          color: data[i].color,
                          index: i,
                        ),
                      )
                    : null,
                onHover: (i) => setState(() => _hoveredIndex = i),
                onExit: () => setState(() => _hoveredIndex = null),
                tooltipBuilder: widget.tooltipBuilder,
                onShowTooltip: _showTooltip,
              ),
            ),
          ),
          if (widget.showLabels)
            Padding(
              padding: const EdgeInsets.only(top: KinSpacing.xs),
              child: Row(
                children: data.map((d) {
                  final formatter = widget.axisStyle.xLabelFormatter;
                  final text = formatter != null
                      ? formatter(d.entry.label)
                      : d.entry.label;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.barSpacing,
                      ),
                      child: KinText(
                        text,
                        style: KinTypography.labelSmall,
                        color: theme.onSurfaceVariant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );

    return _withYAxis(context, theme, maxVal, barChart);
  }

  // ── Horizontal Bar Chart ───────────────────────────────────────────────

  Widget _buildHorizontalBar(
    BuildContext context,
    KinTheme theme,
    List<({KinChartEntry entry, Color color})> data,
  ) {
    final maxVal = _resolveMaxValue(data);
    final chartHeight = widget.height ?? (data.length * 40.0);
    final rowHeight = chartHeight / data.length;

    return SizedBox(
      height: chartHeight,
      child: Column(
        children: data.asMap().entries.map((e) {
          final i = e.key;
          final d = e.value;
          // Staggered spring per bar
          final barT = _staggeredBarProgress(i, data.length, widget.progress);
          final ratio = maxVal > 0
              ? (d.entry.value / maxVal) * barT
              : 0.0;
          return SizedBox(
            height: rowHeight,
            child: GestureDetector(
              onTap: widget.onEntryTap != null
                  ? () => _handleEntryTap(
                      KinChartTooltipData(
                        label: d.entry.label,
                        value: d.entry.value,
                        color: d.color,
                        index: i,
                      ),
                    )
                  : null,
              child: Row(
                children: [
                  if (widget.showLabels)
                    SizedBox(
                      width: widget.axisStyle.yAxisWidth + 20,
                      child: Padding(
                        padding: const EdgeInsets.only(right: KinSpacing.sm),
                        child: KinText(
                          d.entry.label,
                          style: KinTypography.labelSmall,
                          color: theme.onSurfaceVariant,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: widget.barSpacing,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              AnimatedContainer(
                                duration: KinMotion.fast,
                                curve: KinMotion.enter,
                                width: constraints.maxWidth * ratio,
                                decoration: BoxDecoration(
                                  color: d.color,
                                  gradient: widget.barGradient,
                                  borderRadius: BorderRadius.circular(
                                    widget.barRadius,
                                  ),
                                ),
                              ),
                              if (widget.showValues)
                                Positioned(
                                  left:
                                      constraints.maxWidth * ratio +
                                      KinSpacing.xs,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: KinText(
                                      d.entry.value.toStringAsFixed(0),
                                      style: KinTypography.labelSmall,
                                      color: theme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Line Chart ─────────────────────────────────────────────────────────

  Widget _buildLine(
    BuildContext context,
    KinTheme theme,
    List<({KinChartEntry entry, Color color})> data,
  ) {
    return _buildLineSeries(context, theme, data, showArea: false);
  }

  // ── Area Chart ─────────────────────────────────────────────────────────

  Widget _buildArea(
    BuildContext context,
    KinTheme theme,
    List<({KinChartEntry entry, Color color})> data,
  ) {
    return _buildLineSeries(context, theme, data, showArea: true);
  }

  Widget _buildLineSeries(
    BuildContext context,
    KinTheme theme,
    List<({KinChartEntry entry, Color color})> data, {
    required bool showArea,
  }) {
    final maxVal = _resolveMaxValue(data);
    final chartHeight = widget.height ?? 160.0;

    final allSeries =
        widget.series ??
        [
          KinChartSeries(
            name: '',
            entries: widget.entries,
            color: data.isNotEmpty ? data.first.color : theme.primary,
            lineStyle: widget.lineStyle,
            showArea: showArea,
          ),
        ];

    final lineChart = SizedBox(
      height: chartHeight + (widget.showLabels ? 28.0 : 0.0),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    if (data.isEmpty) return;
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    final range = maxVal - _resolveMinValue();
                    if (range == 0) return;

                    final index = data.length == 1
                        ? 0
                        : (details.localPosition.dx / w * (data.length - 1))
                            .round()
                            .clamp(0, data.length - 1);

                    // Compute the Y position of the nearest data point
                    final ratio =
                        (data[index].entry.value - _resolveMinValue()) / range;
                    final pointY = h - (h * ratio * widget.progress);
                    final tapY = details.localPosition.dy;

                    // Only trigger if tap is within 30px of the data point's Y
                    if ((tapY - pointY).abs() > 30) return;

                    final entry = data[index];
                    final tooltipData = KinChartTooltipData(
                      label: entry.entry.label,
                      value: entry.entry.value,
                      color: entry.color,
                      index: index,
                    );

                    // Compute the actual data point's global position
                    final step = data.length > 1
                        ? w / (data.length - 1)
                        : w / 2;
                    final pointX = index * step;
                    final box = context.findRenderObject() as RenderBox;
                    final pointGlobal = box.localToGlobal(
                      Offset(pointX, pointY),
                    );

                    _handleEntryTap(tooltipData);
                    _showTooltip(context, tooltipData, pointGlobal);
                  },
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _LineChartPainter(
                      allSeries: allSeries,
                      defaultColors: _defaultColors(theme),
                      progress: widget.progress,
                      gridColor: theme.outline.withValues(alpha: 0.15),
                      gridStyle: widget.gridStyle,
                      maxVal: maxVal,
                      minVal: _resolveMinValue(),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.showLabels)
            Padding(
              padding: const EdgeInsets.only(top: KinSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: data.map((d) {
                  final formatter = widget.axisStyle.xLabelFormatter;
                  final text = formatter != null
                      ? formatter(d.entry.label)
                      : d.entry.label;
                  return Flexible(
                    child: KinText(
                      text,
                      style: KinTypography.labelSmall,
                      color: theme.onSurfaceVariant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );

    return _withYAxis(context, theme, maxVal, lineChart);
  }

  // ── Pie Chart ──────────────────────────────────────────────────────────

  Widget _buildPie(
    BuildContext context,
    KinTheme theme,
    List<({KinChartEntry entry, Color color})> data,
  ) {
    final chartSize = widget.height ?? 160.0;
    final total = data.fold(0.0, (s, d) => s + d.entry.value);

    return Center(
      child: SizedBox(
        width: chartSize,
        height: chartSize,
        child: GestureDetector(
          onTapDown: (details) =>
              _handlePieTap(details, data, total, chartSize),
          child: CustomPaint(
            painter: _PieChartPainter(
              data: data,
              total: total,
              progress: widget.progress,
              holeRatio: 0.0,
              hoveredIndex: _hoveredIndex,
            ),
          ),
        ),
      ),
    );
  }

  // ── Donut Chart ────────────────────────────────────────────────────────

  Widget _buildDonut(
    BuildContext context,
    KinTheme theme,
    List<({KinChartEntry entry, Color color})> data,
  ) {
    final chartSize = widget.height ?? 160.0;
    final total = data.fold(0.0, (s, d) => s + d.entry.value);
    final radius = chartSize / 2;
    final holeRatio = 1.0 - (widget.donutWidth / radius);

    return Center(
      child: SizedBox(
        width: chartSize,
        height: chartSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTapDown: (details) =>
                  _handlePieTap(details, data, total, chartSize),
              child: CustomPaint(
                size: Size(chartSize, chartSize),
                painter: _PieChartPainter(
                  data: data,
                  total: total,
                  progress: widget.progress,
                  holeRatio: holeRatio.clamp(0.0, 0.95),
                  hoveredIndex: _hoveredIndex,
                ),
              ),
            ),
            // Centered text in the donut hole — shows tapped % or custom widget
            IgnorePointer(
              child: SizedBox(
                width: chartSize * holeRatio * 0.8,
                height: chartSize * holeRatio * 0.8,
                child: Center(
                  child: widget.donutCenter ??
                      AnimatedSwitcher(
                        duration: KinMotion.fast,
                        child: _tappedSlice != null
                            ? Column(
                                key: ValueKey(_tappedSlice!.index),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${_tappedSlice!.percentage!.toStringAsFixed(1)}%',
                                    style: KinTypography.titleMedium.copyWith(
                                      color: _tappedSlice!.color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _tappedSlice!.label,
                                    style: KinTypography.labelSmall.copyWith(
                                      color: theme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePieTap(
    TapDownDetails details,
    List<({KinChartEntry entry, Color color})> data,
    double total,
    double chartSize,
  ) {
    if (total == 0) return;

    final center = Offset(chartSize / 2, chartSize / 2);
    final tapOffset = details.localPosition - center;
    final angle =
        (math.atan2(tapOffset.dy, tapOffset.dx) + math.pi * 2.5) %
        (math.pi * 2);

    double cumAngle = 0;
    for (int i = 0; i < data.length; i++) {
      final sweep = (data[i].entry.value / total) * math.pi * 2;
      if (angle >= cumAngle && angle < cumAngle + sweep) {
        final pct = (data[i].entry.value / total) * 100;
        final tooltipData = KinChartTooltipData(
          label: data[i].entry.label,
          value: data[i].entry.value,
          color: data[i].color,
          index: i,
          percentage: pct,
        );
        setState(() => _tappedSlice = tooltipData);
        _handleEntryTap(tooltipData);
        _showPieTooltip(context, tooltipData, details.globalPosition);
        return;
      }
      cumAngle += sweep;
    }
  }

  void _showPieTooltip(
    BuildContext context,
    KinChartTooltipData data,
    Offset globalPosition,
  ) {
    _hideTooltip();

    final overlay = Overlay.of(context);
    final theme = KinTheme.of(context);

    final tooltipWidget = widget.tooltipBuilder != null
        ? widget.tooltipBuilder!(data)
        : _PieSliceTooltip(data: data, theme: theme);

    // Position tooltip centered above the chart
    final renderBox = context.findRenderObject() as RenderBox?;
    final chartTopGlobal = renderBox != null
        ? renderBox.localToGlobal(Offset.zero).dy
        : globalPosition.dy - 60;

    _tooltipOverlay = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            // Dismiss on tap anywhere
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _hideTooltip();
                  setState(() => _tappedSlice = null);
                },
              ),
            ),
            // Tooltip bubble — centered horizontally above the chart
            Positioned(
              top: chartTopGlobal - 48,
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: tooltipWidget,
                ),
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_tooltipOverlay!);
    Future.delayed(widget.tooltipDuration, () {
      _hideTooltip();
      if (mounted) setState(() => _tappedSlice = null);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DEFAULT TOOLTIP
// ─────────────────────────────────────────────────────────────────────────────

class _DefaultTooltip extends StatelessWidget {
  final KinChartTooltipData data;
  final KinTheme theme;

  const _DefaultTooltip({required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KinSpacing.sm,
        vertical: KinSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: KinRadius.pillAll,
        boxShadow: [
          BoxShadow(
            color: theme.onSurface.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: KinSpacing.xs),
          Text(
            '${data.label}: ${data.value % 1 == 0 ? data.value.toInt() : data.value}',
            style: KinTypography.labelSmall.copyWith(color: theme.onSurface),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PIE / DONUT SLICE TOOLTIP
// ─────────────────────────────────────────────────────────────────────────────

class _PieSliceTooltip extends StatelessWidget {
  final KinChartTooltipData data;
  final KinTheme theme;

  const _PieSliceTooltip({required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    final pctText = data.percentage != null
        ? '${data.percentage!.toStringAsFixed(1)}%'
        : '';
    final valText = data.value % 1 == 0
        ? data.value.toInt().toString()
        : data.value.toString();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KinSpacing.md,
        vertical: KinSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: KinRadius.lgAll,
        boxShadow: [
          BoxShadow(
            color: theme.onSurface.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color pill indicator
          Container(
            width: 14,
            height: 6,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(KinRadius.pill),
            ),
          ),
          const SizedBox(width: KinSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.label,
                style: KinTypography.labelSmall.copyWith(
                  color: theme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$valText  ·  $pctText',
                style: KinTypography.labelSmall.copyWith(
                  color: theme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BAR TOUCH DETECTOR
// ─────────────────────────────────────────────────────────────────────────────

class _BarTouchDetector extends StatelessWidget {
  final List<({KinChartEntry entry, Color color})> data;
  final double maxVal;
  final ValueChanged<int>? onTap;
  final ValueChanged<int>? onHover;
  final VoidCallback? onExit;
  final Widget Function(KinChartTooltipData)? tooltipBuilder;
  final void Function(BuildContext, KinChartTooltipData, Offset)? onShowTooltip;

  const _BarTouchDetector({
    required this.data,
    required this.maxVal,
    this.onTap,
    this.onHover,
    this.onExit,
    this.tooltipBuilder,
    this.onShowTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth / data.length;
        return MouseRegion(
          onExit: (_) => onExit?.call(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final index = (details.localPosition.dx / barWidth).floor().clamp(
                0,
                data.length - 1,
              );
              // Only trigger if the tap Y is within the actual bar area
              if (maxVal > 0) {
                final ratio = data[index].entry.value / maxVal;
                final barTop = constraints.maxHeight * (1.0 - ratio);
                if (details.localPosition.dy < barTop) return;
              }
              onTap?.call(index);
              if (onShowTooltip != null) {
                // Compute the bar's center X in global coords
                final barCenterX = (index + 0.5) * barWidth;
                final ratio = data[index].entry.value / maxVal;
                final barTopY = constraints.maxHeight * (1.0 - ratio);
                final box = context.findRenderObject() as RenderBox;
                final barCenterGlobal = box.localToGlobal(
                  Offset(barCenterX, barTopY),
                );
                onShowTooltip!(
                  context,
                  KinChartTooltipData(
                    label: data[index].entry.label,
                    value: data[index].entry.value,
                    color: data[index].color,
                    index: index,
                  ),
                  barCenterGlobal,
                );
              }
            },
            onPanUpdate: (details) {
              final index = (details.localPosition.dx / barWidth).floor().clamp(
                0,
                data.length - 1,
              );
              onHover?.call(index);
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BAR CHART PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _BarChartPainter extends CustomPainter {
  final List<({KinChartEntry entry, Color color})> data;
  final double maxVal;
  final double progress;
  final KinChartGridStyle gridStyle;
  final Color gridColor;
  final double barRadius;
  final Gradient? barGradient;
  final int? hoveredIndex;

  _BarChartPainter({
    required this.data,
    required this.maxVal,
    required this.progress,
    required this.gridStyle,
    required this.gridColor,
    required this.barRadius,
    this.barGradient,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxVal == 0) return;

    _paintGrid(canvas, size, gridStyle, gridColor);

    final barWidth = size.width / data.length;
    final padding = barWidth * 0.2;

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      // Staggered spring: each bar starts with a cascade delay + overshoot
      final barT = _staggeredSpring(i, data.length, progress);
      final ratio = (d.entry.value / maxVal) * barT;
      final barHeight = (size.height * ratio).clamp(0.0, size.height * 1.12);
      final x = i * barWidth + padding;
      final w = barWidth - padding * 2;

      // Pill-shaped: radius clamped so short bars stay capsule-shaped
      final r = math.min(barRadius, math.min(w, barHeight.abs()) / 2);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - barHeight, w, barHeight),
        Radius.circular(r),
      );

      final paint = Paint()..style = PaintingStyle.fill;

      if (barGradient != null) {
        paint.shader = barGradient!.createShader(rect.outerRect);
      } else {
        paint.color = hoveredIndex == i
            ? d.color.withValues(alpha: 0.8)
            : d.color;
      }

      canvas.drawRRect(rect, paint);
    }
  }

  /// Cascade delay per bar + easeOutBack overshoot for spring feel.
  static double _staggeredSpring(int index, int count, double t) {
    if (count <= 1) return _easeOutBack(t);
    final delay = index / count * 0.35;
    final local = ((t - delay) / (1.0 - delay)).clamp(0.0, 1.0);
    return _easeOutBack(local);
  }

  static double _easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    final tm1 = t - 1;
    return 1 + c3 * tm1 * tm1 * tm1 + c1 * tm1 * tm1;
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      progress != old.progress ||
      data != old.data ||
      hoveredIndex != old.hoveredIndex;
}

// ─────────────────────────────────────────────────────────────────────────────
// LINE CHART PAINTER (multi-series)
// ─────────────────────────────────────────────────────────────────────────────

class _LineChartPainter extends CustomPainter {
  final List<KinChartSeries> allSeries;
  final List<Color> defaultColors;
  final double progress;
  final Color gridColor;
  final KinChartGridStyle gridStyle;
  final double maxVal;
  final double minVal;

  _LineChartPainter({
    required this.allSeries,
    required this.defaultColors,
    required this.progress,
    required this.gridColor,
    required this.gridStyle,
    required this.maxVal,
    required this.minVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (allSeries.isEmpty) return;

    _paintGrid(canvas, size, gridStyle, gridColor);

    final range = maxVal - minVal;
    if (range == 0) return;

    for (int s = 0; s < allSeries.length; s++) {
      final series = allSeries[s];
      final entries = series.entries;
      if (entries.isEmpty) continue;

      final lineColor = series.color ?? defaultColors[s % defaultColors.length];
      final step = entries.length > 1
          ? size.width / (entries.length - 1)
          : size.width;

      final points = <Offset>[];
      for (int i = 0; i < entries.length; i++) {
        final x = i * step;
        final ratio = (entries[i].value - minVal) / range;
        final y = size.height - (size.height * ratio * progress);
        points.add(Offset(x, y));
      }

      final path = series.lineStyle == KinChartLineStyle.smooth
          ? _smoothPath(points)
          : _sharpPath(points);

      // Area fill
      if (series.showArea) {
        final fillPath = Path.from(path)
          ..lineTo(points.last.dx, size.height)
          ..lineTo(points.first.dx, size.height)
          ..close();

        final fillPaint = Paint()
          ..shader = ui.Gradient.linear(Offset(0, 0), Offset(0, size.height), [
            lineColor.withValues(alpha: 0.25),
            lineColor.withValues(alpha: 0.0),
          ]);
        canvas.drawPath(fillPath, fillPaint);
      }

      // Line stroke
      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = series.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, linePaint);

      // Dots
      if (series.showDots) {
        final dotPaint = Paint()..color = lineColor;
        final dotBgPaint = Paint()..color = lineColor.withValues(alpha: 0.15);
        for (final p in points) {
          canvas.drawCircle(p, series.dotRadius + 2, dotBgPaint);
          canvas.drawCircle(p, series.dotRadius, dotPaint);
        }
      }
    }
  }

  Path _sharpPath(List<Offset> points) {
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(points[i].dx, points[i].dy);
      } else {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }
    return path;
  }

  Path _smoothPath(List<Offset> points) {
    if (points.length < 2) return _sharpPath(points);
    final path = Path()..moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      progress != old.progress || allSeries != old.allSeries;
}

// ─────────────────────────────────────────────────────────────────────────────
// PIE / DONUT CHART PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _PieChartPainter extends CustomPainter {
  final List<({KinChartEntry entry, Color color})> data;
  final double total;
  final double progress;
  final double holeRatio;
  final int? hoveredIndex;

  _PieChartPainter({
    required this.data,
    required this.total,
    required this.progress,
    required this.holeRatio,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 2;

    // ── Donut mode: stroke-based arcs with round caps → pill capsule ends
    if (holeRatio > 0) {
      final strokeWidth = radius * (1.0 - holeRatio);
      final strokeRadius = radius - strokeWidth / 2;
      final strokeRect = Rect.fromCircle(center: center, radius: strokeRadius);
      const gapAngle = 0.06; // slightly wider gap for clean pill separation

      double startAngle = -math.pi / 2;
      for (int i = 0; i < data.length; i++) {
        final d = data[i];
        final sweep =
            (d.entry.value / total) * 2 * math.pi * progress - gapAngle;
        if (sweep <= 0) {
          startAngle += gapAngle;
          continue;
        }

        final paint = Paint()
          ..color =
              hoveredIndex == i ? d.color.withValues(alpha: 0.85) : d.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(strokeRect, startAngle, sweep, false, paint);
        startAngle += sweep + gapAngle;
      }
      return;
    }

    // ── Pie mode: filled arcs
    final rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = -math.pi / 2;
    const gapAngle = 0.03;

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final sweep = (d.entry.value / total) * 2 * math.pi * progress - gapAngle;
      if (sweep <= 0) {
        startAngle += gapAngle;
        continue;
      }

      final paint = Paint()
        ..color = hoveredIndex == i ? d.color.withValues(alpha: 0.85) : d.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter old) =>
      progress != old.progress ||
      data != old.data ||
      hoveredIndex != old.hoveredIndex;
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED GRID PAINTER
// ─────────────────────────────────────────────────────────────────────────────

void _paintGrid(
  Canvas canvas,
  Size size,
  KinChartGridStyle style,
  Color gridColor,
) {
  final paint = Paint()
    ..color = gridColor
    ..strokeWidth = style.lineWidth;

  if (style.showHorizontalLines) {
    for (int i = 0; i <= style.horizontalLineCount; i++) {
      final y = size.height * (i / style.horizontalLineCount);
      if (style.dashed) {
        _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), paint);
      } else {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }
  }

  if (style.showVerticalLines) {
    for (int i = 0; i <= style.horizontalLineCount; i++) {
      final x = size.width * (i / style.horizontalLineCount);
      if (style.dashed) {
        _drawDashedLine(canvas, Offset(x, 0), Offset(x, size.height), paint);
      } else {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }
  }
}

void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
  const dashWidth = 4.0;
  const dashSpace = 4.0;
  final dx = end.dx - start.dx;
  final dy = end.dy - start.dy;
  final length = math.sqrt(dx * dx + dy * dy);
  final unitDx = dx / length;
  final unitDy = dy / length;

  double dist = 0;
  while (dist < length) {
    final s = Offset(start.dx + unitDx * dist, start.dy + unitDy * dist);
    final segEnd = math.min(dist + dashWidth, length);
    final e = Offset(start.dx + unitDx * segEnd, start.dy + unitDy * segEnd);
    canvas.drawLine(s, e, paint);
    dist += dashWidth + dashSpace;
  }
}
