import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/app_settings.dart';
import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../../../core/domain/repositories/taste_profile_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../match_engine/domain/vibe_catalog.dart';
import '../../domain/recommendation_builder.dart';

/// Which of [RecommendationsState]'s two independent slots a call
/// targets — CLAUDE.md rule 9: loading/retrying one never touches the
/// other.
enum RecommendationSlot { forYou, becauseYouLike }

/// One slot's own load state.
sealed class RecommendationSectionState {
  const RecommendationSectionState();
}

final class RecommendationSectionLoading extends RecommendationSectionState {
  const RecommendationSectionLoading();
}

/// No usable signal (`RecommendationBuilder.forYouFilter`/
/// `.becauseYouLikeSeed` returned `null`), or the result fell below
/// `RecommendationBuilder.minRecommendationCount` once filtered — never
/// shown as an empty or generic carousel (`docs/DECISIONS.md` F1b).
final class RecommendationSectionHidden extends RecommendationSectionState {
  const RecommendationSectionHidden();
}

final class RecommendationSectionError extends RecommendationSectionState {
  const RecommendationSectionError(this.reason);

  final FailureReason reason;
}

final class RecommendationSectionLoaded extends RecommendationSectionState {
  const RecommendationSectionLoaded(this.items, {this.seedTitle});

  final List<MediaItem> items;

  /// Set for [RecommendationSlot.becauseYouLike] only — B1's "Because
  /// you like {title}" header (CLAUDE.md rule 15: a typed placeholder,
  /// never baked into pre-formatted text here).
  final String? seedTitle;
}

class RecommendationsState {
  const RecommendationsState({
    required this.segment,
    required this.forYou,
    required this.becauseYouLike,
  });

  final MediaSegment segment;
  final RecommendationSectionState forYou;
  final RecommendationSectionState becauseYouLike;

  RecommendationsState copyWith({
    RecommendationSectionState? forYou,
    RecommendationSectionState? becauseYouLike,
  }) => RecommendationsState(
    segment: segment,
    forYou: forYou ?? this.forYou,
    becauseYouLike: becauseYouLike ?? this.becauseYouLike,
  );
}

/// B1's "For you"/"Because you like X" — `docs/DECISIONS.md` section
/// 5/F1b. Deliberately separate from `DiscoverCubit`: that Cubit fetches
/// its 8 named carousels in one sequential loop and emits a single
/// `DiscoverLoaded` at the end — a failure in any one of them fails the
/// whole segment, with no independent retry. These two sections need
/// their own loading/error/retry per CLAUDE.md rule 9, so rather than
/// reworking that loop (and risking the 8 sections that already work),
/// they get their own Cubit with its own two independent slots.
///
/// Reload triggers, exactly 3, no others:
/// 1. **Language/region change** — same `SettingsRepository.watch()
///    .distinct().skip(1)` pattern `DiscoverCubit` already uses.
/// 2. **Pull-to-refresh** — `DiscoverContentLoaded`'s own
///    `RefreshIndicator.onRefresh` calls [refresh] alongside
///    `DiscoverCubit.loadDiscover`.
/// 3. **Returning from a pushed detail screen** — `DiscoverScreen`'s own
///    `RouteAware.didPopNext` calls [refresh].
///
/// Switching bottom tabs away and back does **not** reload — B1 lives
/// under a `StatefulShellRoute.indexedStack` (`app/root_shell.dart`),
/// which keeps every branch's widget tree (and this Cubit) alive
/// without rebuilding it, so there's no lifecycle event to hook into
/// for that case. Documented as a known, accepted gap in
/// `docs/SCREENS.md` B1 rather than solved with a fragile workaround.
///
/// A library change (a new favorite, a new rating) does **not** reload
/// either, by design — only the 3 triggers above do.
///
/// [refresh] never re-fetches over the network unless the *derived*
/// request (the `DiscoverFilter` "For you" would send, or the seed key
/// "Because you like X" would use) actually changed since the last
/// fetch — comparing the cheap, local derivation (`RecommendationBuilder`,
/// no network) is what makes "reload on language change" and "reload on
/// pull-to-refresh" both cheap when nothing relevant to either section
/// has actually changed, rather than always re-hitting TMDB.
class RecommendationsCubit extends Cubit<RecommendationsState> {
  RecommendationsCubit(
    this._mediaRepository,
    this._userLibraryRepository,
    this._tasteProfileRepository,
    this._settingsRepository,
    FutureOr<VibeCatalog> vibeCatalog,
  ) : _vibeCatalog = Future.value(vibeCatalog),
      super(
        const RecommendationsState(
          segment: MediaSegment.all,
          forYou: RecommendationSectionLoading(),
          becauseYouLike: RecommendationSectionLoading(),
        ),
      ) {
    _settingsSubscription = _settingsRepository
        .watch()
        .distinct()
        .skip(1)
        .listen((_) => unawaited(refresh()));
  }

  final MediaRepository _mediaRepository;
  final UserLibraryRepository _userLibraryRepository;
  final TasteProfileRepository _tasteProfileRepository;
  final SettingsRepository _settingsRepository;
  final Future<VibeCatalog> _vibeCatalog;
  late final StreamSubscription<AppSettings> _settingsSubscription;

  RecommendationBuilder? _cachedBuilder;

