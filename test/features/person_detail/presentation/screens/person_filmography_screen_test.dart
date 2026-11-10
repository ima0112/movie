import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/features/person_detail/presentation/screens/person_filmography_screen.dart';
import 'package:movies/features/person_detail/presentation/widgets/person_filmography_link_card.dart';
import 'package:movies/l10n/app_localizations.dart';

const _person = Person(
  id: 6193,
  name: 'Leonardo DiCaprio',
  profilePath: null,
  knownForDepartment: 'Acting',
);

Movie _movie(int id, String title, int year) => Movie(
  id: id,
  title: title,
  posterUrl: null,
  genres: const [],
  releaseDate: DateTime(year, 1, 1),
  voteAverage: 8,
);

TvShow _show(int id, String title, int year) => TvShow(
  id: id,
  title: title,
  posterUrl: null,
  genres: const [],
  releaseDate: DateTime(year, 1, 1),
  voteAverage: 8,
);

PersonDetail _detail(List<MediaCredit> credits) => PersonDetail(
  person: _person,
  biography: '',
  biographyIsEnglishFallback: false,
  birthday: null,
  deathday: null,
  placeOfBirth: null,
  credits: credits,
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

void main() {
  final credits = [
    MediaCredit(item: _movie(1, 'Inception', 2010), character: 'Dom Cobb'),
    MediaCredit(item: _show(2, 'Growing Pains', 1991), character: 'Luke'),
  ];

  group('PersonFilmographyScreen', () {
    testWidgets('the person\'s name is the title; the list shows every '
        'credit, grouped by year', (tester) async {
      await tester.pumpWidget(
        _app(PersonFilmographyScreen(detail: _detail(credits))),
      );

      expect(find.text('Leonardo DiCaprio'), findsOneWidget);
      expect(find.text('Inception'), findsOneWidget);
      expect(find.text('Growing Pains'), findsOneWidget);
      expect(find.text('2010'), findsOneWidget);
      expect(find.text('1991'), findsOneWidget);
      // The screen's title is the name, so no "Filmography" heading.
      expect(find.text('Filmography'), findsNothing);
    });

    testWidgets('the Movies chip hides the TV credits', (tester) async {
      await tester.pumpWidget(
        _app(PersonFilmographyScreen(detail: _detail(credits))),
      );

      await tester.tap(find.text('Movies'));
      await tester.pump();

      expect(find.text('Inception'), findsOneWidget);
      expect(find.text('Growing Pains'), findsNothing);
    });

    testWidgets('survives a small device at 200% text scale (es)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          PersonFilmographyScreen(detail: _detail(credits)),
          locale: const Locale('es'),
          size: const Size(320, 568),
          textScale: 2,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('PersonFilmographyLinkCard', () {
    testWidgets('shows the heading, the link text and the title count; tap '
        'calls onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: PersonFilmographyLinkCard(
              titleCount: 64,
              onTap: () => taps++,
            ),
          ),
        ),
      );

      expect(find.text('Filmography'), findsOneWidget);
      expect(find.text('View full filmography'), findsOneWidget);
      expect(find.text('64 titles'), findsOneWidget);

      await tester.tap(find.text('View full filmography'));
      expect(taps, 1);
    });

    testWidgets('singular count and no credits at all', (tester) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: PersonFilmographyLinkCard(titleCount: 1, onTap: () {}),
          ),
        ),
      );
      expect(find.text('1 title'), findsOneWidget);

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: PersonFilmographyLinkCard(titleCount: 0, onTap: () {}),
          ),
        ),
      );
      expect(find.text('Filmography'), findsNothing);
    });
  });
}
