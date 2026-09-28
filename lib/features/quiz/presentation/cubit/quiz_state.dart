import '../../../../core/domain/entities/discover_filter.dart'
    show DiscoverTvStatus;
import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/media_type.dart';

/// E2 (Quiz)'s own draft state across all 4 steps — `docs/SCREENS.md` E2.
/// One flat class, not a sealed per-step hierarchy: E2's own back button
/// means every previous step's answer must still be there when the user
/// returns to it, so [step] is just a field sitting on top of every
/// answer collected so far, not a state transition that discards
/// anything.
class QuizState {
  const QuizState({
    required this.mediaType,
    this.step = 1,
    this.excludedGenres = const {},
    this.vibeIds = const {},
    this.yearFrom = defaultYearFrom,
    this.maxRuntimeMinutes,
    this.tvStatus,
    this.maxSeasons,
    this.excludeWatched = false,
  });

  /// No doc gives an explicit default for "how far back" — reuses
  /// `MyTastesState.defaultYearFrom`'s own choice for the identical
  /// slider (H8/C5/E2 all share the same 1950–present range), rather
  /// than inventing a second value.
  static const int defaultYearFrom = 1990;

  static const int maxExcludedGenres = 3;
  static const int requiredVibeCount = 3;

  /// Fixed for the whole quiz session — never part of [copyWith].
  final MediaType mediaType;

  /// 1–4, matching E2's own "Step X of 4" indicator.
  final int step;

  /// Step 1: "Pick up to 3 you're NOT in the mood for" — up to
  /// [maxExcludedGenres]. The cap is enforced by `QuizCubit
  /// .toggleExcludedGenre`, not here: a plain data class has no reason
  /// to reject an already-invalid value if one somehow arrived.
  final Set<Genre> excludedGenres;

  /// Step 2: "pick 3 you ARE in the mood for" — `Vibe.id` values. Stays
  /// decoupled from `VibeCatalog`: this only ever needs the ids the user
  /// picked, never the full catalog used to enumerate them (that's
  /// whichever screen renders the vibe grid).
  final Set<String> vibeIds;

  /// Step 3: "How far back do you want to go?" (1950–present).
  final int yearFrom;

  /// Step 4, movie sessions only — "Max runtime" slider (60–240 min,
  /// "No limit" at the far end). `null` = "No limit", matching
  /// `MaxRuntimeFilter`'s own convention for the identical control.
  final int? maxRuntimeMinutes;

  /// Step 4, TV sessions only — "Finished | Either" toggle. `null` =
  /// "Either"; [DiscoverTvStatus.ended] = "Finished". Reuses
  /// `DiscoverTvStatus` rather than a near-duplicate type — the same
  /// call `ParticipantAnswers.tvStatus`'s own doc comment already makes;
  /// this quiz never produces [DiscoverTvStatus.airing] either.
  final DiscoverTvStatus? tvStatus;

  /// Step 4, TV sessions only — "Max seasons" stepper (1–10, "No
  /// limit"). `null` = "No limit", same convention as
  /// [maxRuntimeMinutes].
  final int? maxSeasons;

  /// Step 4's "discreet toggle, not a question" — "Exclude what I've
  /// already watched".
  final bool excludeWatched;

  /// What the "Next" button's "disabled until the step's rule is met"
  /// binds to. Step 1 is always valid ("up to 3" allows 0); step 2 needs
  /// *exactly* 3, not "up to 3"; steps 3/4 always already hold a real
  /// value (a slider/toggle default), so there's nothing to withhold
  /// "Next" for.
  bool get isCurrentStepValid => switch (step) {
    2 => vibeIds.length == requiredVibeCount,
    _ => true,
  };

  /// [maxRuntimeMinutes]/[tvStatus]/[maxSeasons] take a *function*
  /// returning the new value, not the value itself — same sentinel idiom
  /// `DiscoverFilter.copyWith`/`MatchQuery.copyWith` already use, and for
  /// the same reason: the usual `?? this.x` shortcut can't tell "leave
  /// this alone" apart from "clear it to null" for an already-nullable
  /// field. Every other field here always holds a real value, so the
  /// plain `?? this.x` form is unambiguous for them.
  QuizState copyWith({
    int? step,
    Set<Genre>? excludedGenres,
    Set<String>? vibeIds,
    int? yearFrom,
    int? Function()? maxRuntimeMinutes,
    DiscoverTvStatus? Function()? tvStatus,
    int? Function()? maxSeasons,
    bool? excludeWatched,
  }) {
    return QuizState(
      mediaType: mediaType,
      step: step ?? this.step,
      excludedGenres: excludedGenres ?? this.excludedGenres,
      vibeIds: vibeIds ?? this.vibeIds,
      yearFrom: yearFrom ?? this.yearFrom,
      maxRuntimeMinutes: maxRuntimeMinutes == null
          ? this.maxRuntimeMinutes
          : maxRuntimeMinutes(),
      tvStatus: tvStatus == null ? this.tvStatus : tvStatus(),
      maxSeasons: maxSeasons == null ? this.maxSeasons : maxSeasons(),
      excludeWatched: excludeWatched ?? this.excludeWatched,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is QuizState &&
      other.mediaType == mediaType &&
      other.step == step &&
      _setEquals(other.excludedGenres, excludedGenres) &&
      _setEquals(other.vibeIds, vibeIds) &&
      other.yearFrom == yearFrom &&
      other.maxRuntimeMinutes == maxRuntimeMinutes &&
      other.tvStatus == tvStatus &&
      other.maxSeasons == maxSeasons &&
      other.excludeWatched == excludeWatched;

  @override
  int get hashCode => Object.hash(
    mediaType,
    step,
    Object.hashAllUnordered(excludedGenres),
    Object.hashAllUnordered(vibeIds),
    yearFrom,
    maxRuntimeMinutes,
    tvStatus,
    maxSeasons,
    excludeWatched,
  );

  @override
  String toString() =>
      'QuizState(mediaType: $mediaType, step: $step, '
      'excludedGenres: $excludedGenres, vibeIds: $vibeIds, '
      'yearFrom: $yearFrom, maxRuntimeMinutes: $maxRuntimeMinutes, '
      'tvStatus: $tvStatus, maxSeasons: $maxSeasons, '
      'excludeWatched: $excludeWatched)';
}

/// Order-independent set content equality — same local stand-in used
/// throughout this codebase (e.g. `DiscoverFilter`, `MatchQuery`) for
/// `package:collection`'s `SetEquality`.
bool _setEquals<T>(Set<T> a, Set<T> b) =>
    a.length == b.length && a.containsAll(b);
