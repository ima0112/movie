import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/shared/widgets/clear_of_tab_bar.dart';

void main() {
  testWidgets('centers its child in the room above the tab bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(bottom: 100)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ClearOfTabBar(
            child: Center(child: SizedBox(key: Key('c'))),
          ),
        ),
      ),
    );
    final body = tester.getSize(find.byType(ClearOfTabBar));
    final center = tester.getCenter(find.byKey(const Key('c')));
    // The child's middle is half of what's left once the bar's room is gone.
    expect(center.dy, lessThan(body.height / 2));
    expect(center.dy, closeTo((body.height - 100 - 16) / 2, 0.5));
  });
}
