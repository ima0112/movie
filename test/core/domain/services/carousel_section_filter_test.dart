import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/core/domain/services/carousel_section_filter.dart';

void main() {
  final today = DateTime(2026, 5, 4);
  DiscoverFilter? filter(CarouselSection s, {MediaType? type}) =>
      carouselSectionFilter(s, type: type, today: today);

  test('every collection but Watch later has a catalog equivalent', () {
    for (final s in CarouselSection.values) {
      if (s == CarouselSection.watchLater) {
        expect(filter(s), isNull);
      } else {
        expect(filter(s), isNotNull, reason: '$s');
      }
    }
  });

  test('the segment carries through where a collection is not fixed to a '
      'type', () {
    expect(
      filter(CarouselSection.trending, type: MediaType.movie)!.type,
      MediaType.movie,
    );
    expect(filter(CarouselSection.popularThisWeek)!.type, isNull);
    expect(filter(CarouselSection.comingSoon)!.type, isNull);
  });

  test('movie-only and TV-only collections fix their type', () {
    expect(filter(CarouselSection.inTheaters)!.type, MediaType.movie);
    expect(filter(CarouselSection.airingNow)!.type, MediaType.tvShow);
    expect(filter(CarouselSection.finishedShows)!.type, MediaType.tvShow);
  });

  test('windows and status match the collection', () {
    final cinemas = filter(CarouselSection.inTheaters)!;
    expect(cinemas.releasedTo, today);
    expect(cinemas.releasedFrom, today.subtract(const Duration(days: 45)));
    final soon = filter(CarouselSection.comingSoon)!;
    expect(soon.releasedFrom, today.add(const Duration(days: 1)));
    expect(soon.releasedTo, today.add(const Duration(days: 90)));
    expect(
      filter(CarouselSection.airingNow)!.tvStatus,
      DiscoverTvStatus.airing,
    );
    final finished = filter(CarouselSection.finishedShows)!;
    expect(finished.tvStatus, DiscoverTvStatus.ended);
    expect(finished.sortBy, DiscoverSortBy.rating);
    expect(filter(CarouselSection.topRated)!.minVoteCount, 300);
  });
}
