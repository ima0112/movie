import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/surprise_history_entry.dart';
import '../../../../core/domain/entities/surprise_session.dart';
import '../../../../core/domain/repositories/surprise_history_repository.dart';
import '../../../../core/domain/repositories/surprise_session_repository.dart';
import '../../../../core/domain/stats/surprise_summary.dart';

/// What You's stats card knows about Surprise me: `null` until both the
/// sessions and the history have been read once, then a [SurpriseSummary] that
/// follows them (the card shows up when the first session is recorded).
///
/// **Screen-local** (CLAUDE.md rule 10), like `YouStatsCubit`: it holds the two
/// derived numbers, never the sessions themselves — the repositories' streams
/// are the source — and [SurpriseSummary] is value-equal, so a change that
/// leaves the numbers alone emits nothing.
class YouSurpriseCubit extends Cubit<SurpriseSummary?> {
  YouSurpriseCubit(
    SurpriseSessionRepository sessions,
    SurpriseHistoryRepository history,
  ) : super(null) {
    _sessionsSub = sessions.watchAll().listen((value) {
      _sessions = value;
      _emit();
    });
    _historySub = history.watchAll().listen((value) {
      _history = value;
      _emit();
    });
  }

  late final StreamSubscription<Object?> _sessionsSub;
  late final StreamSubscription<Object?> _historySub;
  List<SurpriseSession>? _sessions;
  List<SurpriseHistoryEntry>? _history;

  void _emit() {
    final sessions = _sessions;
    final history = _history;
    if (sessions == null || history == null || isClosed) return;
    emit(calculateSurpriseSummary(sessions: sessions, history: history));
  }

  @override
  Future<void> close() async {
    await _sessionsSub.cancel();
    await _historySub.cancel();
    return super.close();
  }
}
