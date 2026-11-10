import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/shared/widgets/scroll_edge_fade.dart';

void main() {
  testWidgets('the child stays tappable under the mask', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScrollEdgeFade(
            child: ListView(
              children: [
                GestureDetector(
                  onTap: () => taps++,
                  child: const SizedBox(height: 200, child: Text('Hi')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Hi'));
    expect(taps, 1);
  });

  testWidgets('the top edge fades to transparent, the middle is untouched', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: key,
          child: const ColoredBox(
            color: Color(0xFFFFFFFF),
            child: SizedBox(
              width: 100,
              height: 200,
              child: ScrollEdgeFade(
                top: 40,
                child: ColoredBox(color: Color(0xFFFF0000)),
              ),
            ),
          ),
        ),
      ),
    );

    final alphas = await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      // Red channel stays 255 over the red child and over the white page; the
      // green channel tells them apart: 0 = fully red child, 255 = page.
      int greenAt(int y) => bytes.getUint8((y * image.width + 10) * 4 + 1);
      return (greenAt(1), greenAt(20), greenAt(100));
    });

    final (top, partway, middle) = alphas!;
    // At the very top the child has faded to (almost) nothing: the white page
    // shows. Partway it is half there; in the middle it is fully the child.
    expect(top, greaterThan(200));
    expect(partway, inInclusiveRange(60, 200));
    expect(middle, lessThan(10));
  });
}
