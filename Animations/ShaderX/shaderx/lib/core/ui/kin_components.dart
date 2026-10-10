import 'package:flutter/material.dart';
import 'package:kin_ui/kin_ui.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  const AppText(this.text, {super.key, this.style, this.maxLines});
  @override
  Widget build(BuildContext context) => KinText(
    text,
    style: DefaultTextStyle.of(context).style.merge(style),
    maxLines: maxLines,
    overflow: maxLines == null ? null : TextOverflow.ellipsis,
  );
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  @override
  Widget build(BuildContext context) => KinCard(
    padding: padding,
    borderRadius: BorderRadius.circular(26),
    child: child,
  );
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final IconData? icon;
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
        Flexible(child: Text(label, maxLines: 2)),
      ],
    );
    final native = primary
        ? FilledButton(onPressed: onPressed, child: child)
        : TextButton(onPressed: onPressed, child: child);
    return KinButton(nativeChild: native, onTap: onPressed, child: child);
  }
}

class AppSlider extends StatelessWidget {
  final bool nativeAppearance;
  final String label;
  final double value, min, max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart, onChangeEnd;
  const AppSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.nativeAppearance = true,
    this.min = 0,
    this.max = 1,
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(child: AppText(label)),
          AppText(
            value.toStringAsFixed(2),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      Semantics(
        label: label,
        child: KinSlider(
          nativeAppearance: nativeAppearance,
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
          onChangeStart: onChangeStart,
          onChangeEnd: onChangeEnd,
        ),
      ),
    ],
  );
}
