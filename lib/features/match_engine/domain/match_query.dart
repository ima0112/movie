import 'dart:math' as math;

import '../../../core/domain/entities/discover_filter.dart' show DiscoverTvStatus;
import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/media_key.dart';
import '../../../core/domain/entities/media_type.dart';
import 'participant_answers.dart';

/// The room's aggregated criteria for one fetch attempt — everything
/// `docs/DECISIONS.md` section 5 calls "the hard filters" plus the
/// vibe-scoring weights, combined from every [ParticipantAnswers] via
/// [aggregate]. Every field is `final`: a later relaxation step (see
/// `relaxation.dart`) produces a *new* `MatchQuery` rather than mutating
/// this one.
class MatchQuery {
  const MatchQuery({
    required this.mediaType,
    required this.excludedGenres,
    required this.vibeWeights,
    required this.vibeIdsByParticipant,
    required this.yearFrom,
    this.maxRuntimeMinutes,
    this.tvStatus,
    this.maxSeasons,
    required this.excludedWatchedKeys,
    required this.watchedByAnyone,
    this.voteCountGte = 200,
  });

  final MediaType mediaType;

  /// Union of every participant's [ParticipantAnswers.excludedGenres] —
  /// `docs/DECISIONS.md`: "Genres I do NOT want... Union" → maps to
  /// `without_genres`, a hard filter the relaxation ladder never touches.
  final Set<Genre> excludedGenres;

  /// `Vibe.id` → how many participants requested it — "Union with count
  /// (each person who picked it adds weight)". Whoever scores candidates
  /// resolves each id back to a `Vibe` via `VibeCatalog`; this stays
  /// decoupled from that catalog, same reasoning as
  /// [ParticipantAnswers.vibeIds].
  final Map<String, int> vibeWeights;

  /// Each participant's own [ParticipantAnswers.vibeIds], keyed by
  /// [ParticipantAnswers.participantId] — needed to compute
  /// `MatchResult.satisfaction` ("participant → % of their vibes met")
  /// once a winner is chosen. [vibeWeights] alone can't answer that: it
  /// only keeps the *aggregated* count per vibe, not which participant
  /// asked for which one. `resolve()` only ever receives a [MatchQuery],
  /// never the raw `List<ParticipantAnswers>` it came from, so this has
  /// to travel with it.
  final Map<String, Set<String>> vibeIdsByParticipant;

  /// "Max of the minimums (the most restrictive wins)" — the *highest*
  /// (most recent) `yearFrom` among participants: a higher lower bound
  /// is the more restrictive one.
  final int yearFrom;

  /// Movies only. "Minimum" — the *shortest* max runtime any participant
  /// asked for; `null` (no limit) only if every participant left it
  /// unset.
  final int? maxRuntimeMinutes;

  /// TV only. `ended` if *any* participant asked for "Finished"
  /// (`ParticipantAnswers.tvStatus == DiscoverTvStatus.ended`) —
  /// "Restrictive": requiring "already finished" is more restrictive
  /// than "Either" (`null`). The quiz never produces
  /// `DiscoverTvStatus.airing` (see `ParticipantAnswers.tvStatus`'s own
  /// doc comment), so that value never reaches this aggregation.
  final DiscoverTvStatus? tvStatus;

  /// TV only. "Restrictive" — the smallest max-seasons cap any
  /// participant asked for; `null` only if everyone left it unset.
  final int? maxSeasons;

  /// Union of every participant's own watched keys, but *only* from
  /// those with `excludeWatched == true` — "Union of the lists of
  /// whoever enables it".
  final Set<MediaKey> excludedWatchedKeys;

  /// Union of *every* participant's own watched keys, regardless of
  /// [ParticipantAnswers.excludeWatched] — the scoring formula's
  /// "penalty if someone has already seen it (when not fully excluded)"
  /// needs to know a candidate was watched by *anyone* even when nobody
  /// opted into the hard exclusion above. A candidate can be in both
  /// sets (hard-excluded *and* watched-by-someone-else) — that's fine,
  /// [excludedWatchedKeys] wins for it since a hard-excluded candidate
  /// never reaches scoring at all.
  final Set<MediaKey> watchedByAnyone;

