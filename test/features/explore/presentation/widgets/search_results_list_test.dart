import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/core/domain/entities/search_result.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/explore/presentation/widgets/search_result_rows.dart';
import 'package:movies/shared/widgets/person_result_row.dart';
import 'package:movies/shared/widgets/search_result_tile.dart';
import 'package:movies/features/explore/presentation/widgets/search_results_list.dart';
import 'package:movies/l10n/app_localizations.dart';

final _results = <SearchResult>[
  const PersonResult(
    Person(
      id: 1,
      name: 'Zendaya',
      profilePath: null,
      knownForDepartment: 'Acting',
    ),
  ),
  MediaResult(
    TvShow(
      id: 10,
      title: 'Yellowstone',
      posterUrl: null,
      genres: const [
        Genre(id: 'drama'),
        Genre(id: 'western'),
      ],
      releaseDate: DateTime(2018, 6, 20),
      voteAverage: 8.5,
    ),
  ),
  MediaResult(
    Movie(
      id: 20,
      title: 'Untitled Sequel',
      posterUrl: null,
      genres: const [],
      releaseDate: null,
      voteAverage: 0,
    ),
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  MediaSegment segment = MediaSegment.all,
  VoidCallback? onTap,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SearchResultsList(
          results: _results,
          segment: segment,
          onMediaTap: (_) => onTap?.call(),
          onPersonTap: (_) => onTap?.call(),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a title row is the filmography tile: title, "year · kind · '
      'one genre", the star rating, a chevron, and a hairline', (tester) async {
    await _pump(tester);

    expect(find.text('Yellowstone'), findsOneWidget);
    // One genre only — the first.
    expect(find.text('2018 · TV Show · Drama'), findsOneWidget);
    expect(find.text('Western'), findsNothing);
    expect(find.text('8.5'), findsOneWidget);
    expect(find.byIcon(AppIcons.starFill), findsOneWidget);
    // A chevron on every row.
    expect(find.byIcon(AppIcons.chevronRight), findsNWidgets(_results.length));
    // A hairline under each row.
    final tile = find.ancestor(
      of: find.text('Yellowstone'),
      matching: find.byType(Container),
    );
    final decorated = tester
        .widgetList<Container>(tile)
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.border != null);
    expect(decorated, isNotEmpty);
    expect((decorated.first.border! as Border).bottom.color, AppColors.line);
  });

  testWidgets('with no year, genre or score the row says only what it '
      'knows, and shows no rating line', (tester) async {
    await _pump(tester);
    expect(find.text('Movie'), findsOneWidget); // no year, no genre
    expect(
      find.byIcon(AppIcons.starFill),
      findsOneWidget,
    ); // only Yellowstone's
  });

  testWidgets('rows sit on the page margin; the leading slot is shared by a '
      'poster and a person\'s round photo', (tester) async {
    await _pump(tester);
    expect(tester.getTopLeft(find.byType(SearchResultTile).first).dx, 20);
    final lefts = {
      for (final e in find.byType(SearchResultTile).evaluate())
        tester
            .getTopLeft(
              find
                  .descendant(
                    of: find.byWidget(e.widget),
                    matching: find.byType(SizedBox),
                  )
                  .first,
            )
            .dx,
    };
    expect(lefts, hasLength(1)); // every row's leading slot starts together
  });

  testWidgets('a person row keeps "Department · Person"', (tester) async {
    await _pump(tester);
    expect(find.text('Zendaya'), findsOneWidget);
    expect(find.text('Acting · Person'), findsOneWidget);
  });

  testWidgets('the segment filters: Movies and TV Shows hide people, People '
      'shows only them', (tester) async {
    for (final (segment, titles) in [
      (MediaSegment.all, 3),
      (MediaSegment.movie, 1),
      (MediaSegment.tvShow, 1),
      (MediaSegment.person, 1),
    ]) {
      await _pump(tester, segment: segment);
      expect(
        find.byType(SearchResultTile),
        findsNWidgets(titles),
        reason: '$segment',
      );
    }
    await _pump(tester, segment: MediaSegment.person);
    expect(find.byType(PersonResultRow), findsOneWidget);
    expect(find.byType(MediaResultRow), findsNothing);
  });

  testWidgets('tapping a row reports the tap', (tester) async {
    var taps = 0;
    await _pump(tester, onTap: () => taps++);
    await tester.tap(find.text('Yellowstone'));
    await tester.tap(find.text('Zendaya'));
    expect(taps, 2);
  });
}
