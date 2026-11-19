import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/genre_catalog.dart';
import 'package:movies/core/domain/entities/media_type.dart';

Set<String> _ids(Iterable<Genre> genres) => {for (final g in genres) g.id};

void main() {
  group('GenreCatalog', () {
    test('has 18 distinct genres, Bélica and Western among them', () {
      expect(GenreCatalog.all, hasLength(18));
      expect(_ids(GenreCatalog.all), hasLength(18));
      expect(GenreCatalog.byId('war'), const Genre(id: 'war'));
      expect(GenreCatalog.byId('western'), const Genre(id: 'western'));
    });

    test('movies can use every genre', () {
      expect(GenreCatalog.availableFor(MediaType.movie), GenreCatalog.all);
    });

    test('TV shows lose Adventure and Fantasy (folded into Action and '
        'Sci-Fi) and keep the other 16, the ones TMDB lacks included', () {
      final tv = GenreCatalog.availableFor(MediaType.tvShow);
      final ids = _ids(tv);

      expect(tv, hasLength(16));
      expect(ids, isNot(contains('adventure')));
      expect(ids, isNot(contains('fantasy')));
      expect(
        ids,
        containsAll([
          'action',
          'sci-fi',
          'war',
          'western',
          'horror',
          'romance',
          'thriller',
          'history',
          'music',
        ]),
      );
    });

    test('every TV genre is also a movie genre, in the same order', () {
      final movie = GenreCatalog.availableFor(MediaType.movie).toList();
      final tv = GenreCatalog.availableFor(MediaType.tvShow).toList();
      expect(tv.every(movie.contains), isTrue);
      final positions = [for (final g in tv) movie.indexOf(g)];
      expect(positions, [...positions]..sort());
    });
  });

  group('tvMembers', () {
    test(
      'Action & Adventure and Sci-Fi & Fantasy are one genre each on TV',
      () {
        const action = Genre(id: 'action');
        const adventure = Genre(id: 'adventure');
        const sciFi = Genre(id: 'sci-fi');
        const fantasy = Genre(id: 'fantasy');

        expect(GenreCatalog.tvMembers(action), {action, adventure});
        expect(GenreCatalog.tvMembers(adventure), {action, adventure});
        expect(GenreCatalog.tvMembers(sciFi), {sciFi, fantasy});
        expect(GenreCatalog.tvMembers(fantasy), {sciFi, fantasy});
      },
    );

    test('any other genre is only itself', () {
      for (final genre in GenreCatalog.all) {
        if (const {
          'action',
          'adventure',
          'sci-fi',
          'fantasy',
        }.contains(genre.id)) {
          continue;
        }
        expect(GenreCatalog.tvMembers(genre), {genre}, reason: genre.id);
      }
    });

    test('only Adventure and Fantasy are folded on TV', () {
      final folded = [
        for (final g in GenreCatalog.all)
          if (GenreCatalog.isFoldedOnTv(g)) g.id,
      ];
      expect(folded, ['adventure', 'fantasy']);
    });
  });

  group('GenreCatalog.chipsOf', () {
    const adventure = Genre(id: 'adventure');
    const action = Genre(id: 'action');
    const fantasy = Genre(id: 'fantasy');
    const sciFi = Genre(id: 'sci-fi');
    const comedy = Genre(id: 'comedy');

    test('on TV, Adventure and Fantasy show as their combined chip', () {
      expect(
        GenreCatalog.chipsOf(MediaType.tvShow, [adventure, fantasy, comedy]),
        {action, sciFi, comedy},
      );
      expect(GenreCatalog.chipsOf(MediaType.tvShow, [action, adventure]), {
        action,
      });
    });

    test('for movies or no type, unchanged', () {
      expect(GenreCatalog.chipsOf(MediaType.movie, [adventure]), {adventure});
      expect(GenreCatalog.chipsOf(null, [fantasy]), {fantasy});
    });

    test('availableFor(null) is every genre', () {
      expect(GenreCatalog.availableFor(null), GenreCatalog.all);
    });
  });
}
