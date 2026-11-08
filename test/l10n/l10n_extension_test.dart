import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/l10n/l10n_extension.dart';

void main() {
  Future<BuildContext> pumpWithLocale(
    WidgetTester tester,
    Locale locale,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            captured = context;
            return Text(context.l10n.discoverSeeAll);
          },
        ),
      ),
    );
    return captured;
  }

  group('context.l10n', () {
    testWidgets('resolves a plain message in English', (tester) async {
      final context = await pumpWithLocale(tester, const Locale('en'));

      expect(find.text('See all'), findsOneWidget);
      expect(context.l10n.discoverSeeAll, 'See all');
    });

    testWidgets('resolves the same plain message in Spanish', (tester) async {
      final context = await pumpWithLocale(tester, const Locale('es'));

      expect(find.text('Ver todo'), findsOneWidget);
      expect(context.l10n.discoverSeeAll, 'Ver todo');
    });

    testWidgets('substitutes typed placeholders', (tester) async {
      final en = await pumpWithLocale(tester, const Locale('en'));
      expect(en.l10n.settingsAboutVersion('1.0.0', '3'), '1.0.0 (3)');

      final es = await pumpWithLocale(tester, const Locale('es'));
      expect(es.l10n.settingsAboutVersion('1.0.0', '3'), '1.0.0 (3)');
    });

    testWidgets('resolves ICU plurals on both sides of =1/other', (
      tester,
    ) async {
      final en = await pumpWithLocale(tester, const Locale('en'));
      expect(en.l10n.settingsDataDeleteItemCount(1), '1 item');
      expect(en.l10n.settingsDataDeleteItemCount(5), '5 items');

      final es = await pumpWithLocale(tester, const Locale('es'));
      expect(es.l10n.settingsDataDeleteItemCount(1), '1 elemento');
      expect(es.l10n.settingsDataDeleteItemCount(5), '5 elementos');
    });
  });
}
