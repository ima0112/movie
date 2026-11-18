import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_card_meta.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_suggestion_card.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/streaming_service_logo.dart';

import 'deck_test_data.dart';

Widget _host(
  Widget card, {
  Locale locale = const Locale('en'),
  double textScale = 1,
  Size size = const Size(300, 460),
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: Scaffold(
    body: Center(
      child: SizedBox(width: size.width, height: size.height, child: card),
    ),
  ),
);

Future<AppLocalizations> _l10n(String code) =>
    AppLocalizations.delegate.load(Locale(code));

void main() {
  group('surpriseMetaLine', () {
    test('movie: year and duration', () async {
      final l10n = await _l10n('en');

      expect(
        surpriseMetaLine(movieSuggestion().detail, l10n),
        '2024 · 2 h 46 min',
      );
    });

    test('movie: a part TMDB does not know is left out', () async {
      final l10n = await _l10n('en');

      expect(
        surpriseMetaLine(movieSuggestion(runtime: null).detail, l10n),
        '2024',
      );
    });

    test('series: the years and the seasons, specials not counted', () async {
      final l10n = await _l10n('en');

      expect(
        surpriseMetaLine(showSuggestion().detail, l10n),
        '2017–2020 · 3 seasons',
      );
      expect(
        surpriseMetaLine(showSuggestion(seasons: 1).detail, l10n),
        '2017–2020 · 1 season',
      );
    });

    test('series that began and ended the same year show one year', () async {
      final l10n = await _l10n('en');

      expect(
        surpriseMetaLine(
          showSuggestion(first: 2019, last: 2019, seasons: 1).detail,
          l10n,
        ),
        '2019 · 1 season',
      );
    });

    test('series still airing: "since" and no end year', () async {
      final l10n = await _l10n('en');

      expect(
        surpriseMetaLine(
          showSuggestion(
            first: 2021,
            last: 2025,
            seasons: 4,
            airing: true,
          ).detail,
          l10n,
        ),
        'since 2021 · 4 seasons',
      );
    });

    test('the Spanish copy', () async {
      final l10n = await _l10n('es');

      expect(
        surpriseMetaLine(
          showSuggestion(first: 2021, seasons: 4, airing: true).detail,
          l10n,
        ),
        'desde 2021 · 4 temporadas',
      );
      expect(
        surpriseMetaLine(movieSuggestion().detail, l10n),
        '2024 · 2 h 46 min',
      );
    });
  });

  group('SurpriseSuggestionCard', () {
    testWidgets('a movie: number, tags, title, meta, rating, tagline and the '
        'three platform logos (no count text)', (tester) async {
      await tester.pumpWidget(
        _host(
          SurpriseSuggestionCard(
            suggestion: movieSuggestion(platforms: services(3)),
            number: 3,
            total: 5,
          ),
        ),
      );

      expect(find.text('03'), findsWidgets); // outlined: stroke + fill
      expect(find.text('88 % for you'), findsOneWidget);
      expect(find.text('Movie'), findsOneWidget);
      expect(find.text('Dune: Part Two'), findsOneWidget);
      expect(find.text('2024 · 2 h 46 min'), findsOneWidget);
      expect(find.text('8.2'), findsOneWidget);
      expect(find.text('«Long live the fighters.»'), findsOneWidget);
      expect(find.byType(StreamingServiceLogo), findsNWidgets(3));
      // Three logos say it all: no "3 platforms" text.
      expect(find.text('3 platforms'), findsNothing);
    });

    testWidgets('more than three platforms: three logos and "+2"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SurpriseSuggestionCard(
            suggestion: movieSuggestion(platforms: services(5)),
            number: 1,
            total: 5,
          ),
        ),
      );

      expect(find.byType(StreamingServiceLogo), findsNWidgets(3));
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('no platforms: no row; no tagline: no line', (tester) async {
      await tester.pumpWidget(
        _host(
          SurpriseSuggestionCard(
            suggestion: movieSuggestion(tagline: null),
            number: 1,
            total: 5,
          ),
        ),
      );

      expect(find.byType(StreamingServiceLogo), findsNothing);
      expect(find.textContaining('platform'), findsNothing);
      expect(find.textContaining('«'), findsNothing);
    });

    testWidgets('a series: the TV tag, years and seasons — no duration', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SurpriseSuggestionCard(
            suggestion: showSuggestion(),
            number: 2,
            total: 5,
          ),
        ),
      );

      expect(find.text('TV Show'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('2017–2020 · 3 seasons'), findsOneWidget);
      expect(find.textContaining(' h '), findsNothing);
    });

    testWidgets('no poster: still a usable card with its number and title', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SurpriseSuggestionCard(
            suggestion: movieSuggestion(posterUrl: null),
            number: 4,
            total: 5,
          ),
        ),
      );

      expect(find.text('04'), findsWidgets);
      expect(find.text('Dune: Part Two'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a screen reader gets one complete label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          SurpriseSuggestionCard(
            suggestion: movieSuggestion(platforms: services(3)),
            number: 3,
            total: 5,
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(
          'Card 3 of 5: Dune: Part Two, Movie, 88 % for you, 3 platforms',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('the Spanish copy', (tester) async {
      await tester.pumpWidget(
        _host(
          SurpriseSuggestionCard(
            suggestion: showSuggestion(platforms: services(2)),
            number: 1,
            total: 5,
          ),
          locale: const Locale('es'),
        ),
      );

      expect(find.text('88 % para ti'), findsOneWidget);
      expect(find.text('Serie'), findsOneWidget);
      expect(find.text('2 plataformas'), findsNothing); // the logos say it
      expect(find.text('2017–2020 · 3 temporadas'), findsOneWidget);
      expect(find.text('8,7'), findsOneWidget); // comma decimal
    });

    testWidgets('a short card at 200% text: nothing overflows', (tester) async {
      await tester.pumpWidget(
        _host(
          SurpriseSuggestionCard(
            suggestion: movieSuggestion(
              platforms: services(4),
              title: 'A very long title that does not fit on two lines at all',
              tagline:
                  'An equally long tagline that keeps going and going, '
                  'well past the two lines the card allows for it.',
            ),
            number: 5,
            total: 5,
          ),
          textScale: 2,
          size: const Size(280, 380),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('without the affinity tag, with a corner widget: the type tag '
        'stays and the tagline keeps clear of the corner', (tester) async {
      await tester.pumpWidget(
        _host(
          SurpriseSuggestionCard(
            suggestion: movieSuggestion(),
            number: 3,
            total: 5,
            showAffinity: false,
            bottomEnd: const SizedBox(key: Key('ring'), width: 64, height: 64),
          ),
        ),
      );

      expect(find.text('88 % for you'), findsNothing);
      expect(find.text('Movie'), findsOneWidget);
      expect(find.byKey(const Key('ring')), findsOneWidget);
      final ring = tester.getRect(find.byKey(const Key('ring')));
      final tagline = tester.getRect(find.text('«Long live the fighters.»'));
      expect(tagline.right, lessThanOrEqualTo(ring.left));
    });
  });
}