  /// "Fetching candidates": "1–3 calls to `/discover/{movie|tv}`
  /// with... `vote_count.gte=200`..." — not participant-derived, but
  /// part of the same "hard filters" package one fetch attempt consumes
  /// as a unit. Relaxation step 4 ("Lower `vote_count.gte` to 50")
  /// produces a new `MatchQuery` with this field changed, rather than
  /// mutating it.
  final int voteCountGte;

  /// [maxRuntimeMinutes]/[tvStatus]/[maxSeasons] take a *function*
  /// returning the new value, not the value itself — same sentinel idiom
  /// `DiscoverFilter.copyWith` already uses, and for the same reason: the
  /// usual `?? this.x` shortcut can't tell "leave this alone" apart from
  /// "clear it to null" for a field that's already nullable. Every other
  /// field here always holds a real value, so the plain `?? this.x` form
  /// is unambiguous for them. Exists for the relaxation ladder
  /// (`match_engine.dart`) to produce a new `MatchQuery` per step without
  /// re-listing all ten fields by hand each time.
  MatchQuery copyWith({
    MediaType? mediaType,
    Set<Genre>? excludedGenres,
    Map<String, int>? vibeWeights,
    Map<String, Set<String>>? vibeIdsByParticipant,
    int? yearFrom,
    int? Function()? maxRuntimeMinutes,
    DiscoverTvStatus? Function()? tvStatus,
    int? Function()? maxSeasons,
    Set<MediaKey>? excludedWatchedKeys,
    Set<MediaKey>? watchedByAnyone,
    int? voteCountGte,
  }) {
    return MatchQuery(
      mediaType: mediaType ?? this.mediaType,
      excludedGenres: excludedGenres ?? this.excludedGenres,
      vibeWeights: vibeWeights ?? this.vibeWeights,
      vibeIdsByParticipant: vibeIdsByParticipant ?? this.vibeIdsByParticipant,
      yearFrom: yearFrom ?? this.yearFrom,
      maxRuntimeMinutes: maxRuntimeMinutes == null
          ? this.maxRuntimeMinutes
          : maxRuntimeMinutes(),
      tvStatus: tvStatus == null ? this.tvStatus : tvStatus(),
      maxSeasons: maxSeasons == null ? this.maxSeasons : maxSeasons(),
      excludedWatchedKeys: excludedWatchedKeys ?? this.excludedWatchedKeys,
      watchedByAnyone: watchedByAnyone ?? this.watchedByAnyone,
      voteCountGte: voteCountGte ?? this.voteCountGte,
    );
  }

