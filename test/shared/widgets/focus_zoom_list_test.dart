import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/shared/widgets/focus_zoom_list.dart';

Widget _host({bool reduceMotion = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reduceMotion),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: SizedBox(
      height: 200,
      child: FocusZoomList(
        itemCount: 10,
        itemExtent: 100,
        itemBuilder: (_, i) => SizedBox(width: 100, child: Text('item $i')),
      ),
    ),
  ),
);

void main() {
  test('the focused item is full size; far ones shrink to the minimum', () {
    final (s0, o0) = FocusZoomList.factorsFor(
      index: 0,
      itemExtent: 100,
      offset: 0,
    );
    expect((s0, o0), (1.0, 1.0));
    final (s9, o9) = FocusZoomList.factorsFor(
      index: 9,
      itemExtent: 100,
      offset: 0,
    );
    expect(s9, FocusZoomList.minScale);
    expect(o9, FocusZoomList.minOpacity);
  });

  testWidgets('scrolling moves the focus', (tester) async {
    tester.view.physicalSize = const Size(300, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host());
    double scaleOf(String t) => tester
        .widget<Transform>(
          find
              .ancestor(of: find.text(t), matching: find.byType(Transform))
              .first,
        )
        .transform
        .storage[0];

    expect(scaleOf('item 0'), 1.0);
    expect(scaleOf('item 2'), lessThan(1.0));

    await tester.drag(find.byType(ListView), const Offset(-300, 0));
    await tester.pump();
    expect(scaleOf('item 3'), greaterThan(0.97));
    expect(scaleOf('item 5'), lessThan(scaleOf('item 3')));
  });

  testWidgets('reduced motion draws no transform', (tester) async {
    await tester.pumpWidget(_host(reduceMotion: true));
    expect(
      find.descendant(
        of: find.byType(FocusZoomList),
        matching: find.byType(Opacity),
      ),
      findsNothing,
    );
  });
}
