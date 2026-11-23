import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/features/tv_detail/presentation/widgets/season_poster_tile.dart';
import 'package:movies/features/tv_detail/presentation/widgets/seasons_grid.dart';
import 'package:movies/l10n/app_localizations.dart';

SeasonSummary _season(int n, {int episodes = 8, int? year}) => SeasonSummary(
  seasonNumber: n,
  name: n == 0 ? 'Specials' : 'Season $n',
  episodeCount: episodes,
  posterPath: null,
  airDate: year == null ? null : DateTime(year),
);

Widget _host(
  List<SeasonSummary> seasons, {
  void Function(SeasonSummary)? onTap,
  Locale? locale,
  double textScale = 1,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SeasonsGrid(seasons: seasons, onSeasonTap: onTap),
      ),
    ),
  ),
);

void _phone(WidgetTester tester, [double width = 390]) {
  tester.view.physicalSize = Size(width, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('renders nothing when there are no seasons', (tester) async {
    await tester.pumpWidget(_host(const []));
    expect(find.byType(SeasonPosterTile), findsNothing);
  });

  testWidgets('three columns, each tile one third of the width, then the next '
      'row', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _host([_season(1), _season(2), _season(3), _season(4)]),
    );

    final tiles = [
      for (var i = 0; i < 4; i++)
        tester.getRect(find.byType(SeasonPosterTile).at(i)),
    ];
    expect(tiles[0].top, tiles[1].top);
    expect(tiles[1].top, tiles[2].top);
    expect(tiles[3].top, greaterThan(tiles[0].bottom - 1));
    expect(tiles[3].left, tiles[0].left);
    for (final t in tiles) {
      expect(t.width, moreOrLessEquals((350 - 2 * 12) / 3, epsilon: 0.5));
    }
  });

  testWidgets('a tile shows the S1 tag on the poster, the year in bold and '
      'the episode count', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host([_season(1, episodes: 7, year: 2008)]));

    expect(find.text('S1'), findsOneWidget);
    expect(find.text('2008'), findsOneWidget);
    expect(find.text('7 episodes'), findsOneWidget);
    // The year is above the count, and both are under the poster.
    expect(
      tester.getRect(find.text('2008')).bottom,
      lessThanOrEqualTo(tester.getRect(find.text('7 episodes')).top),
    );
  });

  testWidgets('the tag is T1 in Spanish', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _host([_season(1, year: 2008)], locale: const Locale('es')),
    );
    expect(find.text('T1'), findsOneWidget);
    expect(find.text('8 episodios'), findsOneWidget);
  });

  testWidgets('a season with no year shows only its episode count', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(_host([_season(1, episodes: 7)]));

    expect(find.text('7 episodes'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is Text && RegExp(r'^\d{4}$').hasMatch(w.data ?? ''),
      ),
      findsNothing,
    );
  });

  testWidgets('specials sort last and say "Specials"; an empty specials '
      'season is dropped', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _host([_season(0, episodes: 3), _season(1), _season(2)]),
    );
    final tags = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(SeasonPosterTile),
            matching: find.byType(Text),
          ),
        )
        .map((t) => t.data)
        .whereType<String>()
        .toList();
    expect(tags.where((t) => t == 'S1' || t == 'S2' || t == 'Specials'), [
      'S1',
      'S2',
      'Specials',
    ]);

    await tester.pumpWidget(_host([_season(1), _season(0, episodes: 0)]));
    expect(find.text('Specials'), findsNothing);
    expect(find.byType(SeasonPosterTile), findsOneWidget);
  });

  testWidgets('tapping a tile calls onSeasonTap with that season', (
    tester,
  ) async {
    _phone(tester);
    SeasonSummary? tapped;
    final s2 = _season(2);
    await tester.pumpWidget(_host([_season(1), s2], onTap: (s) => tapped = s));

    await tester.tap(find.text('S2'));
    expect(tapped, s2);
  });

  testWidgets('each tile reads as one semantics label', (tester) async {
    _phone(tester);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host([_season(1, episodes: 7, year: 2008)]));
    expect(find.bySemanticsLabel('Season 1, 2008, 7 episodes'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a really small phone at 200% text: no overflow, tiles grow '
      'with their text', (tester) async {
    _phone(tester, 320);
    await tester.pumpWidget(
      _host(
        [_season(1, episodes: 13, year: 2008), _season(2), _season(0)],
        locale: const Locale('es'),
        textScale: 2,
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
