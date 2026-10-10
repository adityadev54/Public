import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/kin_bottombar.dart';
import '../core/kin_layout.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_spacing.dart';
import 'kin_nav_rail.dart';
import 'kin_nav_drawer.dart';

// ── Scroll-hide scope ────────────────────────────────────────────
/// Provides a [visible] flag that descendants (e.g. [KinTopBar]) can
/// read to hide/show chrome that should disappear while scrolling.
class KinScrollHideScope extends InheritedWidget {
  final bool visible;

  const KinScrollHideScope({
    super.key,
    required this.visible,
    required super.child,
  });

  /// Returns `true` (visible) when no scope is found in the tree.
  static bool of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<KinScrollHideScope>()
            ?.visible ??
        true;
  }

  @override
  bool updateShouldNotify(KinScrollHideScope old) => visible != old.visible;
}

// ── Scaffold ─────────────────────────────────────────────────────
/// Adaptive scaffold that switches between bottom bar, nav rail,
/// and nav drawer based on the current [KinLayout] breakpoint.
class KinScaffold extends StatefulWidget {
  final List<KinNavItem> navItems;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final Widget body;
  final String? drawerHeader;

  /// Optional pill-shaped search bar rendered above the bottom bar.
  final Widget? searchBar;

  const KinScaffold({
    super.key,
    required this.navItems,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.body,
    this.drawerHeader,
    this.searchBar,
  });

  @override
  State<KinScaffold> createState() => _KinScaffoldState();
}

class _KinScaffoldState extends State<KinScaffold> {
  bool _barsVisible = true;
  Timer? _scrollEndTimer;

  // ── scroll listener ──
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification &&
        notification.metrics.pixels > 0) {
      if (_barsVisible) setState(() => _barsVisible = false);
      _scrollEndTimer?.cancel();
      _scrollEndTimer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _barsVisible = true);
      });
    }
    return false;
  }

  @override
  void dispose() {
    _scrollEndTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = KinLayout.of(context);
    final theme = KinTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final safeBottom = mediaQuery.padding.bottom;

    final overlayStyle = isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          );

    // ── Compact (phone) ──
    if (layout.isCompact) {
      final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
      final isLandscape =
          MediaQuery.orientationOf(context) == Orientation.landscape;
      final compactBottomInset = math.max(
        KinSpacing.screen,
        safeBottom + (isLandscape ? KinSpacing.xs : KinSpacing.sm),
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: theme.surface,
          body: SafeArea(
            top: false,
            bottom: false,
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: KinScrollHideScope(
                visible: _barsVisible,
                child: Stack(
                  children: [
                    widget.body,

                    if (!keyboardOpen)
                      // ── Top fade ──
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: isLandscape ? 28 : (isDark ? 60 : 40),
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  theme.surface.withValues(
                                    alpha: isDark ? 1.0 : 0.6,
                                  ),
                                  theme.surface.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ── Bottom fade ──
                    if (!keyboardOpen)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: isLandscape ? 72 : (isDark ? 120 : 80),
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  theme.surface.withValues(
                                    alpha: isDark ? 1.0 : 0.72,
                                  ),
                                  theme.surface.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ── Floating bottom area (search bar + bottom bar) ──
                    if (!keyboardOpen || widget.searchBar != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: compactBottomInset,
                        child: IgnorePointer(
                          ignoring: !_barsVisible && !keyboardOpen,
                          child: AnimatedSlide(
                            offset: (!keyboardOpen && !_barsVisible)
                                ? const Offset(0, 2)
                                : Offset.zero,
                            duration: KinMotion.normal,
                            curve: _barsVisible
                                ? KinMotion.enter
                                : KinMotion.exit,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.searchBar != null)
                                  Padding(
                                    padding: layout.margins,
                                    child: widget.searchBar!,
                                  ),
                                if (widget.searchBar != null && !keyboardOpen)
                                  const SizedBox(height: KinSpacing.sm),
                                if (!keyboardOpen)
                                  Padding(
                                    padding: layout.margins,
                                    child: KinBottomBar(
                                      currentIndex: widget.currentIndex,
                                      initialIndex: widget.currentIndex,
                                      onTabChanged: widget.onIndexChanged,
                                      height: isLandscape ? 56 : 62,
                                      items: widget.navItems
                                          .map(
                                            (item) => Icon(item.icon, size: 22),
                                          )
                                          .toList(),
                                      labels: widget.navItems
                                          .map((item) => item.label)
                                          .toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ── Medium (tablet) ──
    if (layout.isMedium) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Scaffold(
          backgroundColor: theme.surface,
          body: SafeArea(
            top: false,
            bottom: false,
            child: Row(
              children: [
                KinNavRail(
                  items: widget.navItems,
                  currentIndex: widget.currentIndex,
                  onTap: widget.onIndexChanged,
                ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScrollNotification,
                    child: KinScrollHideScope(
                      visible: _barsVisible,
                      child: widget.body,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Expanded (desktop) ──
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: theme.surface,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            children: [
              KinNavDrawer(
                items: widget.navItems,
                currentIndex: widget.currentIndex,
                onTap: widget.onIndexChanged,
                header: widget.drawerHeader,
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScrollNotification,
                  child: KinScrollHideScope(
                    visible: _barsVisible,
                    child: widget.body,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
