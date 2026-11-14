import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/discover_page.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/shared/widgets/listing_platform_logo.dart';
import 'package:movies/shared/widgets/poster_badge.dart';
import 'package:movies/shared/widgets/streaming_service_logo.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/streaming_service.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/section_listing/domain/listing_source.dart';
import 'package:movies/features/section_listing/domain/listing_style.dart';
import 'package:movies/features/section_listing/presentation/widgets/listing_context_pill.dart';
import 'package:movies/features/section_listing/presentation/screens/section_listing_screen.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_card.dart';
import 'package:movies/shared/widgets/scroll_edge_fade.dart';

Movie _movie(int id) => Movie(
  id: id,
  title: 'Movie $id',
  posterUrl: null,
  genres: const [],
  releaseDate: DateTime(2026, 12, 16),
  voteAverage: 8.5,
);

class _Repo extends FakeMediaRepository {
  int totalPages = 4;
  static const perPage = 30;
  final pages = <int>[];
  final providerAsks = <int>[];
  bool failFirst = false;
  bool empty = false;

  @override
  Future<Result<DiscoverPage>> discoverPage(
    DiscoverFilter filter, {
    int page = 1,
  }) async {
    pages.add(page);
    if (failFirst) return Failure(FailureReason.network);
    if (empty) return const Success(DiscoverPage.empty);
    return Success(
      DiscoverPage(
        items: [
          for (var i = 0; i < perPage; i++)
            _movie((page - 1) * perPage + i + 1),
        ],
        page: page,
        totalPages: totalPages,
        totalResults: totalPages * perPage,
      ),
    );
  }

  @override
  Future<Result<List<StreamingService>>> streamingProvidersFor(MediaKey key) {
    providerAsks.add(key.tmdbId);
    return super.streamingProvidersFor(key);
  }

  @override
  Future<Result<DiscoverPage>> carouselSectionPage(
    CarouselSection section, {
    type,
    int page = 1,
  }) => discoverPage(const DiscoverFilter(), page: page);
}

