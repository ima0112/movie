import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'library_row_status.dart';
import 'row_more_button.dart';
import 'swipe_to_delete.dart';

/// A library row: a 56×84 poster, the title, a gray metadata line, a
/// [status] line (the rating and when it was added, or the user's stars and
/// when they watched it) and, at the end, a three-dot button ([onMore]).
///
/// Source of truth: `docs/SCREENS.md` B4 ("Rows: 56×84 poster, 16/500 title,
/// gray 13 px line…, the status line…; swipe left → delete; long-press and
/// the three dots → H1").
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter; [onDelete] decides what the swipe deletes.
class LibraryRow extends StatelessWidget {
  const LibraryRow({
    super.key,
    required this.posterUrl,
    required this.title,
    required this.metadata,
    this.status,
    this.onMore,
    this.onTap,
    this.onLongPress,
    this.onDelete,
  });

  final String? posterUrl;
  final String title;
  final String metadata;

  /// `null` for an entry with nothing to say yet (no rating, no date).
  final LibraryRowStatus? status;

  /// The three-dot button at the end (H1); none when `null`.
  final VoidCallback? onMore;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Swipe left to delete ([SwipeToDelete]); not swipeable when `null`.
  final VoidCallback? onDelete;

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
                        errorBuilder: (context, error, stackTrace) =>
                            const ColoredBox(color: AppColors.surfaceRaised2),
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
                  if (status != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    LibraryRowStatusLine(status: status!),
                  ],
                ],
              ),
            ),
            if (onMore != null) RowMoreButton(onTap: onMore!),
          ],
        ),
      ),
    );

    return onDelete == null
        ? row
        : SwipeToDelete(onDelete: onDelete!, child: row);
  }
}
