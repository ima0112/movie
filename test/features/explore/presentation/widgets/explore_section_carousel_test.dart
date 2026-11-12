import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/features/explore/domain/explore_section.dart';
import 'package:movies/features/explore/presentation/widgets/explore_section_carousel.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_backdrop_carousel.dart';
import 'package:movies/shared/widgets/media_card.dart';

Movie _movie(int id) => Movie(
  id: id,
  title: 'Movie $id',
  posterUrl: null,
  genres: const [],
  releaseDate: DateTime(2026, 12, 16),
  voteAverage: 8.7,
);

Future<void> _pump(WidgetTester tester, ExploreSection section) async {
  tester.view.physicalSize = const Size(390, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ExploreSectionCarousel(
          section: section,
          items: [_movie(1), _movie(2)],
          segment: MediaSegment.movie,
          onItemTap: (_) {},
        ),
      ),
    ),
  );
}

Size _firstCard(WidgetTester tester) =>
    tester.getSize(find.byType(MediaCard).first);

void main() {
  testWidgets('Top today: large posters with a rank number', (tester) async {
    await _pump(tester, ExploreSection.topToday);
    expect(_firstCard(tester), const Size(150, 225));
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('2'), findsNWidgets(2));
  });

  testWidgets('Popular: the plain standard poster', (tester) async {
    await _pump(tester, ExploreSection.popular);
    expect(_firstCard(tester), const Size(110, 165));
    expect(find.text('1'), findsNothing);
  });

  testWidgets('Top rated: wide backdrop cards with title, year and rating', (
    tester,
  ) async {
    await _pump(tester, ExploreSection.topRated);
    expect(find.byType(MediaBackdropCarousel), findsOneWidget);
    expect(find.byType(MediaCard), findsNothing);
    expect(find.text('Movie 1'), findsOneWidget);
    expect(find.text('2026'), findsWidgets);
    expect(find.text('8.7'), findsWidgets);
    // Much bigger than any poster.
    final card = tester.getSize(find.text('Movie 1').first);
    expect(card, isNotNull);
    final carousel = tester.getSize(find.byType(MediaBackdropCarousel));
    expect(carousel.height, MediaBackdropCarousel.cardHeight);
  });

  testWidgets('New releases: medium posters, no badge', (tester) async {
    await _pump(tester, ExploreSection.newReleases);
    expect(_firstCard(tester), const Size(130, 195));
    expect(find.text('NEW'), findsNothing);
  });

  testWidgets('Coming soon: small posters with the release date under each', (
    tester,
  ) async {
    await _pump(tester, ExploreSection.comingSoon);
    expect(_firstCard(tester), const Size(90, 135));
    expect(find.text('Dec 16'), findsWidgets);
  });

  testWidgets('Hidden gems: medium posters with a rating badge', (
    tester,
  ) async {
    await _pump(tester, ExploreSection.hiddenGems);
    expect(_firstCard(tester), const Size(130, 195));
    expect(find.text('8.7'), findsWidgets);
  });

  testWidgets('the sections really differ in weight, large to small', (
    tester,
  ) async {
    final heights = <ExploreSection, double>{};
    for (final section in ExploreSection.values) {
      await _pump(tester, section);
      heights[section] = section == ExploreSection.topRated
          ? MediaBackdropCarousel.cardHeight
          : tester.getSize(find.byType(MediaCard).first).height;
    }
    expect(
      heights[ExploreSection.topToday]!,
      greaterThan(heights[ExploreSection.popular]!),
    );
    expect(
      heights[ExploreSection.newReleases]!,
      greaterThan(heights[ExploreSection.popular]!),
    );
    expect(
      heights[ExploreSection.comingSoon]!,
      lessThan(heights[ExploreSection.popular]!),
    );
    // All different from the plain baseline except none ties for "most
    // relevant": Top rated's cards are the widest by far.
    expect(
      MediaBackdropCarousel.cardWidth,
      greaterThan(MediaCardSize.carouselLarge.width * 1.5),
    );
  });
}
