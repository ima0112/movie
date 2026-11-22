import 'genre.dart';
import 'media_type.dart';

/// How a Surprise-me session got its answers.
enum SurpriseSessionSource {
  /// "Use my tastes": the saved taste profile.
  profile,

  /// "Use my tastes" with no profile: inferred from My List.
  inferredList,

  /// The quiz (E2).
  quiz,
}

/// What one Surprise-me session **asked for**, kept beside what it showed
/// (`SurpriseHistoryEntry`) so the statistics can say which collections, vibes
/// and vetoes lead to a pick. Persisted locally with the history (drift, table
/// `surprise_session`) — never leaves the device, and **never feeds the user's
/// saved tastes** (`docs/decisions/quiz-answers-not-saved-to-profile.md`): it is
/// a record of the session, nothing reads it back as a preference.
///
/// Pure value — no Flutter, no storage. Ids are plain strings and sets (a
/// collection's or vibe's `id`, a [Genre]) so this needs no feature's domain.
class SurpriseSession {
  const SurpriseSession({
    required this.sessionId,
    required this.startedAt,
    required this.mediaType,
    required this.source,
    required this.yearFrom,
    this.collectionIds = const {},
    this.vibeIds = const {},
    this.excludedGenres = const {},
    this.platformIds = const {},
    this.yearTo,
    this.relaxations = const {},
  });

  final String sessionId;
  final DateTime startedAt;
  final MediaType mediaType;
  final SurpriseSessionSource source;

  /// `Collection.id`s asked for (none = anything).
  final Set<String> collectionIds;

  /// `Vibe.id`s asked for.
  final Set<String> vibeIds;

  /// The genres vetoed.
  final Set<Genre> excludedGenres;

  /// The streaming services asked for (TMDB provider ids); none = any.
  final Set<int> platformIds;

  final int yearFrom;
  final int? yearTo;

  /// The names of the relaxation steps the engine needed in **any** batch of
  /// the session (`SurpriseRelaxation.name`): the answers were too tight.
  final Set<String> relaxations;

  /// The same session with [more] relaxation steps added (a later batch).
  SurpriseSession withRelaxations(Set<String> more) => SurpriseSession(
    sessionId: sessionId,
    startedAt: startedAt,
    mediaType: mediaType,
    source: source,
    yearFrom: yearFrom,
    collectionIds: collectionIds,
    vibeIds: vibeIds,
    excludedGenres: excludedGenres,
    platformIds: platformIds,
    yearTo: yearTo,
    relaxations: {...relaxations, ...more},
  );
}
