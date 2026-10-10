import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/region_sheet.dart';

/// CLAUDE.md rule 14's own checklist — this branch's own manual-
/// verification claim ("la hoja de región con el teclado abierto, en
/// un dispositivo pequeño y con escala de texto al 200%") turned into
/// an automated check, since this sandbox has no real device/simulator
/// tap-automation to drive that scenario by hand.
Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: const MediaQueryData(
        // A small device — "iPhone SE (3rd generation)"-sized.
        size: Size(375, 667),
        padding: EdgeInsets.only(top: 20, bottom: 0),
        viewInsets: EdgeInsets.only(bottom: 300),
        textScaler: TextScaler.linear(2),
      ),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('RegionSheet survives a small device + open keyboard + 200% text '
      'scale with no RenderFlex overflow, and search still filters', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(
      _wrap(
        RegionSheet(
          selectedRegionCode: 'US',
          onSelected: (code) => picked = code,
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Region'), findsOneWidget);

    // The keyboard + 200% text scale leave little vertical room —
    // typing narrows the list down to what actually matters here,
    // which is also the realistic flow (the keyboard is open to
    // search, not to browse the full, mostly off-screen list).
    await tester.enterText(find.byType(TextField), 'spa');
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Spain'), findsOneWidget);
    expect(find.text('United States'), findsNothing);

    await tester.tap(find.text('Spain'));
    await tester.pump();

    expect(picked, 'ES');
  });
}
