import 'package:flutter/material.dart';
import 'package:kin_ui/kin_ui.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import '../../../../core/ui/app_sheet_route.dart';
import '../../domain/composition.dart';
import 'composition_identity.dart';

typedef CompositionDetails = ({
  String title,
  String description,
  String iconId,
  int colorValue,
  int frameRate,
});

Future<CompositionDetails?> showCompositionSetup(BuildContext context) =>
    Navigator.of(context).push<CompositionDetails>(
      AppSheetRoute(
        scrollableBuilder: (context, controller) =>
            _CompositionDetailsForm(scrollController: controller),
      ),
    );

class _CompositionDetailsForm extends StatefulWidget {
  final ScrollController scrollController;
  const _CompositionDetailsForm({required this.scrollController});
  @override
  State<_CompositionDetailsForm> createState() =>
      _CompositionDetailsFormState();
}

class _CompositionDetailsFormState extends State<_CompositionDetailsForm> {
  final title = TextEditingController();
  final description = TextEditingController();
  String iconId = 'layers';
  int colorValue = 0xFFAAB85A, frameRate = 30;
  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  void create() => Navigator.pop(context, (
    title: title.text.trim(),
    description: description.text.trim(),
    iconId: iconId,
    colorValue: colorValue,
    frameRate: frameRate,
  ));
  Widget circle(
    String label,
    IconData icon,
    VoidCallback? onTap, {
    Color? fill,
    Color? foreground,
  }) => Tooltip(
    message: label,
    child: Semantics(
      label: label,
      button: true,
      enabled: onTap != null,
      child: KinPress(
        enabled: onTap != null,
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill ?? Theme.of(context).colorScheme.surface,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 22,
            color: foreground ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    ),
  );

  Widget group(Widget child) => KinCard(
    borderRadius: BorderRadius.circular(26),
    padding: const EdgeInsets.all(20),
    child: child,
  );

  Widget section(String label, Widget child) => Padding(
    padding: const EdgeInsets.only(top: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        child,
      ],
    ),
  );

  Widget choices(List<Widget> children) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 288 ? 6 : 3;
      return Wrap(
        runSpacing: 12,
        children: [
          for (final child in children)
            SizedBox(
              width: constraints.maxWidth / columns,
              child: Center(child: child),
            ),
        ],
      );
    },
  );

  InputDecoration field(String label) => InputDecoration(
    hintText: label,
    filled: false,
    counterText: '',
    contentPadding: const EdgeInsets.symmetric(vertical: 10),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(colorValue);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                children: [
                  circle(
                    'Close setup',
                    HeroiconsOutline.xMark,
                    () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  circle(
                    'Create composition',
                    HeroiconsOutline.check,
                    title.text.trim().isEmpty ? null : create,
                    fill: theme.colorScheme.primary.withValues(alpha: .12),
                    foreground: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: widget.scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Text(
                      'New composition',
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  group(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 132,
                          child: Stack(
                            children: [
                              Positioned(
                                right: -8,
                                top: -16,
                                bottom: -12,
                                child: Image.asset(
                                  'assets/illustrations/new-composition.png',
                                  width: 170,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 64,
                                  height: 64,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: .18),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Icon(
                                    CompositionIdentity.icon(iconId),
                                    size: 28,
                                    color: theme.brightness == Brightness.dark
                                        ? color
                                        : Color.lerp(color, Colors.black, .35),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        KinTextField(
                          controller: title,
                          maxLength: 64,
                          style: theme.textTheme.headlineMedium,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          decoration: field('Composition name'),
                          onChanged: (_) => setState(() {}),
                        ),
                        KinTextField(
                          controller: description,
                          minLines: 1,
                          maxLines: 3,
                          maxLength: 280,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          decoration: field('Description'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  section(
                    'Icon',
                    choices([
                      for (final entry in CompositionIdentity.icons.entries)
                        Semantics(
                          selected: iconId == entry.key,
                          child: circle(
                            entry.value.$1,
                            entry.value.$2,
                            () => setState(() => iconId = entry.key),
                            fill: iconId == entry.key
                                ? color.withValues(alpha: .18)
                                : Colors.transparent,
                            foreground: iconId == entry.key
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ]),
                  ),
                  section(
                    'Color',
                    choices([
                      for (final choice in CompositionIdentity.colors)
                        Semantics(
                          selected: colorValue == choice.$2,
                          child: Tooltip(
                            message: choice.$1,
                            child: KinPress(
                              onTap: () =>
                                  setState(() => colorValue = choice.$2),
                              buttonSemantics: true,
                              child: Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: colorValue == choice.$2
                                      ? Border.all(
                                          color: Color(
                                            choice.$2,
                                          ).withValues(alpha: .5),
                                        )
                                      : null,
                                ),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Color(choice.$2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: colorValue == choice.$2
                                      ? Icon(
                                          HeroiconsOutline.check,
                                          size: 18,
                                          color: CompositionIdentity.foreground(
                                            Color(choice.$2),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ]),
                  ),
                  section(
                    'Frame rate',
                    Row(
                      children: [
                        for (final fps in Composition.frameRates)
                          Expanded(
                            child: Semantics(
                              selected: frameRate == fps,
                              button: true,
                              child: KinPress(
                                onTap: () => setState(() => frameRate = fps),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: frameRate == fps
                                        ? theme.colorScheme.primary.withValues(
                                            alpha: .10,
                                          )
                                        : Colors.transparent,
                                  ),
                                  child: Text(
                                    '$fps fps',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: frameRate == fps
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: frameRate == fps
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
