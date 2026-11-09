import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_detail/media_cast_row.dart';
import 'package:movies/shared/widgets/media_detail/media_similar_section.dart';

CastMember _cast(int i) => CastMember(
  person: Person(
    id: i,
    name: 'Actor $i',
    profilePath: null,
    knownForDepartment: 'Acting',
  ),
  character: 'Role $i',
  order: i,
);

final _crew = [
  CrewMember(
    person: const Person(
      id: 900,
      name: 'Christopher Nolan',
      profilePath: null,
      knownForDepartment: 'Directing',
    ),
    job: 'Director',
    department: 'Directing',
  ),
];

Widget _app(Widget child, {Locale? locale}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  group('MediaCastRow', () {
    testWidgets('has a "Cast" heading, and "See all" only past 10 people', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          MediaCastRow(
            cast: [for (var i = 0; i < 5; i++) _cast(i)],
            crew: const [],
          ),
        ),
      );
      expect(find.text('Cast'), findsOneWidget);
      expect(find.text('See all'), findsNothing);

      await tester.pumpWidget(
        _app(
          MediaCastRow(
            cast: [for (var i = 0; i < 12; i++) _cast(i)],
            crew: const [],
          ),
        ),
      );
      expect(find.text('See all'), findsOneWidget);
    });

    testWidgets('"See all" calls onSeeFullCastTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          MediaCastRow(
            cast: [for (var i = 0; i < 12; i++) _cast(i)],
            crew: const [],
            onSeeFullCastTap: () => taps++,
          ),
        ),
      );

      await tester.tap(find.text('See all'));
      expect(taps, 1);
    });

    testWidgets('the Spanish heading is "Reparto" and the link "Ver todo"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          MediaCastRow(
            cast: [for (var i = 0; i < 12; i++) _cast(i)],
            crew: const [],
          ),
          locale: const Locale('es'),
        ),
      );

      expect(find.text('Reparto'), findsOneWidget);
      expect(find.text('Ver todo'), findsOneWidget);
    });

    testWidgets('crew names are listed by default, and hidden with '
        'showCrew: false', (tester) async {
      final cast = [for (var i = 0; i < 3; i++) _cast(i)];
      await tester.pumpWidget(_app(MediaCastRow(cast: cast, crew: _crew)));
      expect(find.textContaining('Christopher Nolan'), findsOneWidget);

      await tester.pumpWidget(
        _app(MediaCastRow(cast: cast, crew: _crew, showCrew: false)),
      );
      expect(find.textContaining('Christopher Nolan'), findsNothing);
    });

    testWidgets('a crew of hundreds is never printed when showCrew is false', (
      tester,
    ) async {
      final bigCrew = [
        for (var i = 0; i < 735; i++)
          CrewMember(
            person: Person(
              id: i,
              name: 'Crew $i',
              profilePath: null,
              knownForDepartment: 'Crew',
            ),
            job: 'Grip',
            department: 'Crew',
          ),
      ];
      await tester.pumpWidget(
        _app(
          MediaCastRow(
            cast: [for (var i = 0; i < 3; i++) _cast(i)],
            crew: bigCrew,
            showCrew: false,
          ),
        ),
      );

      expect(find.textContaining('Crew 5'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('MediaSimilarSection', () {
    final similar = [
      const Movie(
        id: 1,
        title: 'Interstellar',
        posterUrl: null,
        genres: [],
        releaseDate: null,
        voteAverage: 8,
      ),
    ];

    testWidgets('default heading is "Similar"; a title overrides it', (
      tester,
    ) async {
      await tester.pumpWidget(_app(MediaSimilarSection(similar: similar)));
      expect(find.text('Similar'), findsOneWidget);

      await tester.pumpWidget(
        _app(MediaSimilarSection(similar: similar, title: 'Similar movies')),
      );
      expect(find.text('Similar movies'), findsOneWidget);
      expect(find.text('Similar'), findsNothing);
    });
  });
}
