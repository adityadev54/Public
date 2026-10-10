import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kin_press.dart';
import 'kin_text.dart';
import '../core/kin_theme.dart';
import '../core/kin_motion.dart';
import '../core/kin_radius.dart';
import '../core/kin_spacing.dart';
import '../core/kin_typography.dart';

/// Layout orientation for [KinStepper].
enum KinStepperOrientation { horizontal, vertical }

/// Visual style variants for [KinStepper].
enum KinStepperVariant {
  /// Numbered circles with connecting line.
  numbered,

  /// Dots expanding on active step.
  dot,

  /// Progress bar style with labeled steps.
  progress,
}

/// State of an individual step.
enum KinStepState { completed, active, upcoming }

/// A single step definition.
class KinStep {
  final String title;
  final String? subtitle;
  final Widget? icon;

  const KinStep({
    required this.title,
    this.subtitle,
    this.icon,
  });
}

/// Themed stepper with multiple layout and style variants.
class KinStepper extends StatelessWidget {
  final List<KinStep> steps;
  final int currentStep;
  final KinStepperOrientation orientation;
  final KinStepperVariant variant;
  final ValueChanged<int>? onStepTapped;
  final bool enableTap;

  const KinStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.orientation = KinStepperOrientation.horizontal,
    this.variant = KinStepperVariant.numbered,
    this.onStepTapped,
    this.enableTap = true,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    return switch (orientation) {
      KinStepperOrientation.horizontal => _HorizontalStepper(
          steps: steps,
          currentStep: currentStep.clamp(0, steps.length - 1),
          variant: variant,
          onStepTapped: enableTap ? onStepTapped : null,
        ),
      KinStepperOrientation.vertical => _VerticalStepper(
          steps: steps,
          currentStep: currentStep.clamp(0, steps.length - 1),
          variant: variant,
          onStepTapped: enableTap ? onStepTapped : null,
        ),
    };
  }
}

// ── Horizontal stepper ──────────────────────────────────────────

class _HorizontalStepper extends StatelessWidget {
  final List<KinStep> steps;
  final int currentStep;
  final KinStepperVariant variant;
  final ValueChanged<int>? onStepTapped;

  const _HorizontalStepper({
    required this.steps,
    required this.currentStep,
    required this.variant,
    this.onStepTapped,
  });

