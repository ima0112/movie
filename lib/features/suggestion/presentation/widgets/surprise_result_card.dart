import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';

/// E3's own result card — `docs/SCREENS.md` E3: "White card: large
/// poster, title, 'Year · Genres', rating, 2-line synopsis, 'View
/// details' link."
///
/// Two deviations from that literal wording, both deliberate:
/// - [AppColors.surfaceRaised] (every other card in this app's own
///   dark-locked palette) instead of a literal white background — this
///   app has no light-surface token at all (`AppTheme` only ever
///   configures a dark theme), so a genuinely white card would need an
///   entirely new color pairing this design system doesn't define
///   anywhere. `AppColors.ink` (white) is text/icon-only, never a
///   background, throughout the rest of this app.
/// - No synopsis: `MatchResult.winner`/`.alternatives` are `MediaItem`s
///   (list-level — the same entity Discover's own carousels use), which
///   carries no overview text at all; only `MediaDetail` (a separate
///   `MediaRepository.detail` call per candidate) has one. Fetching that
///   for whichever candidate is currently shown — and re-fetching on
///   every "Another suggestion" tap — is out of scope for this assembly
///   pass.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class SurpriseResultCard extends StatelessWidget {
  const SurpriseResultCard({super.key, required this.item, this.onViewDetails});

  final MediaItem item;
  final VoidCallback? onViewDetails;

  // DESIGN_SYSTEM.md section 4: "18: dentro de pills pequeñas" — the
  // closest existing token to a small inline rating icon.
  static const double _ratingIconSize = 18;

  @override
  Widget build(BuildContext context) {
    final year = item.releaseDate?.year;
    final genreNames = item.genres
        .map((g) => g.localizedName(context.l10n))
        .join(', ');
    final metadata = [
      if (year != null) '$year',
      if (genreNames.isNotEmpty) genreNames,
    ].join(' · ');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: item.posterUrl == null
                    ? const ColoredBox(color: AppColors.surfaceRaised2)
                    : Image.network(
                        item.posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const ColoredBox(color: AppColors.surfaceRaised2),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(item.title, style: AppTextStyles.h2),
            if (metadata.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                metadata,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  AppIcons.starFill,
                  size: _ratingIconSize,
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  item.voteAverage.toStringAsFixed(1),
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
            if (onViewDetails != null) ...[
              const SizedBox(height: AppSpacing.md),
              TextLinkButton(
                label: 'View details',
                onTap: onViewDetails,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
