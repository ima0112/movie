import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// The third line of a [LibraryRow]: what the user knows about the title.
///
/// - [LibraryRowStatus.rated] — Favorites / Watch later: the ★ TMDB rating
///   and when it was added ("★ 8,2  Added today"). Either part may be absent.
/// - [LibraryRowStatus.watched] — Watched: the user's own 1–5 stars and when
///   they watched it ("★★★★☆  8 Nov, 2026").
sealed class LibraryRowStatus {
  const LibraryRowStatus();

  const factory LibraryRowStatus.rated({String? rating, String? label}) =
      _RatedStatus;

  const factory LibraryRowStatus.watched({
    required int? stars,
    required String label,
  }) = _WatchedStatus;
}

class _RatedStatus extends LibraryRowStatus {
  const _RatedStatus({this.rating, this.label});
  final String? rating;
  final String? label;
}

class _WatchedStatus extends LibraryRowStatus {
  const _WatchedStatus({required this.stars, required this.label});
  final int? stars;
  final String label;
}

/// Draws a [LibraryRowStatus] on one line.
class LibraryRowStatusLine extends StatelessWidget {
  const LibraryRowStatusLine({super.key, required this.status});

  final LibraryRowStatus status;

  static const double _starSize = 14;

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted);
    final children = switch (status) {
      _RatedStatus(:final rating, :final label) => [
        if (rating != null) ...[
          const Icon(
            AppIcons.starFill,
            size: _starSize,
            color: AppColors.accent,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(rating, style: AppTextStyles.bodySmToggle(true)),
        ],
        if (rating != null && label != null)
          const SizedBox(width: AppSpacing.sm),
        if (label != null) Flexible(child: _Line(label, muted)),
      ],
      _WatchedStatus(:final stars, :final label) => [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= (stars ?? 0) ? AppIcons.starFill : AppIcons.star,
            size: _starSize + 2,
            color: AppColors.accent,
          ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: _Line(label, muted)),
      ],
    };
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class _Line extends StatelessWidget {
  const _Line(this.text, this.style);

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
}