  /// [VibeCatalog.loadFromAssets] is async (reads `assets/vibes.json`)
  /// but `BlocProvider.create` must build this Cubit synchronously —
  /// same constraint `MyTastesScreen`/`QuizScreen` already solve with
  /// their own `FutureBuilder<VibeCatalog>`. Resolving it lazily here
  /// instead means `DiscoverScreen` can provide this Cubit the same
  /// synchronous way it already provides `DiscoverCubit`, with no
  /// second loading state blocking the rest of B1 — only these two
  /// sections wait on it, and only once, ever (cached after the first
  /// resolve).
  Future<RecommendationBuilder> get _builder async =>
      _cachedBuilder ??= RecommendationBuilder(await _vibeCatalog);

  /// What "For you" last actually fetched with, for [refresh]'s own
  /// "skip if nothing changed" check. Reset to `null` by [load] (a
  /// segment switch always re-fetches, since the filter's own `type`
  /// differs).
  DiscoverFilter? _lastForYouFilter;

  /// Same idea as [_lastForYouFilter], for "Because you like X"'s seed.
  MediaKey? _lastSeedKey;

  Future<void> load(MediaSegment segment) async {
    _lastForYouFilter = null;
    _lastSeedKey = null;
    emit(
      RecommendationsState(
        segment: segment,
        forYou: const RecommendationSectionLoading(),
        becauseYouLike: const RecommendationSectionLoading(),
      ),
    );
    await Future.wait([_runForYou(segment), _runBecauseYouLike(segment)]);
  }

  /// Re-derives both sections' requests for the *current* segment and
  /// only re-fetches whichever one actually changed — see this class's
  /// own doc comment.
  Future<void> refresh() async {
    final segment = state.segment;
    await Future.wait([_runForYou(segment), _runBecauseYouLike(segment)]);
  }

  Future<void> retry(RecommendationSlot slot) async {
    switch (slot) {
      case RecommendationSlot.forYou:
        _lastForYouFilter = null;
        emit(state.copyWith(forYou: const RecommendationSectionLoading()));
        await _runForYou(state.segment);
      case RecommendationSlot.becauseYouLike:
        _lastSeedKey = null;
        emit(
          state.copyWith(becauseYouLike: const RecommendationSectionLoading()),
        );
        await _runBecauseYouLike(state.segment);
    }
  }

  Future<void> _runForYou(MediaSegment segment) async {
    final builder = await _builder;
    final profile = await _tasteProfileRepository.watch().first;
    final libraryResult = await _userLibraryRepository.all();
    final library = switch (libraryResult) {
      Success<List<UserMediaEntry>>(:final value) => value,
      Failure<List<UserMediaEntry>>() => const <UserMediaEntry>[],
    };

    final filter = builder.forYouFilter(
      profile: profile,
      libraryEntries: library,
      type: segment.mediaType,
    );

    if (filter == null) {
      _lastForYouFilter = null;
      if (isClosed) return;
      emit(state.copyWith(forYou: const RecommendationSectionHidden()));
      return;
    }

    if (filter == _lastForYouFilter) return; // nothing relevant changed

    if (isClosed) return;
    emit(state.copyWith(forYou: const RecommendationSectionLoading()));

    final result = await _mediaRepository.discover(filter);
    if (isClosed) return;
    switch (result) {
      case Success<List<MediaItem>>(:final value):
        final libraryKeys = library.map((e) => e.key).toSet();
        final filtered = builder.filterAndThreshold(value, libraryKeys);
        _lastForYouFilter = filter;
        emit(
          state.copyWith(
            forYou: filtered == null
                ? const RecommendationSectionHidden()
                : RecommendationSectionLoaded(filtered),
          ),
        );
      case Failure<List<MediaItem>>(:final reason):
        emit(state.copyWith(forYou: RecommendationSectionError(reason)));
    }
  }

  Future<void> _runBecauseYouLike(MediaSegment segment) async {
    final builder = await _builder;
    final libraryResult = await _userLibraryRepository.all();
    final library = switch (libraryResult) {
      Success<List<UserMediaEntry>>(:final value) => value,
      Failure<List<UserMediaEntry>>() => const <UserMediaEntry>[],
    };

    final seed = builder.becauseYouLikeSeed(
      libraryEntries: library,
      type: segment.mediaType,
    );

    if (seed == null) {
      _lastSeedKey = null;
      if (isClosed) return;
      emit(state.copyWith(becauseYouLike: const RecommendationSectionHidden()));
      return;
    }

    if (seed.key == _lastSeedKey) return; // nothing relevant changed

    if (isClosed) return;
    emit(state.copyWith(becauseYouLike: const RecommendationSectionLoading()));

    final result = await _mediaRepository.recommendationsFor(seed.key);
    if (isClosed) return;
    switch (result) {
      case Success<List<MediaItem>>(:final value):
        final libraryKeys = library.map((e) => e.key).toSet();
        final filtered = builder.filterAndThreshold(value, libraryKeys);
        _lastSeedKey = seed.key;
        emit(
          state.copyWith(
            becauseYouLike: filtered == null
                ? const RecommendationSectionHidden()
                : RecommendationSectionLoaded(filtered, seedTitle: seed.title),
          ),
        );
      case Failure<List<MediaItem>>(:final reason):
        emit(
          state.copyWith(becauseYouLike: RecommendationSectionError(reason)),
        );
    }
  }

  @override
  Future<void> close() {
    unawaited(_settingsSubscription.cancel());
    return super.close();
  }
}
