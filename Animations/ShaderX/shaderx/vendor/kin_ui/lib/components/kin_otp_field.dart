import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_spacing.dart';
import '../core/kin_radius.dart';
import '../core/kin_typography.dart';

/// A one-time-password input field with auto-focus advancing.
class KinOtpField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool autofocus;

  const KinOtpField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.obscureText = false,
    this.autofocus = true,
  });

  @override
  State<KinOtpField> createState() => _KinOtpFieldState();
}

class _KinOtpFieldState extends State<KinOtpField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Paste handling
      final chars = value.split('');
      for (int i = 0; i < chars.length && (index + i) < widget.length; i++) {
        _controllers[index + i].text = chars[i];
      }
      final nextIdx = (index + chars.length).clamp(0, widget.length - 1);
      _focusNodes[nextIdx].requestFocus();
    } else if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    widget.onChanged?.call(_value);
    if (_value.length == widget.length) {
      widget.onCompleted?.call(_value);
    }
  }

  void _onKeyDown(int index, KeyEvent event) {
    if (event.logicalKey.keyLabel == 'Backspace' &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    return Row(
      children: List.generate(widget.length, (i) {
        return Expanded(
          child: Padding(
          padding: EdgeInsets.only(right: i < widget.length - 1 ? KinSpacing.sm : 0),
          child: SizedBox(
            height: 56,
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) => _onKeyDown(i, event),
              child: AnimatedContainer(
                duration: KinMotion.fast,
                decoration: BoxDecoration(
                  color: theme.surfaceVariant,
                  borderRadius: KinRadius.mdAll,
                  border: Border.all(
                    color: _focusNodes[i].hasFocus ? theme.primary : theme.outline,
                    width: _focusNodes[i].hasFocus ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: EditableText(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    style: KinTypography.titleLarge.copyWith(color: theme.onSurface),
                    cursorColor: theme.primary,
                    backgroundCursorColor: theme.surfaceVariant,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    obscureText: widget.obscureText,
                    maxLines: 1,
                    onChanged: (v) => _onChanged(i, v),
                    autofocus: widget.autofocus && i == 0,
                  ),
                ),
              ),
            ),
          ),
        ),
        );
      }),
    );
  }
}

/// A number pad widget for PIN/code entry.
class KinNumberPad extends StatelessWidget {
  final ValueChanged<String> onKeyPressed;
  final VoidCallback? onDelete;
  final VoidCallback? onSubmit;
  final bool showBiometric;

  const KinNumberPad({
    super.key,
    required this.onKeyPressed,
    this.onDelete,
    this.onSubmit,
    this.showBiometric = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    Widget keyButton(String label, {VoidCallback? onTap, IconData? icon}) {
      return GestureDetector(
        onTap: onTap ?? () => onKeyPressed(label),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: theme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, size: 24, color: theme.onSurface)
                : Text(
                    label,
                    style: KinTypography.titleLarge.copyWith(
                      color: theme.onSurface,
                      fontSize: 28,
                    ),
                  ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: KinSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final key in row) ...[
                  keyButton(key),
                  if (key != row.last) const SizedBox(width: KinSpacing.lg),
                ],
              ],
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            showBiometric
                ? keyButton('', onTap: onSubmit, icon: Icons.fingerprint)
                : const SizedBox(width: 72, height: 72),
            const SizedBox(width: KinSpacing.lg),
            keyButton('0'),
            const SizedBox(width: KinSpacing.lg),
            keyButton('', onTap: onDelete, icon: Icons.backspace_outlined),
          ],
        ),
      ],
    );
  }
}
