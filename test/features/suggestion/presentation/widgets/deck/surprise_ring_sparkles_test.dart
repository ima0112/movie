import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/shared/widgets/progress_ring.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_affinity_ring.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_sparkles.dart';

Widget _host(Widget child, {bool still = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: still),
    child: Scaffold(body: Center(child: child)),
  ),
);

double _fraction(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(SurpriseAffinityRing),
      matching: find.byType(CustomPaint),
    ),
  );
  return (paint.painter! as ProgressRingPainter).fraction;
}

void main() {
  group('SurpriseAffinityRing', () {
    testWidgets('the arc fills from empty to the percent while the number is '
        'there from the start', (tester) async {
      await tester.pumpWidget(_host(const SurpriseAffinityRing(percent: 88)));

      expect(find.textContaining('88'), findsOneWidget);
      expect(_fraction(tester), 0);

      await tester.pump(SurpriseAffinityRing.duration * 0.6);
      final mid = _fraction(tester);
      expect(mid, greaterThan(0));
      expect(mid, lessThan(0.88));

      await tester.pump(SurpriseAffinityRing.duration);
      expect(_fraction(tester), closeTo(0.88, 0.0001));
    });

    testWidgets('reduced motion: drawn full at once', (tester) async {
      await tester.pumpWidget(
        _host(const SurpriseAffinityRing(percent: 88), still: true),
      );
      expect(_fraction(tester), closeTo(0.88, 0.0001));
    });
  });

  group('SurpriseSparkle.random', () {
    test('three to five stars, all of them sized and placed inside the box, '
        'at most two over the card, and the set changes', () {
      final counts = <int>{};
      final sets = <String>{};
      for (var seed = 0; seed < 200; seed++) {
        final stars = SurpriseSparkle.random(math.Random(seed));
        counts.add(stars.length);
        sets.add([for (final s in stars) '${s.x},${s.y},${s.size}'].join(';'));
        expect(stars.length, inInclusiveRange(3, 5));
        expect(stars.where((s) => s.front).length, lessThanOrEqualTo(2));
        for (final s in stars) {
          expect(s.x, inInclusiveRange(0, 1));
          expect(s.y, inInclusiveRange(0, 1));
          expect(s.size, inInclusiveRange(10, 20));
          // Over the card: only the poster's open middle.
          if (s.front) {
            expect(s.x, inInclusiveRange(0.2, 0.8));
            expect(s.y, inInclusiveRange(0.2, 0.55));
          }
        }
      }
      expect(counts, {3, 4, 5}, reason: 'every count shows up');
      expect(sets.length, greaterThan(150), reason: 'positions are random');
    });
  });

  group('SurpriseSparkles', () {
    testWidgets('each layer draws only its own stars', (tester) async {
      const stars = [
        SurpriseSparkle(x: 0.1, y: 0.1, size: 12, phase: 0, front: false),
        SurpriseSparkle(x: 0.5, y: 0.4, size: 14, phase: 0, front: true),
        SurpriseSparkle(x: 0.9, y: 0.9, size: 16, phase: 0, front: false),
      ];
      Widget layer(bool front) => _host(
        SizedBox(
          width: 300,
          height: 500,
          child: SurpriseSparkles(stars: stars, front: front),
        ),
        still: true,
      );

      await tester.pumpWidget(layer(false));
      expect(find.byType(Icon).evaluate().length, 2);

      await tester.pumpWidget(layer(true));
      expect(find.byType(Icon).evaluate().length, 1);
    });
  });
}
