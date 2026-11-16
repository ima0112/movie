import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/stats/library_insights_calculator.dart';
import 'package:movies/core/domain/stats/stats_period.dart';
import 'package:movies/features/stats/presentation/widgets/stats_highlight_card.dart';
import 'package:movies/features/stats/presentation/widgets/stats_highlights.dart';
import 'package:movies/l10n/app_localizations.dart';

final _now = DateTime(2026, 11, 14, 12);

UserMediaEntry _w(
  int id,
  DateTime at, {
  MediaType type = MediaType.movie,
  int? minutes,
  int? episodes,
  int? rating,
}) => UserMediaEntry(
  key: MediaKey(type: type, tmdbId: id),
  title: 'Title $id',
  watchedAt: at,
  runtimeMinutes: minutes,
  episodeCount: episodes,
  episodeRuntimeMinutes: episodes == null ? null : 50,
  rating: rating,
);

Widget _host(List<UserMediaEntry> entries, {Locale? locale}) {
  final insights = calculateInsights(
    entries,
    period: StatsPeriod.allTime,
    now: _now,
  );
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(child: StatsHighlights(insights: insights)),
    ),
  );
}

void main() {
  setUpAll(() {});

  testWidgets('nothing watched and nothing saved: no section at all', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const []));

    expect(find.text('Highlights'), findsNothing);
    expect(find.byType(StatsHighlightCard), findsNothing);
  });

  testWidgets('each card appears only when it has something to say', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host([_w(1, DateTime(2026, 11, 10), minutes: 166, rating: 5)]),
    );

    expect(find.text('Highlights'), findsOneWidget);
    expect(find.text('Busiest month'), findsOneWidget);
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('Longest movie'), findsOneWidget);
    expect(find.text('2 h 46 min'), findsOneWidget);
    expect(find.text('Your top rated'), findsOneWidget);
    expect(find.text('★ 5 of 5'), findsOneWidget);
    // No show, no backlog, a one-week streak with nothing longer.
    expect(find.text('Longest show'), findsNothing);
    expect(find.text('Watch later'), findsNothing);
  });

  testWidgets('streak, longest show and the backlog', (tester) async {
    await tester.pumpWidget(
      _host([
        _w(1, DateTime(2026, 11, 10)),
        _w(2, DateTime(2026, 11, 3)),
        _w(3, DateTime(2026, 10, 27), type: MediaType.tvShow, episodes: 24),
        UserMediaEntry(
          key: const MediaKey(type: MediaType.movie, tmdbId: 9),
          title: 'Later',
          isWatchLater: true,
          runtimeMinutes: 150,
        ),
      ]),
    );

    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('3 weeks'), findsOneWidget);
    expect(find.text('Best: 3 weeks'), findsOneWidget);
    expect(find.text('Longest show'), findsOneWidget);
    expect(find.text('24 episodes · 20 h'), findsOneWidget); // 24 × 50 min
    expect(find.text('Watch later'), findsOneWidget);
    expect(find.text('1 title'), findsWidgets);
    expect(find.text('≈ 3 h to watch'), findsOneWidget);
  });

  testWidgets('a streak that lapsed says so and keeps the best', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host([_w(1, DateTime(2026, 5, 4)), _w(2, DateTime(2026, 5, 11))]),
    );

    expect(find.text('No streak now'), findsOneWidget);
    expect(find.text('Best: 2 weeks'), findsOneWidget);
  });

  testWidgets('the Spanish copy', (tester) async {
    await tester.pumpWidget(
      _host([
        _w(1, DateTime(2026, 11, 10), minutes: 90),
      ], locale: const Locale('es')),
    );

    expect(find.text('Destacados'), findsOneWidget);
    expect(find.text('Mes más activo'), findsOneWidget);
    expect(find.text('Noviembre de 2026'), findsOneWidget);
    expect(find.text('Película más larga'), findsOneWidget);
  });
}
