import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/shared/widgets/app_halo.dart';

/// The halo's glow must be gone before its box ends, whatever the screen's
/// width: otherwise the box's lower edge shows as a horizontal line across the
/// page (the radius is a fraction of the box's shortest side).
void main() {
  for (final width in [320.0, 390.0, 430.0, 600.0, 800.0]) {
    testWidgets('fades to the page color by the bottom edge at $width px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Align(alignment: Alignment.topCenter, child: AppHalo()),
          ),
        ),
      );

      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(AppHalo),
          matching: find.byType(DecoratedBox),
        ),
      );
      final gradient =
          (box.decoration as BoxDecoration).gradient! as RadialGradient;
      final size = tester.getSize(find.byType(AppHalo));
      final shortest = size.width < size.height ? size.width : size.height;

      // Where the gradient is fully the page's color, in logical pixels from
      // the top: the last stop times the radius.
      final reach = gradient.stops!.last * gradient.radius * shortest;
      expect(reach, lessThanOrEqualTo(size.height));
      expect(gradient.colors.last, AppColors.surface);
    });
  }

  testWidgets('painted: no visible step between one row of pixels and the '
      'next down the whole halo, including where its box ends', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.surface,
          body: RepaintBoundary(
            key: key,
            child: const ColoredBox(
              color: AppColors.surface,
              child: Align(alignment: Alignment.topCenter, child: AppHalo()),
            ),
          ),
        ),
      ),
    );

    final bytes = await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      return (data!, image.width, image.height);
    });
    final (data, width, height) = bytes!;

    // Down the centre column: the colour never jumps by more than 2 levels
    // between consecutive rows.
    int channel(int y, int c) =>
        data.getUint8(((y * width) + width ~/ 2) * 4 + c);
    var worst = 0;
    var worstRow = 0;
    for (var y = 1; y < height; y++) {
      for (var c = 0; c < 3; c++) {
        final d = (channel(y, c) - channel(y - 1, c)).abs();
        if (d > worst) {
          worst = d;
          worstRow = y;
        }
      }
    }
    expect(worst, lessThanOrEqualTo(2), reason: 'a step at row $worstRow');
    // And below the halo it is exactly the page's colour.
    final below = height - 1;
    expect(channel(below, 0), (AppColors.surface.r * 255).round());
  });
}
