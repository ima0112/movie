import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/discover_page.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/streaming_service.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/section_listing/domain/listing_source.dart';
import 'package:movies/features/section_listing/domain/listing_style.dart';
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
        ),
      ),
    );
    await _settle(tester);
  }

  testWidgets('shows the title with the count under it, the context pill, '
      'the sort icon and a 3-column grid', (tester) async {
    await pump(
      tester,
      context: const ListingContext.explore(
        segment: MediaSegment.movie,
        genre: Genre(id: 'comedy'),
        platform: StreamingService(id: 8, name: 'Netflix'),
      ),
    );

    expect(find.text('Hidden gems'), findsOneWidget);
    expect(find.text('120 titles'), findsOneWidget); // under the title
    expect(find.textContaining('Default order'), findsNothing); // no summary
    // The pill: the platform's logo (its initial, no image here), a dot, the
    // genre — and not the segment.
    expect(find.text('N'), findsOneWidget);
    expect(find.text('·'), findsOneWidget);
    expect(find.text('Comedy'), findsOneWidget);
    expect(find.text('Movies'), findsNothing);
    expect(find.byIcon(AppIcons.sort), findsOneWidget);
    // Three posters share the first row.
    final first = tester.getTopLeft(find.byType(MediaCard).at(0)).dy;
    expect(tester.getTopLeft(find.byType(MediaCard).at(1)).dy, first);
    expect(tester.getTopLeft(find.byType(MediaCard).at(2)).dy, first);
    expect(
      tester.getTopLeft(find.byType(MediaCard).at(3)).dy,
      greaterThan(first),
    );
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
    await pump(tester);
    expect(tester.getSize(find.byIcon(AppIcons.sort)).width, lessThan(24));
  });

  testWidgets('Explore with no platform shows just the genre; Home shows '
      'only the segment', (tester) async {
    await pump(tester);
    expect(find.text('All genres'), findsOneWidget);
    expect(find.text('·'), findsNothing);

    await pump(tester, context: const ListingContext.home(MediaSegment.tvShow));
    expect(find.text('TV Shows'), findsOneWidget);
    expect(find.textContaining('genres'), findsNothing);
  });

  testWidgets('scrolling to the end loads the next page', (tester) async {
    await pump(tester);
    expect(repo.pages, [1]);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
    await _settle(tester);

    expect(repo.pages.length, greaterThan(1));
    expect(repo.pages, containsAllInOrder([1, 2]));
  });

  testWidgets('each sort dresses the posters its own way', (tester) async {
    // The section's own style is plain: nothing on the posters.
    await pump(tester);
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
}
