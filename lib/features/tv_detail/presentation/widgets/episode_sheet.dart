import 'package:flutter/material.dart';
import '../../../../shared/widgets/overline_label.dart';

import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../core/domain/entities/person.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/media_detail/media_cast_circle.dart';
import 'episode_meta_line.dart';
import 'episode_sheet_header.dart';

/// H4b (Episode) — `docs/SCREENS.md` H4b: opened from an episode row in
/// D2c. An edge-to-edge 16:9 still with the "S1 · E1" pill, the name, one meta
/// line (air date, runtime, rating) and the full synopsis. Static data already loaded by the season
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
  static const double _starSize = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final code = seasonNumber == 0
        ? l10n.tvEpisodeCodeSpecials(episode.episodeNumber)
        : l10n.tvEpisodeCode(seasonNumber, episode.episodeNumber);

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: _heightFactor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            EpisodeSheetHeader(stillPath: episode.stillPath, code: code),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(episode.name, style: AppTextStyles.display),
                  const SizedBox(height: AppSpacing.sm),
                  EpisodeMetaLine(
                    episode: episode,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.inkMuted,
                    ),
                    starSize: _starSize,
                    maxLines: null,
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
                          for (final (i, member)
                              in episode.guestStars.indexed) ...[
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
          ],
        ),
      ),
    );
  }
}
