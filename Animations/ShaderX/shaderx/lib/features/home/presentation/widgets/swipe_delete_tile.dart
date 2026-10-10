import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

/// A short left swipe reveals an action; swiping never deletes saved work.
class SwipeDeleteTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  const SwipeDeleteTile({
    super.key,
    required this.child,
    required this.onDelete,
  });
  @override
  State<SwipeDeleteTile> createState() => _SwipeDeleteTileState();
}

class _SwipeDeleteTileState extends State<SwipeDeleteTile> {
  double offset = 0;
  @override
  Widget build(BuildContext context) => Semantics(
    customSemanticsActions: {
      CustomSemanticsAction(label: 'Show delete'): () =>
          setState(() => offset = 80),
    },
    child: ClipRect(
      child: GestureDetector(
        onHorizontalDragUpdate: (details) =>
            setState(() => offset = (offset - details.delta.dx).clamp(0, 80)),
        onHorizontalDragEnd: (_) =>
            setState(() => offset = offset > 35 ? 80 : 0),
        onHorizontalDragCancel: () => setState(() => offset = 0),
        onTap: offset > 0 ? () => setState(() => offset = 0) : null,
        child: Stack(
          children: [
            if (offset > 0)
              Positioned.fill(
                child: ExcludeSemantics(
                  excluding: offset == 0,
                  child: IgnorePointer(
                    ignoring: offset == 0,
                    child: Material(
                      color: Theme.of(context).colorScheme.error,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 80,
                          height: double.infinity,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onError,
                              shape: const RoundedRectangleBorder(),
                            ),
                            onPressed: () {
                              setState(() => offset = 0);
                              widget.onDelete();
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(HeroiconsOutline.trash, size: 20),
                                SizedBox(height: 4),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(-offset, 0, 0),
              child: AbsorbPointer(
                absorbing: offset > 0,
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
