import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/discover_preset.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/shared/widgets/app_segmented_control.dart';
import 'package:movies/shared/widgets/discover_range_filters.dart';
import 'package:movies/shared/widgets/explore_filter_sheet.dart';
import 'package:movies/shared/widgets/year_range_fields.dart';

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
    expect(find.byType(YearRangeFields), findsOneWidget);
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
    expect(find.byType(YearRangeFields), findsOneWidget);

    await tester.tap(find.text('Coming soon'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(YearRangeFields), findsNothing);

    await tester.tap(find.text('TV Shows'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(YearRangeFields), findsOneWidget);

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

  testWidgets('it stays a bottom sheet: at most 90% of the screen, the filters '
      'scroll inside and "See N results" stays in reach', (tester) async {
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => ExploreFilterSheet.show(
                context,
                initialFilter: const DiscoverFilter(),
                mediaRepository: FakeMediaRepository(),
                regionName: 'United States',
                onApply: (_) {},
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final sheet = tester.getRect(find.byType(ExploreFilterSheet));
    expect(sheet.height, lessThanOrEqualTo(700 * 0.9));
    expect(sheet.top, greaterThan(0));
    final button = tester.getRect(find.textContaining('See '));
    expect(button.bottom, lessThanOrEqualTo(700));
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the kind tabs are the app\'s one segmented control, inset by '
      'the sheet\'s margin only, on a track that shows against the sheet', (
    tester,
  ) async {
    await _pump(tester, onApply: (_) {});

    final control = find.byType(AppSegmentedControl<MediaSegment>);
    expect(control, findsOneWidget);
    expect(
      tester.widget<AppSegmentedControl<MediaSegment>>(control).onSheet,
      isTrue,
    );
    // Same left edge as the section labels (one margin, not two).
    expect(
      tester.getTopLeft(control).dx,
      tester.getTopLeft(find.text('SORT BY')).dx,
    );
  });

  group('the year fields', () {
    testWidgets('a valid range is reported; a wrong one is not and gets the '
        'danger border', (tester) async {
      DiscoverFilter? applied;
      await _pump(tester, onApply: (f) => applied = f);
      final fields = find.descendant(
        of: find.byType(YearRangeFields),
        matching: find.byType(TextField),
      );

      await tester.enterText(fields.first, '1990');
      await tester.enterText(fields.last, '2020');
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.textContaining('See '));
      await tester.pumpAndSettle();
      expect(applied?.yearFrom, 1990);
      expect(applied?.yearTo, 2020);
    });

    testWidgets('a first year after the last, or out of range, is not '
        'reported', (tester) async {
      DiscoverFilter? applied;
      await _pump(
        tester,
        filter: const DiscoverFilter(yearFrom: 1900, yearTo: 2026),
        onApply: (f) => applied = f,
      );
      final fields = find.descendant(
        of: find.byType(YearRangeFields),
        matching: find.byType(TextField),
      );

      await tester.enterText(fields.first, '2027'); // after 2026
      await tester.pump();
      await tester.enterText(fields.last, '1800'); // before 1900
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.textContaining('See '));
      await tester.pumpAndSettle();

      expect(applied?.yearFrom, 1900);
      expect(applied?.yearTo, 2026);
    });

    testWidgets('only digits; a half-typed year is not reported; empty is '
        'an open end', (tester) async {
      DiscoverFilter? applied;
      await _pump(
        tester,
        filter: const DiscoverFilter(yearFrom: 1900, yearTo: 2026),
        onApply: (f) => applied = f,
      );
      final fields = find.descendant(
        of: find.byType(YearRangeFields),
        matching: find.byType(TextField),
      );

      await tester.enterText(fields.first, 'ab');
      await tester.pump();
      expect(tester.widget<TextField>(fields.first).controller!.text, '');

      await tester.enterText(fields.first, '19'); // half typed: kept, unsent
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(fields.first, '1990');
      await tester.enterText(fields.last, '');
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.textContaining('See '));
      await tester.pumpAndSettle();

      expect(applied?.yearFrom, 1990);
      expect(applied?.yearTo, isNull);
    });

    testWidgets('Clear empties both fields', (tester) async {
      await _pump(
        tester,
        filter: const DiscoverFilter(yearFrom: 2000, yearTo: 2010),
        onApply: (_) {},
      );
      final fields = find.descendant(
        of: find.byType(YearRangeFields),
        matching: find.byType(TextField),
      );
      expect(tester.widget<TextField>(fields.first).controller!.text, '2000');

      await tester.tap(find.text('Clear'));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.widget<TextField>(fields.first).controller!.text, '');
      expect(tester.widget<TextField>(fields.last).controller!.text, '');
    });
  });
}
