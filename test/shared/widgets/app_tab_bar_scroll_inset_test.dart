import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/shared/widgets/app_tab_bar.dart';

void main() {
  testWidgets('the last item of a root tab can scroll up above the floating '
      'bar (not stay hidden behind it)', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const barHeight = AppTabBar.height;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          extendBody: true,
          body: Builder(
            builder: (context) => ListView(
              padding: EdgeInsets.only(bottom: AppTabBar.scrollInset(context)),
              children: [
                for (var i = 0; i < 30; i++)
                  SizedBox(height: 60, child: Text('Row $i')),
              ],
            ),
          ),
          bottomNavigationBar: const SizedBox(height: barHeight),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pumpAndSettle();

    final lastBottom = tester.getBottomLeft(find.text('Row 29')).dy;
    // The bar occupies the bottom [barHeight] px of the 700 px screen.
    expect(lastBottom, lessThanOrEqualTo(700 - barHeight));
  });
}
