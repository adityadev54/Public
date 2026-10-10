import 'package:flutter/material.dart';
import '../components/kin_card.dart';
import '../core/kin_layout.dart';
import '../navigation/kin_top_bar.dart';
import '../core/kin_spacing.dart';

/// A section header + grouped list items, matching the Samsung One UI
/// Settings screen pattern.
class KinSettingsSection {
  /// Optional header text displayed above the section.
  final String? header;

  /// The list-tile children in this section.
  final List<Widget> children;

  const KinSettingsSection({
    this.header,
    required this.children,
  });
}

/// A settings-style template with grouped list sections inside cards.
///
/// Each [KinSettingsSection] is rendered as a [KinCard] with optional
/// section header text above it.
class KinSettingsTemplate extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  /// Ordered list of grouped sections.
  final List<KinSettingsSection> sections;

  /// Optional widget placed above the first section (e.g. profile card).
  final Widget? header;

  /// Optional footer widget below all sections.
  final Widget? footer;

  const KinSettingsTemplate({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    required this.sections,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final layout = KinLayout.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        KinTopBar(
          title: title,
          actions: actions,
          leading: leading,
        ),
        SliverPadding(
          padding: layout.margins,
          sliver: SliverList.list(
            children: [
              const SizedBox(height: KinSpacing.md),
              if (header != null) ...[
                header!,
                const SizedBox(height: KinSpacing.lg),
              ],
              for (final section in sections) ...[
                if (section.header != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: KinSpacing.xs,
                      bottom: KinSpacing.sm,
                    ),
                    child: Text(
                      section.header!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                KinCard(
                  padding: EdgeInsets.zero,
                  child: Column(children: section.children),
                ),
                const SizedBox(height: KinSpacing.lg),
              ],
              if (footer != null) ...[
                footer!,
                const SizedBox(height: KinSpacing.lg),
              ],
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }
}
