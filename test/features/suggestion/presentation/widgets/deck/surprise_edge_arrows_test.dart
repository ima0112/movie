import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_edge_arrows.dart';

Future<void> _pump(WidgetTester tester, {double left = 0, double right = 0}) {
  return tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(
          width: 400,
          height: 600,
          child: SurpriseEdgeArrows(leftProgress: left, rightProgress: right),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('at rest there is nothing on screen', (tester) async {
    await _pump(tester);
    expect(find.byIcon(AppIcons.back), findsNothing);
    expect(find.byIcon(AppIcons.next), findsNothing);
  });

  testWidgets('dragging left shows only the left arrow, fully inside the '
      'screen once pulled', (tester) async {
    await _pump(tester, left: 1);

    expect(find.byIcon(AppIcons.next), findsNothing);
    final rect = tester.getRect(find.byIcon(AppIcons.back));
    expect(rect.left, greaterThanOrEqualTo(200)); // the box's left edge
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 1);
  });

  testWidgets('dragging right shows only the right arrow, faint at first', (
    tester,
  ) async {
    await _pump(tester, right: 0.3);

    expect(find.byIcon(AppIcons.back), findsNothing);
    expect(find.byIcon(AppIcons.next), findsOneWidget);
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, closeTo(0.3, 0.001));
  });
}
