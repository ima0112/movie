import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/still_image.dart';
import 'season_episode_row.dart';

/// H4b (Episode) — `docs/SCREENS.md` H4b: opened from an episode row in
/// H4. A 16:9 still, the "S1 · E1" caption, the name, info chips (air date,
/// runtime) and the full synopsis. Static data already loaded by the season
/// sheet, so no Cubit (CLAUDE.md rule 9: nothing here changes).
class EpisodeSheet extends StatelessWidget {
  const EpisodeSheet({
    super.key,
    required this.seasonNumber,
    required this.episode,
  });

  final int seasonNumber;
  final Episode episode;

  static const double _heightFactor = 0.85;
  static const double _captionSpacing = 0.6;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final airDate = episode.airDate;
    final runtime = episode.runtimeMinutes;
    final code = seasonNumber == 0
        ? l10n.tvEpisodeCodeSpecials(episode.episodeNumber)
        : l10n.tvEpisodeCode(seasonNumber, episode.episodeNumber);

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: _heightFactor,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: StillImage(stillPath: episode.stillPath),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              code.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.inkMuted,
                letterSpacing: _captionSpacing,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(episode.name, style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppChip(
                  label: airDate == null
                      ? l10n.tvEpisodeTba
                      : formatEpisodeDate(airDate),
                ),
                if (runtime != null)
                  AppChip(label: l10n.myListRuntimeMinutesOnly(runtime)),
              ],
            ),
            if (episode.overview.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(episode.overview, style: AppTextStyles.body),
            ],
          ],
        ),
      ),
    );
  }
}
