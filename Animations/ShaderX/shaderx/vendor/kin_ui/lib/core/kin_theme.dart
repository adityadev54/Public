import 'package:flutter/material.dart';

/// Eight-color theme extension that every Kin component reads from context.
class KinTheme extends ThemeExtension<KinTheme> {
  final Color primary;
  final Color primaryContainer;
  final Color surface;
  final Color surfaceVariant;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color destructive;
  final Color success;
  final Color warning;

  const KinTheme({
    required this.primary,
    required this.primaryContainer,
    required this.surface,
    required this.surfaceVariant,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.destructive,
    this.success = const Color(0xFF34C759),
    this.warning = const Color(0xFFFF9F0A),
  });

  @override
  KinTheme copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? surface,
    Color? surfaceVariant,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? outline,
    Color? destructive,
    Color? success,
    Color? warning,
  }) {
    return KinTheme(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      destructive: destructive ?? this.destructive,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  KinTheme lerp(covariant KinTheme? other, double t) {
    if (other == null) return this;
    return KinTheme(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(
        onSurfaceVariant,
        other.onSurfaceVariant,
        t,
      )!,
      outline: Color.lerp(outline, other.outline, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }

  static KinTheme of(BuildContext context) {
    return Theme.of(context).extension<KinTheme>()!;
  }

  /// Default shipped light preset.
  static KinTheme get light => inkLight;

  /// Default shipped dark preset.
  static KinTheme get dark => inkDark;

  /// Monochrome light preset tuned for out-of-the-box package usage.
  static KinTheme get inkLight => _inkLight;

  /// Monochrome dark preset tuned for out-of-the-box package usage.
  static KinTheme get inkDark => _inkDark;

  // Backwards-compatible aliases.
  static KinTheme get white => inkLight;
  static KinTheme get black => inkDark;

  // ── Preset instances ──
  static const _inkDark = KinTheme(
    primary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF181818),
    surface: Color(0xFF000000),
    surfaceVariant: Color(0xFF101010),
    onSurface: Color(0xFFF7F7F7),
    onSurfaceVariant: Color(0xFF9A9A9A),
    outline: Color(0xFF262626),
    destructive: Color(0xFFFF453A),
  );

  static const _inkLight = KinTheme(
    primary: Color(0xFF111111),
    primaryContainer: Color(0xFFF2F2F2),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF7F7F7),
    onSurface: Color(0xFF111111),
    onSurfaceVariant: Color(0xFF6E6E73),
    outline: Color(0xFFE6E6E6),
    destructive: Color(0xFFFF453A),
  );
}
