//
//  DEPRECTAED COMPONENT -- SOON TO BE DELETED
//



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../core/kin_theme.dart';
// import '../core/kin_motion.dart';
// import '../core/kin_radius.dart';
// import '../core/kin_spacing.dart';
// import '../core/kin_typography.dart';
// import 'kin_text.dart';

// /// A single action in [KinActionSheet].
// class KinSheetAction {
//   final String label;
//   final IconData? icon;
//   final VoidCallback onTap;
//   final bool isDestructive;
//   final bool isDefault;

//   const KinSheetAction({
//     required this.label,
//     this.icon,
//     required this.onTap,
//     this.isDestructive = false,
//     this.isDefault = false,
//   });
// }

// /// iOS-style action sheet that slides up from the bottom.
// class KinActionSheet {
//   KinActionSheet._();

//   static Future<void> show(
//     BuildContext context, {
//     String? title,
//     String? message,
//     required List<KinSheetAction> actions,
//     String cancelLabel = 'Cancel',
//   }) {
//     return showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: 'Dismiss',
//       barrierColor: Colors.black.withValues(alpha: 0.4),
//       transitionDuration: const Duration(milliseconds: 400),
//       transitionBuilder: (_, animation, __, child) {
//         final curved = CurvedAnimation(
//           parent: animation,
//           curve: Curves.easeOutBack,
//           reverseCurve: Curves.easeInCubic,
//         );
//         return SlideTransition(
//           position: Tween<Offset>(
//             begin: const Offset(0, 0.6),
//             end: Offset.zero,
//           ).animate(curved),
//           child: FadeTransition(
//             opacity: CurvedAnimation(
//               parent: animation,
//               curve: const Interval(0.0, 0.6),
//             ),
//             child: child,
//           ),
//         );
//       },
//       pageBuilder: (ctx, _, __) {
//         return _KinActionSheetLayout(
//           title: title,
//           message: message,
//           actions: actions,
//           cancelLabel: cancelLabel,
//         );
//       },
//     );
//   }
// }

// class _KinActionSheetLayout extends StatelessWidget {
//   final String? title;
//   final String? message;
//   final List<KinSheetAction> actions;
//   final String cancelLabel;

//   const _KinActionSheetLayout({
//     this.title,
//     this.message,
//     required this.actions,
//     required this.cancelLabel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = KinTheme.of(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final safePadding = MediaQuery.paddingOf(context);

//     final bgColor = isDark
//         ? theme.surfaceVariant
//         : theme.surfaceVariant;

//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Padding(
//         padding: EdgeInsets.only(
//           left: KinSpacing.sm,
//           right: KinSpacing.sm,
//           bottom: safePadding.bottom + KinSpacing.sm,
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Actions group
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: bgColor,
//                   borderRadius: KinRadius.xlAll,
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Header
//                     if (title != null || message != null)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: KinSpacing.md,
//                           vertical: KinSpacing.sm + 4,
//                         ),
//                         child: Column(
//                           children: [
//                             if (title != null)
//                               KinText(
//                                 title!,
//                                 style: KinTypography.footnote.copyWith(
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                                 color: theme.onSurfaceVariant,
//                                 textAlign: TextAlign.center,
//                               ),
//                             if (message != null) ...[
//                               const SizedBox(height: 4),
//                               KinText(
//                                 message!,
//                                 style: KinTypography.captionLarge,
//                                 color: theme.onSurfaceVariant,
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     if (title != null || message != null)
//                       Divider(
//                         height: 0.5,
//                         thickness: 0.5,
//                         color: theme.outline.withValues(alpha: 0.2),
//                       ),
//                     // Action buttons
//                     for (int i = 0; i < actions.length; i++) ...[
//                       if (i > 0)
//                         Divider(
//                           height: 0.5,
//                           thickness: 0.5,
//                           color: theme.outline.withValues(alpha: 0.2),
//                         ),
//                       _ActionRow(
//                         action: actions[i],
//                         theme: theme,
//                         onTap: () {
//                           Navigator.of(context).pop();
//                           actions[i].onTap();
//                         },
//                       ),
//                     ],
//                   ],
//                 ),
//               ),

//               const SizedBox(height: KinSpacing.sm),

//               // Cancel button
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: bgColor,
//                   borderRadius: KinRadius.xlAll,
//                 ),
//                 child: _ActionRow(
//                   action: KinSheetAction(
//                     label: cancelLabel,
//                     onTap: () {},
//                     isDefault: true,
//                   ),
//                   theme: theme,
//                   onTap: () => Navigator.of(context).pop(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ActionRow extends StatefulWidget {
//   final KinSheetAction action;
//   final KinTheme theme;
//   final VoidCallback onTap;

//   const _ActionRow({
//     required this.action,
//     required this.theme,
//     required this.onTap,
//   });

//   @override
//   State<_ActionRow> createState() => _ActionRowState();
// }

// class _ActionRowState extends State<_ActionRow> {
//   bool _pressed = false;

//   @override
//   Widget build(BuildContext context) {
//     final color = widget.action.isDestructive
//         ? widget.theme.destructive
//         : widget.theme.primary;
//     final fontWeight = widget.action.isDefault ? FontWeight.w600 : FontWeight.w400;

//     return GestureDetector(
//       onTapDown: (_) => setState(() => _pressed = true),
//       onTapUp: (_) {
//         setState(() => _pressed = false);
//         HapticFeedback.selectionClick();
//         Future.delayed(const Duration(milliseconds: 80), widget.onTap);
//       },
//       onTapCancel: () => setState(() => _pressed = false),
//       behavior: HitTestBehavior.opaque,
//       child: AnimatedContainer(
//         duration: KinMotion.fast,
//         color: _pressed
//             ? widget.theme.onSurface.withValues(alpha: 0.06)
//             : Colors.transparent,
//         padding: const EdgeInsets.symmetric(vertical: KinSpacing.md - 2),
//         child: Center(
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (widget.action.icon != null) ...[
//                 Icon(widget.action.icon, size: 20, color: color),
//                 const SizedBox(width: KinSpacing.sm),
//               ],
//               Text(
//                 widget.action.label,
//                 style: KinTypography.bodyLarge.copyWith(
//                   color: color,
//                   fontWeight: fontWeight,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
