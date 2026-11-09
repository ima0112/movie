import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_detail/full_cast_screen.dart';

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
  group('FullCastScreen', () {
    testWidgets('starts on Cast; the Crew tab swaps the list', (tester) async {
      _usePhoneScreen(tester);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FullCastScreen(title: 'Dune', cast: _cast, crew: _crew),
        ),
      );

      expect(find.text('Dune'), findsOneWidget);
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
              body: FullCastScreen(title: 'Dune', cast: _cast, crew: _crew),
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
          home: FullCastScreen(title: 'Dune', cast: _cast, crew: _crew),
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
          home: FullCastScreen(title: 'Dune', cast: _cast, crew: _crew),
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
          home: FullCastScreen(
            title: 'Dune',
            cast: _cast,
            crew: _crew,
            onPersonTap: (person) => tapped = person,
          ),
        ),
      );

      await tester.tap(find.text('Zendaya'));
      expect(tapped, _zendaya);
    });

    testWidgets('searching looks through cast AND crew, whichever tab is '
        'selected, grouped under their headings', (tester) async {
      _usePhoneScreen(tester);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FullCastScreen(title: 'Dune', cast: _cast, crew: _crew),
        ),
      );

      // On the Cast tab, a crew member's name still finds them.
      await tester.enterText(find.byType(TextField), 'denis');
      await tester.pump();
      expect(find.text('Denis Villeneuve'), findsOneWidget);
      expect(find.text('CREW'), findsOneWidget);
      expect(find.text('CAST'), findsNothing);

      // A name present in both lists shows under both headings.
      await tester.enterText(find.byType(TextField), 'e');
      await tester.pump();
      expect(find.text('CAST'), findsOneWidget);
      expect(find.text('CREW'), findsOneWidget);
      expect(find.text('Zendaya'), findsOneWidget);
      expect(find.text('Denis Villeneuve'), findsOneWidget);

      // The tabs never go away: they show the counts, and picking Crew puts
      // the crew matches first.
      expect(find.text('Cast · 2'), findsOneWidget);
      expect(find.text('Crew · 1'), findsOneWidget);
      await tester.tap(find.text('Crew · 1'));
      await tester.pump();
      expect(
        tester.getTopLeft(find.text('CREW')).dy,
        lessThan(tester.getTopLeft(find.text('CAST')).dy),
      );

      // Clearing the search brings back the plain tabs.
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(find.text('Cast'), findsOneWidget);
      expect(find.text('Denis Villeneuve'), findsOneWidget);
    });

    testWidgets('Cast and Crew scroll independently', (tester) async {
      _usePhoneScreen(tester);
      Person p(int i) => Person(
        id: 100 + i,
        name: 'Person $i',
        profilePath: null,
        knownForDepartment: 'Acting',
      );
      final cast = [
        for (var i = 0; i < 60; i++)
          CastMember(person: p(i), character: 'Role $i', order: i),
      ];
      final crew = [
        for (var i = 0; i < 60; i++)
          CrewMember(person: p(1000 + i), job: 'Job $i', department: 'Crew'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FullCastScreen(title: 'Dune', cast: cast, crew: crew),
        ),
      );

      double offset() => tester
          .state<ScrollableState>(
            find.descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            ),
          )
          .position
          .pixels;

      await tester.drag(find.byType(ListView), const Offset(0, -900));
      await tester.pumpAndSettle();
      final castOffset = offset();
      expect(castOffset, greaterThan(0));

      // Crew starts at the top — Cast's scroll did not carry over.
      await tester.tap(find.text('Crew'));
      await tester.pumpAndSettle();
      expect(offset(), 0);
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Back on Cast, its own position is exactly where we left it.
      await tester.tap(find.text('Cast'));
      await tester.pumpAndSettle();
      expect(offset(), castOffset);
    });
  });
}
