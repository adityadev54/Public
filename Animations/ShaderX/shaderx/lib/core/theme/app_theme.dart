import 'package:flutter/material.dart';
import 'package:kin_ui/kin_ui.dart';
import 'app_tokens.dart';

abstract final class AppTheme {
  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppTokens.accent,
      brightness: brightness,
      primary: dark ? AppTokens.accent : const Color(0xFF52621A),
      surface: dark ? AppTokens.darkSurface : const Color(0xFFFAFBF4),
    );
    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? AppTokens.darkBackground
          : const Color(0xFFF0F2E9),
      extensions: [
        (dark ? KinTheme.dark : KinTheme.light).copyWith(
          primary: scheme.primary,
          surface: scheme.surface,
          onSurface: scheme.onSurface,
          onSurfaceVariant: scheme.onSurfaceVariant,
          outline: scheme.outline,
        ),
      ],
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w600,
          letterSpacing: -1,
          height: 1.12,
          color: scheme.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w600,
          letterSpacing: -.4,
          color: scheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: scheme.onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: scheme.onSurfaceVariant,
        ),
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 3,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: .4),
        thickness: .5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