/// `pumpAndSettle` never settles here: the next-page spinner animates for as
/// long as there is another page.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late _Repo repo;
  final today = DateTime(2026, 5, 4);

  setUp(() {
    configureDependencies(fake.name);
    repo = _Repo();
    getIt.unregister<MediaRepository>();
    getIt.registerSingleton<MediaRepository>(repo);
  });
  tearDown(getIt.reset);

  Future<void> pump(
    WidgetTester tester, {
    ListingSource? source,
    ListingStyle style = ListingStyle.plain,
    ListingContext? context,
    bool sort = false,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SectionListingScreen(
          title: 'Hidden gems',
          source: source ?? FilterListing(const DiscoverFilter(), today: today),
          style: style,
          listingContext:
              context ??
              const ListingContext.explore(segment: MediaSegment.all),
          sortEnabled: sort,
        ),
      ),
    );
    await _settle(tester);
  }

  testWidgets('shows the title, an amber pill (platform, genre) and a 3-column '
      'grid — and, for now, no sort icon', (tester) async {
    await pump(
      tester,
      context: const ListingContext.explore(
        segment: MediaSegment.movie,
        genre: Genre(id: 'comedy'),
        platform: StreamingService(id: 8, name: 'Netflix'),
      ),
    );

    expect(find.text('Hidden gems'), findsOneWidget);
    expect(find.textContaining('titles'), findsNothing); // not under the title
    // The pill: the platform's logo (its initial, no image here), a dot and
    // the genre — no count (a listing is never longer than 100), no segment.
    expect(find.text('N'), findsOneWidget);
    expect(find.text('·'), findsOneWidget);
    expect(find.text('Comedy'), findsOneWidget);
    expect(find.text('100'), findsNothing);
    expect(find.text('Movies'), findsNothing);
    // The app's selected-pill look: dark amber tint, amber hairline, amber
    // text.
    final pill = tester.widget<Container>(
      find
          .ancestor(of: find.text('Comedy'), matching: find.byType(Container))
          .first,
    );
    final decoration = pill.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.accentSoft);
    expect((decoration.border! as Border).top.color, AppColors.accentLine);
    expect(
      tester.widget<Text>(find.text('Comedy')).style!.color,
      AppColors.accent,
    );
    expect(find.byIcon(AppIcons.sort), findsNothing); // off for now
    // Three posters share the first row.
    final first = tester.getTopLeft(find.byType(MediaCard).at(0)).dy;
    expect(tester.getTopLeft(find.byType(MediaCard).at(1)).dy, first);
    expect(tester.getTopLeft(find.byType(MediaCard).at(2)).dy, first);
    expect(
      tester.getTopLeft(find.byType(MediaCard).at(3)).dy,
      greaterThan(first),
    );
  });

  testWidgets('with sorting off the pill is centered in the row, with room '
      'below it before the grid', (tester) async {
    await pump(tester);
    final pill = tester.getRect(
      find
          .ancestor(
            of: find.text('All genres'),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(pill.center.dx, closeTo(390 / 2, 1));
    final firstPoster = tester.getRect(find.byType(MediaCard).first);
    // Clear of the grid's top fade (a page gap) plus the grid's own padding.
    expect(firstPoster.top - pill.bottom, greaterThanOrEqualTo(32));
  });

  testWidgets('the sort icon sits at the right end of the row, lined up with '
      'the grid\'s right edge', (tester) async {
    await pump(tester, sort: true);
    final icon = tester.getRect(find.byIcon(AppIcons.sort));
    final grid = tester.getRect(find.byType(MediaCard).at(2));
    expect(icon.right, closeTo(grid.right, 0.5));
    // And the pill is at the left, on the page margin.
    final pill = tester.getRect(find.text('All genres'));
    expect(pill.left, greaterThan(20));
  });

  testWidgets('the grid fades out under the toolbar as it scrolls', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byType(ScrollEdgeFade), findsOneWidget);
  });

  testWidgets('the sort icon is smaller than a default icon button', (
    tester,
  ) async {
    await pump(tester, sort: true);
    expect(tester.getSize(find.byIcon(AppIcons.sort)).width, lessThan(24));
  });

  testWidgets('Explore with no platform shows just the genre; Home shows no '
      'pill at all (not even the segment)', (tester) async {
    await pump(tester);
    expect(find.text('All genres'), findsOneWidget);
    expect(find.text('·'), findsNothing);

    await pump(tester, context: const ListingContext.home(MediaSegment.tvShow));
    expect(find.byType(ListingContextPill), findsNothing);
    expect(find.text('TV Shows'), findsNothing);
    expect(find.textContaining('genres'), findsNothing);
    // The grid starts right under the title bar, with its own top padding.
    expect(find.byType(MediaCard), findsWidgets);
  });

  testWidgets('scrolling to the end loads the next page', (tester) async {
    await pump(tester);
    expect(repo.pages, [1]);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -6000));
    await _settle(tester);

    expect(repo.pages.length, greaterThan(1));
    expect(repo.pages, containsAllInOrder([1, 2]));
  });

  testWidgets('each sort dresses the posters its own way', (tester) async {
    // The section's own style is plain: nothing on the posters.
    await pump(tester, sort: true);
    expect(find.text('8.5'), findsNothing);
    expect(find.text('2026'), findsNothing);

    Future<void> chooseSort(String label) async {
      await tester.tap(find.byIcon(AppIcons.sort));
      await _settle(tester);
      await tester.tap(find.text(label));
      await _settle(tester);
    }

    await chooseSort('Popularity'); // a small rank in each corner
    expect(find.text('1'), findsWidgets);
    expect(find.text('2'), findsWidgets);

    await chooseSort('Rating'); // the star badge, no ranks
    expect(find.text('8.5'), findsWidgets);
    expect(find.text('1'), findsNothing);

    await chooseSort('Most voted'); // the title over each poster
    expect(find.text('Movie 1'), findsWidgets);
    expect(find.text('8.5'), findsNothing);

    await chooseSort('Newest first'); // the year
    expect(find.text('2026'), findsWidgets);
    expect(find.text('Movie 1'), findsNothing);

    await chooseSort('Default order'); // back to the section's own (plain)
    expect(find.text('2026'), findsNothing);
  });

  testWidgets(
    're-sorting keeps the same list: the whole set is there and nothing '
    'more is being paged in',
    (tester) async {
      await pump(tester, sort: true);

      await tester.tap(find.byIcon(AppIcons.sort));
      await _settle(tester);
      await tester.tap(find.text('Rating'));
      await _settle(tester);

      // Scrolled to the very end: no next-page spinner, the set is all there.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -20000));
      await _settle(tester);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(repo.pages.toSet(), {1, 2, 3, 4}); // the pages the set needed
    },
  );

  testWidgets('a section keeps its own dressing in its own order', (
    tester,
  ) async {
    await pump(tester, style: ListingStyle.ranked);
    expect(find.text('1'), findsWidgets);
    await pump(tester, style: ListingStyle.rating);
    expect(find.text('8.5'), findsWidgets);
    await pump(tester, style: ListingStyle.dated);
    expect(find.text('Dec 16, 2026'), findsWidgets);
  });

  testWidgets('the detailed style (Hidden gems): the rating on the poster and '
      'the title and year under it, still three to a row', (tester) async {
    await pump(tester, style: ListingStyle.detailed);

    expect(find.text('Movie 1'), findsOneWidget);
    expect(find.text('2026'), findsWidgets);
    expect(find.text('8.5'), findsWidgets);
    final poster = tester.getRect(find.byType(MediaCard).first);
    expect(
      tester.getTopLeft(find.text('Movie 1')).dy,
      greaterThan(poster.bottom - 1),
    );
    final first = tester.getTopLeft(find.byType(MediaCard).at(0)).dy;
    expect(tester.getTopLeft(find.byType(MediaCard).at(2)).dy, first);
    expect(
      tester.getTopLeft(find.byType(MediaCard).at(3)).dy,
      greaterThan(first),
    );
    expect(tester.takeException(), isNull); // no overflow
  });

  test('listingStyleFor: each sort brings its style; the section\'s own '
      'order keeps the section\'s', () {
    expect(
      listingStyleFor(ListingSort.byDefault, ListingStyle.dated),
      ListingStyle.dated,
    );
    expect(
      listingStyleFor(ListingSort.popularity, ListingStyle.plain),
      ListingStyle.ranked,
    );
    expect(
      listingStyleFor(ListingSort.rating, ListingStyle.plain),
      ListingStyle.rating,
    );
    expect(
      listingStyleFor(ListingSort.mostVoted, ListingStyle.rating),
      ListingStyle.titled,
    );
    expect(
      listingStyleFor(ListingSort.newest, ListingStyle.plain),
      ListingStyle.year,
    );
    // A section that already shows dates keeps the full date.
    expect(
      listingStyleFor(ListingSort.newest, ListingStyle.dated),
      ListingStyle.dated,
    );
  });

  testWidgets('an unreleased window offers a shorter sort list', (
    tester,
  ) async {
    await pump(
      tester,
      source: FilterListing(
        DiscoverFilter(releasedFrom: DateTime(2026, 6, 1)),
        today: today,
      ),
      sort: true,
    );
    await tester.tap(find.byIcon(AppIcons.sort));
    await _settle(tester);
    expect(find.text('Default order'), findsOneWidget);
    expect(find.text('Rating'), findsNothing);
    expect(find.text('Most voted'), findsNothing);
  });

  testWidgets('error and empty states', (tester) async {
    repo.failFirst = true;
    await pump(tester);
    expect(find.text('Retry'), findsOneWidget);

    repo
      ..failFirst = false
      ..empty = true;
    await tester.tap(find.text('Retry'));
    await _settle(tester);
    expect(find.text('Nothing to show here'), findsOneWidget);
  });

  group('the platform each title streams on', () {
    testWidgets('with no genre and no platform picked, each poster shows its '
        'platform\'s logo in the top-right corner', (tester) async {
      await pump(tester);

      final logos = find.byType(ListingPlatformLogo);
      expect(logos, findsWidgets);
      // Netflix (the fake gives it to even ids) — its initial, no image here.
      expect(find.byType(StreamingServiceLogo), findsWidgets);
      final poster = tester.getRect(find.byType(MediaCard).at(1)); // id 2
      final logo = tester.getRect(
        find.descendant(
          of: find.byType(ListingPlatformLogo).at(1),
          matching: find.byType(StreamingServiceLogo),
        ),
      );
      expect(logo.right, lessThan(poster.right));
      expect(logo.top, greaterThan(poster.top));
      expect(logo.center.dx, greaterThan(poster.center.dx));
      expect(logo.center.dy, lessThan(poster.center.dy));
    });

    testWidgets('a poster asks for its title\'s providers once, and only the '
        'posters that are built ask', (tester) async {
      await pump(tester);
      final asked = [...repo.providerAsks];
      expect(asked.toSet(), hasLength(asked.length));
      expect(asked.length, lessThan(30)); // not every title of the list

      await _settle(tester);
      expect(repo.providerAsks, asked); // no repeats on rebuilds
    });

    testWidgets('never over another dressing: the rating badge, the rank and '
        'the date sit on other corners', (tester) async {
      Rect logoOf(int index) => tester.getRect(
        find
            .descendant(
              of: find.byType(ListingPlatformLogo).at(index),
              matching: find.byType(StreamingServiceLogo),
            )
            .first,
      );

      // Poster 2 (an even id: it has a logo) in each dressing, and the thing
      // that dressing draws.
      final cases = <(ListingStyle, Finder)>[
        (ListingStyle.rating, find.byType(PosterBadge)),
        (ListingStyle.detailed, find.byType(PosterBadge)),
        (ListingStyle.ranked, find.text('2')),
        (ListingStyle.dated, find.text('Dec 16, 2026')),
      ];
      for (final (style, dressing) in cases) {
        await pump(tester, style: style);
        final logo = logoOf(1);
        final poster = tester.getRect(find.byType(MediaCard).at(1));
        final onThatPoster = dressing.evaluate().where(
          (e) => poster.overlaps(tester.getRect(find.byWidget(e.widget))),
        );
        expect(onThatPoster, isNotEmpty, reason: '$style draws something');
        for (final e in onThatPoster) {
          expect(
            tester.getRect(find.byWidget(e.widget)).overlaps(logo),
            isFalse,
            reason: '$style overlaps the platform logo',
          );
        }
      }
    });

    testWidgets('a genre picked with the platform left on All still shows '
        'the logos; a platform picked, or Home, does not', (tester) async {
      await pump(
        tester,
        context: const ListingContext.explore(
          segment: MediaSegment.all,
          genre: Genre(id: 'comedy'),
        ),
      );
      expect(find.byType(ListingPlatformLogo), findsWidgets);
      expect(find.text('Comedy'), findsOneWidget); // the pill still says so

      repo.providerAsks.clear();
      await pump(
        tester,
        context: const ListingContext.explore(
          segment: MediaSegment.all,
          genre: Genre(id: 'comedy'),
          platform: StreamingService(id: 8, name: 'Netflix'),
        ),
      );
      expect(find.byType(ListingPlatformLogo), findsNothing);

      await pump(tester, context: const ListingContext.home(MediaSegment.all));
      expect(find.byType(ListingPlatformLogo), findsNothing);
      expect(repo.providerAsks, isEmpty);
    });
  });
}
