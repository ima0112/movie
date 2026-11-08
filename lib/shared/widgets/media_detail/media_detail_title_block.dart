import 'package:flutter/material.dart';

import '../../../core/domain/entities/genre.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// [MediaDetailHeader]'s centered title/metadata/rating/genres block — in
/// its own file per CLAUDE.md rule 11, `media_detail_header.dart` was
/// over the 150-line target on its own.
///
/// Generic across D1/D2: [metadataLine] arrives already formatted (D1's
/// own "2019 · 2 h 10 min · PG-13" vs. D2's "2022–2024 · 3 seasons ·
/// 24 episodes · TV-14" are different enough per-field logic that
/// formatting them is each screen's own job, not this shared widget's —
/// see `movie_detail/widgets/movie_metadata.dart`). [statusPill] is D2's
/// own "Airing"/"Ended" badge next to the title (`docs/SCREENS.md` D2);
/// `null` renders nothing extra, which is exactly D1's own shape.
class MediaDetailTitleBlock extends StatelessWidget {
  const MediaDetailTitleBlock({
    super.key,
    required this.title,
    required this.metadataLine,
    required this.voteAverage,
    required this.genres,
    this.onGenreTap,
    this.statusPill,
  });

  final String title;
  final String metadataLine;
  final double voteAverage;
  final List<Genre> genres;
  final void Function(Genre genre)? onGenreTap;
  final Widget? statusPill;

  @override
  Widget build(BuildContext context) {
    final titleText = Text(
      title,
      style: AppTextStyles.display,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // No pill (D1's own shape): the plain, full-width centered Text,
        // unchanged from before this widget took a statusPill slot at
        // all. A pill (D2) needs a Row so the text can share the line
        // with it — kept as a separate branch rather than always
        // wrapping in a Row, since a `mainAxisSize: min` Row with a
        // `Flexible` child does NOT behave like the plain Text for
        // sizing/wrapping purposes.
        statusPill == null
            ? titleText
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: titleText),
                  const SizedBox(width: AppSpacing.sm),
                  statusPill!,
                ],
              ),
        if (metadataLine.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            metadataLine,
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
            Text(voteAverage.toStringAsFixed(1), style: AppTextStyles.bodySm),
          ],
        ),
        if (genres.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _GenresRow(genres: genres, onGenreTap: onGenreTap),
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
