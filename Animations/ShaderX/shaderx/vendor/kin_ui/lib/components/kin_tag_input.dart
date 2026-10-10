import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_spacing.dart';
import '../core/kin_radius.dart';
import '../core/kin_typography.dart';
import 'kin_press.dart';

/// A tag/chip input field where users can type and add tags.
class KinTagInput extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>>? onChanged;
  final String? hint;
  final String? label;
  final int? maxTags;
  final bool enabled;

  const KinTagInput({
    super.key,
    this.tags = const [],
    this.onChanged,
    this.hint,
    this.label,
    this.maxTags,
    this.enabled = true,
  });

  @override
  State<KinTagInput> createState() => _KinTagInputState();
}

class _KinTagInputState extends State<KinTagInput> {
  late List<String> _tags;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _tags = List.of(widget.tags);
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(KinTagInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tags != oldWidget.tags) {
      _tags = List.of(widget.tags);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty || _tags.contains(trimmed)) return;
    if (widget.maxTags != null && _tags.length >= widget.maxTags!) return;
    setState(() => _tags.add(trimmed));
    _controller.clear();
    widget.onChanged?.call(List.unmodifiable(_tags));
  }

  void _removeTag(int index) {
    setState(() => _tags.removeAt(index));
    widget.onChanged?.call(List.unmodifiable(_tags));
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: KinSpacing.xs),
            child: Text(
              widget.label!,
              style: KinTypography.labelLarge.copyWith(color: theme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: KinSpacing.xs),
        ],
        AnimatedContainer(
          duration: KinMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: KinSpacing.sm, vertical: KinSpacing.xs),
          decoration: BoxDecoration(
            color: theme.surfaceVariant,
            borderRadius: KinRadius.mdAll,
            border: Border.all(
              color: _focusNode.hasFocus ? theme.primary : theme.outline,
              width: _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: Wrap(
            spacing: KinSpacing.xs,
            runSpacing: KinSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (int i = 0; i < _tags.length; i++)
                _TagChip(
                  label: _tags[i],
                  onRemove: widget.enabled ? () => _removeTag(i) : null,
                  theme: theme,
                ),
              if (widget.enabled)
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 80),
                    child: EditableText(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: KinTypography.bodyMedium.copyWith(color: theme.onSurface),
                      cursorColor: theme.primary,
                      backgroundCursorColor: theme.surfaceVariant,
                      onSubmitted: (v) {
                        _addTag(v);
                        _focusNode.requestFocus();
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;
  final KinTheme theme;

  const _TagChip({required this.label, this.onRemove, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: KinSpacing.sm, vertical: KinSpacing.xs),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.12),
        borderRadius: KinRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: KinTypography.labelMedium.copyWith(color: theme.primary),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            KinPress(
              onTap: onRemove,
              child: Icon(Icons.close, size: 14, color: theme.primary),
            ),
          ],
        ],
      ),
    );
  }
}
