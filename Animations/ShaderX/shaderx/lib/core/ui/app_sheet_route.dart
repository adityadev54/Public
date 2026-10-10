import 'package:flutter/cupertino.dart';

class AppSheetRoute<T> extends CupertinoSheetRoute<T> {
  AppSheetRoute({required super.scrollableBuilder});
  @override
  Widget buildContent(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(26),
    child: super.buildContent(context),
  );
  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      (context, animation, secondaryAnimation, allowSnapshotting, child) =>
          CupertinoSheetTransition.delegateTransition(
            context,
            animation,
            secondaryAnimation,
            allowSnapshotting,
            child == null
                ? null
                : ClipRRect(
                    borderRadius: secondaryAnimation.isDismissed
                        ? BorderRadius.zero
                        : BorderRadius.circular(26),
                    child: child,
                  ),
          );
}
