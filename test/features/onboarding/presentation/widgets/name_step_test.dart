import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/onboarding/presentation/widgets/name_step.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/pako_state.dart' show PakoState;

/// CLAUDE.md rule 14's own checklist, enforced for this step: a notched
/// device's safe-area insets plus an open keyboard must never overflow.
Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(390, 844),
        padding: EdgeInsets.only(top: 47, bottom: 34),
        viewInsets: EdgeInsets.only(bottom: 300),
      ),
      child: child,
    ),
  );
}

void main() {
  testWidgets(
    'NameStep survives a notch + home indicator + open keyboard with no '
    'RenderFlex overflow',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          NameStep(
            name: 'Dani',
            initialColor: null,
            isValid: true,
            onNameChanged: (_) {},
            onColorChanged: (_) {},
            onNext: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      // Pako shrinks to 48 px once the keyboard is open.
      expect(tester.widget<PakoState>(find.byType(PakoState)).size, 48);
    },
  );
}
