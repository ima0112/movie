import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_surprise_history_repository.dart';
import 'package:movies/core/data/local/in_memory_surprise_session_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/surprise_history_entry.dart';
import 'package:movies/core/domain/entities/surprise_session.dart';
import 'package:movies/features/you/presentation/cubit/you_surprise_cubit.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/features/you/presentation/cubit/you_stats_cubit.dart';
import 'package:movies/features/you/presentation/widgets/you_stats_card.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/activity_bars.dart';
import 'package:movies/shared/widgets/type_split_bar.dart';

SurpriseSession _session(String id) => SurpriseSession(
  sessionId: id,
  startedAt: DateTime(2026, 11, 20),
  mediaType: MediaType.movie,
  source: SurpriseSessionSource.quiz,
  yearFrom: 2000,
);

SurpriseHistoryEntry _shown(String session, int id, SurpriseOutcome outcome) =>
    SurpriseHistoryEntry(
      key: MediaKey(type: MediaType.movie, tmdbId: id),
      sessionId: session,
      shownAt: DateTime(2026, 11, 20),
      batch: 1,
      genres: const [],
      outcome: outcome,
    );

UserMediaEntry _watched(
  int id, {
  MediaType type = MediaType.movie,
  int? minutes,
  int? episodes,
  DateTime? at,
}) => UserMediaEntry(
  key: MediaKey(type: type, tmdbId: id),
  title: 'T$id',
  watchedAt: at ?? DateTime.now(),
  runtimeMinutes: minutes,
  episodeCount: episodes,
  episodeRuntimeMinutes: episodes == null ? null : 60,
);

