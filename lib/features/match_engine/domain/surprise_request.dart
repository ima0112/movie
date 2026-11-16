import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/media_key.dart';
import '../../../core/domain/entities/media_type.dart';
import 'participant_answers.dart';

/// One ask to the Surprise-me engine: "give me 5 for these [answers]".
///
/// [sessionId] names the shuffle: every "other 5" of the same session reuses
/// it, so the engine can skip what that session already showed ([excludeKeys])
/// and pick pages it hasn't used. [region] is the user's region (Settings →
/// Region), needed for the platform filter. [seed] makes the random parts
/// (pages, noise, sampling) reproducible — a new value per batch.
///
/// Pure value — no Flutter, no TMDB.
class SurpriseRequest {
  const SurpriseRequest({
    required this.type,
    required this.answers,
    required this.sessionId,
    required this.region,
    required this.seed,
    this.excludeKeys = const {},
    this.genreAffinity = const {},
    this.count = defaultCount,
  });

  /// How many suggestions a batch holds.
  static const int defaultCount = 5;

  final MediaType type;
  final ParticipantAnswers answers;
  final String sessionId;

  /// ISO 3166-1 region ("ES", "US").
  final String region;
  final int seed;

  /// Titles never to suggest: what this session already showed, what the
  /// history says was seen recently, and what the user has watched (when
  /// [ParticipantAnswers.excludeWatched] is on).
  final Set<MediaKey> excludeKeys;

  /// How much the user likes each genre — positive liked, negative disliked,
  /// the shape `genreAffinityFrom(library)` already returns. A soft signal:
  /// it orders candidates, it never excludes. Empty = no taste to go on.
  final Map<Genre, int> genreAffinity;

  final int count;

  SurpriseRequest copyWith({int? seed, Set<MediaKey>? excludeKeys}) =>
      SurpriseRequest(
        type: type,
        answers: answers,
        sessionId: sessionId,
        region: region,
        seed: seed ?? this.seed,
        excludeKeys: excludeKeys ?? this.excludeKeys,
        genreAffinity: genreAffinity,
        count: count,
      );

  @override
  String toString() =>
      'SurpriseRequest($type, session: $sessionId, region: $region, '
      'seed: $seed, exclude: ${excludeKeys.length}, count: $count)';
}
