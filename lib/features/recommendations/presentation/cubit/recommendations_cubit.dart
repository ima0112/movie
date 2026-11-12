import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/app_settings.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../../../core/domain/repositories/taste_profile_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../match_engine/domain/vibe_catalog.dart';
import '../../domain/recommendation_builder.dart';
import '../../domain/recommendation_planner.dart';

/// Which of [RecommendationsState]'s three independent slots a call
/// targets — CLAUDE.md rule 9: loading/retrying one never touches the
/// other.
enum RecommendationSlot { forYou, becauseYouLike, becauseYouWant }

/// One slot's own load state.
sealed class RecommendationSectionState {
  const RecommendationSectionState();
}

final class RecommendationSectionLoading extends RecommendationSectionState {
  const RecommendationSectionLoading();
}

/// No signal today (`RecommendationPlanner` planned nothing for this slot),
/// or the result fell below
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
  const RecommendationSectionLoaded(this.items, {this.seed});

  final List<MediaItem> items;

  /// What a "Because you…" section is about (a title, a genre or a vibe) —
  /// the header is built from it by the view (CLAUDE.md rule 15: a typed
  /// placeholder, never pre-formatted text here). `null` for "For you".
  final BecauseSeed? seed;

  /// The seed's title, when it is a saved title.
  String? get seedTitle => switch (seed) {
    TitleSeed(:final entry) => entry.title,
    _ => null,
  };
}

class RecommendationsState {
  const RecommendationsState({
    required this.segment,
    required this.forYou,
    required this.becauseYouLike,
    required this.becauseYouWant,
  });

  final MediaSegment segment;
  final RecommendationSectionState forYou;
  final RecommendationSectionState becauseYouLike;

  /// The All tab's "Because you want {vibe}" — hidden in the other tabs.
  final RecommendationSectionState becauseYouWant;

  RecommendationsState copyWith({
    RecommendationSectionState? forYou,
    RecommendationSectionState? becauseYouLike,
    RecommendationSectionState? becauseYouWant,
  }) => RecommendationsState(
    segment: segment,
    forYou: forYou ?? this.forYou,
    becauseYouLike: becauseYouLike ?? this.becauseYouLike,
    becauseYouWant: becauseYouWant ?? this.becauseYouWant,
  );

  RecommendationSectionState slot(RecommendationSlot slot) => switch (slot) {
    RecommendationSlot.forYou => forYou,
    RecommendationSlot.becauseYouLike => becauseYouLike,
    RecommendationSlot.becauseYouWant => becauseYouWant,
  };
}

