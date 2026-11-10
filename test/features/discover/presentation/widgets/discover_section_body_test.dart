import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/features/discover/presentation/widgets/discover_section_body.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_backdrop_carousel.dart';
import 'package:movies/shared/widgets/media_card.dart';

final _items = [
  for (var i = 1; i <= 3; i++)
    Movie(
      id: i,
      title: 'Movie $i',
      posterUrl: null,
      genres: const [],
      releaseDate: DateTime(2026, 3, i),
      voteAverage: 7.5,
    ),
];

Future<void> _pump(WidgetTester tester, CarouselSection section) =>
    tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListView(
            children: [
              DiscoverSectionBody(
                section: section,
                segment: MediaSegment.all,
                items: _items,
              ),
            ],
          ),
        ),
      ),
    );

Size _card(WidgetTester tester) => tester.getSize(find.byType(MediaCard).first);

void main() {
  const sizes = {
    CarouselSection.popularThisWeek: Size(150, 225),
    CarouselSection.trending: Size(150, 225),
    CarouselSection.inTheaters: Size(130, 195),
    CarouselSection.airingNow: Size(130, 195),
    CarouselSection.finishedShows: Size(130, 195),
    CarouselSection.comingSoon: Size(90, 135),
    CarouselSection.upcoming: Size(90, 135),
    CarouselSection.popular: Size(110, 165),
    CarouselSection.watchLater: Size(110, 165),
  };

  for (final entry in sizes.entries) {
    testWidgets('${entry.key.name} uses ${entry.value}', (tester) async {
      await _pump(tester, entry.key);
      expect(_card(tester), entry.value);
    });
  }

  testWidgets('Top rated uses the wide backdrop cards', (tester) async {
    await _pump(tester, CarouselSection.topRated);
    expect(find.byType(MediaBackdropCarousel), findsOneWidget);
    expect(find.byType(MediaCard), findsNothing);
  });

  testWidgets('Coming soon shows the release date under each poster; '
      'Finished shows carry a rating badge', (tester) async {
    await _pump(tester, CarouselSection.comingSoon);
    expect(find.text('Mar 1, 2026'), findsOneWidget);

    await _pump(tester, CarouselSection.finishedShows);
    expect(find.text('7.5'), findsWidgets);
  });
}
