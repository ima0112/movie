import 'package:flutter/material.dart';

import '../../../../core/domain/entities/person.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/number_format_extension.dart';

/// D3b's filmography row (`docs/SCREENS.md` D3b, the "Filmografía"
/// design): the poster, the title, a muted "role · year" line ("Coming soon"
/// in place of the year for an undated credit), and the ★ rating at the far
/// end (hidden while TMDB has no score), with a hairline underneath.
class PersonFilmographyRow extends StatelessWidget {
  const PersonFilmographyRow({
    super.key,
    required this.credit,
    required this.onTap,
  });

  final MediaCredit credit;
  final VoidCallback onTap;

  static const double _posterWidth = 52;
  static const double _posterHeight = 76;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final role = credit.character ?? credit.job ?? '';
    final year = credit.item.releaseDate?.year;
    final subtitle = [
      if (role.isNotEmpty) role,
      year == null ? l10n.personFilmographyComingSoon : '$year',
    ].join(' · ');
    final rating = credit.item.voteAverage;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: SizedBox(
                width: _posterWidth,
                height: _posterHeight,
                // MediaItem.posterUrl is already a built URL (unlike
                // PosterImage's own raw-path convention), same as
                // media_card.dart's own poster.
                child: credit.item.posterUrl == null
                    ? const ColoredBox(color: AppColors.surfaceRaised2)
                    : Image.network(
                        credit.item.posterUrl!,
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
                    credit.item.title,
                    style: AppTextStyles.h3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.inkMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (rating > 0) ...[
              const SizedBox(width: AppSpacing.md),
              const Icon(AppIcons.starFill, size: 12, color: AppColors.accent),
              const SizedBox(width: AppSpacing.xs),
              Text(
                rating.localizedRating(l10n),
                style: AppTextStyles.bodySmStrong,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
