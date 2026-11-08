import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/shared/widgets/scrim_back_button.dart';

void main() {
  group('ScrimBackButton', () {
    Future<void> pumpInStack(WidgetTester tester, StackFit fit) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(fit: fit, children: const [ScrimBackButton()]),
          ),
        ),
      );
    }

    testWidgets('stays a fixed 40x40 circle in a loose Stack', (tester) async {
      await pumpInStack(tester, StackFit.loose);

      expect(tester.getSize(find.byType(Container)), const Size(40, 40));
    });

    testWidgets('stays a fixed 40x40 circle even in a StackFit.expand Stack — '
        'regression test: a plain non-Positioned child would otherwise be '
        'stretched to fill the whole Stack (this broke MovieDetailHeader, '
        "whose Stack uses fit: StackFit.expand for the full-bleed poster)", (
      tester,
    ) async {
      await pumpInStack(tester, StackFit.expand);

      expect(tester.getSize(find.byType(Container)), const Size(40, 40));
    });

    testWidgets('sits below the safe area, not under the status bar/notch', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: 50)),
          child: MaterialApp(
            home: Scaffold(body: Stack(children: const [ScrimBackButton()])),
          ),
        ),
      );

      final top = tester.getTopLeft(find.byType(Container)).dy;
      expect(top, greaterThanOrEqualTo(50));
    });
  });
}
