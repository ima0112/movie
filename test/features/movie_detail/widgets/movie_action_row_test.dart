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
  });
}
