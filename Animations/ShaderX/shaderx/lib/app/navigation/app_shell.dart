import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:kin_ui/kin_ui.dart';

import '../../core/layout/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/ui/kin_components.dart';
import '../../core/ui/app_dialog.dart';
import '../../core/ui/app_sheet_route.dart';
import '../../features/catalog/data/component_catalog.dart';
import '../../features/catalog/domain/shader_component.dart';
import '../../features/catalog/presentation/themes_screen.dart';
import '../../features/composition/presentation/workspace_screen.dart';
import '../../features/composition/presentation/widgets/composition_setup_sheet.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/settings/application/settings_controller.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../studio_session.dart';
import 'app_routes.dart';

class AppShell extends StatefulWidget {
  final StudioSession session;
  final SettingsController settings;
  const AppShell({super.key, required this.session, required this.settings});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController drawer;
  AppDestination destination = AppDestination.home;
  bool dragging = false, obscured = false;
  AppDestination studioReturn = AppDestination.home;
  @override
  void initState() {
    super.initState();
    drawer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    drawer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) widget.session.flushDraft();
  }

  void navigate(AppDestination next) {
    if (next == AppDestination.workspace &&
        destination != AppDestination.workspace) {
      studioReturn = destination == AppDestination.settings
          ? AppDestination.home
          : destination;
    }
    setState(() => destination = next);
    drawer.reverse();
  }

  void openDrawer() {
    MediaQuery.disableAnimationsOf(context)
        ? drawer.value = 1
        : drawer.forward();
  }

  Future<void> openComponent(ShaderComponent component) async {
    setState(() => obscured = true);
    await AppRoutes.component(
      context,
      session: widget.session,
      component: component,
      animate: widget.settings.animate,
      onAdded: () => navigate(AppDestination.workspace),
      onSettings: () => navigate(AppDestination.settings),
    );
    if (mounted) setState(() => obscured = false);
  }

  Future<void> addComponent() async {
    if (!widget.session.composition.canAdd) return;
    setState(() => obscured = true);
    final component = await Navigator.of(context).push<ShaderComponent>(
      AppSheetRoute(
        scrollableBuilder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
          children: [
            Text(
              'Add an ingredient',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 24),
            ...ComponentCatalog.components.map(
              (component) => ListTile(
                title: Text(component.name),
                subtitle: Text(
                  widget.session.catalog.theme(component.themeId).name,
                ),
                trailing: const Icon(HeroiconsOutline.plus, size: 20),
                onTap: () => Navigator.pop(context, component),
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (component != null) widget.session.composition.add(component);
    setState(() => obscured = false);
  }

  Future<void> fresh() async {
    drawer.reverse();
    setState(() => obscured = true);
    final details = await showCompositionSetup(context);
    if (!mounted) return;
    setState(() => obscured = false);
    if (details == null) return;
    if (widget.session.composition.recipe.layers.isNotEmpty) {
      final discard = await showAppDialog<bool>(
        context,
        Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start a new composition?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text(
                  'The current draft will be replaced. Saved compositions remain available.',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Keep working'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Start new'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      if (discard != true || !mounted) return;
    }
    widget.session.composition.newComposition(
      title: details.title,
      description: details.description,
      iconId: details.iconId,
      colorValue: details.colorValue,
      frameRate: details.frameRate,
    );
    navigate(AppDestination.themes);
  }

  Widget screen() => switch (destination) {
    AppDestination.home => HomeScreen(
      session: widget.session,
      onMenu: openDrawer,
      onSettings: () => navigate(AppDestination.settings),
      onWorkspace: () => navigate(AppDestination.workspace),
      onNew: fresh,
    ),
    AppDestination.themes => ThemesScreen(
      session: widget.session,
      onMenu: openDrawer,
      onSettings: () => navigate(AppDestination.settings),
      onOpen: openComponent,
    ),
    AppDestination.workspace => WorkspaceScreen(
      session: widget.session,
      onBack: () => navigate(studioReturn),
      onSettings: () => navigate(AppDestination.settings),
      onAdd: addComponent,
      animate: widget.settings.animate,
    ),
    AppDestination.settings => SettingsScreen(
      settings: widget.settings,
      onMenu: openDrawer,
      onSettings: () => navigate(AppDestination.settings),
    ),
  };
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([drawer, widget.session, widget.settings]),
    builder: (context, _) {
      final width = MediaQuery.sizeOf(context).width, t = drawer.value;
      final scheme = Theme.of(context).colorScheme;
      final drawerTheme = AppTheme.build(Brightness.dark);
      final darkStatusBar =
          t > .01 || Theme.of(context).brightness == Brightness.dark;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        key: const ValueKey('app-system-bars'),
        value:
            (darkStatusBar
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark)
                .copyWith(statusBarColor: Colors.transparent),
        child: PopScope(
          canPop: t == 0,
          onPopInvokedWithResult: (popped, result) {
            if (!popped) drawer.reverse();
          },
          child: Scaffold(
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (d) {
                dragging = drawer.value > .01 || d.localPosition.dx <= 28;
              },
              onHorizontalDragUpdate: (d) {
                if (dragging) {
                  drawer.value +=
                      (d.primaryDelta ?? 0) /
                      (width * Responsive.drawerRatio(width));
                }
              },
              onHorizontalDragEnd: (d) {
                if (!dragging) return;
                dragging = false;
                if ((d.primaryVelocity ?? 0) > 300) {
                  drawer.forward();
                } else if ((d.primaryVelocity ?? 0) < -300) {
                  drawer.reverse();
                } else {
                  drawer.value > .5 ? drawer.forward() : drawer.reverse();
                }
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(color: AppTokens.drawerBackground),
                  ),
                  Theme(
                    data: drawerTheme,
                    child: DefaultTextStyle(
                      style: drawerTheme.textTheme.bodyLarge!,
                      child: ExcludeSemantics(
                        excluding: t == 0,
                        child: IgnorePointer(
                          ignoring: t == 0,
                          child: Transform.translate(
                            offset: Offset(-60 * (1 - t), 0),
                            child: Opacity(
                              opacity: .4 + .6 * t,
                              child: SizedBox(
                                width: Responsive.drawerWidth(width),
                                child: SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      28,
                                      12,
                                      20,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              KinText(
                                                'ShaderX',
                                                style: drawerTheme
                                                    .textTheme
                                                    .headlineLarge,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        Expanded(
                                          child: ListView(
                                            children: [
                                              for (final entry in const [
                                                (
                                                  AppDestination.home,
                                                  'Compositions',
                                                  HeroiconsOutline
                                                      .rectangleStack,
                                                ),
                                                (
                                                  AppDestination.themes,
                                                  'Themes',
                                                  HeroiconsOutline.squares2x2,
                                                ),
                                                (
                                                  AppDestination.workspace,
                                                  'Studio',
                                                  HeroiconsOutline
                                                      .cubeTransparent,
                                                ),
                                              ])
                                                ListTile(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  selected:
                                                      destination == entry.$1,
                                                  selectedTileColor: drawerTheme
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: .12),
                                                  leading: Icon(
                                                    entry.$3,
                                                    size: 22,
                                                  ),
                                                  title: Text(entry.$2),
                                                  onTap: () =>
                                                      navigate(entry.$1),
                                                ),
                                              const Divider(height: 32),
                                              AppButton(
                                                label: 'New composition',
                                                onPressed: fresh,
                                                icon: HeroiconsOutline.plus,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.identity()
                      ..translateByDouble(
                        width * Responsive.drawerRatio(width) * t,
                        0,
                        0,
                        1,
                      )
                      ..scaleByDouble(
                        1 - (1 - Responsive.drawerScale(width)) * t,
                        1 - (1 - Responsive.drawerScale(width)) * t,
                        1,
                        1,
                      ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28 * t),
                      child: ColoredBox(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Stack(
                          children: [
                            TickerMode(
                              enabled: t == 0 && !obscured,
                              child: Column(
                                children: [
                                  if (widget.session.error != null)
                                    SafeArea(
                                      bottom: false,
                                      child: MaterialBanner(
                                        content: Text(widget.session.error!),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                widget.session.clearError,
                                            child: const Text('Dismiss'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Expanded(child: screen()),
                                ],
                              ),
                            ),
                            if (destination != AppDestination.workspace &&
                                destination != AppDestination.home &&
                                widget
                                    .session
                                    .composition
                                    .recipe
                                    .layers
                                    .isNotEmpty)
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 12,
                                child: SafeArea(
                                  top: false,
                                  child: KinCard(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    child: Row(
                                      children: [
                                        Icon(
                                          HeroiconsOutline.square3Stack3d,
                                          color: scheme.primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            widget
                                                .session
                                                .composition
                                                .recipe
                                                .name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        AppButton(
                                          label: 'Resume',
                                          onPressed: () => navigate(
                                            AppDestination.workspace,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (t > .01)
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () => drawer.reverse(),
                                  child: ColoredBox(
                                    color: Colors.black.withValues(
                                      alpha: .15 * t,
                                    ),
                                  ),
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
      );
    },
  );
}
