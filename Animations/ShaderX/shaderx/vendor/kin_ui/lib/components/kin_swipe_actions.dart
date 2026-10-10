import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/kin_motion.dart';
import '../core/kin_typography.dart';

/// A single swipe action button.
class KinSwipeAction {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;

  const KinSwipeAction({
    required this.label,
    this.icon,
    required this.color,
    required this.onTap,
  });
}

/// Wraps a child with swipe-to-reveal action buttons.
///
/// Swipe left to reveal trailing actions, right for leading actions.
class KinSwipeActions extends StatefulWidget {
  final Widget child;
  final List<KinSwipeAction> leadingActions;
  final List<KinSwipeAction> trailingActions;
  final double actionWidth;

  const KinSwipeActions({
    super.key,
    required this.child,
    this.leadingActions = const [],
    this.trailingActions = const [],
    this.actionWidth = 72,
  });

  @override
  State<KinSwipeActions> createState() => _KinSwipeActionsState();
}

class _KinSwipeActionsState extends State<KinSwipeActions>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragOffset = 0;


  double get _maxTrailing => widget.trailingActions.length * widget.actionWidth;
  double get _maxLeading => widget.leadingActions.length * widget.actionWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: KinMotion.normal,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.primaryDelta!;

      // Clamp with rubber-band
      if (_dragOffset < -_maxTrailing) {
        _dragOffset = -_maxTrailing - (_dragOffset + _maxTrailing) * 0.2;
      }
      if (_dragOffset > _maxLeading) {
        _dragOffset = _maxLeading + (_dragOffset - _maxLeading) * 0.2;
      }

      // No leading if no leading actions
      if (widget.leadingActions.isEmpty && _dragOffset > 0) {
        _dragOffset = _dragOffset * 0.2;
      }
      if (widget.trailingActions.isEmpty && _dragOffset < 0) {
        _dragOffset = _dragOffset * 0.2;
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    double target = 0;
    if (_dragOffset < -_maxTrailing * 0.4 || velocity < -500) {
      target = -_maxTrailing;
      HapticFeedback.selectionClick();
    } else if (_dragOffset > _maxLeading * 0.4 || velocity > 500) {
      target = _maxLeading;
      HapticFeedback.selectionClick();
    }

    _animateTo(target);
  }

  void _animateTo(double target) {
    final startOffset = _dragOffset;
    _controller.reset();

    _controller.addListener(() {
      setState(() {
        _dragOffset = startOffset + (_controller.value * (target - startOffset));
      });
    });

    _controller.forward();
  }

  void _close() => _animateTo(0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onTap: _dragOffset != 0 ? _close : null,
      child: Stack(
        children: [
          // Leading actions (right side, revealed by swiping right)
          if (widget.leadingActions.isNotEmpty && _dragOffset > 0)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: _dragOffset.clamp(0, _maxLeading + 20),
              child: Row(
                children: widget.leadingActions.map((action) {
                  return _ActionButton(
                    action: action,
                    width: (_dragOffset / widget.leadingActions.length).clamp(0, widget.actionWidth),
                    onTap: () {
                      _close();
                      action.onTap();
                    },
                  );
                }).toList(),
              ),
            ),

          // Trailing actions (right side, revealed by swiping left)
          if (widget.trailingActions.isNotEmpty && _dragOffset < 0)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: (-_dragOffset).clamp(0, _maxTrailing + 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.trailingActions.map((action) {
                  return _ActionButton(
                    action: action,
                    width: (-_dragOffset / widget.trailingActions.length).clamp(0, widget.actionWidth),
                    onTap: () {
                      _close();
                      action.onTap();
                    },
                  );
                }).toList(),
              ),
            ),

          // Main content
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final KinSwipeAction action;
  final double width;
  final VoidCallback onTap;

  const _ActionButton({
    required this.action,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: width,
        color: action.color,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (action.icon != null)
                Icon(action.icon, color: Colors.white, size: 22),
              if (action.icon != null && width > 50) const SizedBox(height: 2),
              if (width > 50)
                Text(
                  action.label,
                  style: KinTypography.captionLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
