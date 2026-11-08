import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/features/person_detail/presentation/widgets/filmography_grouping.dart';

Movie _movie(int id, String title, {DateTime? releaseDate}) => Movie(
  id: id,
  title: title,
  posterUrl: null,
  genres: const [],
  releaseDate: releaseDate,
  voteAverage: 7,
);

TvShow _tvShow(int id, String title, {DateTime? releaseDate}) => TvShow(
  id: id,
  title: title,
  posterUrl: null,
  genres: const [],
  releaseDate: releaseDate,
  voteAverage: 7,
);

void main() {
  group('PersonFilmography.groupedByYear', () {
    test('groups by release year, newest first', () {
      final credits = [
        MediaCredit(
          item: _movie(1, 'A', releaseDate: DateTime(2020, 1, 1)),
          character: 'A',
        ),
        MediaCredit(
          item: _movie(2, 'B', releaseDate: DateTime(2022, 1, 1)),
          character: 'B',
        ),
        MediaCredit(
          item: _movie(3, 'C', releaseDate: DateTime(2022, 6, 1)),
          character: 'C',
        ),
      ];

      final groups = credits.groupedByYear;

      expect(groups.map((g) => g.label), ['2022', '2020']);
      expect(groups.first.credits, hasLength(2));
      expect(groups.last.credits, hasLength(1));
    });

    test('undated credits group as "Coming soon", ahead of every real '
        'year', () {
      final credits = [
        MediaCredit(
          item: _movie(1, 'Past', releaseDate: DateTime(2019, 1, 1)),
          character: 'Past',
        ),
        MediaCredit(
          item: _movie(2, 'Future', releaseDate: null),
          character: 'Future',
        ),
      ];

      final groups = credits.groupedByYear;

      expect(groups.map((g) => g.label), ['Coming soon', '2019']);
      expect(groups.first.credits.single.item.title, 'Future');
    });

    test('no undated credits: no "Coming soon" group at all', () {
      final credits = [
        MediaCredit(
          item: _movie(1, 'A', releaseDate: DateTime(2020, 1, 1)),
          character: 'A',
        ),
      ];

      expect(credits.groupedByYear.map((g) => g.label), ['2020']);
    });
  });

  group('PersonFilmography.filteredBy', () {
    final movieCredit = MediaCredit(
      item: _movie(1, 'Movie', releaseDate: DateTime(2020, 1, 1)),
      character: 'Lead',
    );
    final tvCredit = MediaCredit(
      item: _tvShow(2, 'Show', releaseDate: DateTime(2021, 1, 1)),
      character: 'Lead',
    );
    final directingCredit = MediaCredit(
      item: _movie(3, 'Directed', releaseDate: DateTime(2022, 1, 1)),
      job: 'Director',
    );
    final otherCrewCredit = MediaCredit(
      item: _movie(4, 'Produced', releaseDate: DateTime(2023, 1, 1)),
      job: 'Producer',
    );
    final credits = [movieCredit, tvCredit, directingCredit, otherCrewCredit];

    test('all keeps every credit', () {
      expect(credits.filteredBy(FilmographySegment.all), credits);
    });

    test('movies keeps only Movie items', () {
      expect(credits.filteredBy(FilmographySegment.movies), [
        movieCredit,
        directingCredit,
        otherCrewCredit,
      ]);
    });

    test('tvShows keeps only TvShow items', () {
      expect(credits.filteredBy(FilmographySegment.tvShows), [tvCredit]);
    });

    test('asDirector keeps only job == Director, not every crew credit', () {
      expect(credits.filteredBy(FilmographySegment.asDirector), [
        directingCredit,
      ]);
    });
  });

  group('PersonFilmography.hasBothCastAndCrew', () {
    test('false for cast-only credits', () {
      final credits = [MediaCredit(item: _movie(1, 'A'), character: 'Lead')];
      expect(credits.hasBothCastAndCrew, isFalse);
    });

    test('false for crew-only credits', () {
      final credits = [MediaCredit(item: _movie(1, 'A'), job: 'Director')];
      expect(credits.hasBothCastAndCrew, isFalse);
    });

    test('true once both a cast and a crew credit exist', () {
      final credits = [
        MediaCredit(item: _movie(1, 'A'), character: 'Lead'),
        MediaCredit(item: _movie(2, 'B'), job: 'Director'),
      ];
      expect(credits.hasBothCastAndCrew, isTrue);
    });
  });
}
