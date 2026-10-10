import 'package:flutter/widgets.dart';
import '../core/kin_theme.dart';
import '../core/kin_typography.dart';

/// Typography-aware text with named constructors for each type-scale level.
class KinText extends StatelessWidget {
  final InlineSpan? textSpan;
  final String data;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const KinText(
    this.data, {
    super.key,
    this.textSpan,
    this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  const KinText.rich(
    this.textSpan, {
    super.key,
    this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : data = '';

  // ── Display ──

  const KinText.displayLarge(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.displayLarge;

  const KinText.displayMedium(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.displayMedium;

  const KinText.displaySmall(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.displaySmall;

  // ── Title ──

  const KinText.titleLarge(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.titleLarge;

  const KinText.titleMedium(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.titleMedium;

  const KinText.titleSmall(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.titleSmall;

  // ── Headline / Subheadline ──

  const KinText.headline(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.headline;

  const KinText.subheadline(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.subheadline;

  // ── Body ──

  const KinText.bodyLarge(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.bodyLarge;

  const KinText.bodyMedium(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.bodyMedium;

  const KinText.bodySmall(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.bodySmall;

  // ── Callout ──

  const KinText.callout(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.callout;

  // ── Label ──

  const KinText.labelLarge(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.labelLarge;

  const KinText.labelMedium(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.labelMedium;

  const KinText.labelSmall(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.labelSmall;

  // ── Caption ──

  const KinText.captionLarge(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.captionLarge;

  const KinText.captionSmall(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.captionSmall;

  // ── Footnote ──

  const KinText.footnote(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.footnote;

  // ── Overline ──

  const KinText.overline(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.overline;

  // ── Mono ──

  const KinText.mono(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.mono;

  const KinText.monoSmall(
    this.data, {
    super.key,
    this.textSpan,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = KinTypography.monoSmall;

  @override
  Widget build(BuildContext context) {
    if (textSpan != null)
      return Text.rich(
        textSpan!,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    final theme = KinTheme.of(context);
    final resolvedColor = color ?? theme.onSurface;

    return Text(
      data,
      style: (style ?? KinTypography.bodyLarge).copyWith(color: resolvedColor),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
