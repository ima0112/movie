import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/stats/library_insights.dart';
import 'package:movies/core/domain/stats/library_insights_calculator.dart';
import 'package:movies/core/domain/stats/stats_period.dart';
import 'package:movies/features/stats/presentation/widgets/stats_coverage_note.dart';
import 'package:movies/features/stats/presentation/widgets/stats_decades_section.dart';
import 'package:movies/features/stats/presentation/widgets/stats_genres_section.dart';
import 'package:movies/l10n/app_localizations.dart';

final _now = DateTime(2026, 11, 14, 12);

UserMediaEntry _w(
  int id, {
  List<String> genres = const [],
  int? year,
  int? minutes,
}) => UserMediaEntry(
  key: MediaKey(type: MediaType.movie, tmdbId: id),
  title: 'Title $id',
  watchedAt: DateTime(2026, 11, 3),
  genres: [for (final g in genres) Genre(id: g)],
  year: year,
  runtimeMinutes: minutes,
);

LibraryInsights _insights(List<UserMediaEntry> entries) =>
    calculateInsights(entries, period: StatsPeriod.allTime, now: _now);

Widget _host(
  Widget Function(LibraryInsights) build,
  List<UserMediaEntry> e, {
  Locale? locale,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: build(_insights(e)))),
  );
}

void main() {
  testWidgets('genres: name and share of all the genres counted', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        (i) => StatsGenresSection(genres: i.genres, genreTotal: i.genreTotal),
        [
          _w(1, genres: ['drama', 'crime']),
          _w(2, genres: ['drama']),
        ],
      ),
    );

    expect(find.text('Genres you watch most'), findsOneWidget);
    expect(find.text('Drama'), findsOneWidget);
    expect(find.text('67%'), findsOneWidget); // 2 of 3 genres counted
    expect(find.text('33%'), findsOneWidget);
    expect(find.textContaining('Show all'), findsNothing);
  });

  testWidgets('genres: the top six, then "Show all (N)" expands and folds', (
    tester,
  ) async {
    const ids = [
      'action',
      'comedy',
      'crime',
      'drama',
      'family',
      'fantasy',
      'horror',
      'music',
    ];
    await tester.pumpWidget(
      _host(
        (i) => StatsGenresSection(genres: i.genres, genreTotal: i.genreTotal),
        [_w(1, genres: ids)],
      ),
    );
    expect(find.text('Show all (8)'), findsOneWidget);
    expect(find.text('Music'), findsNothing);

    await tester.tap(find.text('Show all (8)'));
    await tester.pump();
    expect(find.text('Music'), findsOneWidget);
    expect(find.text('Show less'), findsOneWidget);

    await tester.tap(find.text('Show less'));
    await tester.pump();
    expect(find.text('Music'), findsNothing);
  });

  testWidgets('no genre data: no section', (tester) async {
    await tester.pumpWidget(
      _host(
        (i) => StatsGenresSection(genres: i.genres, genreTotal: i.genreTotal),
        [_w(1)],
      ),
    );
    expect(find.text('Genres you watch most'), findsNothing);
  });

  testWidgets('decades: one column per decade with its count', (tester) async {
    await tester.pumpWidget(
      _host((i) => StatsDecadesSection(decades: i.decades), [
        _w(1, year: 1994),
        _w(2, year: 1999),
        _w(3, year: 2015),
      ]),
    );

    expect(find.text('By decade'), findsOneWidget);
    expect(find.text('1990s'), findsOneWidget);
    expect(find.text('2010s'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('the coverage note is always there, in both languages', (
    tester,
  ) async {
    final entries = [
      _w(1, genres: ['drama'], year: 2000, minutes: 100),
      _w(2),
    ];
    await tester.pumpWidget(
      _host((i) => StatsCoverageNote(insights: i), entries),
    );
    expect(find.text('Based on 1 of 2 titles with full data.'), findsOneWidget);

    await tester.pumpWidget(
      _host((i) => StatsCoverageNote(insights: i), [
        _w(1, genres: ['drama'], year: 2000, minutes: 100),
      ], locale: const Locale('es')),
    );
    await tester.pump();
    expect(
      find.text('Calculado sobre 1 de 1 título con datos completos.'),
      findsOneWidget,
    );
  });
}
