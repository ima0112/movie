import 'package:flutter/material.dart';

import '../../../../core/domain/entities/person.dart';
import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/media_detail/media_cast_circle.dart';
import '../../../../shared/widgets/overline_label.dart';
import 'episode_meta_line.dart';
import 'episode_sheet_header.dart';

/// What the episode sheet scrolls: the edge-to-edge still with its code pill,
/// the name, the meta line, the synopsis and the guest stars.
class EpisodeSheetBody extends StatelessWidget {
  const EpisodeSheetBody({
    super.key,
    required this.seasonNumber,
    required this.episode,
    this.onPersonTap,
  });

  final int seasonNumber;
  final Episode episode;

  /// A guest star was tapped → D3.
  final void Function(Person person)? onPersonTap;

  static const double _guestSize = 64;
  static const double _starSize = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final code = seasonNumber == 0
        ? l10n.tvEpisodeCodeSpecials(episode.episodeNumber)
        : l10n.tvEpisodeCode(seasonNumber, episode.episodeNumber);
    return ListView(
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
                style: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
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
      ],
    );
  }
}
