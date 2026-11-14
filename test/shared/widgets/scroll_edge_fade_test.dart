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

  testWidgets('a fade appearing or going never rebuilds the child: a scrolled '
      'list keeps its position and its state', (tester) async {
    Widget host(double bottom) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 300,
          child: ScrollEdgeFade(
            top: 0,
            bottom: bottom,
            child: ListView(
              children: [
                for (var i = 0; i < 30; i++)
                  SizedBox(height: 50, child: Text('row $i')),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(host(40));
    ScrollableState scrollable() => tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    final before = scrollable();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();
    final scrolled = scrollable().position.pixels;
    expect(scrolled, greaterThan(0));

    // The fade goes (the end of a list), and comes back.
    for (final bottom in [0.0, 40.0, 0.0]) {
      await tester.pumpWidget(host(bottom));
      expect(identical(scrollable(), before), isTrue, reason: 'bottom $bottom');
      expect(scrollable().position.pixels, scrolled, reason: 'bottom $bottom');
    }
  });

  testWidgets('with no fade at all it is plainly opaque: nothing is hidden, '
      'not even the first or last row', (tester) async {
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
                top: 0,
                child: ColoredBox(color: Color(0xFFFF0000)),
              ),
            ),
          ),
        ),
      ),
    );
    final pixels = await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      // First and last row, first pixel: red and fully opaque on white.
      int pixel(int y) => bytes.getUint32((y * image.width) * 4);
      return [pixel(0), pixel(image.height - 1)];
    });
    for (final p in pixels!) {
      expect(p, 0xFF0000FF); // rgba: red, opaque
    }
  });
}
