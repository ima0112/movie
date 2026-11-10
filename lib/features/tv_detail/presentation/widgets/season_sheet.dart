import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/failure_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/season_cubit.dart';
import 'episode_sheet.dart';
import 'season_episode_row.dart';
import 'season_header_card.dart';
import 'season_overview.dart';

/// H4 (Season sheet) — `docs/SCREENS.md` H4: "Title, season synopsis,
/// episode list (number, name, runtime, date, still)". Opened from a
/// D2 "Seasons" row tap (`tv_seasons_section.dart`).
///
/// [seasonSummary] is what D2 already has on hand (season number, so
/// the title shows immediately) — [SeasonCubit] then fetches the
/// season's own synopsis + full episode list on demand
/// (`docs/DECISIONS.md`: "seasons on demand").
class SeasonSheet extends StatelessWidget {
  const SeasonSheet({
    super.key,
    required this.tvId,
    required this.seasonSummary,
    this.showTitle,
  });

  final int tvId;
  final SeasonSummary seasonSummary;

  /// The show's name, shown small over the season title.
  final String? showTitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SeasonCubit(getIt<MediaRepository>())
            ..loadSeason(tvId, seasonSummary.seasonNumber),
      child: _SeasonSheetView(
        seasonSummary: seasonSummary,
        showTitle: showTitle,
      ),
    );
  }
}

class _SeasonSheetView extends StatelessWidget {
  const _SeasonSheetView({required this.seasonSummary, this.showTitle});

  final SeasonSummary seasonSummary;
  final String? showTitle;

  static const double _heightFactor = 0.85;

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

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: _heightFactor,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ListView(
            children: [
              SeasonHeaderCard(
                title: title,
                showTitle: showTitle,
                posterPath: seasonSummary.posterPath,
                voteAverage: seasonSummary.voteAverage,
                episodeCountLabel: l10n.tvEpisodeCount(
                  seasonSummary.episodeCount,
                ),
              ),
              // The only `BlocBuilder` this sheet has (CLAUDE.md rule 9) —
              // scoped to "is the season loading, errored, or loaded", the
              // same shape D1/D2's own top-level `BlocBuilder` uses.
              BlocBuilder<SeasonCubit, SeasonState>(
                builder: (context, state) {
                  return switch (state) {
                    SeasonInitial() ||
                    SeasonLoading() => const _SeasonSkeleton(),
                    SeasonError(:final reason) => ErrorStateView(
                      title: context.l10n.commonCouldntLoad,
                      body: reason.localizedMessage(context.l10n),
                    ),
                    SeasonLoaded(:final season) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (season.overview.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          SeasonOverview(overview: season.overview),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          l10n.tvEpisodesSectionTitle.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.inkMuted,
                            letterSpacing: 0.6,
                          ),
                        ),
                        for (final episode in season.episodes)
                          SeasonEpisodeRow(
                            episode: episode,
                            onTap: () => _openEpisode(context, episode),
                          ),
                      ],
                    ),
                  };
                },
              ),
            ],
          ),
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
    return Column(
      children: [
        for (var i = 0; i < _rows; i++) ...[
          const SizedBox(height: AppSpacing.lg),
          SkeletonBlock(width: width, height: 64),
        ],
      ],
    );
  }
}
