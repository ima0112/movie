import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/domain/stats/library_insights.dart';
import '../../../../core/domain/stats/library_insights_calculator.dart';
import '../../../../core/domain/stats/stats_period.dart';

/// C4 (Stats)'s state: the chosen [period] and the [LibraryInsights]
/// computed for it.
class StatsState {
  const StatsState({required this.period, required this.insights});

  final StatsPeriod period;
  final LibraryInsights insights;
}

/// Screen-local Cubit for C4 — created where its `BlocProvider` is placed
/// (the Stats screen), never registered in `di.config.dart`.
///
/// Not the library-wide cache CLAUDE.md rule 10 rules out: that rule targets
/// a *shared* copy other screens would piggyback on. Stats is the opposite —
/// its one screen's whole purpose is an aggregate over the watched list, so
/// holding that aggregate as its own state is the same shape as
/// `DiscoverCubit`.
///
/// Subscribes to [UserLibraryRepository.watch] so the screen live-updates as
/// titles are watched or removed, and recomputes [LibraryInsights] on every
/// emission and every period change ([clock] anchors "this month" / "this
/// year" for tests).
class StatsCubit extends Cubit<StatsState> {
  StatsCubit(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(
        StatsState(
          period: StatsPeriod.allTime,
          insights: calculateInsights(
            const [],
            period: StatsPeriod.allTime,
            now: (clock ?? DateTime.now)(),
          ),
        ),
      ) {
    _subscription = _repository.watch().listen(_onEntries);
  }

  final UserLibraryRepository _repository;
  final DateTime Function() _clock;
  late final StreamSubscription<List<UserMediaEntry>> _subscription;
  List<UserMediaEntry> _entries = const [];

  void selectPeriod(StatsPeriod period) => _emit(period);

  void _onEntries(List<UserMediaEntry> entries) {
    _entries = entries;
    _emit(state.period);
  }

  void _emit(StatsPeriod period) => emit(
    StatsState(
      period: period,
      insights: calculateInsights(_entries, period: period, now: _clock()),
    ),
  );

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
