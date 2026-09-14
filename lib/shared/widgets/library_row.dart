import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// The right-hand column of a [LibraryRow].
///
/// Source of truth: `docs/SCREENS.md` B4 (My List rows) and D3 (filmography
/// rows).
sealed class LibraryRowTrailing {
  const LibraryRowTrailing();

  /// A relative date, e.g. "Saved yesterday" (Favorites, Watch later).
  const factory LibraryRowTrailing.date(String date) = _DateTrailing;

  /// 1–5 stars, e.g. the Watched tab. `rating == 0` renders as unrated:
  /// all five stars in gray.
  const factory LibraryRowTrailing.stars(int rating) = _StarsTrailing;

  /// A plain chevron, e.g. a filmography row that just pushes a detail.
  const factory LibraryRowTrailing.chevron() = _ChevronTrailing;
}

class _DateTrailing extends LibraryRowTrailing {
  const _DateTrailing(this.date);
  final String date;
}

class _StarsTrailing extends LibraryRowTrailing {
  const _StarsTrailing(this.rating);
  final int rating;
}

class _ChevronTrailing extends LibraryRowTrailing {
  const _ChevronTrailing();
}

/// A library row: a 56×84 poster, title, a gray metadata line, and a
/// configurable trailing column.
///
/// Source of truth: `docs/SCREENS.md` B4 ("Rows: 56×84 poster, 16/500
/// title, gray 13 px line... Swipe left → 'Remove' (red)... swipe right →
/// 'Watched' (amber)... Long-press → H1.").
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter. Swipe reveals a colored background via the framework's own
/// `Dismissible` (no extra package needed) but never actually removes the
/// row — [onSwipeLeft] / [onSwipeRight] decide what that means; the row
/// itself doesn't know whether the swipe means "remove", "watched", or
/// something else.
class LibraryRow extends StatelessWidget {
  const LibraryRow({
    super.key,
    required this.posterUrl,
    required this.title,
    required this.metadata,
    required this.trailing,
    this.onTap,
    this.onLongPress,
    this.onSwipeLeft,
    this.onSwipeRight,
  });

  final String? posterUrl;
  final String title;
  final String metadata;
  final LibraryRowTrailing trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Fires on a left swipe (e.g. "Remove"). Renders a `danger` reveal.
  final VoidCallback? onSwipeLeft;

  /// Fires on a right swipe (e.g. "Watched"/"Favorite"). Renders an
  /// `accent` reveal.
  final VoidCallback? onSwipeRight;

  // docs/SCREENS.md B4: "56×84 poster".
  static const double _posterWidth = 56;
  static const double _posterHeight = 84;

  @override
  Widget build(BuildContext context) {
    final row = GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: SizedBox(
                width: _posterWidth,
                height: _posterHeight,
                child: posterUrl == null
                    ? const ColoredBox(color: AppColors.surfaceRaised2)
                    : Image.network(
                        posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const ColoredBox(
                            color: AppColors.surfaceRaised2,
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    metadata,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.inkMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _Trailing(trailing: trailing),
          ],
        ),
      ),
    );

    if (onSwipeLeft == null && onSwipeRight == null) {
      return row;
    }

    return Dismissible(
      key: key ?? ValueKey(title),
      direction: switch ((onSwipeLeft, onSwipeRight)) {
        (null, null) => DismissDirection.none,
        (_, null) => DismissDirection.endToStart,
        (null, _) => DismissDirection.startToEnd,
        (_, _) => DismissDirection.horizontal,
      },
      background: const ColoredBox(color: AppColors.accent),
      secondaryBackground: const ColoredBox(color: AppColors.danger),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          onSwipeLeft?.call();
        } else if (direction == DismissDirection.startToEnd) {
          onSwipeRight?.call();
        }
        // The row never removes itself — the caller owns that decision.
        return false;
      },
      child: row,
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({required this.trailing});

  final LibraryRowTrailing trailing;

  @override
  Widget build(BuildContext context) {
    return switch (trailing) {
      _DateTrailing(:final date) => Text(
        date,
        style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
      ),
      _StarsTrailing(:final rating) => _StarRow(rating: rating),
      _ChevronTrailing() => Icon(
        AppIcons.chevronRight,
        size: 20,
        color: AppColors.inkMuted,
      ),
    };
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});

  final int rating;

  // Compact rating stars — smaller than the standard 18 px "small pill"
  // icon size, since five of them sit in a row's trailing column.
  static const double _starSize = 14;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          // Always the filled star glyph — only the color switches. Per
          // docs/SCREENS.md B4: "1–5 amber stars (empty ones in dark
          // gray; unrated shows all five in gray)".
          Icon(
            AppIcons.starFill,
            size: _starSize,
            color: i <= rating ? AppColors.accent : AppColors.inkDim,
          ),
      ],
    );
  }
}
