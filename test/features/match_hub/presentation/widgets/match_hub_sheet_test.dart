import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/match_hub/presentation/widgets/match_hub_sheet.dart';
import 'package:movies/l10n/app_localizations.dart';

Widget _host({Locale? locale}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const Scaffold(body: MatchHubSheet()),
);

void main() {
  testWidgets('title, the active Surprise me card and the Soon friends card', (
    tester,
  ) async {
    await tester.pumpWidget(_host());

    expect(find.text('Match'), findsOneWidget);
    expect(find.text('Surprise me'), findsOneWidget);
    expect(find.text('A suggestion just for you'), findsOneWidget);
    expect(find.text('Match with friends'), findsOneWidget);
    expect(find.text('Soon'), findsOneWidget);
    // Only the active card has a chevron.
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('the Spanish copy', (tester) async {
    await tester.pumpWidget(_host(locale: const Locale('es')));

    expect(find.text('Sorpréndeme'), findsOneWidget);
    expect(find.text('Pronto'), findsOneWidget);
  });
}
