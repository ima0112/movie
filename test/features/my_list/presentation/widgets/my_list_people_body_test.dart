import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_saved_people_repository.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/features/my_list/presentation/widgets/my_list_people_body.dart';
import 'package:movies/l10n/app_localizations.dart';

const _ana = Person(
  id: 1,
  name: 'Ana',
  profilePath: null,
  knownForDepartment: 'Acting',
);
const _zed = Person(id: 2, name: 'Zed', profilePath: null);

Widget _host(InMemorySavedPeopleRepository repo) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: MyListPeopleBody(savedPeopleRepository: repo)),
);

void main() {
  testWidgets('empty: says so, centered clear of the tab bar', (tester) async {
    await tester.pumpWidget(_host(InMemorySavedPeopleRepository()));
    await tester.pump();

    expect(find.text('No people yet'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
  });

  testWidgets('lists the saved people A–Z with their department', (
    tester,
  ) async {
    await tester.pumpWidget(_host(InMemorySavedPeopleRepository([_zed, _ana])));
    await tester.pump();

    expect(find.text('Acting · Person'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Ana')).dy,
      lessThan(tester.getTopLeft(find.text('Zed')).dy),
    );
  });

  testWidgets('swipe left removes with an Undo that brings them back', (
    tester,
  ) async {
    final repo = InMemorySavedPeopleRepository([_ana]);
    await tester.pumpWidget(_host(repo));
    await tester.pump();

    await tester.drag(find.text('Ana'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Ana'), findsNothing);
    expect(find.text('Ana removed from People'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Ana'), findsOneWidget);
  });

  testWidgets('the three dots open a sheet with one red row, '
      '"Remove from People", that removes with Undo', (tester) async {
    final repo = InMemorySavedPeopleRepository([_ana]);
    await tester.pumpWidget(_host(repo));
    await tester.pump();

    await tester.tap(find.byIcon(AppIcons.more));
    await tester.pumpAndSettle();
    expect(find.text('Acting · Person'), findsNWidgets(2)); // row and sheet
    expect(find.text('Remove from People'), findsOneWidget);
    expect(find.text('Mark as watched'), findsNothing);

    await tester.tap(find.text('Remove from People'));
    await tester.pumpAndSettle();

    expect(find.text('Ana'), findsNothing);
    expect(find.text('Ana removed from People'), findsOneWidget);
  });
}
