import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/streaming_service.dart';
import '../../../../core/domain/repositories/media_repository.dart';

/// What C5's "My platforms" can show.
sealed class TastePlatformsState {
  const TastePlatformsState();
}

final class TastePlatformsLoading extends TastePlatformsState {
  const TastePlatformsLoading();
}

final class TastePlatformsLoaded extends TastePlatformsState {
  const TastePlatformsLoaded(this.services);

  final List<StreamingService> services;
}

final class TastePlatformsError extends TastePlatformsState {
  const TastePlatformsError(this.reason);

  final FailureReason reason;
}

/// The streaming services of the user's region for C5's "My platforms"
/// (movies and TV shows merged), loaded once when the section appears.
///
/// **Screen-local** (CLAUDE.md rule 10): the list is only this section's
/// business. Which ones are picked is not here — that is
/// `MyTastesState.platformIds`, saved by `MyTastesCubit`.
class TastePlatformsCubit extends Cubit<TastePlatformsState> {
  TastePlatformsCubit(this._mediaRepository)
    : super(const TastePlatformsLoading()) {
    load();
  }

  final MediaRepository _mediaRepository;

  Future<void> load() async {
    emit(const TastePlatformsLoading());
    final result = await _mediaRepository.streamingServices();
    if (isClosed) return;
    emit(switch (result) {
      Success(:final value) => TastePlatformsLoaded(value),
      Failure(:final reason) => TastePlatformsError(reason),
    });
  }
}
