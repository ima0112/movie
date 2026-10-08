import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/repositories/media_repository.dart';

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
  TvDetailCubit(this._mediaRepository) : super(const TvDetailInitial());

  final MediaRepository _mediaRepository;

  Future<void> loadDetail(MediaKey key) async {
    emit(const TvDetailLoading());

    final result = await _mediaRepository.detail(key);
    switch (result) {
      case Success<MediaDetail>(:final value):
        emit(TvDetailLoaded(value));
      case Failure<MediaDetail>(:final reason):
        emit(TvDetailError(reason));
    }
  }
}
