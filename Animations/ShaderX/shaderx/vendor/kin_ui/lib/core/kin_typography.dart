import 'dart:ui';
import 'package:flutter/widgets.dart';

/// Complete type-scale inspired by iOS 18 SF Pro.
///
/// Uses the system font (SF Pro on iOS/macOS, Roboto on Android) with
/// precise optical sizing: tighter letter-spacing on large sizes,
/// generous height on body text, and proportional font-feature settings.
///
/// Scale levels follow Apple HIG naming with additions:
///   display → title → headline → subheadline → body → callout → caption → footnote → overline
abstract final class KinTypography {
  // ── Font feature for proportional figures ──
  static const _proportional = [FontFeature.proportionalFigures()];

  // ─────────────────────────────────────────────────────────────
  // DISPLAY — Hero text, splash screens, large headings
  // ─────────────────────────────────────────────────────────────

  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -1.0,
    fontFeatures: _proportional,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.7,
    fontFeatures: _proportional,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    fontFeatures: _proportional,
  );

  // ─────────────────────────────────────────────────────────────
  // TITLE — Section headers, navigation titles
  // ─────────────────────────────────────────────────────────────

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.4,
    fontFeatures: _proportional,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    fontFeatures: _proportional,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.1,
    fontFeatures: _proportional,
  );

  // ─────────────────────────────────────────────────────────────
  // HEADLINE / SUBHEADLINE — Card headers, list group titles
  // ─────────────────────────────────────────────────────────────

  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.2,
  );

  static const TextStyle subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: -0.1,
  );

  // ─────────────────────────────────────────────────────────────
  // BODY — Primary reading text
  // ─────────────────────────────────────────────────────────────

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.2,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.1,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  // ─────────────────────────────────────────────────────────────
  // CALLOUT — Emphasized secondary text, badges, tags
  // ─────────────────────────────────────────────────────────────

  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: -0.1,
  );

  // ─────────────────────────────────────────────────────────────
  // LABEL — Buttons, tabs, form labels
  // ─────────────────────────────────────────────────────────────

  static const TextStyle labelLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.0,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  // ─────────────────────────────────────────────────────────────
  // CAPTION — Timestamps, metadata, secondary info
  // ─────────────────────────────────────────────────────────────

  static const TextStyle captionLarge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: 0.1,
  );

  static const TextStyle captionSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.2,
  );

  // ─────────────────────────────────────────────────────────────
  // FOOTNOTE — Legal text, disclaimers, fine print
  // ─────────────────────────────────────────────────────────────

  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.0,
  );

  // ─────────────────────────────────────────────────────────────
  // OVERLINE — Section overlines, category tags
  // ─────────────────────────────────────────────────────────────

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 1.5,
  );

  // ─────────────────────────────────────────────────────────────
  // MONO — Code, numeric data, tabular content
  // ─────────────────────────────────────────────────────────────

  static const TextStyle mono = TextStyle(
    fontFamily: 'SF Mono',
    fontFamilyFallback: ['Menlo', 'Consolas', 'monospace'],
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle monoSmall = TextStyle(
    fontFamily: 'SF Mono',
    fontFamilyFallback: ['Menlo', 'Consolas', 'monospace'],
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
