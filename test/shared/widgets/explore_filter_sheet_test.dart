import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/discover_preset.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/discover_range_filters.dart';
import 'package:movies/shared/widgets/explore_filter_sheet.dart';

Future<void> _pump(
  WidgetTester tester, {
  DiscoverFilter filter = const DiscoverFilter(),
  required ValueChanged<DiscoverFilter> onApply,
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ExploreFilterSheet(
          initialFilter: filter,
          mediaRepository: FakeMediaRepository(),
          regionName: 'United States',
          onApply: onApply,
        ),
      ),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('the kind tabs, then sort, streaming, genres, years, rating and '
      'original language — and no runtime or status', (tester) async {
    await _pump(tester, onApply: (_) {});

    final labels = [
      'SORT BY',
      'GENRES',
      'YEARS',
      'RATING',
      'ORIGINAL LANGUAGE',
    ];
    final tops = [for (final l in labels) tester.getTopLeft(find.text(l)).dy];
    expect(tops, orderedEquals([...tops]..sort()));
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Top rated'), findsOneWidget);
    expect(find.text('Release date'), findsOneWidget);
    expect(find.text('All'), findsWidgets);
    expect(find.text('Movies'), findsWidgets);
    expect(find.text('TV Shows'), findsWidgets);
    expect(find.text('MAX RUNTIME'), findsNothing);
    expect(find.text('STATUS'), findsNothing);
    expect(find.byType(YearRangeFilter), findsOneWidget);
    expect(find.byType(RatingRangeFilter), findsOneWidget);
  });

  testWidgets('Clear only shows while something is set, and goes back to the '
      'default of the same segment', (tester) async {
    DiscoverFilter? applied;
    await _pump(
      tester,
      filter: const DiscoverFilter(type: MediaType.movie),
      onApply: (f) => applied = f,
    );
    expect(find.text('Clear'), findsNothing);

    await tester.tap(find.text('Top rated'));
    await tester.pump();
    expect(find.text('Clear'), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Clear'), findsNothing);

    await tester.tap(find.textContaining('See '));
    await tester.pumpAndSettle();
    expect(applied, const DiscoverFilter(type: MediaType.movie));
  });

  testWidgets('applying reports the draft; swiping closed would not', (
    tester,
  ) async {
    DiscoverFilter? applied;
    await _pump(tester, onApply: (f) => applied = f);

    await tester.tap(find.text('Top rated'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.textContaining('See '));
    await tester.pumpAndSettle();

    expect(applied?.sortBy, DiscoverSortBy.rating);
  });

  testWidgets('Sort by adds the presets of the kind: movies Coming soon and '
      'In theaters, shows Finished and Airing now, All none', (tester) async {
    await _pump(tester, onApply: (_) {});
    expect(find.text('Coming soon'), findsNothing);
    expect(find.text('Finished'), findsNothing);

    await tester.tap(find.text('Movies'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.text('In theaters'), findsOneWidget);
    expect(find.text('Finished'), findsNothing);

    await tester.tap(find.text('TV Shows'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Finished'), findsOneWidget);
    expect(find.text('Airing now'), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
    await tester.pump(const Duration(seconds: 2)); // the count's debounce
  });

  testWidgets('a release-window preset hides the years; changing the kind '
      'drops the preset', (tester) async {
    DiscoverFilter? applied;
    await _pump(
      tester,
      filter: const DiscoverFilter(type: MediaType.movie),
      onApply: (f) => applied = f,
    );
    expect(find.byType(YearRangeFilter), findsOneWidget);

    await tester.tap(find.text('Coming soon'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(YearRangeFilter), findsNothing);

    await tester.tap(find.text('TV Shows'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(YearRangeFilter), findsOneWidget);

    await tester.tap(find.textContaining('See '));
    await tester.pumpAndSettle();
    expect(applied?.type, MediaType.tvShow);
    expect(applied?.preset, isNull);
    expect(applied?.releasedFrom, isNull);
  });

  testWidgets('Finished sets the TV status; the original language is picked '
      'from its chips', (tester) async {
    DiscoverFilter? applied;
    await _pump(
      tester,
      filter: const DiscoverFilter(type: MediaType.tvShow),
      onApply: (f) => applied = f,
    );

    await tester.tap(find.text('Finished'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Español'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.textContaining('See '));
    await tester.pumpAndSettle();

    expect(applied?.tvStatus, DiscoverTvStatus.ended);
    expect(applied?.originalLanguage, 'es');
  });
}
