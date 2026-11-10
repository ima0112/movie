import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../shared/widgets/media_detail_duration.dart';

/// Movie detail's (D1) load state.
sealed class MovieDetailState {
  const MovieDetailState();
}

/// Nothing loaded yet — before the first [MovieDetailCubit.loadDetail] call.
final class MovieDetailInitial extends MovieDetailState {
  const MovieDetailInitial();
}

/// Fetching the detail for the key passed to [MovieDetailCubit.loadDetail].
final class MovieDetailLoading extends MovieDetailState {
  const MovieDetailLoading();
}

/// Detail ready.
final class MovieDetailLoaded extends MovieDetailState {
  const MovieDetailLoaded(this.detail, {this.regionCode});

  final MediaDetail detail;

  /// The country picked on this screen for "Where to watch", or `null` for
  /// the saved (global) region. Lives only as long as this screen's Cubit.
  final String? regionCode;
}

/// The load failed.
final class MovieDetailError extends MovieDetailState {
  const MovieDetailError(this.reason);

  final FailureReason reason;
}

/// Loads a movie's full detail (D1) for the screen's `MediaKey`.
///
/// Source of truth: `docs/SCREENS.md` D1 (Movie detail) and
/// `docs/STRUCTURE.md` ("One `Cubit` ... per screen in `presentation/`").
///
/// Takes its [MediaRepository] by constructor — per `docs/STRUCTURE.md`'s
/// DI row, Cubits are never annotated/registered in `getIt` themselves;
/// the screen that builds this one resolves the repository and passes it
/// in.
class MovieDetailCubit extends Cubit<MovieDetailState> {
  MovieDetailCubit(this._mediaRepository, this._userLibraryRepository)
    : super(const MovieDetailInitial());

  final MediaRepository _mediaRepository;
  final UserLibraryRepository _userLibraryRepository;
  String? _regionCode;

  /// Shows [key] for [regionCode] on this screen only (providers and the
  /// certification are per region); the saved region is untouched, and
  /// leaving the screen drops the choice. Swapped in with no loading state so
  /// the scroll position stays; a failed read keeps what is on screen.
  Future<void> setRegion(MediaKey key, String regionCode) async {
    if (state is! MovieDetailLoaded) return;
    final result = await _mediaRepository.detail(key, regionCode: regionCode);
    if (isClosed) return;
    if (result case Success<MediaDetail>(:final value)) {
      _regionCode = regionCode;
      emit(MovieDetailLoaded(value, regionCode: regionCode));
    }
  }

  Future<void> loadDetail(MediaKey key) async {
    emit(const MovieDetailLoading());

    final result = await _mediaRepository.detail(key, regionCode: _regionCode);
    switch (result) {
      case Success<MediaDetail>(:final value):
        emit(MovieDetailLoaded(value, regionCode: _regionCode));
        await _refreshLibrarySnapshot(key, value);
      case Failure<MediaDetail>(:final reason):
        emit(MovieDetailError(reason));
    }
  }

  /// My List's own "refresh on open" (`docs/DECISIONS.md` section 4) —
  /// a no-op if nothing is saved at [key] yet. Catalog-only: never
  /// touches isFavorite/isWatchLater/watchedAt/rating, and never races
  /// a favorite/watch-later toggle landing on the same row (see
  /// `UserLibraryRepository.updateCatalogSnapshot`'s own doc comment).
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
