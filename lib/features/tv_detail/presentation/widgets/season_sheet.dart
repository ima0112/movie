import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/failure_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/season_cubit.dart';
import 'season_episode_row.dart';

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
  });

  final int tvId;
  final SeasonSummary seasonSummary;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SeasonCubit(getIt<MediaRepository>())
            ..loadSeason(tvId, seasonSummary.seasonNumber),
      child: _SeasonSheetView(seasonSummary: seasonSummary),
    );
  }
}

class _SeasonSheetView extends StatelessWidget {
  const _SeasonSheetView({required this.seasonSummary});

  final SeasonSummary seasonSummary;

  static const double _heightFactor = 0.85;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              // The only `BlocBuilder` this sheet has (CLAUDE.md rule
              // 9) — scoped to "is the season loading, errored, or
              // loaded", the same shape D1/D2's own top-level
              // `BlocBuilder` uses.
              Expanded(
                child: BlocBuilder<SeasonCubit, SeasonState>(
                  builder: (context, state) {
                    return switch (state) {
                      SeasonInitial() ||
                      SeasonLoading() => const _SeasonSkeleton(),
                      SeasonError(:final reason) => Center(
                        child: ErrorStateView(
                          title: context.l10n.commonCouldntLoad,
                          body: reason.localizedMessage(context.l10n),
                        ),
                      ),
                      SeasonLoaded(:final season) => ListView(
                        children: [
                          if (season.overview.isNotEmpty) ...[
                            Text(season.overview, style: AppTextStyles.body),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          for (final episode in season.episodes)
                            SeasonEpisodeRow(episode: episode),
                        ],
                      ),
                    };
                  },
                ),
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
    return ListView.separated(
      itemCount: _rows,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) =>
          SkeletonBlock(width: width, height: width * 9 / 16),
    );
  }
}
