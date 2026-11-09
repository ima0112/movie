import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/settings/presentation/screens/attribution_screen.dart';
import 'package:movies/l10n/app_localizations.dart';

Widget _wrap({Locale locale = const Locale('en'), double textScale = 1}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: const Size(375, 667),
        textScaler: TextScaler.linear(textScale),
      ),
      child: child!,
    ),
    home: const AttributionScreen(),
  );
}

void main() {
  testWidgets('shows both providers, the required TMDB wording and the note', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    expect(find.text('Attribution and credits'), findsOneWidget);
    expect(find.text('TMDB'), findsOneWidget);
    expect(find.text('JustWatch'), findsOneWidget);
    expect(
      find.text(
        'This product uses the TMDB API but is not endorsed or certified '
        'by TMDB.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('free personal project'), findsOneWidget);
  });

  testWidgets('survives Spanish at 200% text scale without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(locale: const Locale('es'), textScale: 2));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Atribución y créditos'), findsOneWidget);
  });
}
