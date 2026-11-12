import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../widgets/episode_ref_card.dart';
import '../widgets/season_sheet.dart';
import '../widgets/seasons_summary_card.dart';
import '../widgets/tv_seasons_section.dart';
import '../widgets/tv_status.dart';

/// Seasons (D2b) — pushed from D2's Seasons card (`docs/SCREENS.md` D2b).
///
/// Static: it renders the [TvShowDetail] D2 already loaded, so there is no
/// Cubit and no network call here (CLAUDE.md rule 9 — nothing changes).
/// Tapping a season opens H4 as a sheet, like D2 used to.
class TvSeasonsScreen extends StatelessWidget {
  const TvSeasonsScreen({super.key, required this.detail});

  final TvShowDetail detail;

  void _openSeason(BuildContext context, SeasonSummary season) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SeasonSheet(
        tvId: detail.item.id,
        seasonSummary: season,
        showTitle: detail.item.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final seasonCount = detail.seasons.where((s) => s.seasonNumber != 0).length;
    final finished = tvStatusIsFinished(detail.status);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.tvSeasonsSectionTitle, style: AppTextStyles.h3),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.sectionGap),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                AppSpacing.xl,
                AppSpacing.screenMargin,
                0,
              ),
              child: SeasonsSummaryCard(
                title: detail.item.title,
                chips: [
                  tvStatusLabel(detail.status, l10n),
                  if (seasonCount > 0) l10n.myListSeasonsCount(seasonCount),
                  if (detail.numberOfEpisodes > 0)
                    l10n.tvEpisodeCount(detail.numberOfEpisodes),
                ],
              ),
            ),
            // A show that has ended or been cancelled has no next episode to
            // announce, so the section isn't drawn at all.
            if (!finished)
              AppSection.overline(
                title: l10n.tvNextEpisodeCaption,
                child: EpisodeRefCard(
                  episode: detail.nextEpisode,
                  emptyTitle: l10n.tvNoNextEpisodeTitle,
                  emptyBody: l10n.tvNoNextEpisodeUnknown,
                ),
              ),
            if (detail.lastEpisode != null)
              AppSection.overline(
                title: l10n.tvLastAiredEpisodeCaption,
                child: EpisodeRefCard(
                  episode: detail.lastEpisode,
                  emptyTitle: '',
                  emptyBody: '',
                ),
              ),
            AppSection.overline(
              title: l10n.tvSeasonsSectionTitle,
              child: TvSeasonsSection(
                seasons: detail.seasons,
                showTitle: false,
                padding: EdgeInsets.zero,
                onSeasonTap: (season) => _openSeason(context, season),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
