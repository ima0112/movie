import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/domain/entities/media_key.dart';
import '../../core/domain/entities/result.dart';
import '../../core/domain/entities/streaming_service.dart';
import '../../core/domain/repositories/media_repository.dart';

/// Which subscription services each poster of the "See all" listing is on —
/// the logo in a poster's corner when the listing isn't narrowed to a platform.
/// Screen-local (CLAUDE.md rule 10) and separate from the list itself, so a
/// logo arriving never rebuilds the grid.
///
/// There is no bulk call for this: each title costs one small request, so a
/// poster asks for its own only once it is built (the grid builds only what is
/// on or near the screen), [request] is idempotent, and what is learned is
/// kept in memory for the life of the screen. A title with none (or whose
/// lookup failed) is recorded as empty and simply shows no logo.
class ListingProvidersCubit
    extends Cubit<Map<MediaKey, List<StreamingService>>> {
  ListingProvidersCubit(this._mediaRepository) : super(const {});

  final MediaRepository _mediaRepository;
  final Set<MediaKey> _asked = {};

  Future<void> request(MediaKey key) async {
    if (!_asked.add(key)) return;
    final result = await _mediaRepository.streamingProvidersFor(key);
    if (isClosed) return;
    emit({
      ...state,
      key: switch (result) {
        Success(:final value) => value,
        Failure() => const <StreamingService>[],
      },
    });
  }
}
