import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/kin_theme.dart';
import '../core/kin_typography.dart';

/// Size presets for [KinAvatar].
enum KinAvatarSize {
  xs(24),
  sm(32),
  md(40),
  lg(56),
  xl(72);

  final double diameter;
  const KinAvatarSize(this.diameter);
}

/// Online/offline status indicator.
enum KinAvatarStatus { none, online, offline, busy, away }

/// A themed avatar with image, initials fallback, status dot, and group stacking.
class KinAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final KinAvatarSize size;
  final KinAvatarStatus status;
  final Color? backgroundColor;
  final Widget? child;

  const KinAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = KinAvatarSize.md,
    this.status = KinAvatarStatus.none,
    this.backgroundColor,
    this.child,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Color _hashColor(String name) {
    final hash = name.codeUnits.fold(0, (h, c) => h + c);
    const palette = [
      Color(0xFF3478F6),
      Color(0xFF34C759),
      Color(0xFFFF9500),
      Color(0xFFFF3B30),
      Color(0xFF5856D6),
      Color(0xFFAF52DE),
      Color(0xFFFF2D55),
      Color(0xFF00C7BE),
    ];
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final d = size.diameter;
    final fontSize = d * 0.38;

    Widget avatar;

    if (child != null) {
      avatar = child!;
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = ClipOval(
        child: Image.network(
          imageUrl!,
          width: d,
          height: d,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitials(theme, d, fontSize),
        ),
      );
    } else {
      avatar = _buildInitials(theme, d, fontSize);
    }

    if (status == KinAvatarStatus.none) {
      return SizedBox(width: d, height: d, child: avatar);
    }

    final dotSize = math.max(d * 0.28, 10.0);
    final statusColor = switch (status) {
      KinAvatarStatus.online => const Color(0xFF34C759),
      KinAvatarStatus.busy => const Color(0xFFFF3B30),
      KinAvatarStatus.away => const Color(0xFFFF9500),
      KinAvatarStatus.offline => theme.onSurfaceVariant,
      KinAvatarStatus.none => Colors.transparent,
    };

    return SizedBox(
      width: d + 2,
      height: d + 2,
      child: Stack(
        children: [
          Positioned.fill(child: Center(child: avatar)),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(KinTheme theme, double d, double fontSize) {
    final bg = backgroundColor ?? (name != null ? _hashColor(name!) : theme.primaryContainer);
    final initials = name != null ? _initials(name!) : '?';

    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Stacked group of avatars with overlap.
class KinAvatarGroup extends StatelessWidget {
  final List<KinAvatar> avatars;
  final int maxVisible;
  final double overlap;
  final KinAvatarSize size;

  const KinAvatarGroup({
    super.key,
    required this.avatars,
    this.maxVisible = 4,
    this.overlap = 0.3,
    this.size = KinAvatarSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KinTheme.of(context);
    final visible = avatars.take(maxVisible).toList();
    final remaining = avatars.length - maxVisible;
    final d = size.diameter;
    final shift = d * (1 - overlap);

    return SizedBox(
      height: d + 4,
      width: (visible.length + (remaining > 0 ? 1 : 0)) * shift + d * overlap + 4,
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * shift,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.surface, width: 2),
                ),
                child: visible[i],
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: visible.length * shift,
              child: Container(
                width: d,
                height: d,
                decoration: BoxDecoration(
                  color: theme.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.surface, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: KinTypography.labelSmall.copyWith(
                      color: theme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
