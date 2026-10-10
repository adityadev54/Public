import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// Position from which the drawer slides in.
enum KinDrawerEdge { left, right }

/// Controller that drives a [KinDrawer] open / closed.
class KinDrawerController extends ChangeNotifier {
  bool _isOpen = false;
  bool get isOpen => _isOpen;

  void open() {
    if (!_isOpen) {
      _isOpen = true;
      notifyListeners();
    }
  }

  void close() {
    if (_isOpen) {
      _isOpen = false;
      notifyListeners();
    }
  }

  void toggle() => _isOpen ? close() : open();
}

/// iOS 18-style push-body drawer with spring physics, swipe gesture,
/// body scale-down + corner radius, and dark panel.
class KinDrawer extends StatefulWidget {
  final Widget body;
  final List<Widget> children;
  final Widget? header;
  final Widget? footer;
  final KinDrawerController controller;
  final double drawerWidth;
  final KinDrawerEdge edge;

  const KinDrawer({
    super.key,
    required this.body,
    required this.children,
    required this.controller,
    this.header,
    this.footer,
    this.drawerWidth = 280,
    this.edge = KinDrawerEdge.left,
  });

  @override
  State<KinDrawer> createState() => _KinDrawerState();
}

class _KinDrawerState extends State<KinDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  double _dragOffset = 0;

  bool get _isLeft => widget.edge == KinDrawerEdge.left;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this);
    widget.controller.addListener(_sync);
  }

  @override
  void didUpdateWidget(covariant KinDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_sync);
      widget.controller.addListener(_sync);
    }
  }

  /// Drawer-tuned spring: fluid and weighty like iOS sidebar.
  static final SpringDescription _drawerSpring = SpringDescription(
    mass: 1.0,
    stiffness: 180.0,
    damping: 22.0,
  );

  void _sync() => _springTo(widget.controller.isOpen ? 1.0 : 0.0, 0);

  void _springTo(double target, double velocity) {
    final sim = SpringSimulation(_drawerSpring, _anim.value, target, velocity);
    _anim.animateWith(sim);
  }

  // ── Gesture ──
  void _onDragStart(DragStartDetails _) {
    _dragOffset = _anim.value * widget.drawerWidth;
    _anim.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    _dragOffset += _isLeft ? delta : -delta;
    _dragOffset = _dragOffset.clamp(0.0, widget.drawerWidth);
    _anim.value = _dragOffset / widget.drawerWidth;
  }

  void _onDragEnd(DragEndDetails details) {
    final v = details.primaryVelocity ?? 0;
    final nv = (v / widget.drawerWidth).clamp(-5.0, 5.0);
    final sv = _isLeft ? nv : -nv;
    final shouldOpen = _isLeft
        ? (v > 300 || (_anim.value > 0.35 && v >= 0))
        : (v < -300 || (_anim.value > 0.35 && v <= 0));

    if (shouldOpen) {
      widget.controller.open();
    } else {
      widget.controller.close();
    }
    _springTo(shouldOpen ? 1.0 : 0.0, sv);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final t = _anim.value.clamp(0.0, 1.0);
        // Curves for a polished feel
        final tEased = Curves.easeOutCubic.transform(t);
        final slideX = widget.drawerWidth * tEased;
        final bodyScale = 1.0 - (0.06 * tEased);
        final bodyRadius = 40.0 * Curves.easeOut.transform(t);
        final scrimAlpha = 0.4 * tEased;
        // Drawer parallax: starts pushed back, slides into place
        final drawerParallax = widget.drawerWidth * 0.25 * (1.0 - tEased);
        final drawerOpacity = Curves.easeOut.transform(t.clamp(0.0, 1.0));

        final statusBarStyle = t > 0.3
            ? SystemUiOverlayStyle.light
            : (Theme.of(context).brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: statusBarStyle,
          child: Material(
            color: const Color(0xFF0E0E14),
            child: GestureDetector(
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: Stack(
                children: [
                  // ── Drawer panel ──
                  Positioned(
                    left: _isLeft ? 0 : null,
                    right: _isLeft ? null : 0,
                    top: 0,
                    bottom: 0,
                    width: widget.drawerWidth,
                    child: Transform.translate(
                      offset: Offset(_isLeft ? -drawerParallax : drawerParallax, 0),
                      child: Opacity(
                        opacity: drawerOpacity,
                        child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.header != null) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  KinSpacing.lg, KinSpacing.md, KinSpacing.lg, KinSpacing.sm,
                                ),
                                child: IconTheme(
                                  data: const IconThemeData(color: Colors.white),
                                  child: DefaultTextStyle(
                                    style: const TextStyle(color: Colors.white, decoration: TextDecoration.none),
                                    child: widget.header!,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: KinSpacing.lg),
                                child: Container(height: 0.5, color: Colors.white.withValues(alpha: 0.08)),
                              ),
                              const SizedBox(height: KinSpacing.sm),
                            ],
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(vertical: KinSpacing.xs),
                                children: widget.children,
                              ),
                            ),
                            if (widget.footer != null) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: KinSpacing.lg),
                                child: Container(height: 0.5, color: Colors.white.withValues(alpha: 0.08)),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  KinSpacing.lg, KinSpacing.sm, KinSpacing.lg, KinSpacing.sm,
                                ),
                                child: IconTheme(
                                  data: const IconThemeData(color: Colors.white70),
                                  child: DefaultTextStyle(
                                    style: const TextStyle(color: Colors.white70, decoration: TextDecoration.none),
                                    child: widget.footer!,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  ),

                  // ── Body ──
                  Transform.translate(
                    offset: Offset(_isLeft ? slideX : -slideX, 0),
                    child: Transform.scale(
                      scale: bodyScale,
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(bodyRadius),
                        child: Stack(
                          children: [
                            widget.body,
                            if (t > 0.01)
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () => widget.controller.close(),
                                  child: Container(color: Colors.black.withValues(alpha: scrimAlpha)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A row item for [KinDrawer] with press highlight.
class KinDrawerItem extends StatefulWidget {
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;
  final VoidCallback? onTap;

  const KinDrawerItem({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onTap,
  });

  @override
  State<KinDrawerItem> createState() => _KinDrawerItemState();
}

class _KinDrawerItemState extends State<KinDrawerItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    final textColor = sel ? Colors.white : Colors.white.withValues(alpha: 0.65);
    final iconColor = sel ? Colors.white : Colors.white.withValues(alpha: 0.5);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: const EdgeInsets.symmetric(horizontal: KinSpacing.sm, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: KinSpacing.md, vertical: KinSpacing.sm + 2),
        decoration: BoxDecoration(
          color: _pressed
              ? Colors.white.withValues(alpha: 0.12)
              : sel
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          spacing: KinSpacing.sm + 2,
          children: [
            if (widget.leading != null)
              IconTheme(data: IconThemeData(color: iconColor, size: 22), child: widget.leading!),
            Expanded(
              child: Text(
                widget.label,
                style: KinTypography.bodyMedium.copyWith(
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                  color: textColor,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            if (widget.trailing != null)
              IconTheme(data: IconThemeData(color: Colors.white.withValues(alpha: 0.4), size: 18), child: widget.trailing!),
          ],
        ),
      ),
    );
  }
}

/// Section header within a [KinDrawer].
class KinDrawerSection extends StatelessWidget {
  final String title;

  const KinDrawerSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: KinSpacing.lg + KinSpacing.sm,
        right: KinSpacing.lg,
        top: KinSpacing.md + 4,
        bottom: KinSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: KinTypography.labelSmall.copyWith(
          color: Colors.white.withValues(alpha: 0.35),
          letterSpacing: 0.8,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
