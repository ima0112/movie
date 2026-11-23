import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/surprise_session.dart';
import 'package:movies/core/domain/entities/surprise_history_entry.dart';
import 'package:movies/core/domain/repositories/surprise_session_repository.dart';
import 'package:movies/core/domain/repositories/surprise_history_repository.dart';
import 'package:movies/core/data/local/in_memory_surprise_session_repository.dart';
import 'package:movies/core/data/local/in_memory_surprise_history_repository.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/features/stats/presentation/screens/stats_screen.dart';
import 'package:movies/features/stats/presentation/widgets/stats_hero_card.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/activity_bars.dart';

UserMediaEntry _watched(
  int id,
  DateTime at, {
  MediaType type = MediaType.movie,
  int? minutes,
  int? episodes,
}) => UserMediaEntry(
  key: MediaKey(type: type, tmdbId: id),
  title: 'T$id',
  watchedAt: at,
  runtimeMinutes: minutes,
  episodeCount: episodes,
  episodeRuntimeMinutes: episodes == null ? null : 60,
);

/// A text inside the lead card (the highlights below repeat some counts).
Finder _inHero(String text) =>
    find.descendant(of: find.byType(StatsHeroCard), matching: find.text(text));

void main() {
  setUpAll(() => configureDependencies(fake.name));

  Future<void> pump(
    WidgetTester tester,
    List<UserMediaEntry> entries, {
    Locale? locale,
    InMemorySurpriseHistoryRepository? history,
    InMemorySurpriseSessionRepository? sessions,
  }) async {
    final library = InMemoryUserLibraryRepository();
    for (final e in entries) {
      await library.upsert(e);
    }
    getIt.unregister<UserLibraryRepository>();
    getIt.registerSingleton<UserLibraryRepository>(library);
    getIt.unregister<SurpriseHistoryRepository>();
    getIt.registerSingleton<SurpriseHistoryRepository>(
      history ?? InMemorySurpriseHistoryRepository(),
    );
    getIt.unregister<SurpriseSessionRepository>();
    getIt.registerSingleton<SurpriseSessionRepository>(
      sessions ?? InMemorySurpriseSessionRepository(),
    );
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StatsScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the old All · Movies · TV Shows filter is gone; the period '
      'control is All time · This year · This month', (tester) async {
    await pump(tester, [_watched(1, DateTime.now(), minutes: 100)]);

    expect(find.text('All time'), findsOneWidget);
    expect(find.text('This year'), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('TV Shows'), findsNothing);
    expect(find.text('Movies'), findsNothing);
  });

  testWidgets('the lead card: hours, titles, activity bars, the movies / TV '
      'split with each one\'s hours', (tester) async {
    await pump(tester, [
      _watched(1, DateTime.now(), minutes: 120),
      _watched(2, DateTime.now(), type: MediaType.tvShow, episodes: 6),
    ]);

    expect(find.byType(StatsHeroCard), findsOneWidget);
    expect(find.text('8 h'), findsOneWidget); // 2 h + 6 × 60 min
    expect(_inHero('2 titles'), findsOneWidget);
    expect(find.byType(ActivityBars), findsOneWidget);
    expect(find.text('1 movie · 2 h'), findsOneWidget);
    expect(find.text('1 TV show · 6 h'), findsOneWidget);
  });

  testWidgets('switching the period recomputes: this month shows only this '
      'month\'s titles, and an empty period says so', (tester) async {
    final now = DateTime.now();
    await pump(tester, [
      _watched(1, DateTime(now.year - 1, 1, 5), minutes: 100),
      _watched(2, DateTime(now.year - 1, 2, 5), minutes: 100),
    ]);
    expect(_inHero('2 titles'), findsOneWidget);

    await tester.tap(find.text('This month'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing watched in this period'), findsOneWidget);
    expect(find.byType(StatsHeroCard), findsNothing);

    await tester.tap(find.text('All time'));
    await tester.pumpAndSettle();
    expect(_inHero('2 titles'), findsOneWidget);
  });

  testWidgets('a comparison chip with the period before (this month vs '
      'last month)', (tester) async {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 10);
    await pump(tester, [
      _watched(1, DateTime(now.year, now.month, 1), minutes: 90),
      _watched(2, DateTime(now.year, now.month, 1), minutes: 90),
      _watched(3, lastMonth, minutes: 90),
    ]);

    await tester.tap(find.text('This month'));
    await tester.pumpAndSettle();

    expect(find.text('+1 vs last month'), findsOneWidget);
  });

  testWidgets('no library at all: the invitation, as before', (tester) async {
    await pump(tester, const []);

    expect(
      find.text('Mark something as watched to see your stats'),
      findsOneWidget,
    );
  });

  testWidgets('the Spanish copy', (tester) async {
    await pump(tester, [
      _watched(1, DateTime.now(), minutes: 100),
    ], locale: const Locale('es'));

    expect(find.text('Todo'), findsOneWidget);
    expect(find.text('Este año'), findsOneWidget);
    expect(find.text('Este mes'), findsOneWidget);
    expect(_inHero('1 título'), findsOneWidget);
  });

  testWidgets('with nothing watched but Surprise-me sessions, the page is the '
      'Surprise-me block, not the empty state', (tester) async {
    final history = InMemorySurpriseHistoryRepository();
    final sessions = InMemorySurpriseSessionRepository();
    await sessions.recordBatch(
      SurpriseSession(
        sessionId: 's',
        startedAt: DateTime.now(),
        mediaType: MediaType.movie,
        source: SurpriseSessionSource.quiz,
        yearFrom: 1950,
      ),
    );
    await history.recordShown([
      SurpriseHistoryEntry(
        key: const MediaKey(type: MediaType.movie, tmdbId: 1),
        sessionId: 's',
        shownAt: DateTime.now(),
        outcome: SurpriseOutcome.chosen,
      ),
    ]);
    await pump(tester, const [], history: history, sessions: sessions);

    expect(find.text('Surprise me'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(
      find.text('Mark something as watched to see your stats'),
      findsNothing,
    );
  });
}
