import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/app_settings.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/trailer_item.dart';
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

/// One lazily-loaded block of Discover: a named carousel or the trailers.
sealed class DiscoverSlot<T> {
  const DiscoverSlot();
}

final class DiscoverSlotLoading<T> extends DiscoverSlot<T> {
  const DiscoverSlotLoading();
}

final class DiscoverSlotLoaded<T> extends DiscoverSlot<T> {
  const DiscoverSlotLoaded(this.value);

  final T value;
}

final class DiscoverSlotError<T> extends DiscoverSlot<T> {
  const DiscoverSlotError(this.reason);

  final FailureReason reason;
}

/// The hero is ready for [segment]; the carousels fill in as they are
/// requested (CLAUDE.md rule 17).
final class DiscoverLoaded extends DiscoverState {
  const DiscoverLoaded({
    required this.segment,
    required this.heroItems,
    this.carousels = const {},
    this.trailers,
  });

  final MediaSegment segment;
  final List<MediaItem> heroItems;

  /// Only the carousels that have been requested; absent = not asked yet
  /// (which reads as loading) — see `docs/SCREENS.md` B1.
  final Map<CarouselSection, DiscoverSlot<List<MediaItem>>> carousels;

  /// "Latest trailers"; `null` until requested.
  final DiscoverSlot<List<TrailerItem>>? trailers;

  DiscoverLoaded copyWith({
    Map<CarouselSection, DiscoverSlot<List<MediaItem>>>? carousels,
    DiscoverSlot<List<TrailerItem>>? trailers,
  }) => DiscoverLoaded(
    segment: segment,
    heroItems: heroItems,
    carousels: carousels ?? this.carousels,
    trailers: trailers ?? this.trailers,
  );
}

/// The load for [segment] failed.
final class DiscoverError extends DiscoverState {
  const DiscoverError({required this.segment, required this.reason});

  final MediaSegment segment;
  final FailureReason reason;
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
      CarouselSection.comingSoon,
      CarouselSection.inTheaters,
      CarouselSection.watchLater,
    ],
    MediaSegment.movie: [
      CarouselSection.trending,
      CarouselSection.topRated,
      CarouselSection.upcoming,
    ],
    MediaSegment.tvShow: [
      CarouselSection.airingNow,
      CarouselSection.finishedShows,
      CarouselSection.topRated,
      CarouselSection.popular,
    ],
  };

  /// Bumped by every [loadDiscover]; a slot response from an earlier load
  /// (another segment, or before a locale change) is dropped.
  int _generation = 0;

  /// Loads the hero for [segment]. The carousels are *not* fetched here: each
  /// asks for itself through [requestSection] / [requestTrailers] as it nears
  /// the viewport (CLAUDE.md rule 17).
  Future<void> loadDiscover(MediaSegment segment) async {
    final generation = ++_generation;
    emit(DiscoverLoading(segment));

    final heroResult = await _mediaRepository.getHeroItems(
      type: segment.mediaType,
    );
    if (generation != _generation || isClosed) return;
    switch (heroResult) {
      case Success<List<MediaItem>>(:final value):
        emit(DiscoverLoaded(segment: segment, heroItems: value));
      case Failure<List<MediaItem>>(:final reason):
        emit(DiscoverError(segment: segment, reason: reason));
    }
  }

  /// Loads [section] for the segment on screen, once. Idempotent.
  Future<void> requestSection(CarouselSection section) async {
    final current = state;
    if (current is! DiscoverLoaded || current.carousels.containsKey(section)) {
      return;
    }
    await _loadSection(section);
  }

  Future<void> retrySection(CarouselSection section) async {
    if (state is! DiscoverLoaded) return;
    await _loadSection(section);
  }

  Future<void> _loadSection(CarouselSection section) async {
    final generation = _generation;
    final segment = (state as DiscoverLoaded).segment;
    _putSection(section, const DiscoverSlotLoading());
    final result = await _mediaRepository.getCarouselSection(
      section,
      type: segment.mediaType,
    );
    if (generation != _generation || isClosed) return;
    _putSection(section, switch (result) {
      Success<List<MediaItem>>(:final value) => DiscoverSlotLoaded(value),
      Failure<List<MediaItem>>(:final reason) => DiscoverSlotError(reason),
    });
  }

  void _putSection(
    CarouselSection section,
    DiscoverSlot<List<MediaItem>> slot,
  ) {
    final current = state;
    if (current is! DiscoverLoaded) return;
    emit(current.copyWith(carousels: {...current.carousels, section: slot}));
  }

  /// "Latest trailers", loaded once on demand (the All segment).
  Future<void> requestTrailers() async {
    final current = state;
    if (current is! DiscoverLoaded || current.trailers != null) return;
    await _loadTrailers();
  }

  Future<void> retryTrailers() async {
    if (state is DiscoverLoaded) await _loadTrailers();
  }

  Future<void> _loadTrailers() async {
    final generation = _generation;
    _putTrailers(const DiscoverSlotLoading());
    final result = await _mediaRepository.latestTrailers();
    if (generation != _generation || isClosed) return;
    _putTrailers(switch (result) {
      Success<List<TrailerItem>>(:final value) => DiscoverSlotLoaded(value),
      Failure<List<TrailerItem>>(:final reason) => DiscoverSlotError(reason),
    });
  }

  void _putTrailers(DiscoverSlot<List<TrailerItem>> slot) {
    final current = state;
    if (current is DiscoverLoaded) emit(current.copyWith(trailers: slot));
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
