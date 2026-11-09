import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/poster_image.dart';

/// D2's "Seasons" section — `docs/SCREENS.md` D2: "list of rows
/// (thumbnail, 'Season N', year, 'X episodes', chevron) → H4."
///
/// Specials (TMDB's `season_number: 0`) sort to the end, labeled
/// "Specials" rather than "Season 0" — a specials list is often thin or
/// empty, so it reads better as an appendix than as "Season 0" sitting
/// before "Season 1". Hidden entirely when it has no episodes at all
/// (TMDB sometimes lists an empty specials season), unlike a regular
/// season, which is always shown even at 0 episodes (e.g. announced but
/// not yet aired).
class TvSeasonsSection extends StatelessWidget {
  const TvSeasonsSection({
    super.key,
    required this.seasons,
    this.onSeasonTap,
    this.showTitle = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.lg,
    ),
  });

  final List<SeasonSummary> seasons;
  final void Function(SeasonSummary season)? onSeasonTap;

  /// D2b draws its own "SEASONS" caption above this list, so it hides the
  /// section's own title.
  final bool showTitle;

  /// Defaults to the detail screen's side/vertical padding; D2b, which pads
  /// its own list, passes [EdgeInsets.zero].
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final ordered = _ordered(seasons);
    if (ordered.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Text(context.l10n.tvSeasonsSectionTitle, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
          ],
          for (final (i, season) in ordered.indexed) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _SeasonRow(season: season, onTap: () => onSeasonTap?.call(season)),
          ],
        ],
      ),
    );
  }

  static List<SeasonSummary> _ordered(List<SeasonSummary> seasons) {
    final regular = seasons.where((s) => s.seasonNumber != 0).toList();
    final specials = seasons.where(
      (s) => s.seasonNumber == 0 && s.episodeCount > 0,
    );
    return [...regular, ...specials];
  }
}

class _SeasonRow extends StatelessWidget {
  const _SeasonRow({required this.season, required this.onTap});

  final SeasonSummary season;
  final VoidCallback onTap;

  static const double _posterWidth = 44;
  static const double _posterHeight = 64;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = season.seasonNumber == 0
        ? l10n.tvSpecialsLabel
        : l10n.tvSeasonLabel(season.seasonNumber);
    final year = season.airDate?.year;
    final episodeLabel = l10n.tvEpisodeCount(season.episodeCount);
    final metadata = [if (year != null) '$year', episodeLabel].join(' · ');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      // Each season is its own bordered card (the "Temporadas" design).
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: SizedBox(
                width: _posterWidth,
                height: _posterHeight,
                child: PosterImage(posterPath: season.posterPath),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    metadata,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(AppIcons.chevronRight, size: 20, color: AppColors.ink),
          ],
        ),
      ),
    );
  }
}
