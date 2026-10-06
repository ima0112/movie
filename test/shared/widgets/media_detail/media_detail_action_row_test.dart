import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/shared/widgets/media_detail/media_detail_action_row.dart';

const _dune = MediaKey(type: MediaType.movie, tmdbId: 1);

Future<MovieDetail> _duneDetail() async {
  final result = await FakeMediaRepository().detail(_dune);
  return (result as Success<MediaDetail>).value as MovieDetail;
}

/// `FakeMediaRepository.detail()` awaits a real `Future.delayed` — under
/// `AutomatedTestWidgetsFlutterBinding`'s fake clock, a plain `await` on
/// that (with no `pumpWidget`/`pump` yet in flight to drive time
/// forward) never resolves at all. `tester.runAsync` escapes into a real
/// async zone for just this one call, exactly as its own docs describe
/// for "a real asynchronous computation such as `Future.delayed`".
Future<MovieDetail> _loadDuneDetail(WidgetTester tester) async {
  return (await tester.runAsync(_duneDetail))!;
}

void main() {
  group('MediaDetailActionRow', () {
    testWidgets('tapping Watched opens the Mark as watched sheet instead of '
        'upserting directly', (tester) async {
      final userLibraryRepository = InMemoryUserLibraryRepository();
      final detail = await _loadDuneDetail(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaDetailActionRow(
              mediaKey: _dune,
              userLibraryRepository: userLibraryRepository,
              mediaDetail: detail,
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
        final detail = await _loadDuneDetail(tester);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaDetailActionRow(
                mediaKey: _dune,
                userLibraryRepository: userLibraryRepository,
                mediaDetail: detail,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

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
        final detail = await _loadDuneDetail(tester);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaDetailActionRow(
                mediaKey: _dune,
                userLibraryRepository: userLibraryRepository,
                mediaDetail: detail,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

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
      final detail = await _loadDuneDetail(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaDetailActionRow(
              mediaKey: _dune,
              userLibraryRepository: userLibraryRepository,
              mediaDetail: detail,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Watched'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final saved = await userLibraryRepository.watchEntry(_dune).first;
      expect(saved!.genres.map((g) => g.id), ['sci-fi', 'drama']);
    });
  });
}
