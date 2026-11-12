import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/failure_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/season_cubit.dart';
import '../widgets/episode_sheet.dart';
import '../widgets/season_episode_row.dart';
import '../widgets/season_header_card.dart';
import '../widgets/season_overview.dart';

/// D2c (Season, pushed) — `docs/SCREENS.md` D2c (it replaces the old H4
/// bottom sheet): back button, the season's name centered as the title, then
/// the header card, the season's synopsis and the episode list. Opened from
/// a season card on D2b.
///
/// [seasonSummary] is what D2b already has on hand (season number, poster,
/// rating, episode count — so the header shows immediately); [SeasonCubit]
/// then fetches the season's own synopsis and full episode list on demand
/// (`docs/DECISIONS.md`: "seasons on demand"). Tapping an episode opens H4b
/// over this page.
class SeasonScreen extends StatelessWidget {
  const SeasonScreen({
    super.key,
    required this.tvId,
    required this.seasonSummary,
    this.showTitle,
  });

  final int tvId;
  final SeasonSummary seasonSummary;

  /// The show's name, shown small over the season title in the header card.
  final String? showTitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SeasonCubit(getIt<MediaRepository>())
            ..loadSeason(tvId, seasonSummary.seasonNumber),
      child: _SeasonView(seasonSummary: seasonSummary, showTitle: showTitle),
    );
  }
}

class _SeasonView extends StatelessWidget {
  const _SeasonView({required this.seasonSummary, this.showTitle});

  final SeasonSummary seasonSummary;
  final String? showTitle;

  void _openEpisode(BuildContext context, Episode episode) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EpisodeSheet(
        seasonNumber: seasonSummary.seasonNumber,
        episode: episode,
        onPersonTap: (person) => context.pushPersonDetail(person.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = seasonSummary.seasonNumber == 0
        ? l10n.tvSpecialsLabel
        : l10n.tvSeasonLabel(seasonSummary.seasonNumber);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
        // The show's name (the season is the big title in the header card
        // below); nothing when the show's name isn't known, rather than
        // repeating the season.
        title: showTitle == null
            ? null
            : Text(
                showTitle!,
                style: AppTextStyles.h3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
              child: SeasonHeaderCard(
                title: title,
                posterPath: seasonSummary.posterPath,
                voteAverage: seasonSummary.voteAverage,
                episodeCountLabel: l10n.tvEpisodeCount(
                  seasonSummary.episodeCount,
                ),
              ),
            ),
            // The only `BlocBuilder` this page has (CLAUDE.md rule 9) —
            // scoped to "is the season loading, errored, or loaded", the
            // same shape D1/D2's own top-level `BlocBuilder` uses.
            BlocBuilder<SeasonCubit, SeasonState>(
              builder: (context, state) {
                return switch (state) {
                  SeasonInitial() || SeasonLoading() => const _SeasonSkeleton(),
                  SeasonError(:final reason) => ErrorStateView(
                    title: context.l10n.commonCouldntLoad,
                    body: reason.localizedMessage(context.l10n),
                  ),
                  SeasonLoaded(:final season) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (season.overview.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenMargin,
                            AppSpacing.md,
                            AppSpacing.screenMargin,
                            0,
                          ),
                          child: SeasonOverview(overview: season.overview),
                        ),
                      AppSection.overline(
                        title: l10n.tvEpisodesSectionTitle,
                        child: Column(
                          children: [
                            for (final episode in season.episodes)
                              SeasonEpisodeRow(
                                episode: episode,
                                onTap: () => _openEpisode(context, episode),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonSkeleton extends StatelessWidget {
  const _SeasonSkeleton();

  static const int _rows = 3;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - AppSpacing.xl * 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
      child: Column(
        children: [
          for (var i = 0; i < _rows; i++) ...[
            const SizedBox(height: AppSpacing.lg),
            SkeletonBlock(width: width, height: 64),
          ],
        ],
      ),
    );
  }
}
