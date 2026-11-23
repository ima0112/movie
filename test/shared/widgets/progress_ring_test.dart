import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/shared/widgets/progress_ring.dart';

Widget _host({bool still = false}) => MaterialApp(
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: still),
    child: child!,
  ),
  home: const Scaffold(
    body: Center(
      child: ProgressRing(
        fraction: 0.5,
        size: 60,
        strokeWidth: 4,
        child: Text('mid'),
      ),
    ),
  ),
);

double _sweep(WidgetTester tester) =>
    (tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byType(ProgressRing),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .painter!
            as ProgressRingPainter)
        .fraction;

void main() {
  testWidgets('it is the given size, the child in the middle from the start, '
      'the arc empty', (tester) async {
    await tester.pumpWidget(_host());
    expect(tester.getSize(find.byType(ProgressRing)), const Size(60, 60));
    expect(find.text('mid'), findsOneWidget);
    expect(_sweep(tester), 0);
  });

  testWidgets('the arc fills to the fraction and stays there', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pump(ProgressRing.duration * 0.6);
    expect(_sweep(tester), inExclusiveRange(0, 0.5));
    await tester.pumpAndSettle();
    expect(_sweep(tester), moreOrLessEquals(0.5));
  });

  testWidgets('reduce motion: full at once', (tester) async {
    await tester.pumpWidget(_host(still: true));
    expect(_sweep(tester), moreOrLessEquals(0.5));
  });
}
