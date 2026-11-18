import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_flip_card.dart';

Widget _host(ValueNotifier<bool> flipped, {bool still = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: still),
    child: Scaffold(
      body: SizedBox(
        width: 200,
        height: 300,
        child: SurpriseFlipCard(
          flipped: flipped,
          front: const Text('front'),
          back: const Text('back'),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('shows the front; turning it over swaps to the back after the '
      'edge-on point, and turning it back returns', (tester) async {
    final flipped = ValueNotifier(false);
    await tester.pumpWidget(_host(flipped));
    expect(find.text('front'), findsOneWidget);
    expect(find.text('back'), findsNothing);

    flipped.value = true;
    await tester.pump();
    await tester.pump(SurpriseFlipCard.duration * 0.25);
    expect(find.text('front'), findsOneWidget, reason: 'still before 90°');

    await tester.pump(SurpriseFlipCard.duration);
    expect(find.text('back'), findsOneWidget);
    expect(find.text('front'), findsNothing);

    flipped.value = false;
    await tester.pumpAndSettle();
    expect(find.text('front'), findsOneWidget);
  });

  testWidgets('the back is not mirrored', (tester) async {
    final flipped = ValueNotifier(true);
    await tester.pumpWidget(_host(flipped));
    await tester.pumpAndSettle();

    final transforms = tester.widgetList<Transform>(
      find.ancestor(of: find.text('back'), matching: find.byType(Transform)),
    );
    // The card's own half-turn and the back's counter-turn cancel out.
    final x = transforms.fold<double>(
      1,
      (p, t) => p * t.transform.storage[0].sign,
    );
    expect(x, greaterThan(0));
  });

  testWidgets('reduced motion: the faces swap at once', (tester) async {
    final flipped = ValueNotifier(false);
    await tester.pumpWidget(_host(flipped, still: true));

    flipped.value = true;
    await tester.pump();

    expect(find.text('back'), findsOneWidget);
  });

  testWidgets('starts on the back when already flipped', (tester) async {
    await tester.pumpWidget(_host(ValueNotifier(true)));
    expect(find.text('back'), findsOneWidget);
  });
}
