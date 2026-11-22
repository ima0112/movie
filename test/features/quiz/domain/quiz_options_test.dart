import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/tmdb_genre_mapper.dart';
import 'package:movies/core/domain/entities/collection_catalog.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/quiz/domain/quiz_options.dart';

const _animation = Genre(id: 'animation');
const _family = Genre(id: 'family');
const _horror = Genre(id: 'horror');
const _thriller = Genre(id: 'thriller');
const _crime = Genre(id: 'crime');
const _comedy = Genre(id: 'comedy');

void main() {
  final collections = CollectionCatalog.fromJsonString(
    File('assets/collections.json').readAsStringSync(),
  );
  final vibes = VibeCatalog.fromJsonString(
    File('assets/vibes.json').readAsStringSync(),
  );
  final kids = collections.byId('kids')!;
  final turkish = collections.byId('turkish_series')!;
  const genreOf = TmdbGenreMapper.fromTmdbId;

  test('with no collection, the veto list is every genre of the type', () {
    expect(
      QuizOptions.vetoOptions(MediaType.movie, const [], genreOf),
      hasLength(18),
    );
    expect(
      QuizOptions.vetoOptions(MediaType.tvShow, const [], genreOf),
      hasLength(16),
    );
  });

  test('Kids on movies hides what it requires (Family) and what it leaves '
      'out (Horror, Thriller, Crime, War, Western): 18 - 6 = 12; Animation '
      'stays', () {
    final options = QuizOptions.vetoOptions(MediaType.movie, [kids], genreOf);
    expect(options, hasLength(12));
    for (final g in [
      _family,
      _horror,
      _thriller,
      _crime,
      const Genre(id: 'war'),
      const Genre(id: 'western'),
    ]) {
      expect(options, isNot(contains(g)));
    }
    expect(options, contains(_animation));
  });

  test('a collection with genres TMDB has but we do not (Kids on TV, '
      'Turkish\'s Talk and News) hides nothing', () {
    expect(
      QuizOptions.vetoOptions(MediaType.tvShow, [kids], genreOf),
      hasLength(16),
    );
    expect(
      QuizOptions.vetoOptions(MediaType.tvShow, [turkish], genreOf),
      hasLength(16),
    );
  });

  test('a collection that does not exist for the type hides nothing', () {
    expect(
      QuizOptions.vetoOptions(MediaType.movie, [turkish], genreOf),
      hasLength(18),
    );
  });

  test('vibes: with no collection and no veto, all of the type', () {
    expect(
      QuizOptions.vibeOptions(
        vibes.all(),
        MediaType.movie,
        const [],
        {},
        genreOf,
      ),
      hasLength(19),
    );
    expect(
      QuizOptions.vibeOptions(
        vibes.all(),
        MediaType.tvShow,
        const [],
        {},
        genreOf,
      ),
      hasLength(15),
    );
  });

  test('Kids hides the vibes that make no sense with it — Gangster, Gritty, '
      'Revenge, Dystopia, Survival, Heist, Martial Arts, Tearjerker — on both '
      'kinds of title; the rest stay', () {
    for (final type in MediaType.values) {
      final offered = ids2(
        QuizOptions.vibeOptions(vibes.all(), type, [kids], {}, genreOf),
      );
      for (final hidden in [
        'gangster',
        'gritty',
        'revenge',
        'dystopia',
        'survival',
        'heist',
        'martial_arts',
        'tearjerker',
      ]) {
        expect(offered, isNot(contains(hidden)), reason: '$hidden / $type');
      }
      expect(
        offered,
        containsAll(['feel_good', 'superhero', 'sports', 'time_travel']),
      );
    }
  });

  test('Kids loses Gritty (crime and thriller are excluded); keyword themes '
      'stay', () {
    final offered = ids2(
      QuizOptions.vibeOptions(
        vibes.all(),
        MediaType.movie,
        [kids],
        {},
        genreOf,
      ),
    );
    expect(offered, isNot(contains('gritty')));
    expect(offered, containsAll(['superhero', 'monster', 'feel_good']));
  });

  test('vetoing every genre of an ambiente removes it; some leaves it', () {
    List<String> offeredWith(Set<Genre> vetoed) => ids2(
      QuizOptions.vibeOptions(
        vibes.all(),
        MediaType.movie,
        const [],
        vetoed,
        genreOf,
      ),
    );
    expect(offeredWith({_comedy}), contains('feel_good')); // still family
    expect(offeredWith({_comedy, _family}), isNot(contains('feel_good')));
    expect(offeredWith({_comedy, _family}), contains('date')); // romance
  });

  test('changing the collection prunes what became invalid, silently', () {
    expect(
      QuizOptions.prunedVetoes(
        {_horror, _comedy},
        MediaType.movie,
        [kids],
        genreOf,
      ),
      {_comedy},
    );
    expect(
      QuizOptions.prunedVibes(
        {'gritty', 'superhero'},
        vibes.all(),
        MediaType.movie,
        [kids],
        const {},
        genreOf,
      ),
      {'superhero'},
    );
  });
}

List<String> ids2(Iterable<dynamic> vibes) => [
  for (final v in vibes) v.id as String,
];
