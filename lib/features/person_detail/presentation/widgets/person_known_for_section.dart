import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/media_card.dart';

/// D3's "Known for": a row of their most popular titles, each poster with
/// its title underneath (the "Persona" design — unlike the home carousels,
/// the poster alone doesn't say what the title is here).
///
/// A plain horizontal scroll of columns rather than a fixed-height list,
/// so the title lines can grow with the text scale without overflowing.
class PersonKnownForSection extends StatelessWidget {
  const PersonKnownForSection({super.key, required this.items, this.onItemTap});

  final List<MediaItem> items;
  final void Function(MediaItem item)? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.personKnownForTitle, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: AppSpacing.xl),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, item) in items.indexed) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: MediaCardSize.carousel.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MediaCard(
                          size: MediaCardSize.carousel,
                          title: item.title,
                          posterUrl: item.posterUrl,
                          showTypeTag: item.type == MediaType.tvShow,
                          onTap: onItemTap == null
                              ? null
                              : () => onItemTap!(item),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.title,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.ink,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
