import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../match_engine/domain/vibe_catalog.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';
import 'quiz_final_step.dart';
import 'quiz_genre_step.dart';
import 'quiz_vibe_step.dart';
import 'quiz_year_step.dart';

/// The one `BlocBuilder` for "whichever step is showing" — the same
/// "content legitimately varies together" shape `DiscoverContentArea`/
/// `StatsScreen`'s own content builders already use: exactly one step is
/// ever mounted at a time, and each step's own fields are disjoint from
/// every other step's, so this isn't a screen-wide builder in spirit,
/// just a single switch over which narrow slice to show. Split out of
/// `quiz_screen.dart` to keep that file within CLAUDE.md rule 11's line
/// limit.
class QuizStepContent extends StatelessWidget {
  const QuizStepContent({super.key, required this.vibeCatalog});

  final VibeCatalog vibeCatalog;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        final cubit = context.read<QuizCubit>();
        return switch (state.step) {
          1 => QuizGenreStep(
            selected: state.excludedGenres,
            onToggle: cubit.toggleExcludedGenre,
          ),
          2 => QuizVibeStep(
            vibeCatalog: vibeCatalog,
            mediaType: state.mediaType,
            selected: state.vibeIds,
            onToggle: cubit.toggleVibe,
          ),
          3 => QuizYearStep(
            yearFrom: state.yearFrom,
            onChanged: cubit.setYearFrom,
          ),
          _ => QuizFinalStep(
            mediaType: state.mediaType,
            maxRuntimeMinutes: state.maxRuntimeMinutes,
            onMaxRuntimeMinutesChanged: cubit.setMaxRuntimeMinutes,
            tvStatus: state.tvStatus,
            onTvStatusChanged: cubit.setTvStatus,
            maxSeasons: state.maxSeasons,
            onMaxSeasonsChanged: cubit.setMaxSeasons,
            excludeWatched: state.excludeWatched,
            onExcludeWatchedChanged: cubit.setExcludeWatched,
          ),
        };
      },
    );
  }
}
