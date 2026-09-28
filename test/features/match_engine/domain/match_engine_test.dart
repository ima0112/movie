import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/match_engine/domain/match_engine.dart';
import 'package:movies/features/match_engine/domain/match_query.dart';
import 'package:movies/features/match_engine/domain/participant_answers.dart';
import 'package:movies/features/match_engine/domain/relaxation.dart';
import 'package:movies/features/match_engine/domain/vibe.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';

/// FakeMediaRepository's sample movies relevant to these tests (see its
/// own `_movies` list) — spelled out here so every expectation below can
/// be traced back to a concrete title without re-reading that file:
///   1  Dune: Part Two        sci-fi, drama              2024   8.4
///   2  Oppenheimer           drama                      2023   8.2
///   3  Poor Things           comedy, drama              2023   8.0
///   4  Knives Out            mystery, comedy            2019   7.9
///   5  The Substance         horror                     2024   7.3
///   6  Inside Out 2          animation, comedy          2024   7.7
///   7  Furiosa               action, sci-fi             2024   7.6
///   8  My Octopus Teacher    documentary                2020   8.1
///   9  Untitled Sci-Fi Proj. sci-fi                     (none) 0
void main() {
  /// A minimal, single-genre [Vibe] — movie-only, no keywords/year/rating
  /// filter — built directly rather than parsed from `assets/vibes.json`
  /// so each test controls exactly which genre it targets.
  Vibe vibe(String id, List<String> movieGenreIds) {
    return Vibe(
      id: id,
      name: id,
      icon: 'icon',
      movie: VibeRule(genreIds: movieGenreIds, keywordIds: const []),
      tv: const VibeRule(genreIds: [], keywordIds: []),
    );
  }

  ParticipantAnswers answers(
    String id, {
    Set<String> vibeIds = const {},
    Set<Genre> excludedGenres = const {},
    required int yearFrom,
    bool excludeWatched = false,
    Set<MediaKey> watchedKeys = const {},
  }) {
    return ParticipantAnswers(
      participantId: id,
      vibeIds: vibeIds,
      excludedGenres: excludedGenres,
      yearFrom: yearFrom,
      excludeWatched: excludeWatched,
      watchedKeys: watchedKeys,
    );
  }

  late MatchEngineImpl engine;

  setUp(() {
    engine = MatchEngineImpl(FakeMediaRepository());
  });

  group('MatchEngine.resolve — a perfect match', () {
    test('every participant fully satisfied, no relaxation needed', () async {
      const action = Genre(id: 'action', name: 'Action');
      final catalog = VibeCatalog([
        vibe('scifi', ['sci-fi']),
      ]);
      final query = MatchQuery.aggregate(MediaType.movie, [
        answers('ana', vibeIds: {'scifi'}, excludedGenres: {action}, yearFrom: 1950),
        answers('luis', vibeIds: {'scifi'}, excludedGenres: {action}, yearFrom: 1950),
      ]);

      final result = await engine.resolve(
        query,
        options: MatchOptions(vibeCatalog: catalog),
      );

      // Furiosa also has sci-fi but is vetoed via "action"; the untitled
      // sci-fi project has no release date, so the yearFrom bound alone
      // already drops it — Dune: Part Two is the only candidate left.
      expect(result, isNotNull);
      expect(result!.winner.title, 'Dune: Part Two');
      expect(result.alternatives, isEmpty);
      expect(result.relaxationsApplied, isEmpty);
      expect(result.isPerfectMatch, isTrue);
      expect(result.satisfaction, hasLength(2));
      for (final s in result.satisfaction) {
        expect(s.vibesRequested, 1);
        expect(s.vibesMet, 1);
        expect(s.percentage, 1.0);
      }
    });
  });

  group('MatchEngine.resolve — needs relaxation', () {
    test('the initial yearFrom leaves nothing; widening it 10 years back '
        'finds Knives Out', () async {
      final catalog = VibeCatalog([
        vibe('mystery', ['mystery']),
      ]);
      // Knives Out (2019) is the only mystery-tagged sample movie —
      // yearFrom: 2024 excludes it outright.
      final query = MatchQuery.aggregate(MediaType.movie, [
        answers('ana', vibeIds: {'mystery'}, yearFrom: 2024),
        answers('luis', vibeIds: {'mystery'}, yearFrom: 2024),
      ]);

      final result = await engine.resolve(
        query,
        options: MatchOptions(vibeCatalog: catalog),
      );

      expect(result, isNotNull);
      expect(result!.winner.title, 'Knives Out');
      // Only one shared vibe: dropLeastSupportedVibe would empty the
      // query entirely, so the engine skips straight to widening the
      // year range instead (yearFrom: 2024 - 10 = 2014, which now
      // includes 2019).
      expect(result.relaxationsApplied, [Relaxation.widenYearRange]);
    });

    test('resolve() returns null once every relaxation step is exhausted '
        'and nothing has ever matched', () async {
      // No sample movie has the "crime" genre — no relaxation step
      // (dropping a vibe that's the only one, widening the year,
      // raising a limit, lowering vote_count.gte) changes that.
      final catalog = VibeCatalog([
        vibe('crime', ['crime']),
      ]);
      final query = MatchQuery.aggregate(MediaType.movie, [
        answers('ana', vibeIds: {'crime'}, yearFrom: 1950),
      ]);

      final result = await engine.resolve(
        query,
        options: MatchOptions(vibeCatalog: catalog),
      );

      expect(result, isNull);
    });
  });

  group('MatchEngine.resolve — tie-break by vote_average', () {
    test('several candidates tie on vibe score; the highest vote_average '
        'wins, in descending order for the rest', () async {
      final catalog = VibeCatalog([
        vibe('comedy', ['comedy']),
      ]);
      // Every comedy-tagged sample movie matches this single vibe query,
      // so all three tie on score — voteAverage alone decides the order:
      // Poor Things (8.0) > Knives Out (7.9) > Inside Out 2 (7.7).
      final query = MatchQuery.aggregate(MediaType.movie, [
        answers('ana', vibeIds: {'comedy'}, yearFrom: 1950),
      ]);

      final result = await engine.resolve(
        query,
        options: MatchOptions(vibeCatalog: catalog),
      );

      expect(result, isNotNull);
      expect(result!.winner.title, 'Poor Things');
      expect(
        result.alternatives.map((m) => m.title).toList(),
        ['Knives Out', 'Inside Out 2'],
      );
      expect(result.relaxationsApplied, isEmpty);
    });
  });

  group('MatchEngine.resolve — watched handling', () {
    test('a hard-excluded candidate never appears, even as an '
        'alternative', () async {
      final catalog = VibeCatalog([
        vibe('comedy', ['comedy']),
      ]);
      // Poor Things would otherwise win this exact query (see the
      // tie-break test above) — excluding it here should promote
      // Knives Out instead, not just drop it silently from third place.
      const poorThings = MediaKey(type: MediaType.movie, tmdbId: 3);
      final query = MatchQuery.aggregate(MediaType.movie, [
        answers(
          'ana',
          vibeIds: {'comedy'},
          yearFrom: 1950,
          excludeWatched: true,
          watchedKeys: {poorThings},
        ),
      ]);

      final result = await engine.resolve(
        query,
        options: MatchOptions(vibeCatalog: catalog),
      );

      expect(result, isNotNull);
      expect(result!.winner.title, 'Knives Out');
      expect(
        result.alternatives.map((m) => m.title).toList(),
        ['Inside Out 2'],
      );
    });

    test('a candidate watched by someone who did NOT opt into '
        'excludeWatched is only penalized, not removed — it can still '
        'lose to a lower-rated title once the penalty outweighs the '
        'vote_average gap', () async {
      final catalog = VibeCatalog([
        vibe('comedy', ['comedy']),
      ]);
      const poorThings = MediaKey(type: MediaType.movie, tmdbId: 3);
      // "ana" has seen Poor Things but does *not* ask to exclude it —
      // MatchQuery.watchedByAnyone still includes it (soft signal),
      // while excludedWatchedKeys stays empty (nothing hard-filtered).
      final query = MatchQuery.aggregate(MediaType.movie, [
        answers(
          'ana',
          vibeIds: {'comedy'},
          yearFrom: 1950,
          excludeWatched: false,
          watchedKeys: {poorThings},
        ),
      ]);
      expect(query.excludedWatchedKeys, isEmpty);
      expect(query.watchedByAnyone, {poorThings});

      final result = await engine.resolve(
        query,
        options: MatchOptions(vibeCatalog: catalog),
      );

      // Poor Things (score 1 - 1 penalty = 0) now ranks below Knives Out
      // and Inside Out 2 (score 1 each, no penalty) — present, but no
      // longer the winner despite having the highest vote_average.
      expect(result, isNotNull);
      expect(result!.winner.title, 'Knives Out');
      expect(
        result.alternatives.map((m) => m.title).toList(),
        ['Inside Out 2', 'Poor Things'],
      );
    });
  });
}
