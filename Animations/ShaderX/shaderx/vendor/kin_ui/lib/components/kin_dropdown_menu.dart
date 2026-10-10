import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';
import 'kin_text.dart';

/// A single item in [KinDropdownMenu].
class KinDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool isDestructive;

  const KinDropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.isDestructive = false,
  });
}

/// A themed dropdown menu with spring animation and blur backdrop.
///
/// Tapping the trigger opens an overlay dropdown aligned below (or above)
/// that matches the Kin design system.
class KinDropdownMenu<T> extends StatefulWidget {
  final T? value;
  final List<KinDropdownItem<T>> items;
  final ValueChanged<T> onChanged;
  final String? hint;
  final String? label;
  final bool enabled;
  final Widget Function(KinDropdownItem<T>)? itemBuilder;

  const KinDropdownMenu({
    super.key,
    this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.label,
    this.enabled = true,
    this.itemBuilder,
  });

  @override
  State<KinDropdownMenu<T>> createState() => _KinDropdownMenuState<T>();
}

class _KinDropdownMenuState<T> extends State<KinDropdownMenu<T>>
    with SingleTickerProviderStateMixin {
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _close();
    _animCtrl.dispose();
    super.dispose();
  }

  KinDropdownItem<T>? get _selectedItem {
    if (widget.value == null) return null;
    try {
      return widget.items.firstWhere((i) => i.value == widget.value);
    } catch (_) {
      return null;
    }
  }

  void _toggle() {
    if (!widget.enabled) return;
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    HapticFeedback.selectionClick();

    final renderBox = context.findRenderObject() as RenderBox;
    final triggerSize = renderBox.size;
    final triggerGlobal = renderBox.localToGlobal(Offset.zero);
    final screenH = MediaQuery.sizeOf(context).height;
    final theme = KinTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Decide: open below or above?
    final spaceBelow = screenH - triggerGlobal.dy - triggerSize.height - 16;
    final menuHeight = (widget.items.length * 44.0 + 8).clamp(0.0, 260.0);
    final openBelow = spaceBelow >= menuHeight;

    _overlayEntry = OverlayEntry(
      builder: (_) => _DropdownOverlay<T>(
        items: widget.items,
        selectedValue: widget.value,
        onSelect: (v) {
          _close();
          widget.onChanged(v);
        },
        onDismiss: _close,
        layerLink: _layerLink,
        triggerWidth: triggerSize.width,
        triggerHeight: triggerSize.height,
        openBelow: openBelow,
        menuHeight: menuHeight,
        scaleAnim: _scaleAnim,
        fadeAnim: _fadeAnim,
        theme: theme,
        isDark: isDark,
        itemBuilder: widget.itemBuilder,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animCtrl.forward(from: 0);
    setState(() => _isOpen = true);
  }

  void _close() {
    if (!_isOpen) return;
    _animCtrl.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
    setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final selected = _selectedItem;
    final isDisabled = !widget.enabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          KinText(
            widget.label!,
            style: KinTypography.labelMedium,
            color: theme.onSurfaceVariant,
          ),
          const SizedBox(height: KinSpacing.xs),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggle,
            child: AnimatedContainer(
              duration: KinMotion.fast,
              padding: const EdgeInsets.symmetric(
                horizontal: KinSpacing.md,
                vertical: KinSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: theme.surfaceVariant,
                borderRadius: KinRadius.pillAll,
                border: Border.all(
                  color: _isOpen ? theme.primary.withValues(alpha: 0.4) : theme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: KinText(
                      selected?.label ?? widget.hint ?? 'Select...',
                      style: KinTypography.bodyMedium,
                      color: selected != null
                          ? theme.onSurface
                          : theme.onSurfaceVariant.withValues(
                              alpha: isDisabled ? 0.4 : 0.6),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0.0,
                    duration: KinMotion.fast,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: isDisabled
                          ? theme.onSurfaceVariant.withValues(alpha: 0.4)
                          : theme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Overlay ──

class _DropdownOverlay<T> extends StatelessWidget {
  final List<KinDropdownItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T> onSelect;
  final VoidCallback onDismiss;
  final LayerLink layerLink;
  final double triggerWidth;
  final double triggerHeight;
  final bool openBelow;
  final double menuHeight;
  final Animation<double> scaleAnim;
  final Animation<double> fadeAnim;
  final KinTheme theme;
  final bool isDark;
  final Widget Function(KinDropdownItem<T>)? itemBuilder;

  const _DropdownOverlay({
    required this.items,
    this.selectedValue,
    required this.onSelect,
    required this.onDismiss,
    required this.layerLink,
    required this.triggerWidth,
    required this.triggerHeight,
    required this.openBelow,
    required this.menuHeight,
    required this.scaleAnim,
    required this.fadeAnim,
    required this.theme,
    required this.isDark,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? theme.surfaceVariant.withValues(alpha: 0.92)
        : theme.surfaceVariant;

    return Stack(
      children: [
        // Dismiss layer
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),

        // Menu
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, openBelow ? triggerHeight + 6 : -(menuHeight + 6)),
          child: AnimatedBuilder(
            animation: scaleAnim,
            builder: (context, _) {
              return FadeTransition(
                opacity: fadeAnim,
                child: ScaleTransition(
                  scale: scaleAnim,
                  alignment: openBelow ? Alignment.topCenter : Alignment.bottomCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: KinRadius.xlAll,
                      child: BackdropFilter(
                        filter: isDark
                            ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                        child: Container(
                          width: triggerWidth,
                          constraints: BoxConstraints(maxHeight: menuHeight),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: KinRadius.xlAll,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: items.map((item) {
                                if (itemBuilder != null) {
                                  return GestureDetector(
                                    onTap: () => onSelect(item.value),
                                    behavior: HitTestBehavior.opaque,
                                    child: itemBuilder!(item),
                                  );
                                }
                                return _DropdownRow<T>(
                                  item: item,
                                  isSelected: item.value == selectedValue,
                                  theme: theme,
                                  onTap: () => onSelect(item.value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DropdownRow<T> extends StatefulWidget {
  final KinDropdownItem<T> item;
  final bool isSelected;
  final KinTheme theme;
  final VoidCallback onTap;

  const _DropdownRow({
    required this.item,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  State<_DropdownRow<T>> createState() => _DropdownRowState<T>();
}

class _DropdownRowState<T> extends State<_DropdownRow<T>> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.item.isDestructive
        ? widget.theme.destructive
        : widget.theme.onSurface;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        Future.delayed(const Duration(milliseconds: 60), widget.onTap);
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        padding: const EdgeInsets.symmetric(
          horizontal: KinSpacing.sm + 2,
          vertical: KinSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: _pressed
              ? widget.theme.onSurface.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: KinRadius.mdAll,
        ),
        child: Row(
          children: [
            if (widget.item.icon != null) ...[
              Icon(widget.item.icon, size: 18, color: color),
              const SizedBox(width: KinSpacing.sm),
            ],
            Expanded(
              child: KinText(
                widget.item.label,
                style: KinTypography.bodyMedium.copyWith(
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                color: color,
              ),
            ),
            if (widget.isSelected)
              Icon(Icons.check_rounded, size: 18, color: widget.theme.primary),
          ],
        ),
      ),
    );
  }
}
