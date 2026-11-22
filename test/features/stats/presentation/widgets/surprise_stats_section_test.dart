import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/surprise_history_entry.dart';
import 'package:movies/core/domain/entities/surprise_session.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/stats/stats_period.dart';
import 'package:movies/core/domain/stats/surprise_insights.dart';
import 'package:movies/core/domain/stats/surprise_insights_calculator.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/stats/presentation/widgets/surprise/surprise_stats_section.dart';
import 'package:movies/l10n/app_localizations.dart';

final _now = DateTime(2026, 11, 18);
MediaKey _m(int id) => MediaKey(type: MediaType.movie, tmdbId: id);

SurpriseInsights _insights({bool withChoice = true}) {
  final at = DateTime(2026, 11, 3);
  return calculateSurpriseInsights(
    now: _now,
    period: StatsPeriod.allTime,
    sessions: [
      SurpriseSession(
        sessionId: 'a',
        startedAt: at,
        mediaType: MediaType.movie,
        source: SurpriseSessionSource.quiz,
        yearFrom: 1950,
        collectionIds: const {'anime'},
        vibeIds: const {'revenge'},
        relaxations: const {'dropVibes'},
      ),
      SurpriseSession(
        sessionId: 'b',
        startedAt: at,
        mediaType: MediaType.movie,
        source: SurpriseSessionSource.profile,
        yearFrom: 1950,
      ),
    ],
    history: [
      SurpriseHistoryEntry(
        key: _m(1),
        sessionId: 'a',
        shownAt: at,
        batch: withChoice ? 2 : 1,
        outcome: withChoice ? SurpriseOutcome.chosen : SurpriseOutcome.viewed,
        genres: const [Genre(id: 'western')],
      ),
    ],
    library: [
      UserMediaEntry(
        key: _m(1),
        title: 'Cowboy Bebop: The Movie',
        watchedAt: DateTime(2026, 11, 10),
        rating: 5,
        genres: const [Genre(id: 'western')],
      ),
      UserMediaEntry(
        key: _m(10),
        title: 'Usual',
        watchedAt: DateTime(2026, 10, 10),
        genres: const [Genre(id: 'drama')],
      ),
    ],
  );
}

Widget _host(SurpriseInsights insights, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      theme: AppTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: SurpriseStatsSection(insights: insights),
        ),
      ),
    );

void main() {
  testWidgets('the six blocks, each with its own heading and numbers', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(_insights()));

    expect(find.text('Surprise me'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget); // 1 of 2 sessions
    expect(find.text('2 sessions · 1 pick'), findsOneWidget);
    expect(find.text('What happened to your picks'), findsOneWidget);
    expect(find.text('1 of 1'), findsWidgets); // watched
    expect(find.text('Cowboy Bebop: The Movie'), findsWidgets);
    expect(find.text('New to you'), findsOneWidget);
    expect(find.text('New: Western'), findsOneWidget);
    expect(find.text('Your picks by genre'), findsOneWidget);
    expect(find.text('What you ask for'), findsOneWidget);
    expect(find.text('Your rhythm'), findsOneWidget);
    expect(
      find.text('1 session had to widen the search (no vibes)'),
      findsOneWidget,
    );
  });

  testWidgets('with no choice the picks, discoveries and genre-of-picks '
      'blocks still say what they can, and the "after" block is absent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(_insights(withChoice: false)));

    expect(find.text('0%'), findsOneWidget);
    expect(find.text('What happened to your picks'), findsNothing);
    expect(find.text('New to you'), findsNothing);
  });

  testWidgets('no session: nothing is drawn', (tester) async {
    await tester.pumpWidget(
      _host(
        calculateSurpriseInsights(
          history: const [],
          sessions: const [],
          library: const [],
          period: StatsPeriod.allTime,
          now: _now,
        ),
      ),
    );
    expect(find.text('Surprise me'), findsNothing);
  });

  testWidgets('Spanish, on a small phone at 200% text: no overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: SurpriseStatsSection(insights: _insights()),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Sorpréndeme'), findsOneWidget);
    expect(find.text('Qué pasó con lo que elegiste'), findsOneWidget);
  });
}
