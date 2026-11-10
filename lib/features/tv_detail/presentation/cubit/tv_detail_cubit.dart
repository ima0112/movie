import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../shared/widgets/media_detail_duration.dart';

/// TV show detail's (D2) load state — same shape as
/// `MovieDetailCubit`'s own `MovieDetailState` (D1).
sealed class TvDetailState {
  const TvDetailState();
}

/// Nothing loaded yet — before the first [TvDetailCubit.loadDetail] call.
final class TvDetailInitial extends TvDetailState {
  const TvDetailInitial();
}

/// Fetching the detail for the key passed to [TvDetailCubit.loadDetail].
final class TvDetailLoading extends TvDetailState {
  const TvDetailLoading();
}

/// Detail ready.
final class TvDetailLoaded extends TvDetailState {
  const TvDetailLoaded(this.detail);

  final MediaDetail detail;
}

/// The load failed.
final class TvDetailError extends TvDetailState {
  const TvDetailError(this.reason);

  final FailureReason reason;
}

/// Loads a TV show's full detail (D2) for the screen's `MediaKey`.
///
/// Source of truth: `docs/SCREENS.md` D2 (TV show detail) and
/// `docs/STRUCTURE.md` ("One `Cubit` ... per screen in `presentation/`").
///
/// Mirrors `MovieDetailCubit` (D1) exactly — same sealed states, same
/// single `loadDetail` method — rather than sharing one generic Cubit:
/// D1/D2 differ enough in which screen widgets a `MediaDetail` feeds
/// (`MovieDetailContent` is typed to `MovieDetail` specifically) that a
/// shared Cubit would need its own type-narrowing anyway, with no
/// benefit over two small, independently readable Cubits.
class TvDetailCubit extends Cubit<TvDetailState> {
  TvDetailCubit(this._mediaRepository, this._userLibraryRepository)
    : super(const TvDetailInitial());

  final MediaRepository _mediaRepository;
  final UserLibraryRepository _userLibraryRepository;

  /// Re-reads [key] after the region changed (providers and the certification
  /// are per region) and swaps it in with no loading state, so the screen
  /// keeps its scroll position. A failed refresh keeps what is on screen.
  Future<void> refreshForRegion(MediaKey key) async {
    if (state is! TvDetailLoaded) return;
    final result = await _mediaRepository.detail(key);
    if (isClosed) return;
    if (result case Success<MediaDetail>(:final value)) {
      emit(TvDetailLoaded(value));
    }
  }

  Future<void> loadDetail(MediaKey key) async {
    emit(const TvDetailLoading());

    final result = await _mediaRepository.detail(key);
    switch (result) {
      case Success<MediaDetail>(:final value):
        emit(TvDetailLoaded(value));
        await _refreshLibrarySnapshot(key, value);
      case Failure<MediaDetail>(:final reason):
        emit(TvDetailError(reason));
    }
  }

  /// See `MovieDetailCubit._refreshLibrarySnapshot`'s own doc comment —
  /// same mechanism, mirrored for D2.
  Future<void> _refreshLibrarySnapshot(MediaKey key, MediaDetail detail) async {
    final snapshot = catalogSnapshotFrom(detail.item);
    final duration = durationFieldsFrom(detail);
    await _userLibraryRepository.updateCatalogSnapshot(
      key,
      title: snapshot.title,
      genres: snapshot.genres,
      posterUrl: snapshot.posterUrl,
      voteAverage: snapshot.voteAverage,
      year: snapshot.year,
      runtimeMinutes: duration.runtimeMinutes,
      episodeCount: duration.episodeCount,
      episodeRuntimeMinutes: duration.episodeRuntimeMinutes,
    );
  }
}
