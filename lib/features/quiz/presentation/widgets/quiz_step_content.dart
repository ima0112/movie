import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/collection_catalog.dart';
import '../../../match_engine/domain/vibe_catalog.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';
import 'quiz_collection_step.dart';
import 'quiz_genre_step.dart';
import 'quiz_vibe_step.dart';
import 'quiz_platform_step.dart';
import 'quiz_year_limits_step.dart';

/// The one `BlocBuilder` for "whichever step is showing" — the same
/// "content legitimately varies together" shape `DiscoverContentArea`/
/// `StatsScreen`'s own content builders already use: exactly one step is
/// ever mounted at a time, and each step's own fields are disjoint from
/// every other step's, so this isn't a screen-wide builder in spirit,
/// just a single switch over which narrow slice to show. Split out of
/// `quiz_screen.dart` to keep that file within CLAUDE.md rule 11's line
/// limit.
class QuizStepContent extends StatelessWidget {
  const QuizStepContent({
    super.key,
    required this.vibeCatalog,
    required this.collectionCatalog,
  });

  final VibeCatalog vibeCatalog;
  final CollectionCatalog collectionCatalog;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        final cubit = context.read<QuizCubit>();
        return switch (state.step) {
          1 => QuizCollectionStep(
            collectionCatalog: collectionCatalog,
            mediaType: state.mediaType,
            selected: state.collectionIds,
            onToggle: cubit.toggleCollection,
          ),
          2 => QuizGenreStep(
            selected: state.excludedGenres,
            mediaType: state.mediaType,
            options: cubit.vetoOptions,
            onToggle: cubit.toggleExcludedGenre,
          ),
          3 => QuizVibeStep(
            vibeCatalog: vibeCatalog,
            mediaType: state.mediaType,
            selected: state.vibeIds,
            options: cubit.vibeOptions,
            onToggle: cubit.toggleVibe,
          ),
          4 => QuizPlatformStep(
            mediaType: state.mediaType,
            selected: state.platformIds,
            includeRentBuy: state.includeRentBuy,
            onToggle: cubit.togglePlatform,
            onClear: cubit.clearPlatforms,
            onIncludeRentBuyChanged: cubit.setIncludeRentBuy,
          ),
          _ => QuizYearLimitsStep(
            mediaType: state.mediaType,
            yearFrom: state.yearFrom,
            yearTo: state.yearTo,
            onYearRangeChanged: (from, to, currentYear) =>
                cubit.setYearRange(from, to, currentYear: currentYear),
            maxRuntimeMinutes: state.maxRuntimeMinutes,
            onMaxRuntimeChanged: cubit.setMaxRuntimeMinutes,
            tvStatus: state.tvStatus,
            onTvStatusChanged: cubit.setTvStatus,
            excludeWatched: state.excludeWatched,
            onExcludeWatchedChanged: cubit.setExcludeWatched,
          ),
        };
      },
    );
  }
}
