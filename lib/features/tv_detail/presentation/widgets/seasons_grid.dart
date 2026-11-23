import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_spacing.dart';
import 'season_poster_tile.dart';

/// D2b's seasons as a **3-column grid** of [SeasonPosterTile]s. Specials (TMDB's
/// `season_number: 0`) sort last and only appear when they have episodes; a
/// regular season always shows, even at 0 episodes (announced, not aired).
///
/// A `Wrap` with a computed column width rather than a fixed-height grid, so a
/// tile grows with its text (big text scale, a long "13 episodes") instead of
/// overflowing. A show has a few dozen seasons at the most, so it isn't built
/// lazily.
class SeasonsGrid extends StatelessWidget {
  const SeasonsGrid({super.key, required this.seasons, this.onSeasonTap});

  final List<SeasonSummary> seasons;
  final void Function(SeasonSummary season)? onSeasonTap;

  static const int columns = 3;

  /// Regular seasons in order, then the specials if they have episodes.
  static List<SeasonSummary> ordered(List<SeasonSummary> seasons) {
    final regular = seasons.where((s) => s.seasonNumber != 0).toList();
    final specials = seasons.where(
      (s) => s.seasonNumber == 0 && s.episodeCount > 0,
    );
    return [...regular, ...specials];
  }

  @override
  Widget build(BuildContext context) {
    final items = ordered(seasons);
    if (items.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.md;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: AppSpacing.lg,
          children: [
            for (final season in items)
              SizedBox(
                width: width,
                child: SeasonPosterTile(
                  season: season,
                  onTap: () => onSeasonTap?.call(season),
                ),
              ),
          ],
        );
      },
    );
  }
}
