import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/features/you/presentation/cubit/you_stats_cubit.dart';
import 'package:movies/features/you/presentation/widgets/you_stats_card.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/activity_bars.dart';
import 'package:movies/shared/widgets/type_split_bar.dart';

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
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider(
        create: (_) => YouStatsCubit(repo),
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
  testWidgets('nothing watched: an invitation, not a row of zeros', (
    tester,
  ) async {
    await _pump(tester, InMemoryUserLibraryRepository());

    expect(
      find.text('Mark something as watched to see your stats'),
      findsOneWidget,
    );
    expect(find.byType(ActivityBars), findsNothing);
    expect(find.text('See stats'), findsNothing);
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
