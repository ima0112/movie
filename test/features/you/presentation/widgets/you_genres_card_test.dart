import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/features/you/presentation/cubit/you_stats_cubit.dart';
import 'package:movies/features/you/presentation/widgets/you_genres_card.dart';
import 'package:movies/l10n/app_localizations.dart';

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
          body: SingleChildScrollView(child: YouGenresCard()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _watch(
  InMemoryUserLibraryRepository repo,
  int id,
  List<Genre> genres,
) => repo.upsert(
  UserMediaEntry(
    key: MediaKey(type: MediaType.movie, tmdbId: id),
    title: 'T$id',
    watchedAt: DateTime(2026, 11, 1),
    genres: genres,
  ),
);

void main() {
  testWidgets('no genres counted: nothing, no gap', (tester) async {
    final repo = InMemoryUserLibraryRepository();
    await _watch(repo, 1, const []);
    await _pump(tester, repo);

    expect(find.text('YOUR MOST-WATCHED GENRES'), findsNothing);
    expect(tester.getSize(find.byType(YouGenresCard)).height, 0);
  });

  testWidgets('each genre with its share of every genre counted', (
    tester,
  ) async {
    final repo = InMemoryUserLibraryRepository();
    const drama = Genre(id: 'drama');
    const crime = Genre(id: 'crime');
    const scifi = Genre(id: 'sci-fi');
    // 8 tags in all: drama 4 (50%), sci-fi 3 (38%), crime 1 (13%).
    await _watch(repo, 1, const [drama, scifi]);
    await _watch(repo, 2, const [drama, scifi]);
    await _watch(repo, 3, const [drama, scifi, crime]);
    await _watch(repo, 4, const [drama]);
    await _pump(tester, repo);

    expect(find.text('YOUR MOST-WATCHED GENRES'), findsOneWidget);
    expect(find.text('Drama'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('38%'), findsOneWidget);
    expect(find.text('13%'), findsOneWidget);
    // Ranked: Drama above Science Fiction above Crime.
    expect(
      tester.getTopLeft(find.text('Drama')).dy,
      lessThan(tester.getTopLeft(find.text('Science Fiction')).dy),
    );
  });

  testWidgets('the Spanish heading', (tester) async {
    final repo = InMemoryUserLibraryRepository();
    await _watch(repo, 1, const [Genre(id: 'drama')]);
    await _pump(tester, repo, locale: const Locale('es'));

    expect(find.text('TUS GÉNEROS MÁS VISTOS'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });
}
