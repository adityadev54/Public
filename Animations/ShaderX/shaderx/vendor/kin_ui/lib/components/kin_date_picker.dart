import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';
import 'kin_press.dart';
import 'kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';
import 'kin_button.dart';

/// Calendar-style date picker with iOS 18 fluid spring animations.
class KinDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onConfirm;
  final VoidCallback? onCancel;
  final String title;
  final String confirmLabel;
  final String cancelLabel;

  const KinDatePicker({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onConfirm,
    this.onCancel,
    this.title = 'Select Date',
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
  });

  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String title = 'Select Date',
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
  }) {
    return showGeneralDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0x88000000),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final t = KinMotion.fluidEnter.transform(animation.value.clamp(0.0, 1.0));
            final slide = 0.12 * (1.0 - t);
            final scale = 0.92 + 0.08 * t;
            return Transform.translate(
              offset: Offset(0, slide * MediaQuery.sizeOf(context).height),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                child: Opacity(
                  opacity: animation.value.clamp(0.0, 1.0),
                  child: child,
                ),
              ),
            );
          },
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  left: KinSpacing.sm + MediaQuery.paddingOf(ctx).left,
                  right: KinSpacing.sm + MediaQuery.paddingOf(ctx).right,
                  bottom: KinSpacing.xs,
                ),
                child: KinDatePicker(
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  title: title,
                  confirmLabel: confirmLabel,
                  cancelLabel: cancelLabel,
                  onConfirm: (date) => Navigator.pop(ctx, date),
                  onCancel: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  State<KinDatePicker> createState() => _KinDatePickerState();
}

class _KinDatePickerState extends State<KinDatePicker>
    with SingleTickerProviderStateMixin {
  late DateTime _displayMonth;
  late DateTime _selectedDate;
  late DateTime _firstDate;
  late DateTime _lastDate;

  // Spring-driven month transition
  late AnimationController _monthCtrl;
  double _monthSlide = 0.0; // -1 = prev, 0 = current, 1 = next
  int _slideDirection = 0;

  static const _weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = widget.initialDate ?? now;
    _displayMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _firstDate = widget.firstDate ?? DateTime(2000);
    _lastDate = widget.lastDate ?? DateTime(2100);
    _monthCtrl = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    _monthCtrl.dispose();
    super.dispose();
  }

  void _prevMonth() {
    final prev = DateTime(_displayMonth.year, _displayMonth.month - 1);
    if (!prev.isBefore(DateTime(_firstDate.year, _firstDate.month))) {
      _slideDirection = -1;
      _animateMonthChange(prev);
    }
  }

  void _nextMonth() {
    final next = DateTime(_displayMonth.year, _displayMonth.month + 1);
    if (!next.isAfter(DateTime(_lastDate.year, _lastDate.month))) {
      _slideDirection = 1;
      _animateMonthChange(next);
    }
  }

  void _animateMonthChange(DateTime target) {
    _monthCtrl.value = _slideDirection.toDouble();
    _monthCtrl.animateWith(
      SpringSimulation(KinMotion.fluidSnap, _slideDirection.toDouble(), 0, 0),
    );
    _monthCtrl.addListener(_monthListener);
    setState(() => _displayMonth = target);
  }

  void _monthListener() {
    if (mounted) setState(() => _monthSlide = _monthCtrl.value);
    if (_monthCtrl.isCompleted) {
      _monthCtrl.removeListener(_monthListener);
      _monthSlide = 0;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  List<DateTime?> _daysInGrid() {
    final first = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final startWeekday = first.weekday;
    final daysInMonth = DateUtils.getDaysInMonth(_displayMonth.year, _displayMonth.month);
    final cells = <DateTime?>[];
    for (var i = 1; i < startWeekday; i++) cells.add(null);
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_displayMonth.year, _displayMonth.month, d));
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = KinTheme.of(context);
    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;

    final bgColor = isDark
        ? theme.surfaceVariant.withValues(alpha: 0.85)
        : theme.surfaceVariant;

    return ClipRRect(
      borderRadius: KinRadius.xlAll,
      child: BackdropFilter(
        filter: isDark
            ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: isLandscape ? 480 : 380),
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? KinSpacing.md : KinSpacing.lg,
              vertical: isLandscape ? KinSpacing.sm : KinSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: KinRadius.xlAll,

              boxShadow: isDark
                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20)]
                  : [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KinText.titleLarge(widget.title, color: theme.onSurface),
                SizedBox(height: isLandscape ? KinSpacing.xs : KinSpacing.md),
                _buildHeader(theme),
                SizedBox(height: isLandscape ? KinSpacing.xs : KinSpacing.md),
                _buildWeekdayRow(theme),
                SizedBox(height: isLandscape ? 2 : KinSpacing.xs),
                // Spring-slide calendar grid
                Transform.translate(
                  offset: Offset(_monthSlide * 40, 0),
                  child: Opacity(
                    opacity: (1.0 - _monthSlide.abs() * 0.3).clamp(0.0, 1.0),
                    child: _buildCalendarGrid(theme, isLandscape: isLandscape),
                  ),
                ),
                SizedBox(height: isLandscape ? KinSpacing.sm : KinSpacing.lg),
                Row(
                  spacing: KinSpacing.sm,
                  children: [
                    Expanded(
                      child: KinButton(
                        label: widget.cancelLabel,
                        variant: KinButtonVariant.secondary,
                        onTap: widget.onCancel,
                      ),
                    ),
                    Expanded(
                      child: KinButton(
                        label: widget.confirmLabel,
                        onTap: () => widget.onConfirm?.call(_selectedDate),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(KinTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        KinPress(
          onTap: _prevMonth,
          child: Icon(CupertinoIcons.chevron_left, color: theme.onSurface, size: 20),
        ),
        KinText.titleMedium(
          '${_months[_displayMonth.month - 1]} ${_displayMonth.year}',
          color: theme.onSurface,
        ),
        KinPress(
          onTap: _nextMonth,
          child: Icon(CupertinoIcons.chevron_right, color: theme.onSurface, size: 20),
        ),
      ],
    );
  }

  Widget _buildWeekdayRow(KinTheme theme) {
    return Row(
      children: _weekdays
          .map((d) => Expanded(
                child: Center(
                  child: KinText(d, style: KinTypography.labelSmall, color: theme.onSurfaceVariant),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid(KinTheme theme, {bool isLandscape = false}) {
    final cells = _daysInGrid();
    final rows = <List<DateTime?>>[];
    for (var i = 0; i < cells.length; i += 7) {
      final end = (i + 7 > cells.length) ? cells.length : i + 7;
      final row = List<DateTime?>.from(cells.sublist(i, end));
      while (row.length < 7) row.add(null);
      rows.add(row);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.map((row) => _buildWeekRow(row, theme, cellHeight: isLandscape ? 26.0 : 40.0)).toList(),
    );
  }

  Widget _buildWeekRow(List<DateTime?> days, KinTheme theme, {double cellHeight = 40.0}) {
    return Row(
      children: days.map((day) {
        if (day == null) return Expanded(child: SizedBox(height: cellHeight));
        final isSelected = _isSameDay(day, _selectedDate);
        final isToday = _isToday(day);

        return Expanded(
          child: KinPress(
            onTap: () => setState(() => _selectedDate = day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: KinMotion.fluidEnter,
              height: cellHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? theme.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: KinText(
                '${day.day}',
                style: KinTypography.bodyMedium.copyWith(
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                ),
                color: isSelected
                    ? const Color(0xFFFFFFFF)
                    : isToday
                        ? theme.primary
                        : theme.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
