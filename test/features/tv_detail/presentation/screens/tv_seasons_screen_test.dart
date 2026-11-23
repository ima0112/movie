import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/features/tv_detail/presentation/screens/tv_seasons_screen.dart';
import 'package:movies/features/tv_detail/presentation/widgets/seasons_header.dart';
import 'package:movies/features/tv_detail/presentation/widgets/seasons_timeline_card.dart';
import 'package:movies/shared/widgets/media_detail/info_chip.dart';
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
    testWidgets('header: the show name big and one status line, no chips', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(TvSeasonsScreen(detail: _show(last: _felina))),
      );

      expect(find.text('Breaking Bad'), findsOneWidget);
      expect(find.text('Ended · 1 season · 62 episodes'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SeasonsHeader),
          matching: find.byType(InfoChip),
        ),
        findsNothing,
      );
    });

    testWidgets('the status dot is green airing, grey ended, red cancelled', (
      tester,
    ) async {
      _phone(tester);
      Color dot() =>
          ((tester
                      .widget<Container>(
                        find
                            .descendant(
                              of: find.byType(SeasonsHeader),
                              matching: find.byType(Container),
                            )
                            .first,
                      )
                      .decoration!)
                  as BoxDecoration)
              .color!;
      for (final (status, color) in [
        ('Returning Series', AppColors.success),
        ('Ended', AppColors.inkMuted),
        ('Canceled', AppColors.danger),
      ]) {
        await tester.pumpWidget(
          _app(TvSeasonsScreen(detail: _show(status: status))),
        );
        expect(dot(), color, reason: status);
      }
    });

    testWidgets('one timeline card: NEXT on top, LAST AIRED under it with its '
        'code, name and rating', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(TvSeasonsScreen(detail: _show(last: _felina))),
      );

      expect(find.byType(SeasonsTimelineCard), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);
      expect(find.text('LAST AIRED'), findsOneWidget);
      expect(
        tester.getRect(find.text('NEXT')).top,
        lessThan(tester.getRect(find.text('LAST AIRED')).top),
      );
      expect(find.text('S5 · E16 · Felina'), findsOneWidget);
      expect(find.textContaining('9.9'), findsOneWidget);
    });

    testWidgets('an ended or cancelled show still shows the Next node, saying '
        'why', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(TvSeasonsScreen(detail: _show(status: 'Ended'))),
      );
      expect(find.text('No next episode'), findsOneWidget);
      expect(find.text('This series has ended.'), findsOneWidget);

      await tester.pumpWidget(
        _app(TvSeasonsScreen(detail: _show(status: 'Canceled'))),
      );
      expect(find.text('This series was cancelled.'), findsOneWidget);
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

    testWidgets('a scheduled next episode shows like the last one', (
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
      expect(find.text('TBA'), findsOneWidget);
      expect(find.text('No next episode'), findsNothing);
    });

    testWidgets('with no last aired episode only the Next node is drawn', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(TvSeasonsScreen(detail: _show(status: 'Returning Series'))),
      );
      expect(find.text('NEXT'), findsOneWidget);
      expect(find.text('LAST AIRED'), findsNothing);
    });

    testWidgets('the timeline card is as wide as the page content', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(TvSeasonsScreen(detail: _show(status: 'Returning Series'))),
      );
      expect(
        tester.getSize(find.byType(SeasonsTimelineCard)).width,
        390 - 2 * 20,
      );
    });

    testWidgets('lists the seasons under a SEASONS caption', (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app(TvSeasonsScreen(detail: _show())));

      expect(find.text('SEASONS'), findsOneWidget);
      expect(find.text('S1'), findsOneWidget);
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

    testWidgets(
      'the timeline survives a really small phone at 200% text (es)',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          _app(
            TvSeasonsScreen(
              detail: _show(
                status: 'Returning Series',
                last: _felina,
                next: const EpisodeRef(
                  seasonNumber: 6,
                  episodeNumber: 1,
                  name: 'Un nombre de episodio bastante largo',
                  airDate: null,
                  stillPath: null,
                  voteAverage: 8.1,
                ),
              ),
            ),
            locale: const Locale('es'),
            textScale: 2,
          ),
        );

        expect(tester.takeException(), isNull);
      },
    );
  });
}
