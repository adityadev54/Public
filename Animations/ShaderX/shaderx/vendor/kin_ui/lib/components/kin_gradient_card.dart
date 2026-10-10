import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A rich card with gradient background, center icon, category chip,
/// title, subtitle row with rating and favorite button.
///
/// Inspired by iOS travel/discovery card designs.
class KinGradientCard extends StatelessWidget {
  /// The main title displayed prominently at the bottom.
  final String title;

  /// Subtitle text (e.g. location).
  final String? subtitle;

  /// Category label shown in a chip.
  final String? category;

  /// Icon displayed inside the category chip.
  final IconData? categoryIcon;

  /// Large subtle icon displayed in the center of the card.
  final IconData? centerIcon;

  /// Rating value (e.g. 4.8).
  final double? rating;

  /// Review count text (e.g. '7.2k').
  final String? reviews;

  /// Gradient colors from top-left to bottom-right.
  final List<Color> gradient;

  /// Whether to show the favorite heart button.
  final bool showFavorite;

  /// Whether the card is in favorite state.
  final bool isFavorite;

  /// Called when the favorite button is tapped.
  final VoidCallback? onFavoriteTap;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Corner radius of the card.
  final double borderRadius;

  /// Use smaller text sizes for compact layouts.
  final bool compact;

  const KinGradientCard({
    super.key,
    required this.title,
    required this.gradient,
    this.subtitle,
    this.category,
    this.categoryIcon,
    this.centerIcon,
    this.rating,
    this.reviews,
    this.showFavorite = true,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onTap,
    this.borderRadius = 28,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
          child: Stack(
            children: [
              if (centerIcon != null)
                Center(
                  child: Icon(
                    centerIcon,
                    size: compact ? 48 : 64,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (categoryIcon != null) ...[
                              Icon(categoryIcon,
                                  size: 12, color: Colors.white),
                              const SizedBox(width: 5),
                            ],
                            Text(
                              category!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: compact ? 6 : 10),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 24 : 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    if (subtitle != null || rating != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (subtitle != null) ...[
                            Icon(CupertinoIcons.info_circle_fill,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.8)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                subtitle!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ] else
                            const Spacer(),
                          if (rating != null) ...[
                            const Icon(CupertinoIcons.star_fill,
                                size: 14, color: Color(0xFFFFB800)),
                            const SizedBox(width: 3),
                            Text(
                              '$rating',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (reviews != null) ...[
                              const SizedBox(width: 2),
                              Text(
                                '($reviews)',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                          if (showFavorite) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: onFavoriteTap,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFavorite
                                      ? CupertinoIcons.heart_fill
                                      : CupertinoIcons.heart,
                                  size: 16,
                                  color: isFavorite
                                      ? const Color(0xFFFF3B5C)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
