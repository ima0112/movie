import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/app_settings.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/settings_repository.dart';

/// Discover's (B1) load state.
sealed class DiscoverState {
  const DiscoverState();
}

/// Nothing loaded yet — before the first [DiscoverCubit.loadDiscover] call.
final class DiscoverInitial extends DiscoverState {
  const DiscoverInitial();
}

/// Fetching the hero and carousels for [segment].
final class DiscoverLoading extends DiscoverState {
  const DiscoverLoading(this.segment);

  final MediaSegment segment;
}

/// Hero + carousels ready for [segment].
final class DiscoverLoaded extends DiscoverState {
  const DiscoverLoaded({
    required this.segment,
    required this.heroItems,
    required this.carousels,
  });

  final MediaSegment segment;
  final List<MediaItem> heroItems;

  /// One entry per carousel shown for [segment], in display order — see
  /// `docs/SCREENS.md` B1.
  final Map<CarouselSection, List<MediaItem>> carousels;
}

/// The load for [segment] failed.
final class DiscoverError extends DiscoverState {
  const DiscoverError({required this.segment, required this.message});

  final MediaSegment segment;
  final String message;
}

/// Loads Discover's (B1) hero and named carousels for whichever segment
/// (All / Movies / TV Shows) is selected.
///
/// Source of truth: `docs/SCREENS.md` B1 (Discover) and `docs/STRUCTURE.md`
/// ("One `Cubit` ... per screen in `presentation/`").
///
/// Takes its [MediaRepository] by constructor — per `docs/STRUCTURE.md`'s
/// DI row, Cubits are never annotated/registered in `getIt` themselves;
/// the screen that builds this one resolves the repository and passes it
/// in.
///
/// Also subscribes to [SettingsRepository.watch] so a language/region
/// change (F11) refreshes whatever segment is currently showing — this
/// Cubit's own data is the only thing that goes stale on a locale
/// change; nothing in the widget tree needs to react itself (CLAUDE.md
/// rule 9 is about widget rebuild scope, not about this). The
/// subscription is cancelled in [close] — a Cubit used after it's
/// closed is a real failure this app has already hit once.
class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit(this._mediaRepository, this._settingsRepository)
    : super(const DiscoverInitial()) {
    // `.distinct()` ignores a settings emission that doesn't actually
    // change language/region (AppSettings' own `==` compares both
    // fields); `.skip(1)` drops the very first emission, which is just
    // the already-current value `SettingsRepository.watch` replays on
    // subscribe, not an actual change.
    _settingsSubscription = _settingsRepository
        .watch()
        .distinct()
        .skip(1)
        .listen(_onSettingsChanged);
  }

  final MediaRepository _mediaRepository;
  final SettingsRepository _settingsRepository;
  late final StreamSubscription<AppSettings> _settingsSubscription;

  /// The named carousels shown per segment — see `docs/SCREENS.md` B1.
  /// `forYou` and `becauseYouLike` aren't included yet: they need a taste
  /// profile this Cubit has no way to read (no `TasteProfileRepository`
  /// yet). Public so the screen can know which sections a segment has
  /// (and render their skeletons) before any data has arrived.
  static const Map<MediaSegment, List<CarouselSection>> sectionsBySegment = {
    MediaSegment.all: [
      CarouselSection.popularThisWeek,
      CarouselSection.watchLater,
    ],
    MediaSegment.movie: [
      CarouselSection.inTheaters,
      CarouselSection.trending,
      CarouselSection.topRated,
      CarouselSection.upcoming,
    ],
    MediaSegment.tvShow: [
      CarouselSection.airingNow,
      CarouselSection.trending,
      CarouselSection.topRated,
      CarouselSection.popular,
    ],
  };

  Future<void> loadDiscover(MediaSegment segment) async {
    emit(DiscoverLoading(segment));

    final heroResult = await _mediaRepository.getHeroItems(
      type: segment.mediaType,
    );
    final List<MediaItem> heroItems;
    switch (heroResult) {
      case Success<List<MediaItem>>(:final value):
        heroItems = value;
      case Failure<List<MediaItem>>(:final message):
        emit(DiscoverError(segment: segment, message: message));
        return;
    }

    final carousels = <CarouselSection, List<MediaItem>>{};
    for (final section in sectionsBySegment[segment]!) {
      final result = await _mediaRepository.getCarouselSection(
        section,
        type: segment.mediaType,
      );
      switch (result) {
        case Success<List<MediaItem>>(:final value):
          carousels[section] = value;
        case Failure<List<MediaItem>>(:final message):
          emit(DiscoverError(segment: segment, message: message));
          return;
      }
    }

    emit(
      DiscoverLoaded(
        segment: segment,
        heroItems: heroItems,
        carousels: carousels,
      ),
    );
  }

  /// Whichever segment is currently showing (loading, loaded, or
  /// errored) — `null` before the very first [loadDiscover] call, in
  /// which case there's nothing yet for a locale change to refresh.
  MediaSegment? get _currentSegment => switch (state) {
    DiscoverInitial() => null,
    DiscoverLoading(:final segment) => segment,
    DiscoverLoaded(:final segment) => segment,
    DiscoverError(:final segment) => segment,
  };

  void _onSettingsChanged(AppSettings _) {
    if (isClosed) return;
    final segment = _currentSegment;
    if (segment != null) unawaited(loadDiscover(segment));
  }

  @override
  Future<void> close() {
    unawaited(_settingsSubscription.cancel());
    return super.close();
  }
}
