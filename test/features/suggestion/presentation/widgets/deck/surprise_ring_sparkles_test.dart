import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  return (paint.painter! as SurpriseRingPainter).fraction;
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

  group('SurpriseSparkles', () {
    testWidgets('there are plenty behind the card and a few over it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 300,
            height: 500,
            child: SurpriseSparkles.behind(),
          ),
          still: true,
        ),
      );
      expect(
        find.byType(Icon).evaluate().length,
        SurpriseSparkles.behindStars.length,
      );
      expect(SurpriseSparkles.behindStars.length, greaterThanOrEqualTo(12));

      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 300,
            height: 500,
            child: SurpriseSparkles.front(),
          ),
          still: true,
        ),
      );
      expect(
        find.byType(Icon).evaluate().length,
        SurpriseSparkles.frontStars.length,
      );
      expect(SurpriseSparkles.frontStars, isNotEmpty);
    });
  });
}
