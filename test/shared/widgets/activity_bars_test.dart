import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/shared/widgets/activity_bars.dart';
import 'package:movies/shared/widgets/type_split_bar.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(
    body: Center(child: SizedBox(width: 300, child: child)),
  ),
);

List<double> _heights(WidgetTester tester) => tester
    .widgetList<SizedBox>(
      find.descendant(
        of: find.byType(ActivityBars),
        matching: find.byType(SizedBox),
      ),
    )
    .where((b) => b.width == double.infinity)
    .map((b) => b.height!)
    .toList();

void main() {
  group('ActivityBars', () {
    testWidgets('one bar per count, scaled to the busiest, empty months a '
        'stub', (tester) async {
      await tester.pumpWidget(
        _host(const ActivityBars(counts: [0, 2, 4], height: 40)),
      );

      final h = _heights(tester);
      expect(h.length, 3);
      expect(h[2], 40); // the busiest fills the height
      expect(h[1], closeTo(20, 0.1)); // half
      expect(h[0], lessThan(h[1])); // the stub
    });

    testWidgets('all empty: just stubs, no division by zero', (tester) async {
      await tester.pumpWidget(_host(const ActivityBars(counts: [0, 0, 0])));
      expect(tester.takeException(), isNull);
      expect(_heights(tester).toSet().length, 1);
    });

    testWidgets('the current (last) bar is the brightest', (tester) async {
      await tester.pumpWidget(_host(const ActivityBars(counts: [3, 3])));

      final colors = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((d) => (d.decoration as BoxDecoration).color)
          .toList();
      expect(colors.last, AppColors.accent);
      expect(colors.first, isNot(AppColors.accent));
    });
  });

  group('TypeSplitBar', () {
    testWidgets('both parts: proportional flex and a legend', (tester) async {
      await tester.pumpWidget(
        _host(
          const TypeSplitBar(
            firstCount: 3,
            firstLabel: '3 movies',
            secondCount: 1,
            secondLabel: '1 show',
          ),
        ),
      );

      final flexes = tester
          .widgetList<Expanded>(find.byType(Expanded))
          .map((e) => e.flex)
          .toList();
      expect(flexes, [3, 1]);
      expect(find.text('3 movies'), findsOneWidget);
      expect(find.text('1 show'), findsOneWidget);
    });

    testWidgets('one part empty: the other fills the bar; both empty: '
        'nothing', (tester) async {
      await tester.pumpWidget(
        _host(
          const TypeSplitBar(
            firstCount: 5,
            firstLabel: 'a',
            secondCount: 0,
            secondLabel: 'b',
          ),
        ),
      );
      expect(tester.widgetList<Expanded>(find.byType(Expanded)).length, 1);

      await tester.pumpWidget(
        _host(
          const TypeSplitBar(
            firstCount: 0,
            firstLabel: 'a',
            secondCount: 0,
            secondLabel: 'b',
          ),
        ),
      );
      expect(find.byType(Expanded), findsNothing);
    });
  });
}
