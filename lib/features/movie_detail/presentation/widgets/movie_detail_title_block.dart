import 'package:flutter/material.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// [MovieDetailHeader]'s centered title/metadata/rating/genres block — in
/// its own file per CLAUDE.md rule 11, `movie_detail_header.dart` was over
/// the 150-line target on its own.
class MovieDetailTitleBlock extends StatelessWidget {
  const MovieDetailTitleBlock({
    super.key,
    required this.detail,
    this.onGenreTap,
  });

  final MovieDetail detail;
  final void Function(Genre genre)? onGenreTap;

  String get _metadata {
    final year = detail.releaseDate?.year;
    final runtime = detail.runtimeMinutes;
    final certification = detail.certification;
    return [
      if (year != null) '$year',
      if (runtime != null) _formatRuntime(runtime),
      ?certification,
    ].join(' · ');
  }

  static String _formatRuntime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '$h h $m min' : '$m min';
  }

  @override
  Widget build(BuildContext context) {
    final metadata = _metadata;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          detail.item.title,
          style: AppTextStyles.display,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (metadata.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            metadata,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.starFill, size: 14, color: AppColors.accent),
            const SizedBox(width: AppSpacing.xs),
            Text(
              detail.item.voteAverage.toStringAsFixed(1),
              style: AppTextStyles.bodySm,
            ),
          ],
        ),
        if (detail.item.genres.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _GenresRow(genres: detail.item.genres, onGenreTap: onGenreTap),
        ],
      ],
    );
  }
}

class _GenresRow extends StatelessWidget {
  const _GenresRow({required this.genres, required this.onGenreTap});

  final List<Genre> genres;
  final void Function(Genre genre)? onGenreTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < genres.length; i++) ...[
          if (i > 0)
            Text(
              ' · ',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
          GestureDetector(
            onTap: () => onGenreTap?.call(genres[i]),
            child: Text(
              genres[i].name,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ],
    );
  }
}
