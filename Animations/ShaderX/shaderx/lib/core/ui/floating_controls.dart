import 'package:flutter/material.dart';
import 'package:kin_ui/kin_ui.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

/// Only root vertical scrolling influences the header; bounce is ignored.
class FloatingVisibility {
  double progress = 0;
  bool get visible => progress > .8;
  bool update(ScrollNotification notification) {
    if (notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical ||
        notification.metrics.outOfRange) {
      return visible;
    }
    progress = (notification.metrics.pixels / 100).clamp(0, 1);
    return visible;
  }
}

class StatusFade extends StatelessWidget {
  const StatusFade({super.key});
  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: SizedBox(
          height: MediaQuery.paddingOf(context).top + 136,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, .28, .64, 1],
                colors: [
                  background,
                  background.withValues(alpha: .94),
                  background.withValues(alpha: .60),
                  background.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FloatingControls extends StatelessWidget {
  final Key? trailingKey;
  final IconData trailingIcon;
  final String trailingTooltip;
  final double progress;
  final VoidCallback onMenu;
  final VoidCallback? onSettings;
  final String tooltip;
  final IconData icon;
  const FloatingControls({
    super.key,
    required this.progress,
    required this.onMenu,
    this.onSettings,
    this.trailingKey,
    this.trailingIcon = HeroiconsOutline.cog6Tooth,
    this.trailingTooltip = 'Open settings',
    this.tooltip = 'Open navigation',
    this.icon = HeroiconsOutline.bars3,
  });
  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);
    const diameter = 48.0;
    final scheme = Theme.of(context).colorScheme;
    Widget control(
      IconData glyph,
      VoidCallback action,
      String hint,
      String key,
    ) => AnimatedContainer(
      key: key == 'settings-circle' && trailingKey != null
          ? trailingKey
          : ValueKey(key),
      duration: duration,
      curve: Curves.easeOutCubic,
      width: diameter,
      height: diameter,
      child: KinMaterialSurface(
        material: const KinMaterial.glass(),
        border: const Border(),
        backgroundColor: scheme.surface,
        borderRadius: BorderRadius.circular(diameter / 2),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: IconButton(
            tooltip: hint,
            onPressed: action,
            icon: Icon(glyph, size: 22),
          ),
        ),
      ),
    );
    return Positioned(
      top: 0,
      left: 16,
      right: 16,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              control(icon, onMenu, tooltip, 'menu-circle'),
              const Spacer(),
              if (onSettings != null)
                control(
                  trailingIcon,
                  onSettings!,
                  trailingTooltip,
                  'settings-circle',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PageFrame extends StatefulWidget {
  final String title;
  final Widget child;
  final VoidCallback onMenu;
  final VoidCallback? onSettings;
  final bool immersive;
  final double topSpacing;
  final IconData leadingIcon;
  final String leadingTooltip;
  const PageFrame({
    super.key,
    required this.title,
    required this.child,
    required this.onMenu,
    this.onSettings,
    this.immersive = false,
    this.topSpacing = 88,
    this.leadingIcon = HeroiconsOutline.bars3,
    this.leadingTooltip = 'Open navigation',
  });
  @override
  State<PageFrame> createState() => _PageFrameState();
}

class _PageFrameState extends State<PageFrame> {
  final visibility = FloatingVisibility();
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final old = visibility.progress;
          visibility.update(notification);
          if ((old - visibility.progress).abs() > .005) setState(() {});
          return false;
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            if (!widget.immersive)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.paddingOf(context).top + widget.topSpacing,
                ),
              ),
            SliverToBoxAdapter(child: widget.child),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.paddingOf(context).bottom + 100,
              ),
            ),
          ],
        ),
      ),
      const StatusFade(),
      FloatingControls(
        progress: visibility.progress,
        onMenu: widget.onMenu,
        onSettings: widget.onSettings,
        icon: widget.leadingIcon,
        tooltip: widget.leadingTooltip,
      ),
    ],
  );
}
