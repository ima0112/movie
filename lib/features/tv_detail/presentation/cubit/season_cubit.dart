import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/domain/repositories/media_repository.dart';

/// H4's (season sheet) load state.
sealed class SeasonState {
  const SeasonState();
}

/// Nothing loaded yet — before the first [SeasonCubit.loadSeason] call.
final class SeasonInitial extends SeasonState {
  const SeasonInitial();
}

/// Fetching the season passed to [SeasonCubit.loadSeason].
final class SeasonLoading extends SeasonState {
  const SeasonLoading();
}

/// Season ready.
final class SeasonLoaded extends SeasonState {
  const SeasonLoaded(this.season);

  final SeasonDetail season;
}

/// The load failed.
final class SeasonError extends SeasonState {
  const SeasonError(this.message);

  final String message;
}

/// Loads one season's full detail (H4) on demand — `docs/SCREENS.md`
/// H4: "Season row in D2" opens this sheet, which then fetches
/// `MediaRepository.season(tvId, n)` itself rather than D2 prefetching
/// every season up front (`docs/DECISIONS.md` §2: "seasons on demand").
///
/// Screen-local per CLAUDE.md rule 10 — this Cubit's lifecycle matches
/// exactly one open H4 sheet, not D2 as a whole: created where the
/// sheet's own `BlocProvider` is placed (once that sheet widget exists),
/// not registered in `di.config.dart`.
class SeasonCubit extends Cubit<SeasonState> {
  SeasonCubit(this._mediaRepository) : super(const SeasonInitial());

  final MediaRepository _mediaRepository;

  Future<void> loadSeason(int tvId, int seasonNumber) async {
    emit(const SeasonLoading());

    final result = await _mediaRepository.season(tvId, seasonNumber);
    switch (result) {
      case Success<SeasonDetail>(:final value):
        emit(SeasonLoaded(value));
      case Failure<SeasonDetail>(:final message):
        emit(SeasonError(message));
    }
  }
}
