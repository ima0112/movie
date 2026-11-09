import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/l10n/app_localizations.dart';
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

/// A phone-sized screen: on the default 800x600 test surface the 3-column
/// portraits are ~300 px tall and push the names out of view.
void _usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('FullCastSheet', () {
    testWidgets('starts on Cast; the Crew tab swaps the list', (tester) async {
      _usePhoneScreen(tester);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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
      expect(find.text('Denis Villeneuve'), findsNothing);

      await tester.tap(find.text('Crew'));
      await tester.pump();

      expect(find.text('Denis Villeneuve'), findsOneWidget);
      expect(find.text('Director'), findsOneWidget);
      expect(find.text('Zendaya'), findsNothing);
    });

    testWidgets('survives a small device + open keyboard + 200% text scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 568),
              viewInsets: EdgeInsets.only(bottom: 250),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(
              body: FullCastSheet(cast: _cast, crew: _crew),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('the search box filters by name, case-insensitively', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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
      _usePhoneScreen(tester);
      Person? tapped;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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
