import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/onboarding/presentation/widgets/welcome_view.dart';
import 'package:movies/l10n/app_localizations.dart';

/// CLAUDE.md rule 14's own checklist, enforced for step 0.
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
    'WelcomeView survives a notch + home indicator + open keyboard with '
    'no RenderFlex overflow',
    (tester) async {
      await tester.pumpWidget(_wrap(WelcomeView(onGetStarted: () {})));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.text('Get started'), findsOneWidget);
    },
  );
}
