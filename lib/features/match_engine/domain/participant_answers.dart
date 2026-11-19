import '../../../core/domain/entities/discover_filter.dart'
    show DiscoverTvStatus;
import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/media_key.dart';

/// One person's answers to the Matcher/Surprise-me questionnaire —
/// `docs/DECISIONS.md` section 5 ("Questionnaire (`ParticipantAnswers`)").
/// Shared by both flows: "Used by both Surprise me (N=1, local) and the
/// Matcher (N≥2, Firebase)".
///
/// One instance per person, for whichever `MediaType` the session already
/// picked (F1's "What are you watching?", E1's own type choice) — that
/// type isn't part of this answer set, it's `MatchQuery.aggregate`'s own
/// separate parameter, common to every participant in the same room.
///
/// [maxRuntimeMinutes] only means anything for a movie session;
/// [tvStatus]/[maxSeasons] only for a TV one — E2's own step 4 is
/// conditional per type ("Movie: 'Max runtime' slider... TV show:
/// 'Finished | Either' toggle + 'Max seasons' stepper"). Nothing here
/// enforces that split; whichever quiz screen builds this only ever
/// fills the branch matching its own session type.
class ParticipantAnswers {
  const ParticipantAnswers({
    required this.participantId,
    this.excludedGenres = const {},
    this.vibeIds = const {},
    required this.yearFrom,
    this.maxRuntimeMinutes,
    this.tvStatus,
    this.maxSeasons,
    this.excludeWatched = false,
    this.watchedKeys = const {},
    this.yearTo,
    this.platformIds = const {},
    this.includeRentBuy = false,
    this.collectionIds = const {},
  });

  final String participantId;

  /// E2 step 1: "Pick up to 3 you're NOT in the mood for" — a hard veto,
  /// unioned across participants (`docs/DECISIONS.md`'s own aggregation
  /// table: "Genres I do NOT want... Union").
  final Set<Genre> excludedGenres;

  /// E2 step 2: "pick 3 you ARE in the mood for" — `Vibe.id` values, not
  /// full `Vibe` objects. Stays decoupled from `VibeCatalog`: resolving
  /// an id back to a `Vibe` is whoever scores candidates' job, not this
  /// value object's.
  final Set<String> vibeIds;

  /// E2 step 3: "How far back do you want to go?" — the earliest year
  /// this participant will accept, inclusive. A single lower bound, not
  /// a range: `docs/DECISIONS.md`'s own aggregation rule ("Max of the
  /// minimums") only makes sense for one bound per person.
  final int yearFrom;

  /// Movie sessions only — E2 step 4's "Max runtime" slider (60–240 min,
  /// "No limit" at the far end). `null` = no limit, the same "unset"
  /// convention H8's own `MaxRuntimeFilter` already uses.
  final int? maxRuntimeMinutes;

  /// TV sessions only — E2 step 4's "Finished | Either" toggle. Reuses
  /// `DiscoverTvStatus` (H8's own airing/ended vocabulary) rather than a
  /// near-duplicate type, even though the quiz itself only ever produces
  /// [DiscoverTvStatus.ended] ("Finished") or `null` ("Either") — it
  /// never offers "only Airing" the way H8 does. `MatchQuery.aggregate`
  /// only ever checks for `ended`.
  final DiscoverTvStatus? tvStatus;

  /// TV sessions only — E2 step 4's "Max seasons" stepper (1–10, "No
  /// limit"). `null` = no limit, same convention as [maxRuntimeMinutes].
  final int? maxSeasons;

  /// E2's own "discreet toggle, not a question" — "Exclude what I've
  /// already watched". `false` unless this participant explicitly
  /// enabled it (`docs/DECISIONS.md`: "Union of the lists of whoever
  /// enables it" — someone who leaves this off contributes nothing to
  /// the union, regardless of what [watchedKeys] holds).
  final bool excludeWatched;

  /// This participant's own watched keys — only meaningful, and only
  /// read by `MatchQuery.aggregate`, when [excludeWatched] is true.
  /// Sourced from `UserLibraryRepository`'s watched entries
  /// (`UserMediaEntry.key`) by whoever builds this — not this value
  /// object's job to fetch.
  final Set<MediaKey> watchedKeys;

  /// The latest year this participant will accept, inclusive — the "To"
  /// card of the quiz's year range. `null` = up to today (the open end).
  /// Only the Surprise-me engine reads it for now.
  final int? yearTo;

  /// The streaming services this participant has (TMDB provider ids, from
  /// `/watch/providers` for the user's region — never hardcoded). Empty =
  /// "All platforms": any service of the user's region (not just the dozen the
  /// quiz shows). A hard filter for the Surprise-me engine either way.
  final Set<int> platformIds;

  /// "Include rent and buy": also accept titles that are only rentable or
  /// buyable — on the picked [platformIds], or on any service of the region
  /// when none is picked — not just included in a subscription.
  final bool includeRentBuy;

  /// The quiz's first step: the collections (Turkish series, Anime…) this
  /// participant wants everything to come from — `Collection.id` values, at
  /// most [maxCollections]. Empty = "any". A hard filter for the Surprise-me
  /// engine, never relaxed; the Matcher (v1.1) does not read it yet.
  final Set<String> collectionIds;

  /// The most collections one search combines (their results are unioned).
  static const int maxCollections = 2;

  @override
  bool operator ==(Object other) =>
      other is ParticipantAnswers &&
      other.participantId == participantId &&
      _setEquals(other.excludedGenres, excludedGenres) &&
      _setEquals(other.vibeIds, vibeIds) &&
      other.yearFrom == yearFrom &&
      other.maxRuntimeMinutes == maxRuntimeMinutes &&
      other.tvStatus == tvStatus &&
      other.maxSeasons == maxSeasons &&
      other.excludeWatched == excludeWatched &&
      _setEquals(other.watchedKeys, watchedKeys) &&
      other.yearTo == yearTo &&
      _setEquals(other.platformIds, platformIds) &&
      other.includeRentBuy == includeRentBuy &&
      _setEquals(other.collectionIds, collectionIds);

  @override
  int get hashCode => Object.hash(
    participantId,
    Object.hashAllUnordered(excludedGenres),
    Object.hashAllUnordered(vibeIds),
    yearFrom,
    maxRuntimeMinutes,
    tvStatus,
    maxSeasons,
    excludeWatched,
    Object.hashAllUnordered(watchedKeys),
    yearTo,
    Object.hashAllUnordered(platformIds),
    includeRentBuy,
    Object.hashAllUnordered(collectionIds),
  );

  @override
  String toString() =>
      'ParticipantAnswers($participantId, excludedGenres: $excludedGenres, '
      'vibeIds: $vibeIds, yearFrom: $yearFrom, '
      'maxRuntimeMinutes: $maxRuntimeMinutes, tvStatus: $tvStatus, '
      'maxSeasons: $maxSeasons, excludeWatched: $excludeWatched, '
      'watchedKeys: $watchedKeys, yearTo: $yearTo, '
      'platformIds: $platformIds, includeRentBuy: $includeRentBuy, '
      'collectionIds: $collectionIds)';
}

/// Order-independent set content equality — same local stand-in for
/// `package:collection`'s `SetEquality` that `DiscoverFilter`/`TasteProfile`
/// already each have their own copy of, for the same reason (no new
/// dependency for just this).
bool _setEquals<T>(Set<T> a, Set<T> b) =>
    a.length == b.length && a.containsAll(b);
