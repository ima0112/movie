import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/features/tv_detail/presentation/screens/tv_seasons_screen.dart';
import 'package:movies/l10n/app_localizations.dart';

const _s1 = SeasonSummary(
  seasonNumber: 1,
  name: 'Season 1',
  episodeCount: 7,
  posterPath: null,
  airDate: null,
);

TvShowDetail _show({
  String status = 'Ended',
  EpisodeRef? last,
  EpisodeRef? next,
}) => TvShowDetail(
  item: const TvShow(
    id: 1396,
    title: 'Breaking Bad',
    posterUrl: null,
    genres: [],
    releaseDate: null,
    voteAverage: 9,
  ),
  overview: '',
  cast: const [],
  crew: const [],
  videos: const [],
  similar: const [],
  imdbId: null,
  tagline: null,
  status: status,
  watchProviders: WatchProviders.empty,
  creators: const [],
  seasons: const [_s1],
  numberOfEpisodes: 62,
  episodeRuntimeMinutes: 45,
  firstAirDate: null,
  lastAirDate: null,
  inProduction: false,
  certification: null,
  lastEpisode: last,
  nextEpisode: next,
);

const _felina = EpisodeRef(
  seasonNumber: 5,
  episodeNumber: 16,
  name: 'Felina',
  airDate: null,
  stillPath: null,
  voteAverage: 9.9,
);

Widget _app(
  Widget child, {
  Locale? locale,
  Size size = const Size(390, 844),
  double textScale = 1,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: MediaQuery(
    data: MediaQueryData(size: size, textScaler: TextScaler.linear(textScale)),
    child: child,
  ),
);

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('TvSeasonsScreen', () {
    testWidgets('header card: show name and status, season and episode '
        'chips', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(TvSeasonsScreen(detail: _show(last: _felina))),
      );

      expect(find.text('Breaking Bad'), findsOneWidget);
      expect(find.text('Ended'), findsOneWidget);
      expect(find.text('1 season'), findsOneWidget);
      expect(find.text('62 episodes'), findsOneWidget);
    });

    testWidgets('last aired episode: code and name, rating chip', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(TvSeasonsScreen(detail: _show(last: _felina))),
      );

      expect(find.text('LAST AIRED EPISODE'), findsOneWidget);
      expect(find.text('S5 · E16 · Felina'), findsOneWidget);
      expect(find.text('9.9'), findsOneWidget);
    });

    testWidgets('an ended or cancelled show has no Next episode section at '
        'all', (tester) async {
      _phone(tester);
      for (final status in ['Ended', 'Canceled']) {
        await tester.pumpWidget(
          _app(TvSeasonsScreen(detail: _show(status: status))),
        );
        expect(find.text('NEXT EPISODE'), findsNothing, reason: status);
        expect(find.text('No next episode'), findsNothing, reason: status);
        // The rest of the page is still there.
        expect(find.text('SEASONS'), findsOneWidget, reason: status);
      }
    });

    testWidgets('every card on the page is as wide as the others', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(TvSeasonsScreen(detail: _show(status: 'Returning Series'))),
      );

      // The "No next episode" card used to shrink to its text.
      final cards = find.ancestor(
        of: find.text('No next episode'),
        matching: find.byType(Container),
      );
      final width = tester.getSize(cards.first).width;
      expect(width, 390 - 2 * 20);
    });

    testWidgets('a returning show with no next episode says none has been '
        'announced', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(TvSeasonsScreen(detail: _show(status: 'Returning Series'))),
      );

      expect(
        find.text('No upcoming episode has been announced yet.'),
        findsOneWidget,
      );
    });

    testWidgets('a scheduled next episode shows its card instead', (
      tester,
    ) async {
      _phone(tester);
      const next = EpisodeRef(
        seasonNumber: 2,
        episodeNumber: 6,
        name: 'Reboot',
        airDate: null,
        stillPath: null,
        voteAverage: null,
      );
      await tester.pumpWidget(
        _app(
          TvSeasonsScreen(
            detail: _show(status: 'Returning Series', next: next),
          ),
        ),
      );

      expect(find.text('S2 · E6 · Reboot'), findsOneWidget);
      expect(find.text('No next episode'), findsNothing);
    });

    testWidgets('lists the seasons under a SEASONS caption', (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app(TvSeasonsScreen(detail: _show())));

      expect(find.text('SEASONS'), findsOneWidget);
      expect(find.text('Season 1'), findsOneWidget);
    });

    testWidgets('survives a small device at 200% text scale (es)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          TvSeasonsScreen(detail: _show(last: _felina)),
          locale: const Locale('es'),
          size: const Size(320, 568),
          textScale: 2,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
