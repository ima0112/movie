import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/repositories/media_repository.dart';

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
  const MovieDetailLoaded(this.detail);

  final MediaDetail detail;
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
  MovieDetailCubit(this._mediaRepository) : super(const MovieDetailInitial());

  final MediaRepository _mediaRepository;

  Future<void> loadDetail(MediaKey key) async {
    emit(const MovieDetailLoading());

    final result = await _mediaRepository.detail(key);
    switch (result) {
      case Success<MediaDetail>(:final value):
        emit(MovieDetailLoaded(value));
      case Failure<MediaDetail>(:final reason):
        emit(MovieDetailError(reason));
    }
  }
}
