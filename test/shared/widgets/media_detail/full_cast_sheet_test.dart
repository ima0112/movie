import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/shared/widgets/media_detail/full_cast_sheet.dart';

const _chalamet = Person(
  id: 1,
  name: 'Timothée Chalamet',
  profilePath: null,
  knownForDepartment: 'Acting',
);
const _zendaya = Person(
  id: 2,
  name: 'Zendaya',
  profilePath: null,
  knownForDepartment: 'Acting',
);
const _villeneuve = Person(
  id: 3,
  name: 'Denis Villeneuve',
  profilePath: null,
  knownForDepartment: 'Directing',
);

const _cast = [
  CastMember(person: _chalamet, character: 'Paul Atreides', order: 0),
  CastMember(person: _zendaya, character: 'Chani', order: 1),
];
const _crew = [
  CrewMember(person: _villeneuve, job: 'Director', department: 'Directing'),
];

void main() {
  group('FullCastSheet', () {
    testWidgets('lists cast and crew, each under its own section label', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FullCastSheet(cast: _cast, crew: _crew),
          ),
        ),
      );

      expect(find.text('Cast'), findsOneWidget);
      expect(find.text('Crew'), findsOneWidget);
      expect(find.text('Timothée Chalamet'), findsOneWidget);
      expect(find.text('Paul Atreides'), findsOneWidget);
      expect(find.text('Zendaya'), findsOneWidget);
      expect(find.text('Denis Villeneuve'), findsOneWidget);
      expect(find.text('Director'), findsOneWidget);
    });

    testWidgets('the search box filters by name, case-insensitively', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FullCastSheet(cast: _cast, crew: _crew),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'zend');
      await tester.pump();

      expect(find.text('Zendaya'), findsOneWidget);
      expect(find.text('Timothée Chalamet'), findsNothing);
      expect(find.text('Denis Villeneuve'), findsNothing);
    });

    testWidgets('a query matching nobody shows "No matches"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FullCastSheet(cast: _cast, crew: _crew),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'nobody here');
      await tester.pump();

      expect(find.text('No matches'), findsOneWidget);
    });

    testWidgets('tapping a row calls onPersonTap with that person', (
      tester,
    ) async {
      Person? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullCastSheet(
              cast: _cast,
              crew: _crew,
              onPersonTap: (person) => tapped = person,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Zendaya'));
      expect(tapped, _zendaya);
    });
  });
}
