import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'kin_press.dart';
import 'kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import 'kin_button.dart';

/// Rating style for [KinRatingPicker].
enum KinRatingStyle { star, heart, circle }

/// A bottom-dialog rating picker with animated icons and optional feedback text.
///
/// ```dart
/// final rating = await KinRatingPicker.show(context: context);
/// ```
class KinRatingPicker extends StatefulWidget {
  final int maxRating;
  final int initialRating;
  final KinRatingStyle style;
  final String title;
  final List<String>? ratingLabels;
  final ValueChanged<int>? onConfirm;
  final VoidCallback? onCancel;
  final bool showLabel;
  final Color? activeColor;
  final String confirmLabel;
  final String cancelLabel;

  const KinRatingPicker({
    super.key,
    this.maxRating = 5,
    this.initialRating = 0,
    this.style = KinRatingStyle.star,
    this.title = 'Rate',
    this.ratingLabels,
    this.onConfirm,
    this.onCancel,
    this.showLabel = true,
    this.activeColor,
    this.confirmLabel = 'Submit',
    this.cancelLabel = 'Cancel',
  });

  static Future<int?> show({
    required BuildContext context,
    int maxRating = 5,
    int initialRating = 0,
    KinRatingStyle style = KinRatingStyle.star,
    String title = 'Rate',
    List<String>? ratingLabels,
    bool showLabel = true,
    Color? activeColor,
    String confirmLabel = 'Submit',
    String cancelLabel = 'Cancel',
  }) {
    return showGeneralDialog<int>(
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
                  child: KinRatingPicker(
                    maxRating: maxRating,
                    initialRating: initialRating,
                    style: style,
                    title: title,
                    ratingLabels: ratingLabels,
                    showLabel: showLabel,
                    activeColor: activeColor,
                    confirmLabel: confirmLabel,
                    cancelLabel: cancelLabel,
                    onConfirm: (r) => Navigator.pop(ctx, r),
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
  State<KinRatingPicker> createState() => _KinRatingPickerState();
}

class _KinRatingPickerState extends State<KinRatingPicker> {
  late int _selected;

  static const _defaultLabels = [
    '',
    'Terrible',
    'Bad',
    'OK',
    'Good',
    'Amazing',
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialRating;
  }

  String get _label {
    if (!widget.showLabel || _selected == 0) return '';
    final labels = widget.ratingLabels ?? _defaultLabels;
    if (_selected < labels.length) return labels[_selected];
    return '';
  }

  IconData get _iconFilled => switch (widget.style) {
        KinRatingStyle.star => CupertinoIcons.star_fill,
        KinRatingStyle.heart => CupertinoIcons.heart_fill,
        KinRatingStyle.circle => CupertinoIcons.circle_fill,
      };

  IconData get _iconEmpty => switch (widget.style) {
        KinRatingStyle.star => CupertinoIcons.star,
        KinRatingStyle.heart => CupertinoIcons.heart,
        KinRatingStyle.circle => CupertinoIcons.circle,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = KinTheme.of(context);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    final bgColor = isDark
        ? theme.surfaceVariant.withValues(alpha: 0.85)
        : theme.surfaceVariant;
    final accentColor = widget.activeColor ?? theme.primary;

    return ClipRRect(
      borderRadius: KinRadius.xlAll,
      child: BackdropFilter(
        filter: isDark
            ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isLandscape ? 440 : 340,
            ),
            width: double.infinity,
            padding: EdgeInsets.all(
                isLandscape ? KinSpacing.md : KinSpacing.lg),
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
                SizedBox(height: isLandscape ? KinSpacing.sm : KinSpacing.lg),

                // Rating icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.maxRating, (i) {
                    final index = i + 1;
                    final isActive = index <= _selected;
                    return KinPress(
                      onTap: () {
                        setState(() {
                          _selected = _selected == index ? 0 : index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KinSpacing.xs,
                        ),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 1.0,
                            end: isActive ? 1.0 : 0.85,
                          ),
                          duration: KinMotion.fast,
                          curve: KinMotion.enter,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: AnimatedSwitcher(
                            duration: KinMotion.fast,
                            child: Icon(
                              isActive ? _iconFilled : _iconEmpty,
                              key: ValueKey('$index-$isActive'),
                              size: isLandscape ? 32 : 40,
                              color: isActive
                                  ? accentColor
                                  : theme.onSurfaceVariant
                                      .withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                // Feedback label
                AnimatedSize(
                  duration: KinMotion.fast,
                  curve: KinMotion.enter,
                  child: _label.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: KinSpacing.sm),
                          child: KinText.bodyMedium(
                            _label,
                            color: theme.onSurfaceVariant,
                          ),
                        )
                      : const SizedBox(height: KinSpacing.sm),
                ),

                SizedBox(height: isLandscape ? KinSpacing.sm : KinSpacing.lg),

                // Buttons
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
                        onTap: _selected > 0
                            ? () => widget.onConfirm?.call(_selected)
                            : null,
                        enabled: _selected > 0,
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
