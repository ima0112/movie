import 'package:flutter/material.dart';

import '../../../../core/domain/entities/person.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// D3's filmography row — `docs/SCREENS.md` D3: "reverse-chronological
/// list (thumbnail, title, year, role)." Grouped under a year header by
/// the section above this (`PersonFilmography.groupedByYear`), so this
/// row itself only shows the title and the role (character or job) —
/// not the year again, already said once per group.
class PersonFilmographyRow extends StatelessWidget {
  const PersonFilmographyRow({
    super.key,
    required this.credit,
    required this.onTap,
  });

  final MediaCredit credit;
  final VoidCallback onTap;

  static const double _posterWidth = 56;
  static const double _posterHeight = 84;

  @override
  Widget build(BuildContext context) {
    final role = credit.character ?? credit.job ?? '';

    return GestureDetector(
      onTap: onTap,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (role.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      role,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.inkMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