  KinStepState _stateFor(int index) {
    if (index < currentStep) return KinStepState.completed;
    if (index == currentStep) return KinStepState.active;
    return KinStepState.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    if (variant == KinStepperVariant.progress) {
      return _ProgressBar(
        steps: steps,
        currentStep: currentStep,
        theme: theme,
      );
    }

    return Row(
      children: List.generate(steps.length, (index) {
        final state = _stateFor(index);
        final step = steps[index];
        final isFirst = index == 0;
        final isLast = index == steps.length - 1;

        final leftDone = index > 0 && _stateFor(index - 1) == KinStepState.completed;
        final rightDone = state == KinStepState.completed;

        return Expanded(
          child: GestureDetector(
            onTap: onStepTapped != null ? () {
              HapticFeedback.selectionClick();
              onStepTapped!(index);
            } : null,
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: isFirst
                          ? const SizedBox.shrink()
                          : AnimatedContainer(
                              duration: KinMotion.fast,
                              height: 2,
                              color: leftDone ? theme.primary : theme.outline,
                            ),
                    ),
                    _buildCircle(index, step, state, theme),
                    Expanded(
                      child: isLast
                          ? const SizedBox.shrink()
                          : AnimatedContainer(
                              duration: KinMotion.fast,
                              height: 2,
                              color: rightDone ? theme.primary : theme.outline,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: KinSpacing.xs),
                KinText(
                  step.title,
                  style: KinTypography.labelSmall,
                  color: state == KinStepState.upcoming
                      ? theme.onSurfaceVariant
                      : theme.onSurface,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCircle(int index, KinStep step, KinStepState state, KinTheme theme) {
    return switch (variant) {
      KinStepperVariant.numbered => _buildNumberedCircle(index, step, state, theme),
      KinStepperVariant.dot => _buildDot(state, theme),
      KinStepperVariant.progress => const SizedBox.shrink(),
    };
  }

  Widget _buildNumberedCircle(int index, KinStep step, KinStepState state, KinTheme theme) {
    final (Color bg, Color fg, BoxBorder? border) = switch (state) {
      KinStepState.completed => (theme.primary, const Color(0xFFFFFFFF), null),
      KinStepState.active => (theme.primaryContainer, theme.primary, Border.all(color: theme.primary, width: 1.5)),
      KinStepState.upcoming => (Colors.transparent, theme.onSurfaceVariant, Border.all(color: theme.outline, width: 1)),
    };

    final child = state == KinStepState.completed
        ? Icon(Icons.check, size: 14, color: fg)
        : (step.icon ?? KinText('${index + 1}', style: KinTypography.labelSmall, color: fg));

    return AnimatedContainer(
      duration: KinMotion.fast,
      curve: KinMotion.enter,
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: border),
      child: Center(child: child),
    );
  }

  Widget _buildDot(KinStepState state, KinTheme theme) {
    final double size = switch (state) {
      KinStepState.completed => 10,
      KinStepState.active => 14,
      KinStepState.upcoming => 8,
    };
    final Color color = switch (state) {
      KinStepState.completed => theme.primary,
      KinStepState.active => theme.primary,
      KinStepState.upcoming => theme.outline,
    };
    return AnimatedContainer(
      duration: KinMotion.fast,
      curve: KinMotion.enter,
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── Vertical stepper ────────────────────────────────────────────

class _VerticalStepper extends StatelessWidget {
  final List<KinStep> steps;
  final int currentStep;
  final KinStepperVariant variant;
  final ValueChanged<int>? onStepTapped;

  const _VerticalStepper({
    required this.steps,
    required this.currentStep,
    required this.variant,
    this.onStepTapped,
  });

  KinStepState _stateFor(int index) {
    if (index < currentStep) return KinStepState.completed;
    if (index == currentStep) return KinStepState.active;
    return KinStepState.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(steps.length, (index) {
        final state = _stateFor(index);
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Node + connector column
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    if (variant == KinStepperVariant.dot)
                      _DotNode(
                        step: step,
                        state: state,
                        onTap: onStepTapped != null ? () => onStepTapped!(index) : null,
                      )
                    else
                      _NumberedNode(
                        index: index,
                        step: step,
                        state: state,
                        onTap: onStepTapped != null ? () => onStepTapped!(index) : null,
                      ),
                    if (!isLast)
                      Expanded(
                        child: AnimatedContainer(
                          duration: KinMotion.fast,
                          width: 2,
                          color: state == KinStepState.completed
                              ? theme.primary
                              : theme.outline,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: KinSpacing.sm),
              // Label column
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : KinSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KinText(
                        step.title,
                        style: KinTypography.bodyMedium.copyWith(
                          fontWeight: state == KinStepState.active ? FontWeight.w600 : FontWeight.w400,
                        ),
                        color: state == KinStepState.upcoming
                            ? theme.onSurfaceVariant
                            : theme.onSurface,
                      ),
                      if (step.subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: KinText(
                            step.subtitle!,
                            style: KinTypography.labelSmall,
                            color: theme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Shared nodes ────────────────────────────────────────────────

class _NumberedNode extends StatelessWidget {
  final int index;
  final KinStep step;
  final KinStepState state;
  final VoidCallback? onTap;

  const _NumberedNode({
    required this.index,
    required this.step,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    final (Color bg, Color fg, BoxBorder? border) = switch (state) {
      KinStepState.completed => (theme.primary, const Color(0xFFFFFFFF), null),
      KinStepState.active => (theme.primaryContainer, theme.primary, Border.all(color: theme.primary, width: 1.5)),
      KinStepState.upcoming => (Colors.transparent, theme.onSurfaceVariant, Border.all(color: theme.outline, width: 1)),
    };

    final child = state == KinStepState.completed
        ? Icon(Icons.check, size: 14, color: fg)
        : (step.icon ??
            KinText(
              '${index + 1}',
              style: KinTypography.labelSmall,
              color: fg,
            ));

    return KinPress(
      onTap: onTap,
      enabled: onTap != null,
      child: AnimatedContainer(
        duration: KinMotion.fast,
        curve: KinMotion.enter,
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _DotNode extends StatelessWidget {
  final KinStep step;
  final KinStepState state;
  final VoidCallback? onTap;

  const _DotNode({
    required this.step,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);

    final double size = switch (state) {
      KinStepState.completed => 10,
      KinStepState.active => 14,
      KinStepState.upcoming => 8,
    };

    final Color color = switch (state) {
      KinStepState.completed => theme.primary,
      KinStepState.active => theme.primary,
      KinStepState.upcoming => theme.outline,
    };

    return KinPress(
      onTap: onTap,
      enabled: onTap != null,
      child: AnimatedContainer(
        duration: KinMotion.fast,
        curve: KinMotion.enter,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Progress bar variant ────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final List<KinStep> steps;
  final int currentStep;
  final KinTheme theme;

  const _ProgressBar({
    required this.steps,
    required this.currentStep,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final progress = steps.isNotEmpty ? (currentStep + 1) / steps.length : 0.0;
    final label = steps.isNotEmpty ? steps[currentStep.clamp(0, steps.length - 1)].title : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: KinSpacing.xs,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            KinText(
              label,
              style: KinTypography.labelLarge,
              color: theme.onSurface,
            ),
            KinText(
              '${currentStep + 1}/${steps.length}',
              style: KinTypography.labelSmall,
              color: theme.onSurfaceVariant,
            ),
          ],
        ),
        ClipRRect(
          borderRadius: KinRadius.pillAll,
          child: AnimatedContainer(
            duration: KinMotion.normal,
            curve: KinMotion.enter,
            height: 6,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        color: theme.outline,
                        borderRadius: KinRadius.pillAll,
                      ),
                    ),
                    AnimatedContainer(
                      duration: KinMotion.normal,
                      curve: KinMotion.enter,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius: KinRadius.pillAll,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