Future<void> _pump(
  WidgetTester tester,
  InMemoryUserLibraryRepository repo, {
  VoidCallback? onSeeStats,
  Locale? locale,
  InMemorySurpriseSessionRepository? sessions,
  InMemorySurpriseHistoryRepository? history,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => YouStatsCubit(repo)),
          BlocProvider(
            create: (_) => YouSurpriseCubit(
              sessions ?? InMemorySurpriseSessionRepository(),
              history ?? InMemorySurpriseHistoryRepository(),
            ),
          ),
        ],
        child: Scaffold(
          body: SingleChildScrollView(
            child: YouStatsCard(onSeeStats: onSeeStats ?? () {}),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('nothing watched and no Surprise me session: no card at all, '
      'and no gap either', (tester) async {
    await _pump(tester, InMemoryUserLibraryRepository());

    expect(find.byType(ActivityBars), findsNothing);
    expect(find.text('See stats'), findsNothing);
    expect(
      find.text('Mark something as watched to see your stats'),
      findsNothing,
    );
    expect(tester.getSize(find.byType(YouStatsCard)).height, 0);
  });

  testWidgets('only Favorites or Watch later is not enough: still no card', (
    tester,
  ) async {
    final repo = InMemoryUserLibraryRepository();
    await repo.upsert(
      const UserMediaEntry(
        key: MediaKey(type: MediaType.movie, tmdbId: 1),
        title: 'Fav',
        isFavorite: true,
        isWatchLater: true,
      ),
    );
    await _pump(tester, repo);

    expect(find.text('See stats'), findsNothing);
    expect(tester.getSize(find.byType(YouStatsCard)).height, 0);
  });

  testWidgets('only Surprise me: its mini summary (sessions and picks) and the '
      'link, without the library numbers', (tester) async {
    final sessions = InMemorySurpriseSessionRepository();
    final history = InMemorySurpriseHistoryRepository();
    await sessions.recordBatch(_session('a'));
    await sessions.recordBatch(_session('b'));
    await history.recordShown([_shown('a', 1, SurpriseOutcome.chosen)]);
    var opened = 0;
    await _pump(
      tester,
      InMemoryUserLibraryRepository(),
      sessions: sessions,
      history: history,
      onSeeStats: () => opened++,
    );

    expect(find.text('SURPRISE ME'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('Picks'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // sessions
    expect(find.text('1'), findsOneWidget); // picks
    expect(find.byType(ActivityBars), findsNothing);
    expect(find.byType(TypeSplitBar), findsNothing);

    await tester.tap(find.text('See stats'));
    expect(opened, 1);
  });

  testWidgets('a session with nothing chosen still counts: 1 session, 0 '
      'picks', (tester) async {
    final sessions = InMemorySurpriseSessionRepository();
    await sessions.recordBatch(_session('a'));
    await _pump(tester, InMemoryUserLibraryRepository(), sessions: sessions);

    expect(find.text('SURPRISE ME'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('both: the library first, Surprise me under it, one link', (
    tester,
  ) async {
    final repo = InMemoryUserLibraryRepository();
    await repo.upsert(_watched(1, minutes: 120));
    final sessions = InMemorySurpriseSessionRepository();
    await sessions.recordBatch(_session('a'));
    await _pump(tester, repo, sessions: sessions);

    expect(find.byType(ActivityBars), findsOneWidget);
    expect(find.text('SURPRISE ME'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(ActivityBars)).dy,
      lessThan(tester.getTopLeft(find.text('SURPRISE ME')).dy),
    );
    expect(
      tester.getTopLeft(find.text('SURPRISE ME')).dy,
      lessThan(tester.getTopLeft(find.text('See stats')).dy),
    );
    expect(find.text('See stats'), findsOneWidget);
  });

  testWidgets('the card appears live when Surprise me is used for the first '
      'time', (tester) async {
    final sessions = InMemorySurpriseSessionRepository();
    await _pump(tester, InMemoryUserLibraryRepository(), sessions: sessions);
    expect(find.text('See stats'), findsNothing);

    await sessions.recordBatch(_session('a'));
    await tester.pumpAndSettle();
    expect(find.text('See stats'), findsOneWidget);
  });

  testWidgets('the four numbers, the split and the 12-month bars', (
    tester,
  ) async {
    final repo = InMemoryUserLibraryRepository();
    // 3 movies (166 min each) and 1 show (10 × 60 min) = ~18 h.
    for (var i = 1; i <= 3; i++) {
      await repo.upsert(_watched(i, minutes: 166).copyWith(isFavorite: i == 1));
    }
    await repo.upsert(_watched(10, type: MediaType.tvShow, episodes: 10));
    await repo.upsert(
      const UserMediaEntry(
        key: MediaKey(type: MediaType.movie, tmdbId: 50),
        title: 'Later',
        isWatchLater: true,
      ),
    );
    await _pump(tester, repo);

    expect(find.text('4'), findsOneWidget); // watched
    expect(find.text('18'), findsOneWidget); // hours
    expect(find.text('1'), findsNWidgets(2)); // favorites, watch later
    expect(find.text('3 movies'), findsOneWidget);
    expect(find.text('1 TV show'), findsOneWidget);
    expect(find.byType(ActivityBars), findsOneWidget);
    expect(find.byType(TypeSplitBar), findsOneWidget);
    expect(find.text('Last 12 months'), findsOneWidget);
  });

  testWidgets('insights: days of screen time, streak and this month appear '
      'only when they have something to say', (tester) async {
    final repo = InMemoryUserLibraryRepository();
    // 48 h of movies: two whole days.
    await repo.upsert(_watched(1, minutes: 48 * 60));
    await _pump(tester, repo);

    expect(find.text('≈ 2 days of screen time'), findsOneWidget);
    expect(find.text('1 week streak'), findsOneWidget);
    expect(find.text('1 this month'), findsOneWidget);

    // A short, old watch: none of the three.
    final old = InMemoryUserLibraryRepository();
    await old.upsert(_watched(2, minutes: 90, at: DateTime(2020, 1, 1)));
    await tester.pumpWidget(const SizedBox()); // a fresh cubit
    await _pump(tester, old);

    expect(find.textContaining('days of screen time'), findsNothing);
    expect(find.textContaining('streak'), findsNothing);
    expect(find.textContaining('this month'), findsNothing);
  });

  testWidgets('See stats calls back, and the numbers follow My List live', (
    tester,
  ) async {
    final repo = InMemoryUserLibraryRepository();
    await repo.upsert(_watched(1, minutes: 120));
    var opened = 0;
    await _pump(tester, repo, onSeeStats: () => opened++);

    await tester.tap(find.text('See stats'));
    expect(opened, 1);

    await repo.upsert(_watched(2, minutes: 120));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsWidgets);
    expect(find.text('2 movies'), findsOneWidget);
  });

  testWidgets('the Spanish copy', (tester) async {
    final repo = InMemoryUserLibraryRepository();
    await repo.upsert(_watched(1, minutes: 48 * 60));
    await _pump(tester, repo, locale: const Locale('es'));

    expect(find.text('≈ 2 días de pantalla'), findsOneWidget);
    expect(find.text('Racha de 1 semana'), findsOneWidget);
    expect(find.text('1 este mes'), findsOneWidget);
    expect(find.text('1 película'), findsOneWidget);
    expect(find.text('Últimos 12 meses'), findsOneWidget);
  });
}
