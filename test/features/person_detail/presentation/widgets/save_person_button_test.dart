import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_saved_people_repository.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/features/person_detail/presentation/widgets/save_person_button.dart';
import 'package:movies/l10n/app_localizations.dart';

const _person = Person(id: 7, name: 'Ana', profilePath: null);

Widget _host(InMemorySavedPeopleRepository repo, {required bool compact}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Stack(
          children: [
            SavePersonButton(
              person: _person,
              repository: repo,
              compact: compact,
            ),
          ],
        ),
      ),
    );

Color _iconColor(WidgetTester tester) =>
    tester.widget<Icon>(find.byType(Icon)).color!;

void main() {
  for (final compact in [false, true]) {
    testWidgets('${compact ? 'compact' : 'circle'}: a tap saves, the next '
        'one forgets, and the heart follows', (tester) async {
      final repo = InMemorySavedPeopleRepository();
      await tester.pumpWidget(_host(repo, compact: compact));
      await tester.pump();

      expect(find.byIcon(AppIcons.favorite), findsOneWidget);
      expect(_iconColor(tester), AppColors.ink);

      await tester.tap(find.byType(Icon));
      await tester.pump();
      await tester.pump();
      expect(await tester.runAsync(() => repo.watchAll().first), [_person]);
      expect(find.byIcon(AppIcons.favoriteFill), findsOneWidget);
      expect(_iconColor(tester), AppColors.accent);

      await tester.tap(find.byType(Icon));
      await tester.pump();
      await tester.pump();
      expect(await tester.runAsync(() => repo.watchAll().first), isEmpty);
      expect(find.byIcon(AppIcons.favorite), findsOneWidget);
    });
  }

  testWidgets('already saved: starts filled, labelled for screen readers', (
    tester,
  ) async {
    final repo = InMemorySavedPeopleRepository([_person]);
    await tester.pumpWidget(_host(repo, compact: false));
    await tester.pump();
    await tester.pump();

    expect(find.byIcon(AppIcons.favoriteFill), findsOneWidget);
    expect(find.bySemanticsLabel('Save to My List'), findsOneWidget);
  });
}
