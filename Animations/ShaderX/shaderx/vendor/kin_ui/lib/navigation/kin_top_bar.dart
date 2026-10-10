import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';
import 'kin_scaffold.dart';

/// Samsung One UI 8.5-inspired top bar.
///
/// Uses [SliverAppBar] for native stretch & snap physics so the body
/// content and the collapsing header feel physically connected.
///
/// - Expanded: transparent background, large title at the bottom.
/// - Collapsed: solid [theme.surface] background, compact inline title.
class KinTopBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double expandedHeight;

  const KinTopBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.expandedHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    // Strip M3 icon-button containers so leading / actions stay
    // transparent during scroll-hide and collapse transitions,
    // but keep the ink splash overlay intact.
    return IconButtonTheme(
      data: IconButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return theme.onSurface.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return theme.onSurface.withValues(alpha: 0.08);
            }
            return null;
          }),
        ),
      ),
      child: SliverAppBar(
        pinned: true,
        stretch: true,
        expandedHeight: expandedHeight,
        toolbarHeight: 56,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: theme.onSurface,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: leading != null
            ? Builder(
                builder: (context) {
                  final visible = KinScrollHideScope.of(context);
                  final progress = _collapseProgress(context);
                  return AnimatedOpacity(
                    opacity: visible ? 1.0 : 0.0,
                    duration: KinMotion.normal,
                    curve: KinMotion.enter,
                    child: IgnorePointer(
                      ignoring: !visible,
                      child: Center(
                        child: SizedBox(
                          width: 45,
                          height: 45,
                          child: _FrostedWrap(
                            progress: progress,
                            isCircle: true,
                            theme: theme,
                            child: leading!,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : null,
        actions: actions != null
            ? [
                Builder(
                  builder: (context) {
                    final visible = KinScrollHideScope.of(context);
                    final progress = _collapseProgress(context);
                    return AnimatedOpacity(
                      opacity: visible ? 1.0 : 0.0,
                      duration: KinMotion.normal,
                      curve: KinMotion.enter,
                      child: IgnorePointer(
                        ignoring: !visible,
                        child: _FrostedWrap(
                          progress: progress,
                          isCircle: actions!.length == 1,
                          theme: theme,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: actions!,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: KinSpacing.sm),
              ]
            : null,
        flexibleSpace: _KinFlexibleSpace(title: title, theme: theme),
      ),
    );
  }
}

class _KinFlexibleSpace extends StatelessWidget {
  final String title;
  final KinTheme theme;

  const _KinFlexibleSpace({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
        final maxHeight = settings.maxExtent;
        final minHeight = settings.minExtent;
        final range = maxHeight - minHeight;
        final progress = range > 0
            ? ((maxHeight - constraints.maxHeight) / range).clamp(0.0, 1.0)
            : 0.0;
        final largeTitleOpacity = (1.0 - progress * 1.8).clamp(0.0, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            // ── Large title (expanded area) ──
            Positioned(
              left: KinSpacing.screen,
              right: KinSpacing.screen,
              bottom: KinSpacing.md,
              child: Opacity(
                opacity: largeTitleOpacity,
                child: Text(
                  title,
                  style: KinTypography.displayLarge.copyWith(
                    color: theme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────

/// Reads [FlexibleSpaceBarSettings] to derive a 0→1 collapse progress.
/// Returns 0.0 when no settings ancestor is found (e.g. outside SliverAppBar).
double _collapseProgress(BuildContext context) {
  final settings = context
      .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
  if (settings == null) return 0.0;
  final range = settings.maxExtent - settings.minExtent;
  if (range <= 0) return 0.0;
  return ((settings.maxExtent - settings.currentExtent) / range).clamp(
    0.0,
    1.0,
  );
}

/// Frosted-glass container that fades in as the bar collapses.
///
/// [isCircle] → circular shape (single icon / leading).
/// `!isCircle` → pill shape (multiple actions).
class _FrostedWrap extends StatelessWidget {
  final double progress;
  final bool isCircle;
  final KinTheme theme;
  final Widget child;

  const _FrostedWrap({
    required this.progress,
    required this.isCircle,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // No container while expanded.
    if (progress < 0.01) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = isCircle ? KinRadius.pill : KinRadius.pill;
    final borderRadius = BorderRadius.circular(radius);
    final sigma = isDark ? 10.0 * progress : 0.0;

    final bgColor = isDark
        ? theme.surfaceVariant.withValues(alpha: 0.55 * progress)
        : theme.surfaceVariant.withValues(alpha: 0.70 * progress);
    final borderColor = theme.outline.withValues(alpha: 0.5 * progress);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: AnimatedContainer(
          duration: KinMotion.fast,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: 0.5),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isCircle ? 0 : KinSpacing.xs,
          ),
          child: child,
        ),
      ),
    );
  }
}
