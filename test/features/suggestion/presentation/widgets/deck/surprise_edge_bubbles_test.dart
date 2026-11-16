import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_edge_bubbles.dart';

Future<void> _pump(WidgetTester tester, {double save = 0, double next = 0}) {
  return tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(
          width: 400,
          height: 600,
          child: SurpriseEdgeBubbles(saveProgress: save, nextProgress: next),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('at rest: outline bookmark in amber, whole icon on screen', (
    tester,
  ) async {
    await _pump(tester);

    final icon = tester.widget<Icon>(find.byIcon(AppIcons.watchLater));
    expect(icon.color, AppColors.accent);
    expect(find.byIcon(AppIcons.watchLaterFill), findsNothing);

    final rect = tester.getRect(find.byIcon(AppIcons.watchLater));
    expect(rect.left, greaterThanOrEqualTo(200));
    final arrow = tester.getRect(find.byIcon(AppIcons.next));
    expect(arrow.right, lessThanOrEqualTo(600));
  });

  testWidgets('pulled: solid dark bookmark on amber with a halo, no border', (
    tester,
  ) async {
    await _pump(tester, save: 1);

    final icon = tester.widget<Icon>(find.byIcon(AppIcons.watchLaterFill));
    expect(icon.color, AppColors.onAccent);
    expect(find.byIcon(AppIcons.watchLater), findsNothing);

    final disc = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((d) => d.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((d) => d.boxShadow != null);
    expect(disc.color, AppColors.accent);
    expect(disc.boxShadow, isNotEmpty);
    expect((disc.border! as Border).top.color.a, 0);
  });
}
