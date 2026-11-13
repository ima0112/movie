import 'dart:ui' show PictureRecorder;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/shared/widgets/comet_border.dart';

Widget _host({bool reduceMotion = false}) => MaterialApp(
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
    child: child!,
  ),
  home: const Scaffold(
    body: Center(
      child: CometBorder(radius: 16, child: SizedBox(width: 300, height: 140)),
    ),
  ),
);

CometBorderPainter _painter(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(CometBorder),
      matching: find.byType(CustomPaint),
    ),
  );
  return paint.painter! as CometBorderPainter;
}

void main() {
  testWidgets('the comet makes a lap every 5 seconds', (tester) async {
    await tester.pumpWidget(_host());
    expect(_painter(tester).progress, 0);

    await tester.pump(const Duration(milliseconds: 2500));
    expect(_painter(tester).progress, closeTo(0.5, 0.02));

    await tester.pump(const Duration(milliseconds: 2500));
    // Back at the start (a full lap, wrapped).
    expect(
      _painter(tester).progress,
      anyOf(closeTo(0, 0.02), closeTo(1, 0.02)),
    );

    await tester.pump(const Duration(milliseconds: 1250));
    expect(_painter(tester).progress, closeTo(0.25, 0.02));
  });

  testWidgets('with reduce motion on the halo stands still and no animation '
      'runs', (tester) async {
    await tester.pumpWidget(_host(reduceMotion: true));
    final first = _painter(tester).progress;
    expect(first, CometBorder.stillProgress);

    await tester.pump(const Duration(seconds: 3));
    expect(_painter(tester).progress, first);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('switching reduce motion on stops it, off starts it again', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(_host(reduceMotion: true));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(_host());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('it never takes a touch, and does not resize its child', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    expect(tester.getSize(find.byType(CometBorder)), const Size(300, 140));
    expect(
      find.descendant(
        of: find.byType(CometBorder),
        matching: find.byType(IgnorePointer),
      ),
      findsWidgets,
    );
  });

  test('the painter draws a full lap without throwing, at any progress', () {
    for (final progress in [0.0, 0.05, 0.5, 0.97, 1.0]) {
      final recorder = PictureRecorder();
      CometBorderPainter(
        progress: progress,
        radius: 16,
        color: Colors.amber,
      ).paint(Canvas(recorder), const Size(300, 140));
      recorder.endRecording();
    }
  });
}
