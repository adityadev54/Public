import 'package:flutter/widgets.dart';
import 'kin_layout.dart';

/// Root wrapper that injects [KinLayout] and sets bouncing scroll physics.
class KinApp extends StatelessWidget {
  final Widget child;

  const KinApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the shortest side so landscape keeps the same layout tier.
        final shortest = constraints.biggest.shortestSide;
        final data = KinLayoutData.fromWidth(shortest);
        return KinLayout(
          data: data,
          child: ScrollConfiguration(
            behavior: const _KinScrollBehavior(),
            child: child,
          ),
        );
      },
    );
  }
}

class _KinScrollBehavior extends ScrollBehavior {
  const _KinScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}
