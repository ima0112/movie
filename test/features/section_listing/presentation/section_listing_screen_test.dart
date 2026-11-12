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

  testWidgets('shows the title, the context pill, the sort icon and a 3-column '
      'grid', (tester) async {
    await pump(
      tester,
      context: const ListingContext.explore(
        segment: MediaSegment.movie,
        genre: Genre(id: 'comedy'),
        platform: StreamingService(id: 8, name: 'Netflix'),
      ),
    );

    expect(find.text('Hidden gems'), findsOneWidget);
    expect(find.text('Movies · Comedy · Netflix'), findsOneWidget);
    expect(find.byIcon(AppIcons.sort), findsOneWidget);
    expect(find.textContaining('120 titles'), findsOneWidget);
    // Three posters share the first row.
    final first = tester.getTopLeft(find.byType(MediaCard).at(0)).dy;
    expect(tester.getTopLeft(find.byType(MediaCard).at(1)).dy, first);
    expect(tester.getTopLeft(find.byType(MediaCard).at(2)).dy, first);
    expect(
      tester.getTopLeft(find.byType(MediaCard).at(3)).dy,
      greaterThan(first),
    );
  });

  testWidgets('Explore with nothing narrowed says so; Home shows only the '
      'segment', (tester) async {
    await pump(tester);
    expect(find.text('All genres · All platforms'), findsOneWidget);

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

  testWidgets('a rank shows in the section\'s own order and goes away once '
      're-sorted', (tester) async {
    await pump(tester, style: ListingStyle.ranked);
    expect(find.text('1'), findsWidgets);

    await tester.tap(find.byIcon(AppIcons.sort));
    await _settle(tester);
    await tester.tap(find.text('Popularity'));
    await _settle(tester);

    expect(find.text('1'), findsNothing);
  });

  testWidgets('rating and dated styles dress the posters', (tester) async {
    await pump(tester, style: ListingStyle.rating);
    expect(find.text('8.5'), findsWidgets);

    await pump(tester, style: ListingStyle.dated);
    expect(find.text('Dec 16, 2026'), findsWidgets);
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
