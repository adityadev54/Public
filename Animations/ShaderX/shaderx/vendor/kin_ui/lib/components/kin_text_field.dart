import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// Visual states for [KinTextField].
enum KinTextFieldState { normal, focused, error, disabled }

/// Themed text input with label, hint, error, prefix, and suffix support.
class KinTextField extends StatefulWidget {
  // Optional native decoration preserves an existing app's appearance.
  final InputDecoration? decoration;
  final TextStyle? style;
  final Color? cursorColor;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final int? minLines;
  final bool autofocus;
  final String? hint;
  final String? label;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final int? maxLines;
  final Widget? prefix;
  final Widget? suffix;
  final FocusNode? focusNode;
  final int? maxLength;
  final bool showCharCounter;
  final List<TextInputFormatter>? inputFormatters;

  const KinTextField({
    super.key,
    this.decoration,
    this.style,
    this.cursorColor,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.minLines,
    this.autofocus = false,
    this.hint,
    this.label,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.maxLines = 1,
    this.prefix,
    this.suffix,
    this.focusNode,
    this.maxLength,
    this.showCharCounter = false,
    this.inputFormatters,
  });

  @override
  State<KinTextField> createState() => _KinTextFieldState();
}

class _KinTextFieldState extends State<KinTextField> {
  late FocusNode _focusNode;
  TextEditingController? _internalController;
  bool _hasFocus = false;

  int _charCount = 0;

  TextEditingController get _effectiveController =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _effectiveController.addListener(_onTextChanged);
    _charCount = _effectiveController.text.length;
  }

  @override
  void didUpdateWidget(KinTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (widget.controller == null) {
        _internalController ??= TextEditingController();
        _internalController!.value = oldWidget.controller!.value;
      }
      (oldWidget.controller ?? _internalController)?.removeListener(
        _onTextChanged,
      );
      _effectiveController.addListener(_onTextChanged);
      _charCount = _effectiveController.text.length;
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      if (oldWidget.focusNode == null) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
      _hasFocus = _focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.decoration != null) {
      _hasFocus = _focusNode.hasFocus;
      return;
    }
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  void _onTextChanged() {
    if (widget.decoration != null) {
      _charCount = _effectiveController.text.length;
      return;
    }
    setState(() => _charCount = _effectiveController.text.length);
  }

  KinTextFieldState get _state {
    if (!widget.enabled) return KinTextFieldState.disabled;
    if (widget.errorText != null) return KinTextFieldState.error;
    if (_hasFocus) return KinTextFieldState.focused;
    return KinTextFieldState.normal;
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    if (widget.decoration != null) {
      return TextField(
        controller: _effectiveController,
        focusNode: _focusNode,
        decoration: widget.decoration!.copyWith(errorText: widget.errorText),
        style: widget.style,
        cursorColor: widget.cursorColor,
        textAlign: widget.textAlign,
        textCapitalization: widget.textCapitalization,
        textInputAction: widget.textInputAction,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
      );
    }

    final Color borderColor = switch (_state) {
      KinTextFieldState.focused => theme.primary,
      KinTextFieldState.error => theme.destructive,
      KinTextFieldState.disabled => theme.outline.withValues(alpha: 0.3),
      KinTextFieldState.normal => theme.outline,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: KinSpacing.xs),
            child: Text(
              widget.label!,
              style: KinTypography.labelLarge.copyWith(
                color: theme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: KinSpacing.xs),
        ],
        AnimatedContainer(
          duration: KinMotion.fast,
          curve: KinMotion.enter,
          padding: const EdgeInsets.only(
            top: KinSpacing.sm,
            bottom: KinSpacing.xs,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: borderColor,
                width: _hasFocus ? 2.0 : 1.0,
              ),
            ),
          ),
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                widget.prefix!,
                const SizedBox(width: KinSpacing.sm),
              ],
              Expanded(
                child: EditableText(
                  controller: _effectiveController,
                  focusNode: _focusNode,
                  style: KinTypography.bodyLarge.copyWith(
                    color: widget.enabled
                        ? theme.onSurface
                        : theme.onSurfaceVariant,
                  ),
                  cursorColor: theme.primary,
                  backgroundCursorColor: theme.surfaceVariant,
                  obscureText: widget.obscureText,
                  maxLines: widget.maxLines,
                  keyboardType: widget.keyboardType,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  readOnly: !widget.enabled,
                  inputFormatters: [
                    if (widget.maxLength != null)
                      LengthLimitingTextInputFormatter(widget.maxLength),
                    ...?widget.inputFormatters,
                  ],
                ),
              ),
              if (widget.suffix != null) ...[
                const SizedBox(width: KinSpacing.sm),
                widget.suffix!,
              ],
            ],
          ),
        ),
        if (widget.showCharCounter || widget.maxLength != null) ...[
          const SizedBox(height: KinSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(right: KinSpacing.xs),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                widget.maxLength != null
                    ? '$_charCount / ${widget.maxLength}'
                    : '$_charCount',
                style: KinTypography.labelSmall.copyWith(
                  color:
                      (widget.maxLength != null &&
                          _charCount > widget.maxLength!)
                      ? theme.destructive
                      : theme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
        if (widget.errorText != null) ...[
          const SizedBox(height: KinSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(left: KinSpacing.xs),
            child: Text(
              widget.errorText!,
              style: KinTypography.labelSmall.copyWith(
                color: theme.destructive,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
