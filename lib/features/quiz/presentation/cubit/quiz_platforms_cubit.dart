import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/streaming_service.dart';
import '../../../../core/domain/repositories/media_repository.dart';

sealed class QuizPlatformsState {
  const QuizPlatformsState();
}

final class QuizPlatformsLoading extends QuizPlatformsState {
  const QuizPlatformsLoading();
}

final class QuizPlatformsLoaded extends QuizPlatformsState {
  const QuizPlatformsLoaded(this.services);

  /// The region's top services, most relevant first. Can be empty (a region
  /// TMDB lists none for).
  final List<StreamingService> services;
}

final class QuizPlatformsError extends QuizPlatformsState {
  const QuizPlatformsError(this.reason);

  final FailureReason reason;
}

/// Loads the streaming services E2's platforms step offers: the user's region's
/// top [maxServices] for the kind of title being searched (the movie and TV
/// catalogues differ), in TMDB's own order there. Screen-local (CLAUDE.md
/// rule 10): created where the step's `BlocProvider` sits.
class QuizPlatformsCubit extends Cubit<QuizPlatformsState> {
  QuizPlatformsCubit(this._mediaRepository, this._mediaType)
    : super(const QuizPlatformsLoading()) {
    load();
  }

  final MediaRepository _mediaRepository;
  final MediaType _mediaType;

  /// A 3×4 grid.
  static const int maxServices = 12;

  Future<void> load() async {
    emit(const QuizPlatformsLoading());
    final result = await _mediaRepository.streamingServices(
      type: _mediaType,
      all: true,
    );
    if (isClosed) return;
    emit(switch (result) {
      Success(:final value) => QuizPlatformsLoaded(
        value.take(maxServices).toList(),
      ),
      Failure(:final reason) => QuizPlatformsError(reason),
    });
  }
}
