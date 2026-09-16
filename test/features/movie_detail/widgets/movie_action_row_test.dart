import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/movie_detail/presentation/cubit/movie_detail_cubit.dart';
import 'package:movies/features/movie_detail/presentation/widgets/movie_action_row.dart';

const _dune = MediaKey(type: MediaType.movie, tmdbId: 1);

void main() {
  group('MovieActionRow', () {
    testWidgets('tapping Watched opens the Mark as watched sheet instead of '
        'upserting directly', (tester) async {
      final userLibraryRepository = InMemoryUserLibraryRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider(
              create: (_) =>
                  MovieDetailCubit(FakeMediaRepository())..loadDetail(_dune),
              child: MovieActionRow(
                mediaKey: _dune,
                userLibraryRepository: userLibraryRepository,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Watched'));
      await tester.pumpAndSettle();

      // The bug: tapping "Watched" used to upsert immediately. It
      // must not — only the sheet's own "Save" does that.
      expect(await userLibraryRepository.watchEntry(_dune).first, isNull);
      expect(find.text('Mark as watched'), findsOneWidget);
    });

    testWidgets(
      'Watched → Save populates runtimeMinutes from the already-loaded '
      "MovieDetail, with no extra fetch",
      (tester) async {
        final userLibraryRepository = InMemoryUserLibraryRepository();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (_) =>
                    MovieDetailCubit(FakeMediaRepository())..loadDetail(_dune),
                child: MovieActionRow(
                  mediaKey: _dune,
                  userLibraryRepository: userLibraryRepository,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        // FakeMediaRepository's own fake network delay: pumpAndSettle()
        // alone doesn't reliably advance far enough past it before the
        // tap below fires (nothing keeps scheduling frames while
        // MovieDetailLoading just sits there), so the row could still
        // read a stale MovieDetailLoading state at tap-time otherwise.
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(find.text('Watched'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // FakeMediaRepository's sample movie (tmdbId 1) has
        // runtimeMinutes: 166.
        final saved = await userLibraryRepository.watchEntry(_dune).first;
        expect(saved!.runtimeMinutes, 166);
      },
    );

    testWidgets(
      'tapping Favorite on a brand-new entry populates genres from the '
      'already-loaded MediaDetail',
      (tester) async {
        final userLibraryRepository = InMemoryUserLibraryRepository();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (_) =>
                    MovieDetailCubit(FakeMediaRepository())..loadDetail(_dune),
                child: MovieActionRow(
                  mediaKey: _dune,
                  userLibraryRepository: userLibraryRepository,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(find.text('Favorite'));
        await tester.pumpAndSettle();

        // FakeMediaRepository's sample movie (tmdbId 1) has
        // genres: [_sciFi, _drama].
        final saved = await userLibraryRepository.watchEntry(_dune).first;
        expect(saved!.genres.map((g) => g.id), ['sci-fi', 'drama']);
      },
    );

    testWidgets('Watched → Save also populates genres from the already-loaded '
        'MediaDetail', (tester) async {
      final userLibraryRepository = InMemoryUserLibraryRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider(
              create: (_) =>
                  MovieDetailCubit(FakeMediaRepository())..loadDetail(_dune),
              child: MovieActionRow(
                mediaKey: _dune,
                userLibraryRepository: userLibraryRepository,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Watched'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final saved = await userLibraryRepository.watchEntry(_dune).first;
      expect(saved!.genres.map((g) => g.id), ['sci-fi', 'drama']);
    });
  });
}
