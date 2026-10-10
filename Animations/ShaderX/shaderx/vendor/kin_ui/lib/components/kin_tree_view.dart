import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// Data model for a single tree node.
class KinTreeNode<T> {
  final T value;
  final String label;
  final IconData? icon;
  final List<KinTreeNode<T>> children;

  const KinTreeNode({
    required this.value,
    required this.label,
    this.icon,
    this.children = const [],
  });

  bool get isLeaf => children.isEmpty;
}

/// An advanced tree view with animated expand/collapse, indentation lines,
/// and optional selection.
class KinTreeView<T> extends StatelessWidget {
  final List<KinTreeNode<T>> nodes;
  final T? selectedValue;
  final ValueChanged<KinTreeNode<T>>? onNodeTap;
  final double indentWidth;
  final bool showLines;
  final Set<T>? initiallyExpanded;
  final Widget Function(KinTreeNode<T>, bool isExpanded, bool isSelected)?
      nodeBuilder;

  const KinTreeView({
    super.key,
    required this.nodes,
    this.selectedValue,
    this.onNodeTap,
    this.indentWidth = 20,
    this.showLines = true,
    this.initiallyExpanded,
    this.nodeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < nodes.length; i++)
          _TreeNodeWidget<T>(
            node: nodes[i],
            depth: 0,
            indentWidth: indentWidth,
            showLines: showLines,
            selectedValue: selectedValue,
            onNodeTap: onNodeTap,
            initiallyExpanded: initiallyExpanded,
            nodeBuilder: nodeBuilder,
            isLastChild: i == nodes.length - 1,
            parentLineFlags: const [],
          ),
      ],
    );
  }
}

class _TreeNodeWidget<T> extends StatefulWidget {
  final KinTreeNode<T> node;
  final int depth;
  final double indentWidth;
  final bool showLines;
  final T? selectedValue;
  final ValueChanged<KinTreeNode<T>>? onNodeTap;
  final Set<T>? initiallyExpanded;
  final Widget Function(KinTreeNode<T>, bool, bool)? nodeBuilder;
  final bool isLastChild;
  final List<bool> parentLineFlags; // true = parent draws continuation line

  const _TreeNodeWidget({
    required this.node,
    required this.depth,
    required this.indentWidth,
    required this.showLines,
    this.selectedValue,
    this.onNodeTap,
    this.initiallyExpanded,
    this.nodeBuilder,
    required this.isLastChild,
    required this.parentLineFlags,
  });

  @override
  State<_TreeNodeWidget<T>> createState() => _TreeNodeWidgetState<T>();
}

class _TreeNodeWidgetState<T> extends State<_TreeNodeWidget<T>>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded?.contains(widget.node.value) ?? false;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: _expanded ? 1.0 : 0.0,
    );
    _expandAnim = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final isSelected = widget.selectedValue == widget.node.value;
    final hasChildren = !widget.node.isLeaf;

    // Build indentation with optional tree lines
    Widget buildIndent() {
      if (widget.depth == 0) return const SizedBox.shrink();
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int d = 0; d < widget.depth; d++)
            SizedBox(
              width: widget.indentWidth,
              height: 36,
              child: widget.showLines
                  ? CustomPaint(
                      painter: _TreeLinePainter(
                        color: theme.outline.withValues(alpha: 0.25),
                        isLast: d == widget.depth - 1 && widget.isLastChild,
                        showVertical: d < widget.parentLineFlags.length &&
                            widget.parentLineFlags[d],
                        isTerminal: d == widget.depth - 1,
                      ),
                    )
                  : null,
            ),
        ],
      );
    }

    // Custom or default node content
    Widget nodeContent;
    if (widget.nodeBuilder != null) {
      nodeContent = widget.nodeBuilder!(widget.node, _expanded, isSelected);
    } else {
      nodeContent = Row(
        children: [
          if (hasChildren)
            AnimatedRotation(
              turns: _expanded ? 0.0 : -0.25,
              duration: KinMotion.fast,
              child: Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: theme.onSurfaceVariant,
              ),
            )
          else
            const SizedBox(width: 18),
          const SizedBox(width: 4),
          if (widget.node.icon != null) ...[
            Icon(
              widget.node.icon,
              size: 16,
              color: isSelected ? theme.primary : theme.onSurfaceVariant,
            ),
            const SizedBox(width: KinSpacing.xs),
          ],
          Expanded(
            child: Text(
              widget.node.label,
              style: KinTypography.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? theme.primary : theme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    final childLineFlags = [
      ...widget.parentLineFlags,
      !widget.isLastChild,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (hasChildren) {
              _toggle();
            }
            widget.onNodeTap?.call(widget.node);
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: KinMotion.fast,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                buildIndent(),
                Expanded(child: nodeContent),
              ],
            ),
          ),
        ),

        // Children with animated expand
        if (hasChildren)
          SizeTransition(
            sizeFactor: _expandAnim,
            axisAlignment: -1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < widget.node.children.length; i++)
                  _TreeNodeWidget<T>(
                    node: widget.node.children[i],
                    depth: widget.depth + 1,
                    indentWidth: widget.indentWidth,
                    showLines: widget.showLines,
                    selectedValue: widget.selectedValue,
                    onNodeTap: widget.onNodeTap,
                    initiallyExpanded: widget.initiallyExpanded,
                    nodeBuilder: widget.nodeBuilder,
                    isLastChild: i == widget.node.children.length - 1,
                    parentLineFlags: childLineFlags,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Paints tree guide lines (vertical continuation + L-shaped branches).
class _TreeLinePainter extends CustomPainter {
  final Color color;
  final bool isLast;
  final bool showVertical;
  final bool isTerminal;

  _TreeLinePainter({
    required this.color,
    required this.isLast,
    required this.showVertical,
    required this.isTerminal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final midX = size.width / 2;
    final midY = size.height / 2;

    if (isTerminal) {
      // Vertical line from top (to mid if last, to bottom otherwise)
      canvas.drawLine(
        Offset(midX, 0),
        Offset(midX, isLast ? midY : size.height),
        paint,
      );
      // Horizontal branch to the right
      canvas.drawLine(
        Offset(midX, midY),
        Offset(size.width, midY),
        paint,
      );
    } else if (showVertical) {
      // Continuation line for ancestors that have more siblings below
      canvas.drawLine(
        Offset(midX, 0),
        Offset(midX, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TreeLinePainter old) =>
      color != old.color ||
      isLast != old.isLast ||
      showVertical != old.showVertical ||
      isTerminal != old.isTerminal;
}
