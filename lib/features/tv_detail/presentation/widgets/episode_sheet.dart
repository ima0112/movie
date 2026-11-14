import '../../../../l10n/full_date_format.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/overline_label.dart';

import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../core/domain/entities/person.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../l10n/number_format_extension.dart';
import '../../../../shared/widgets/media_detail/info_chip.dart';
import '../../../../shared/widgets/media_detail/media_cast_circle.dart';
import '../../../../shared/widgets/still_image.dart';

/// H4b (Episode) — `docs/SCREENS.md` H4b: opened from an episode row in
/// H4. A 16:9 still, the "S1 · E1" caption, the name, info chips (air date,
/// runtime) and the full synopsis. Static data already loaded by the season
/// sheet, so no Cubit (CLAUDE.md rule 9: nothing here changes).
class EpisodeSheet extends StatelessWidget {
  const EpisodeSheet({
    super.key,
    required this.seasonNumber,
    required this.episode,
    this.onPersonTap,
  });

  final int seasonNumber;
  final Episode episode;

  /// A guest star was tapped → D3.
  final void Function(Person person)? onPersonTap;

  static const double _heightFactor = 0.85;
  static const double _guestSize = 64;

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
            OverlineLabel(code),
            const SizedBox(height: AppSpacing.xs),
            Text(episode.name, style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                InfoChip(
                  label: airDate == null
                      ? l10n.tvEpisodeTba
                      : context.l10n.fullDate(airDate),
                ),
                if (runtime != null)
                  InfoChip(label: l10n.myListRuntimeMinutesOnly(runtime)),
                if (episode.voteAverage != null)
                  InfoChip(
                    label: episode.voteAverage!.localizedRating(l10n),
                    icon: AppIcons.starFill,
                  ),
              ],
            ),
            if (episode.overview.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(episode.overview, style: AppTextStyles.body),
            ],
            if (episode.guestStars.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              OverlineLabel(l10n.tvEpisodeGuestStars),
              const SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (i, member) in episode.guestStars.indexed) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.lg),
                      MediaCastCircle(
                        member: member,
                        size: _guestSize,
                        onTap: () => onPersonTap?.call(member.person),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