  /// Combines every participant's answers into one [MatchQuery], per
  /// `docs/DECISIONS.md` section 5's aggregation table. [answers] must
  /// be non-empty — there's no such thing as a 0-person match.
  static MatchQuery aggregate(
    MediaType mediaType,
    List<ParticipantAnswers> answers,
  ) {
    assert(answers.isNotEmpty, 'aggregate() needs at least one participant');

    final excludedGenres = <Genre>{};
    final vibeWeights = <String, int>{};
    final vibeIdsByParticipant = <String, Set<String>>{};
    var yearFrom = answers.first.yearFrom;
    int? maxRuntimeMinutes;
    var anyoneWantsFinished = false;
    int? maxSeasons;
    final excludedWatchedKeys = <MediaKey>{};
    final watchedByAnyone = <MediaKey>{};

    for (final answer in answers) {
      excludedGenres.addAll(answer.excludedGenres);

      for (final vibeId in answer.vibeIds) {
        vibeWeights[vibeId] = (vibeWeights[vibeId] ?? 0) + 1;
      }
      vibeIdsByParticipant[answer.participantId] = answer.vibeIds;

      yearFrom = math.max(yearFrom, answer.yearFrom);

      final runtime = answer.maxRuntimeMinutes;
      if (runtime != null) {
        maxRuntimeMinutes = maxRuntimeMinutes == null
            ? runtime
            : math.min(maxRuntimeMinutes, runtime);
      }

      if (answer.tvStatus == DiscoverTvStatus.ended) {
        anyoneWantsFinished = true;
      }

      final seasons = answer.maxSeasons;
      if (seasons != null) {
        maxSeasons = maxSeasons == null
            ? seasons
            : math.min(maxSeasons, seasons);
      }

      watchedByAnyone.addAll(answer.watchedKeys);
      if (answer.excludeWatched) {
        excludedWatchedKeys.addAll(answer.watchedKeys);
      }
    }

    return MatchQuery(
      mediaType: mediaType,
      excludedGenres: excludedGenres,
      vibeWeights: vibeWeights,
      vibeIdsByParticipant: vibeIdsByParticipant,
      yearFrom: yearFrom,
      maxRuntimeMinutes: maxRuntimeMinutes,
      tvStatus: anyoneWantsFinished ? DiscoverTvStatus.ended : null,
      maxSeasons: maxSeasons,
      excludedWatchedKeys: excludedWatchedKeys,
      watchedByAnyone: watchedByAnyone,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MatchQuery &&
      other.mediaType == mediaType &&
      _setEquals(other.excludedGenres, excludedGenres) &&
      _mapEquals(other.vibeWeights, vibeWeights) &&
      _mapOfSetsEquals(other.vibeIdsByParticipant, vibeIdsByParticipant) &&
      other.yearFrom == yearFrom &&
      other.maxRuntimeMinutes == maxRuntimeMinutes &&
      other.tvStatus == tvStatus &&
      other.maxSeasons == maxSeasons &&
      _setEquals(other.excludedWatchedKeys, excludedWatchedKeys) &&
      _setEquals(other.watchedByAnyone, watchedByAnyone) &&
      other.voteCountGte == voteCountGte;

  @override
  int get hashCode => Object.hash(
    mediaType,
    Object.hashAllUnordered(excludedGenres),
    Object.hashAllUnordered(vibeWeights.entries.map((e) => (e.key, e.value))),
    Object.hashAllUnordered(
      vibeIdsByParticipant.entries.map(
        (e) => (e.key, Object.hashAllUnordered(e.value)),
      ),
    ),
    yearFrom,
    maxRuntimeMinutes,
    tvStatus,
    maxSeasons,
    Object.hashAllUnordered(excludedWatchedKeys),
    Object.hashAllUnordered(watchedByAnyone),
    voteCountGte,
  );

  @override
  String toString() =>
      'MatchQuery(mediaType: $mediaType, excludedGenres: $excludedGenres, '
      'vibeWeights: $vibeWeights, '
      'vibeIdsByParticipant: $vibeIdsByParticipant, yearFrom: $yearFrom, '
      'maxRuntimeMinutes: $maxRuntimeMinutes, tvStatus: $tvStatus, '
      'maxSeasons: $maxSeasons, excludedWatchedKeys: $excludedWatchedKeys, '
      'watchedByAnyone: $watchedByAnyone, voteCountGte: $voteCountGte)';
}

/// Order-independent set content equality — same local stand-in used
/// throughout `core/domain` (e.g. `DiscoverFilter`) for
/// `package:collection`'s `SetEquality`.
bool _setEquals<T>(Set<T> a, Set<T> b) =>
    a.length == b.length && a.containsAll(b);

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}

bool _mapOfSetsEquals<K, V>(Map<K, Set<V>> a, Map<K, Set<V>> b) {
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    final otherValue = b[entry.key];
    if (otherValue == null || !_setEquals(otherValue, entry.value)) {
      return false;
    }
  }
  return true;
}
