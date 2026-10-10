import 'package:flutter/material.dart';
import 'responsive.dart';

class ContentFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ContentFrame({super.key, required this.child, this.maxWidth = 1100});
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.gutter(context)),
        child: child,
      ),
    ),
  );
}
