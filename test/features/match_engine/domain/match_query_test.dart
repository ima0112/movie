import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart'
    show DiscoverTvStatus;
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/match_engine/domain/match_query.dart';
import 'package:movies/features/match_engine/domain/participant_answers.dart';

const _horror = Genre(id: 'horror');
const _romance = Genre(id: 'romance');
const _comedy = Genre(id: 'comedy');

ParticipantAnswers _answers(
  String id, {
  Set<Genre> excludedGenres = const {},
  Set<String> vibeIds = const {},
  required int yearFrom,
  int? maxRuntimeMinutes,
  DiscoverTvStatus? tvStatus,
  int? maxSeasons,
  bool excludeWatched = false,
  Set<MediaKey> watchedKeys = const {},
}) {
  return ParticipantAnswers(
    participantId: id,
    excludedGenres: excludedGenres,
    vibeIds: vibeIds,
    yearFrom: yearFrom,
    maxRuntimeMinutes: maxRuntimeMinutes,
    tvStatus: tvStatus,
    maxSeasons: maxSeasons,
    excludeWatched: excludeWatched,
    watchedKeys: watchedKeys,
  );
}

void main() {
  group('MatchQuery.aggregate — a representative 3-person room', () {
    final query = MatchQuery.aggregate(MediaType.movie, [
      _answers(
        'ana',
        excludedGenres: {_horror},
        vibeIds: {'feel-good', 'date-night'},
        yearFrom: 1990,
        maxRuntimeMinutes: 150,
      ),
      _answers(
        'luis',
        excludedGenres: {_romance},
        vibeIds: {'feel-good', 'superhero'},
        yearFrom: 2010,
        maxRuntimeMinutes: 120,
      ),
      _answers(
        'sofia',
        excludedGenres: {_horror, _comedy},
        vibeIds: {'feel-good'},
        yearFrom: 2000,
      ),
    ]);

    test('excludedGenres is the union of every veto', () {
      expect(query.excludedGenres, {_horror, _romance, _comedy});
    });

    test('vibeWeights counts how many participants picked each one', () {
      expect(query.vibeWeights, {
        'feel-good': 3,
        'date-night': 1,
        'superhero': 1,
      });
    });

    test('yearFrom is the max of the minimums (the most restrictive '
        'bound wins)', () {
      expect(query.yearFrom, 2010);
    });

    test('maxRuntimeMinutes is the minimum among those who set one', () {
      expect(query.maxRuntimeMinutes, 120);
    });

    test('mediaType is carried through unchanged', () {
      expect(query.mediaType, MediaType.movie);
    });

    test('voteCountGte defaults to 200 — aggregate() never touches it', () {
      expect(query.voteCountGte, 200);
    });
  });

  group('MatchQuery.aggregate — edge cases', () {
    test('a single participant: the query is just their own answers', () {
      final query = MatchQuery.aggregate(MediaType.movie, [
        _answers(
          'ana',
          excludedGenres: {_horror},
          vibeIds: {'feel-good', 'date-night', 'cozy'},
          yearFrom: 1995,
          maxRuntimeMinutes: 140,
        ),
      ]);

      expect(query.excludedGenres, {_horror});
      expect(query.vibeWeights, {'feel-good': 1, 'date-night': 1, 'cozy': 1});
      expect(query.yearFrom, 1995);
      expect(query.maxRuntimeMinutes, 140);
    });

    test('overlapping vetoes union without double-counting', () {
      final query = MatchQuery.aggregate(MediaType.movie, [
        _answers('ana', excludedGenres: {_horror, _romance}, yearFrom: 1990),
        _answers('luis', excludedGenres: {_horror}, yearFrom: 1990),
      ]);

      expect(query.excludedGenres, {_horror, _romance});
      expect(query.excludedGenres.length, 2);
    });

    test('every participant leaving maxRuntimeMinutes unset keeps it '
        'null (no limit), not zero', () {
      final query = MatchQuery.aggregate(MediaType.movie, [
        _answers('ana', yearFrom: 1990),
        _answers('luis', yearFrom: 1990),
      ]);

      expect(query.maxRuntimeMinutes, isNull);
    });

    test('maxSeasons is the minimum among those who set one, same rule '
        'as maxRuntimeMinutes', () {
      final query = MatchQuery.aggregate(MediaType.tvShow, [
        _answers('ana', yearFrom: 1990, maxSeasons: 5),
        _answers('luis', yearFrom: 1990, maxSeasons: 2),
        _answers('sofia', yearFrom: 1990),
      ]);

      expect(query.maxSeasons, 2);
    });

    test('tvStatus becomes ended if any participant asked for "Finished", '
        'null if nobody did', () {
      final withFinished = MatchQuery.aggregate(MediaType.tvShow, [
        _answers('ana', yearFrom: 1990, tvStatus: DiscoverTvStatus.ended),
        _answers('luis', yearFrom: 1990),
      ]);
      final withoutFinished = MatchQuery.aggregate(MediaType.tvShow, [
        _answers('ana', yearFrom: 1990),
        _answers('luis', yearFrom: 1990),
      ]);

      expect(withFinished.tvStatus, DiscoverTvStatus.ended);
      expect(withoutFinished.tvStatus, isNull);
    });

    test('excludedWatchedKeys only unions keys from participants who '
        'enabled excludeWatched, but watchedByAnyone unions everyone '
        'regardless — the scoring penalty needs to see it even when '
        "nobody opted into the hard exclusion", () {
      const dune = MediaKey(type: MediaType.movie, tmdbId: 1);
      const matrix = MediaKey(type: MediaType.movie, tmdbId: 2);

      final query = MatchQuery.aggregate(MediaType.movie, [
        _answers(
          'ana',
          yearFrom: 1990,
          excludeWatched: true,
          watchedKeys: {dune},
        ),
        _answers(
          'luis',
          yearFrom: 1990,
          excludeWatched: false,
          watchedKeys: {matrix},
        ),
      ]);

      expect(query.excludedWatchedKeys, {dune});
      expect(query.watchedByAnyone, {dune, matrix});
    });

    test('vibeIdsByParticipant keeps each participant\'s own picks, '
        'separately from the aggregated vibeWeights', () {
      final query = MatchQuery.aggregate(MediaType.movie, [
        _answers('ana', vibeIds: {'feel-good', 'cozy'}, yearFrom: 1990),
        _answers('luis', vibeIds: {'feel-good', 'superhero'}, yearFrom: 1990),
      ]);

      expect(query.vibeIdsByParticipant, {
        'ana': {'feel-good', 'cozy'},
        'luis': {'feel-good', 'superhero'},
      });
    });

    test('different years: the most recent yearFrom (most restrictive) '
        'always wins regardless of participant order', () {
      final ascending = MatchQuery.aggregate(MediaType.movie, [
        _answers('ana', yearFrom: 1980),
        _answers('luis', yearFrom: 2015),
      ]);
      final descending = MatchQuery.aggregate(MediaType.movie, [
        _answers('ana', yearFrom: 2015),
        _answers('luis', yearFrom: 1980),
      ]);

      expect(ascending.yearFrom, 2015);
      expect(descending.yearFrom, 2015);
    });
  });

  group('MatchQuery.copyWith', () {
    test('a field not passed at all stays unchanged', () {
      final original = MatchQuery.aggregate(MediaType.movie, [
        _answers('ana', yearFrom: 1990, maxRuntimeMinutes: 140),
      ]);

      final copy = original.copyWith(yearFrom: 2000);

      expect(copy.yearFrom, 2000);
      expect(copy.maxRuntimeMinutes, 140);
    });

    test('a nullable field can be explicitly cleared to null', () {
      final original = MatchQuery.aggregate(MediaType.movie, [
        _answers('ana', yearFrom: 1990, maxRuntimeMinutes: 140),
      ]);

      final copy = original.copyWith(maxRuntimeMinutes: () => null);

      expect(copy.maxRuntimeMinutes, isNull);
      expect(copy.yearFrom, 1990);
    });

    test('vibeWeights/excludedGenres/voteCountGte use the plain "not '
        'passed" form, no wrapper function needed', () {
      final original = MatchQuery.aggregate(MediaType.movie, [
        _answers('ana', yearFrom: 1990),
      ]);

      final copy = original.copyWith(voteCountGte: 50);

      expect(copy.voteCountGte, 50);
      expect(copy.excludedGenres, original.excludedGenres);
    });
  });
}
