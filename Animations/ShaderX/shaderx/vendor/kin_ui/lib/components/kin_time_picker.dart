import 'dart:ui';
import 'package:flutter/material.dart';
import 'kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';
import 'kin_button.dart';

/// Scroll-wheel time picker with iOS 18 fluid spring animations.
class KinTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final bool use24HourFormat;
  final ValueChanged<TimeOfDay>? onConfirm;
  final VoidCallback? onCancel;
  final String title;
  final String confirmLabel;
  final String cancelLabel;

  const KinTimePicker({
    super.key,
    required this.initialTime,
    this.use24HourFormat = false,
    this.onConfirm,
    this.onCancel,
    this.title = 'Select Time',
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
  });

  static Future<TimeOfDay?> show({
    required BuildContext context,
    TimeOfDay? initialTime,
    bool use24HourFormat = false,
    String title = 'Select Time',
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
  }) {
    final time = initialTime ?? TimeOfDay.now();
    return showGeneralDialog<TimeOfDay>(
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
                child: KinTimePicker(
                  initialTime: time,
                  use24HourFormat: use24HourFormat,
                  title: title,
                  confirmLabel: confirmLabel,
                  cancelLabel: cancelLabel,
                  onConfirm: (t) => Navigator.pop(ctx, t),
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
  State<KinTimePicker> createState() => _KinTimePickerState();
}

class _KinTimePickerState extends State<KinTimePicker> {
  late int _hour;
  late int _minute;
  late bool _isAm;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _amPmController;

  @override
  void initState() {
    super.initState();
    if (widget.use24HourFormat) {
      _hour = widget.initialTime.hour;
      _isAm = true;
    } else {
      final h = widget.initialTime.hourOfPeriod;
      _hour = h == 0 ? 12 : h;
      _isAm = widget.initialTime.period == DayPeriod.am;
    }
    _minute = widget.initialTime.minute;

    _hourController = FixedExtentScrollController(
      initialItem: widget.use24HourFormat ? _hour : (_hour - 1),
    );
    _minuteController = FixedExtentScrollController(initialItem: _minute);
    _amPmController = FixedExtentScrollController(initialItem: _isAm ? 0 : 1);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _amPmController.dispose();
    super.dispose();
  }

  TimeOfDay get _selectedTime {
    if (widget.use24HourFormat) return TimeOfDay(hour: _hour, minute: _minute);
    int h = _hour;
    if (!_isAm && h != 12) h += 12;
    if (_isAm && h == 12) h = 0;
    return TimeOfDay(hour: h, minute: _minute);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = KinTheme.of(context);
    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;

    final bgColor = isDark
        ? theme.surfaceVariant.withValues(alpha: 0.85)
        : theme.surfaceVariant;

    final maxHours = widget.use24HourFormat ? 24 : 12;

    return ClipRRect(
      borderRadius: KinRadius.xlAll,
      child: BackdropFilter(
        filter: isDark
            ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: isLandscape ? 440 : 340),
            width: double.infinity,
            padding: EdgeInsets.all(isLandscape ? KinSpacing.md : KinSpacing.lg),
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
                const SizedBox(height: KinSpacing.lg),
                SizedBox(
                  height: isLandscape ? 140 : 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: _FluidScrollColumn(
                          controller: _hourController,
                          itemCount: maxHours,
                          labelBuilder: (i) => widget.use24HourFormat
                              ? i.toString().padLeft(2, '0')
                              : (i + 1).toString().padLeft(2, '0'),
                          onChanged: (i) => setState(() {
                            _hour = widget.use24HourFormat ? i : (i + 1);
                          }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: KinSpacing.xs),
                        child: KinText.titleLarge(':', color: theme.onSurface),
                      ),
                      Expanded(
                        child: _FluidScrollColumn(
                          controller: _minuteController,
                          itemCount: 60,
                          labelBuilder: (i) => i.toString().padLeft(2, '0'),
                          onChanged: (i) => setState(() => _minute = i),
                        ),
                      ),
                      if (!widget.use24HourFormat) ...[
                        const SizedBox(width: KinSpacing.sm),
                        SizedBox(
                          width: 60,
                          child: _FluidScrollColumn(
                            controller: _amPmController,
                            itemCount: 2,
                            labelBuilder: (i) => i == 0 ? 'AM' : 'PM',
                            onChanged: (i) => setState(() => _isAm = i == 0),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: KinSpacing.lg),
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
                        onTap: () => widget.onConfirm?.call(_selectedTime),
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
}

/// Flat scroll column with fluid spring snapping and top/bottom fade.
/// No haptic feedback on scroll — only buttons produce haptics.
class _FluidScrollColumn extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onChanged;

  const _FluidScrollColumn({
    required this.controller,
    required this.itemCount,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    return Stack(
      children: [
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: KinMotion.fluidEnter,
            height: 44,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.10),
              borderRadius: KinRadius.mdAll,
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
            stops: [0.0, 0.28, 0.72, 1.0],
          ).createShader(bounds),
          blendMode: BlendMode.dstIn,
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 44,
            perspective: 0.001,
            diameterRatio: 100,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: itemCount,
              builder: (context, index) {
                return Center(
                  child: Text(
                    labelBuilder(index),
                    style: KinTypography.titleLarge.copyWith(
                      color: theme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
