import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/release_status.dart';

void main() {
  final today = DateTime(2026, 5, 10);
  ReleaseDateEntry e(int type, DateTime d) =>
      ReleaseDateEntry(type: type, date: d);
  ReleaseStatus? movie(
    List<ReleaseDateEntry> entries, {
    String status = 'Released',
  }) => releaseStatusForMovie(entries, today: today, tmdbStatus: status);

  group('movies', () {
    test('a theatrical date still ahead is upcoming, with that date', () {
      final s = movie([e(3, DateTime(2026, 6, 12))], status: 'Post Production');
      expect(s?.stage, ReleaseStage.upcoming);
      expect(s?.date, DateTime(2026, 6, 12));
    });

    test(
      'the earliest date ahead wins, a festival premiere does not count',
      () {
        final s = movie([
          e(1, DateTime(2026, 2, 1)), // premiere: already past, ignored
          e(3, DateTime(2026, 8, 1)),
          e(2, DateTime(2026, 7, 4)),
        ]);
        expect(s?.stage, ReleaseStage.upcoming);
        expect(s?.date, DateTime(2026, 7, 4));
      },
    );

    test('opened in cinemas, no digital release yet: in theaters, with the '
        'streaming date when known', () {
      final s = movie([
        e(3, DateTime(2026, 4, 24)),
        e(4, DateTime(2026, 6, 20)),
      ]);
      expect(s?.stage, ReleaseStage.inTheaters);
      expect(s?.date, DateTime(2026, 4, 24));
      expect(s?.streamingDate, DateTime(2026, 6, 20));
    });

    test('opening day itself is already in theaters', () {
      expect(
        movie([e(3, DateTime(2026, 5, 10))])?.stage,
        ReleaseStage.inTheaters,
      );
    });

    test('a digital, physical or TV date that has come means it is simply '
        'out', () {
      for (final home in [4, 5, 6]) {
        expect(
          movie([e(3, DateTime(2026, 3, 1)), e(home, DateTime(2026, 5, 1))]),
          isNull,
          reason: 'type $home',
        );
      }
    });

    test('in cinemas for more than 90 days with no home release recorded is '
        'not flagged', () {
      expect(movie([e(3, DateTime(2026, 1, 1))]), isNull);
      expect(
        movie([e(3, DateTime(2026, 2, 10))])?.stage, // exactly 89 days
        ReleaseStage.inTheaters,
      );
    });

    test('no dates: TMDB\'s own status decides, without a date', () {
      for (final status in [
        'Rumored',
        'Planned',
        'In Production',
        'Post Production',
      ]) {
        final s = movie(const [], status: status);
        expect(s?.stage, ReleaseStage.upcoming, reason: status);
        expect(s?.date, isNull);
      }
      expect(movie(const [], status: 'Released'), isNull);
    });

    test(
      'only a past premiere and an unreleased status: upcoming, no date',
      () {
        final s = movie([
          e(1, DateTime(2026, 2, 1)),
        ], status: 'Post Production');
        expect(s?.stage, ReleaseStage.upcoming);
        expect(s?.date, isNull);
      },
    );
  });

  group('TV shows', () {
    ReleaseStatus? tv(DateTime? first, [String status = 'Returning Series']) =>
        releaseStatusForTv(
          firstAirDate: first,
          today: today,
          tmdbStatus: status,
        );

    test('a first episode still ahead is upcoming', () {
      final s = tv(DateTime(2026, 9, 1), 'Planned');
      expect(s?.stage, ReleaseStage.upcoming);
      expect(s?.date, DateTime(2026, 9, 1));
    });

    test('already aired, or airing today, is not flagged', () {
      expect(tv(DateTime(2020, 1, 1), 'Ended'), isNull);
      expect(tv(DateTime(2026, 5, 10)), isNull);
    });

    test(
      'no air date: the unreleased statuses say upcoming, others nothing',
      () {
        expect(tv(null, 'In Production')?.stage, ReleaseStage.upcoming);
        expect(tv(null, 'Ended'), isNull);
      },
    );
  });
}