/// B1's "For you" / "Because you like …" / "Because you want …" —
/// `docs/DECISIONS.md` section 5/F1b. Deliberately separate from
/// `DiscoverCubit`: these sections have their own signal (tastes, My List) and
/// need their own loading/error/retry per CLAUDE.md rule 9, so each is an
/// independent slot.
///
/// **What each section shows is decided by [RecommendationPlanner]**, once
/// per day (a deterministic, day-stable rotation — see [DailyPicker]): the
/// All tab follows the taste profile, Movies/TV Shows follow My List. The
/// plan is recomputed (locally, no network) on every reload trigger, and a
/// slot only goes back to TMDB when its derived request actually changed —
/// so a new day, new tastes or a new My List entry give something new, while
/// an ordinary refresh costs nothing.
///
/// Reload triggers, exactly 3, no others:
/// 1. **Language/region change** — `SettingsRepository.watch()`.
/// 2. **Pull-to-refresh** — `DiscoverContentLoaded`'s own `RefreshIndicator`.
/// 3. **Returning from a pushed detail screen** — `DiscoverScreen`'s
///    `RouteAware.didPopNext` calls [refresh].
///
/// Switching bottom tabs away and back does **not** reload (the shell keeps
/// the branch alive, with no lifecycle event to hook) — a known, accepted gap.
class RecommendationsCubit extends Cubit<RecommendationsState> {
  RecommendationsCubit(
    this._mediaRepository,
    this._userLibraryRepository,
    this._tasteProfileRepository,
    this._settingsRepository,
    FutureOr<VibeCatalog> vibeCatalog, {
    DateTime Function()? clock,
  }) : _vibeCatalog = Future.value(vibeCatalog),
       _clock = clock ?? DateTime.now,
       super(
         const RecommendationsState(
           segment: MediaSegment.all,
           forYou: RecommendationSectionLoading(),
           becauseYouLike: RecommendationSectionLoading(),
           becauseYouWant: RecommendationSectionLoading(),
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
  final DateTime Function() _clock;
  late final StreamSubscription<AppSettings> _settingsSubscription;

  RecommendationBuilder? _cachedBuilder;
  RecommendationPlanner? _cachedPlanner;

  /// [VibeCatalog.loadFromAssets] is async but `BlocProvider.create` must
  /// build this Cubit synchronously, so it is resolved lazily here, once.
  Future<(RecommendationBuilder, RecommendationPlanner)> get _tools async {
    final catalog = await _vibeCatalog;
    return (
      _cachedBuilder ??= const RecommendationBuilder(),
      _cachedPlanner ??= RecommendationPlanner(catalog),
    );
  }

  /// What each slot last fetched with, for the "skip if nothing changed"
  /// check: a `DiscoverFilter` or a seed key. Reset by [load].
  final Map<RecommendationSlot, Object?> _last = {};

  Future<void> load(MediaSegment segment) async {
    _last.clear();
    emit(
      RecommendationsState(
        segment: segment,
        forYou: const RecommendationSectionLoading(),
        becauseYouLike: const RecommendationSectionLoading(),
        becauseYouWant: const RecommendationSectionLoading(),
      ),
    );
    await _runAll(segment);
  }

  /// Re-derives today's plan for the *current* segment and only re-fetches
  /// the slots whose request actually changed.
  Future<void> refresh() => _runAll(state.segment);

  Future<void> retry(RecommendationSlot slot) async {
    _last.remove(slot);
    emit(_withSlot(slot, const RecommendationSectionLoading()));
    await _runAll(state.segment, only: slot);
  }

  RecommendationsState _withSlot(
    RecommendationSlot slot,
    RecommendationSectionState value,
  ) => switch (slot) {
    RecommendationSlot.forYou => state.copyWith(forYou: value),
    RecommendationSlot.becauseYouLike => state.copyWith(becauseYouLike: value),
    RecommendationSlot.becauseYouWant => state.copyWith(becauseYouWant: value),
  };

  void _put(RecommendationSlot slot, RecommendationSectionState value) {
    if (!isClosed) emit(_withSlot(slot, value));
  }

  Future<void> _runAll(MediaSegment segment, {RecommendationSlot? only}) async {
    final (builder, planner) = await _tools;
    final profile = await _tasteProfileRepository.watch().first;
    final libraryResult = await _userLibraryRepository.all();
    final library = switch (libraryResult) {
      Success<List<UserMediaEntry>>(:final value) => value,
      Failure<List<UserMediaEntry>>() => const <UserMediaEntry>[],
    };
    final plan = planner.plan(
      type: segment.mediaType,
      profile: profile,
      library: library,
      today: _clock(),
    );
    final libraryKeys = library.map((e) => e.key).toSet();

    Future<void> run(
      RecommendationSlot slot,
      Object? request,
      Future<Result<List<MediaItem>>> Function() fetch,
      BecauseSeed? seed,
    ) async {
      if (only != null && only != slot) return;
      if (request == null) {
        _last.remove(slot);
        _put(slot, const RecommendationSectionHidden());
        return;
      }
      if (_last[slot] == request) return; // nothing relevant changed
      _put(slot, const RecommendationSectionLoading());
      final result = await fetch();
      if (isClosed || state.segment != segment) return;
      switch (result) {
        case Success<List<MediaItem>>(:final value):
          final filtered = builder.filterAndThreshold(value, libraryKeys);
          _last[slot] = request;
          _put(
            slot,
            filtered == null
                ? const RecommendationSectionHidden()
                : RecommendationSectionLoaded(filtered, seed: seed),
          );
        case Failure<List<MediaItem>>(:final reason):
          _put(slot, RecommendationSectionError(reason));
      }
    }

    final like = plan.becauseLike;
    final want = plan.becauseWant;
    await Future.wait([
      run(
        RecommendationSlot.forYou,
        plan.forYou,
        () => _mediaRepository.discover(plan.forYou!),
        null,
      ),
      run(
        RecommendationSlot.becauseYouLike,
        like == null ? null : _seedKey(like),
        () => switch (like) {
          TitleSeed(:final entry) => _mediaRepository.recommendationsFor(
            entry.key,
          ),
          _ => _mediaRepository.discover(planner.filterForSeed(like!, profile)),
        },
        like,
      ),
      run(
        RecommendationSlot.becauseYouWant,
        want == null ? null : _seedKey(want),
        () => _mediaRepository.discover(planner.filterForSeed(want!, profile)),
        want,
      ),
    ]);
  }

  /// A comparable identity for a seed (the request it makes).
  static String _seedKey(BecauseSeed seed) => switch (seed) {
    TitleSeed(:final entry) =>
      'title:${entry.key.type.name}:${entry.key.tmdbId}',
    GenreSeed(:final genre) => 'genre:${genre.id}',
    VibeSeed(:final vibe) => 'vibe:${vibe.id}',
  };

  @override
  Future<void> close() {
    unawaited(_settingsSubscription.cancel());
    return super.close();
  }
}
