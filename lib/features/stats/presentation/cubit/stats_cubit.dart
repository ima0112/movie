import '../../../../core/domain/stats/surprise_insights_calculator.dart';
import '../../../../core/domain/stats/surprise_insights.dart';
import '../../../../core/domain/repositories/surprise_session_repository.dart';
import '../../../../core/domain/repositories/surprise_history_repository.dart';
import '../../../../core/domain/entities/surprise_session.dart';
import '../../../../core/domain/entities/surprise_history_entry.dart';
import '../../../../core/domain/entities/result.dart';
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
  const StatsState({
    required this.period,
    required this.insights,
    required this.surprise,
  });

  final StatsPeriod period;
  final LibraryInsights insights;

  /// The Surprise-me statistics for [period] (empty without any session).
  final SurpriseInsights surprise;
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
  StatsCubit(
    this._repository, {
    SurpriseHistoryRepository? history,
    SurpriseSessionRepository? sessions,
    DateTime Function()? clock,
    // ignore: prefer_initializing_formals
  }) : _history = history,
       // ignore: prefer_initializing_formals
       _sessions = sessions,
       _clock = clock ?? DateTime.now,
       super(
         StatsState(
           period: StatsPeriod.allTime,
           insights: calculateInsights(
             const [],
             period: StatsPeriod.allTime,
             now: (clock ?? DateTime.now)(),
           ),
           surprise: calculateSurpriseInsights(
             history: const [],
             sessions: const [],
             library: const [],
             period: StatsPeriod.allTime,
             now: (clock ?? DateTime.now)(),
           ),
         ),
       ) {
    _subscription = _repository.watch().listen(_onEntries);
    unawaited(_loadSurprise());
  }

  final UserLibraryRepository _repository;
  final SurpriseHistoryRepository? _history;
  final SurpriseSessionRepository? _sessions;
  final DateTime Function() _clock;
  late final StreamSubscription<List<UserMediaEntry>> _subscription;
  List<UserMediaEntry> _entries = const [];
  List<SurpriseHistoryEntry> _surpriseHistory = const [];
  List<SurpriseSession> _surpriseSessions = const [];

  /// The Surprise-me record is read once when C4 opens (it only grows while a
  /// Surprise-me search runs, never under this screen).
  Future<void> _loadSurprise() async {
    final history = await _history?.all();
    final sessions = await _sessions?.all();
    if (isClosed) return;
    if (history is Success<List<SurpriseHistoryEntry>>) {
      _surpriseHistory = history.value;
    }
    if (sessions is Success<List<SurpriseSession>>) {
      _surpriseSessions = sessions.value;
    }
    _emit(state.period);
  }

  void selectPeriod(StatsPeriod period) => _emit(period);

  void _onEntries(List<UserMediaEntry> entries) {
    _entries = entries;
    _emit(state.period);
  }

  void _emit(StatsPeriod period) => emit(
    StatsState(
      period: period,
      insights: calculateInsights(_entries, period: period, now: _clock()),
      surprise: calculateSurpriseInsights(
        history: _surpriseHistory,
        sessions: _surpriseSessions,
        library: _entries,
        period: period,
        now: _clock(),
      ),
    ),
  );

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
