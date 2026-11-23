import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/features/tv_detail/presentation/screens/season_screen.dart';
import 'package:movies/features/tv_detail/presentation/widgets/season_header.dart';
import 'package:movies/features/tv_detail/presentation/widgets/episode_nav_button.dart';
import 'package:movies/features/tv_detail/presentation/widgets/episode_sheet.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/poster_image.dart';

const _theBearSeason1 = SeasonSummary(
  seasonNumber: 1,
  name: 'Season 1',
  episodeCount: 8,
  posterPath: null,
  airDate: null,
);
const _theBearSpecials = SeasonSummary(
  seasonNumber: 0,
  name: 'Specials',
  episodeCount: 1,
  posterPath: null,
  airDate: null,
);
const _missingSeason = SeasonSummary(
  seasonNumber: 9,
  name: 'Season 9',
  episodeCount: 8,
  posterPath: null,
  airDate: null,
);

void main() {
  setUpAll(() => configureDependencies(fake.name));

  group('SeasonScreen', () {
    testWidgets('an episode opens as a sheet that moves on to the next one '
        'without closing', (tester) async {
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SeasonScreen(tvId: 101, seasonSummary: _theBearSeason1),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();
      expect(find.byType(EpisodeSheet), findsOneWidget);
      expect(find.byType(EpisodeNavButton), findsNWidgets(2));

      await tester.tap(find.textContaining('Next · E'));
      await tester.pumpAndSettle();
      expect(find.byType(EpisodeSheet), findsOneWidget); // still the same sheet
      expect(find.text('Hands'), findsWidgets);
    });

    testWidgets('the header is the big title and one line: year, episode '
        'count and rating, no card and no poster', (tester) async {
      final dated = SeasonSummary(
        seasonNumber: 1,
        name: 'Season 1',
        episodeCount: 7,
        posterPath: null,
        airDate: DateTime(2008, 1, 20),
        voteAverage: 8.7,
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SeasonScreen(tvId: 101, seasonSummary: dated),
        ),
      );

      expect(find.byType(SeasonHeader), findsOneWidget);
      expect(find.text('Season 1'), findsOneWidget);
      expect(
        find.textContaining('2008 · 7 episodes · ', findRichText: true),
        findsOneWidget,
      );
      expect(find.byType(PosterImage), findsNothing);
      await tester.pumpAndSettle();
    });

    testWidgets('shows the season title immediately, then its episodes '
        'once loaded', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SeasonScreen(tvId: 101, seasonSummary: _theBearSeason1),
        ),
      );

      // The title (from SeasonSummary) is there before the fetch settles.
      expect(find.text('Season 1'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('System'), findsOneWidget);
      // Episode 2's row is below the fold of the sheet's own (small)
      // viewport — the sliver list only realizes it once scrolled in.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Hands'), findsOneWidget);
    });

    testWidgets('shows the show name in the app bar and survives a small '
        'device at 200% text scale (es)', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(2),
            ),
            child: const SeasonScreen(
              tvId: 101,
              seasonSummary: _theBearSeason1,
              showTitle: 'The Bear',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('The Bear'), findsOneWidget);
      // No "Episodes" caption: the list follows the synopsis directly.
      expect(find.text('EPISODIOS'), findsNothing);
    });

    testWidgets('the header line shows the rating when TMDB has one', (
      tester,
    ) async {
      const rated = SeasonSummary(
        seasonNumber: 1,
        name: 'Season 1',
        episodeCount: 8,
        posterPath: null,
        airDate: null,
        voteAverage: 8.7,
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SeasonScreen(tvId: 101, seasonSummary: rated),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('8.7'), findsWidgets);
    });

    testWidgets('a specials season titles itself "Specials", not '
        '"Season 0"', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SeasonScreen(tvId: 101, seasonSummary: _theBearSpecials),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Specials'), findsWidgets);
      expect(find.text('Season 0'), findsNothing);
    });

    testWidgets('a season with no sample data shows the error state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SeasonScreen(tvId: 101, seasonSummary: _missingSeason),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load"), findsOneWidget);
    });
  });
}
