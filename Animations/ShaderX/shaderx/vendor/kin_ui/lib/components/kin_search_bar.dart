import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// Size variants for [KinSearchBar].
enum KinSearchBarSize {
  small,
  medium,
  large,
}

/// A pill-shaped search bar with iOS 18-style fluid animations.
///
/// Focus/unfocus transitions use spring curves with subtle scale and
/// shadow morphing. The clear button enters with a bouncy spring.
/// Border color transitions feel organic rather than linear.
class KinSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final Widget? leading;
  final Widget? trailing;
  final FocusNode? focusNode;
  final KinSearchBarSize size;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool enabled;
  final bool autofocus;
  final TextInputAction textInputAction;
  final bool showClearButton;
  final double elevation;
  final TextInputType keyboardType;

  const KinSearchBar({
    super.key,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.leading,
    this.trailing,
    this.focusNode,
    this.size = KinSearchBarSize.large,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction = TextInputAction.search,
    this.showClearButton = true,
    this.elevation = 1.0,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<KinSearchBar> createState() => _KinSearchBarState();
}

class _KinSearchBarState extends State<KinSearchBar>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  late final AnimationController _focusAnimController;
  late final Animation<double> _focusAnim;
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);

    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 600),
    );
    _focusAnim = CurvedAnimation(
      parent: _focusAnimController,
      curve: KinMotion.fluidEnter,
      reverseCurve: KinMotion.fluidExit,
    );

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    _focusAnimController.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
    if (_hasFocus) {
      _focusAnimController.forward();
    } else {
      _focusAnimController.reverse();
    }
  }

  void _onTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _onClear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  double get _height => switch (widget.size) {
        KinSearchBarSize.small => 40,
        KinSearchBarSize.medium => 48,
        KinSearchBarSize.large => 54,
      };

  double get _iconSize => switch (widget.size) {
        KinSearchBarSize.small => 16,
        KinSearchBarSize.medium => 18,
        KinSearchBarSize.large => 20,
      };

  TextStyle get _textStyle => switch (widget.size) {
        KinSearchBarSize.small => KinTypography.bodyMedium,
        KinSearchBarSize.medium => KinTypography.bodyMedium,
        KinSearchBarSize.large => KinTypography.bodyLarge,
      };

  double get _horizontalPad => switch (widget.size) {
        KinSearchBarSize.small => KinSpacing.sm,
        KinSearchBarSize.medium => KinSpacing.sm + 2,
        KinSearchBarSize.large => KinSpacing.md,
      };

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blurSigma = isDark ? 10.0 : 0.0;
    final radius = widget.borderRadius ?? KinRadius.pill;
    final focusBorder =
        widget.borderColor ?? (_hasFocus ? theme.primary : theme.outline);

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: AnimatedBuilder(
        animation: _focusAnim,
        builder: (context, child) {
          // Fluid scale: expands on focus like iOS search
          final scale = 1.0 + (_focusAnim.value * 0.015);
          // Fluid elevation increase on focus
          final dynamicElevation =
              widget.elevation + (_focusAnim.value * 2.5);

          return Transform.scale(
            scale: scale,
            child: AnimatedOpacity(
              opacity: widget.enabled ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 300),
              curve: KinMotion.fluidEnter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: BackdropFilter(
                  filter:
                      ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: KinMotion.fluidEnter,
                    height: _height,
                    padding: EdgeInsets.symmetric(horizontal: _horizontalPad),
                    decoration: BoxDecoration(
                      color: widget.fillColor ??
                          (isDark
                              ? theme.surfaceVariant.withValues(alpha: 0.65)
                              : theme.surfaceVariant),
                      borderRadius: BorderRadius.circular(radius),
                      border: Border.all(
                          color: focusBorder,
                          width: _hasFocus ? 1.5 : 0.5),
                      boxShadow: dynamicElevation > 0
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(
                                    alpha: isDark
                                        ? 0.3 * dynamicElevation
                                        : 0.08 * dynamicElevation),
                                blurRadius: isDark ? 10 : 12,
                                offset: isDark
                                    ? Offset.zero
                                    : const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Fluid icon color transition
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: KinMotion.fluidEnter,
                          child: widget.leading ??
                              Icon(
                                CupertinoIcons.search,
                                key: ValueKey(_hasFocus),
                                size: _iconSize,
                                color: _hasFocus
                                    ? theme.primary
                                    : theme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(width: KinSpacing.sm),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              // Fluid hint fade
                              AnimatedOpacity(
                                opacity: _hasText ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 250),
                                curve: KinMotion.fluidEnter,
                                child: Text(
                                  widget.hint,
                                  style: _textStyle.copyWith(
                                    color: theme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              EditableText(
                                controller: _controller,
                                focusNode: _focusNode,
                                style: _textStyle.copyWith(
                                  color: theme.onSurface,
                                ),
                                cursorColor: theme.primary,
                                backgroundCursorColor: theme.surfaceVariant,
                                keyboardType: widget.keyboardType,
                                textInputAction: widget.textInputAction,
                                onChanged: widget.onChanged,
                                onSubmitted: widget.onSubmitted,
                              ),
                            ],
                          ),
                        ),
                        // Fluid clear button with spring scale-in
                        AnimatedScale(
                          scale: (_hasText && widget.showClearButton) ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 350),
                          curve: KinMotion.fluidEnter,
                          child: AnimatedOpacity(
                            opacity:
                                (_hasText && widget.showClearButton) ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: KinSpacing.sm),
                              child: widget.trailing ??
                                  GestureDetector(
                                    onTap: _onClear,
                                    child: Icon(
                                      CupertinoIcons.xmark_circle_fill,
                                      size: _iconSize,
                                      color: theme.onSurfaceVariant,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        if (!_hasText && widget.trailing != null) ...[
                          const SizedBox(width: KinSpacing.sm),
                          widget.trailing!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
