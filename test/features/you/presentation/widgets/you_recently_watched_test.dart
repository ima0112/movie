import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/features/you/presentation/cubit/you_stats_cubit.dart';
import 'package:movies/features/you/presentation/widgets/you_recently_watched.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_card.dart';

Future<void> _pump(
  WidgetTester tester,
  InMemoryUserLibraryRepository repo, {
  Locale? locale,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider(
        create: (_) => YouStatsCubit(repo),
        child: const Scaffold(
          body: SingleChildScrollView(child: YouRecentlyWatched()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _watch(
  InMemoryUserLibraryRepository repo,
  int id,
  DateTime at, {
  MediaType type = MediaType.movie,
}) => repo.upsert(
  UserMediaEntry(
    key: MediaKey(type: type, tmdbId: id),
    title: 'T$id',
    watchedAt: at,
  ),
);

void main() {
  testWidgets('nothing watched: no heading, no row', (tester) async {
    await _pump(tester, InMemoryUserLibraryRepository());

    expect(find.text('Recently watched'), findsNothing);
    expect(find.byType(MediaCard), findsNothing);
  });

  testWidgets('the last titles, newest first, with the TV tag on shows', (
    tester,
  ) async {
    final repo = InMemoryUserLibraryRepository();
    await _watch(repo, 1, DateTime(2026, 11, 1));
    await _watch(repo, 2, DateTime(2026, 11, 8), type: MediaType.tvShow);
    await _watch(repo, 3, DateTime(2026, 11, 5));
    await _pump(tester, repo);

    expect(find.text('Recently watched'), findsOneWidget);
    final cards = tester.widgetList<MediaCard>(find.byType(MediaCard)).toList();
    expect(cards.map((c) => c.title), ['T2', 'T3', 'T1']);
    expect(cards.first.showTypeTag, isTrue);
    expect(cards.last.showTypeTag, isFalse);
  });

  testWidgets('at most six', (tester) async {
    final repo = InMemoryUserLibraryRepository();
    for (var i = 1; i <= 9; i++) {
      await _watch(repo, i, DateTime(2026, 10, i));
    }
    await _pump(tester, repo);

    // A horizontal list builds lazily, but never has more than six items.
    final list = tester.widget<ListView>(find.byType(ListView));
    expect(list.semanticChildCount, 6);
  });

  testWidgets('Spanish heading', (tester) async {
    final repo = InMemoryUserLibraryRepository();
    await _watch(repo, 1, DateTime(2026, 11, 1));
    await _pump(tester, repo, locale: const Locale('es'));

    expect(find.text('Vistas recientemente'), findsOneWidget);
  });
}
