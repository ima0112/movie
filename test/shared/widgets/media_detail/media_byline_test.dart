import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/shared/widgets/media_detail/media_byline.dart';
import 'package:movies/l10n/app_localizations.dart';

const _storer = Person(
  id: 1,
  name: 'Christopher Storer',
  profilePath: null,
  knownForDepartment: 'Directing',
);
const _kripke = Person(
  id: 2,
  name: 'Eric Kripke',
  profilePath: null,
  knownForDepartment: 'Writing',
);

void main() {
  group('MediaByline', () {
    testWidgets('renders nothing when there are no creators', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MediaByline(label: 'Created by ', people: const []),
          ),
        ),
      );

      expect(find.text('Created by '), findsNothing);
    });

    testWidgets('one creator renders without a separator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MediaByline(label: 'Created by ', people: const [_storer]),
          ),
        ),
      );

      expect(find.text('Created by '), findsOneWidget);
      expect(find.text('Christopher Storer'), findsOneWidget);
      expect(find.text(' · '), findsNothing);
    });

    testWidgets('multiple creators separated by "·"', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MediaByline(
              label: 'Created by ',
              people: const [_storer, _kripke],
            ),
          ),
        ),
      );

      expect(find.text('Christopher Storer'), findsOneWidget);
      expect(find.text('Eric Kripke'), findsOneWidget);
      expect(find.text(' · '), findsOneWidget);
    });

    testWidgets('tapping a name calls onPersonTap with that person', (
      tester,
    ) async {
      Person? tapped;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MediaByline(
              label: 'Created by ',
              people: const [_storer],
              onPersonTap: (person) => tapped = person,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Christopher Storer'));
      expect(tapped, _storer);
    });
  });
}
