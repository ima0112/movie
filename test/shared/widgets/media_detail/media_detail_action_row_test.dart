import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/release_status.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/app_buttons.dart';
import 'package:movies/shared/widgets/media_detail/media_action_button.dart';
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

/// [d] with a release status (the fake's Dune is an ordinary released movie).
MovieDetail _withStatus(MovieDetail d, ReleaseStatus? status) => MovieDetail(
  item: d.item,
  overview: d.overview,
  cast: d.cast,
  crew: d.crew,
  videos: d.videos,
  similar: d.similar,
  imdbId: d.imdbId,
  tagline: d.tagline,
  status: d.status,
  watchProviders: d.watchProviders,
  releaseStatus: status,
  runtimeMinutes: d.runtimeMinutes,
  releaseDate: d.releaseDate,
  certification: d.certification,
);

Future<void> _pumpRow(WidgetTester tester, MovieDetail detail) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MediaDetailActionRow(
          mediaKey: _dune,
          userLibraryRepository: InMemoryUserLibraryRepository(),
          mediaDetail: detail,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('a title that is not out yet', () {
    testWidgets('has no Watched button; Favorite and Watch later stay', (
      tester,
    ) async {
      final detail = _withStatus(
        await _loadDuneDetail(tester),
        const ReleaseStatus(ReleaseStage.upcoming),
      );
      await _pumpRow(tester, detail);

      expect(find.bySemanticsLabel('Watched'), findsNothing);
      expect(find.bySemanticsLabel('Watch later'), findsOneWidget);
      expect(find.bySemanticsLabel('Favorite'), findsOneWidget);
    });

    testWidgets('one only in theaters keeps Watched', (tester) async {
      final detail = _withStatus(
        await _loadDuneDetail(tester),
        ReleaseStatus(ReleaseStage.inTheaters, date: DateTime(2026, 4, 24)),
      );
      await _pumpRow(tester, detail);

      expect(find.bySemanticsLabel('Watched'), findsOneWidget);
    });

    testWidgets('an ordinary released title has all three circles beside the '
        'trailer pill, all 44 px tall', (tester) async {
      await _pumpRow(tester, await _loadDuneDetail(tester));

      for (final label in ['Favorite', 'Watch later', 'Watched']) {
        expect(find.bySemanticsLabel(label), findsOneWidget);
      }
      expect(find.byType(MediaActionButton), findsNWidgets(3));
      final pill = tester.getRect(find.byType(PrimaryButton));
      expect(pill.height, MediaActionButton.size);
      for (final c in tester.widgetList(find.byType(MediaActionButton))) {
        final r = tester.getRect(find.byWidget(c));
        expect(r.size, const Size(44, 44));
        expect(r.left, greaterThan(pill.right)); // same row, after the pill
        expect(r.center.dy, moreOrLessEquals(pill.center.dy, epsilon: 0.5));
      }
    });

    testWidgets('at 200% text the pill takes its own row and the circles sit '
        'under it', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final detail = await _loadDuneDetail(tester);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: MediaDetailActionRow(
                mediaKey: _dune,
                userLibraryRepository: InMemoryUserLibraryRepository(),
                mediaDetail: detail,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final pill = tester.getRect(find.byType(PrimaryButton));
      for (final c in tester.widgetList(find.byType(MediaActionButton))) {
        expect(tester.getRect(find.byWidget(c)).top, greaterThan(pill.bottom));
      }
    });
  });

  group('MediaDetailActionRow', () {
    testWidgets('tapping Watched opens the Mark as watched sheet instead of '
        'upserting directly', (tester) async {
      final userLibraryRepository = InMemoryUserLibraryRepository();
      final detail = await _loadDuneDetail(tester);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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

      await tester.tap(find.bySemanticsLabel('Watched'));
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
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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

        await tester.tap(find.bySemanticsLabel('Watched'));
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
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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

        await tester.tap(find.bySemanticsLabel('Favorite'));
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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

      await tester.tap(find.bySemanticsLabel('Watched'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final saved = await userLibraryRepository.watchEntry(_dune).first;
      expect(saved!.genres.map((g) => g.id), ['sci-fi', 'drama']);
    });
  });

  group('primaryActionFor', () {
    test('trailer first, then similar, then where to watch, else nothing', () {
      PrimaryAction pick(bool t, bool s, bool w) =>
          primaryActionFor(hasTrailer: t, hasSimilar: s, hasWhereToWatch: w);
      expect(pick(true, true, true), PrimaryAction.trailer);
      expect(pick(false, true, true), PrimaryAction.similar);
      expect(pick(false, false, true), PrimaryAction.whereToWatch);
      expect(pick(false, false, false), PrimaryAction.none);
    });
  });

  group('MediaDetailActionRow without a trailer', () {
    // A movie with no videos at all, so no trailer.
    const bare = MovieDetail(
      item: Movie(
        id: 9,
        title: 'Bare',
        posterUrl: null,
        genres: [],
        releaseDate: null,
        voteAverage: 7,
      ),
      overview: '',
      cast: [],
      crew: [],
      videos: [],
      similar: [],
      imdbId: null,
      tagline: null,
      status: 'Released',
      watchProviders: WatchProviders.empty,
      runtimeMinutes: null,
      releaseDate: null,
      certification: null,
    );

    Widget host({VoidCallback? similar, VoidCallback? where}) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MediaDetailActionRow(
          mediaKey: const MediaKey(type: MediaType.movie, tmdbId: 9),
          userLibraryRepository: InMemoryUserLibraryRepository(),
          mediaDetail: bare,
          onSeeSimilar: similar,
          onSeeWhereToWatch: where,
        ),
      ),
    );

    testWidgets('similar titles exist: "See similar"', (tester) async {
      var taps = 0;
      await tester.pumpWidget(host(similar: () => taps++));
      await tester.tap(find.text('See similar'));
      expect(taps, 1);
    });

    testWidgets('no similar but services listed: "Where to watch"', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(host(where: () => taps++));
      expect(find.text('See similar'), findsNothing);
      await tester.tap(find.text('Where to watch'));
      expect(taps, 1);
    });

    testWidgets('nothing to jump to: no primary button, the three circles '
        'spread over the row', (tester) async {
      tester.view.physicalSize = const Size(390, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(host());
      expect(find.byType(PrimaryButton), findsNothing);
      expect(find.text('See similar'), findsNothing);
      expect(find.byType(MediaActionButton), findsNWidgets(3));
      final first = tester.getRect(find.byType(MediaActionButton).first);
      final last = tester.getRect(find.byType(MediaActionButton).last);
      expect(first.left, moreOrLessEquals(0, epsilon: 0.5));
      expect(last.right, moreOrLessEquals(390, epsilon: 0.5));
    });
  });
}
