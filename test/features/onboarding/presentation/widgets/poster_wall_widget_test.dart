import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_spacing.dart';
import 'package:movies/features/onboarding/presentation/widgets/poster_wall.dart';
import 'package:movies/features/onboarding/presentation/widgets/poster_wall_column.dart';
import 'package:movies/features/onboarding/presentation/widgets/poster_wall_geometry.dart';

const _screenSize = Size(390, 844);

/// A notched iPhone's safe-area padding — `docs/DESIGN_SYSTEM.md`
/// section 6 ("Safe areas") / CLAUDE.md rule 14's own checklist.
Widget _wrap(Widget child) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(size: _screenSize, padding: EdgeInsets.only(top: 47, bottom: 34)),
      child: child,
    ),
  );
}

void _expectEveryColumnCoversTheFullScreen(WidgetTester tester) {
  expect(tester.takeException(), isNull);
  for (final element in tester.elementList(find.byType(PosterWallColumn))) {
    final box = element.findRenderObject()! as RenderBox;
    expect(box.size.height, _screenSize.height);
  }
}

void main() {
  testWidgets(
    'every column covers y=0 to the full screen height at the first '
    'frame, partway through the fastest column\'s own loop, and near '
    'the loop point of the slowest — the 4 columns drift at different '
    'speeds on purpose (PosterWallConfig.columnSpeeds), so this also '
    'proves the guarantee holds for arbitrary, non-synchronized t per '
    'column at once, not one cherry-picked synchronized moment',
    (tester) async {
      await tester.binding.setSurfaceSize(_screenSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final urls = List.generate(80, (i) => 'https://example.com/$i.jpg');
      await tester.pumpWidget(_wrap(PosterWall(posterUrls: urls)));
      await tester.pump();
      _expectEveryColumnCoversTheFullScreen(tester);

      // Real geometry this screen size + the 80 urls (20 per column,
      // disjoint) actually produces — same formula poster_wall_column
      // .dart itself uses, so this stays correct if gap/aspect/pool
      // size ever change, rather than hardcoding a stale number again.
      final columnWidth =
          (_screenSize.width - AppSpacing.sm * 3) / 4; // 4 columns, 3 gaps
      final cardHeight = columnWidth * 1.5;
      final loopHeight = 20 * (cardHeight + AppSpacing.sm);
      final fastestDuration = driftDuration(
        loopHeight: loopHeight,
        speed: PosterWallConfig.columnSpeeds.reduce((a, b) => a > b ? a : b),
      );
      final slowestDuration = driftDuration(
        loopHeight: loopHeight,
        speed: PosterWallConfig.columnSpeeds.reduce((a, b) => a < b ? a : b),
      );

      await tester.pump(fastestDuration * 0.5);
      _expectEveryColumnCoversTheFullScreen(tester);

      await tester.pump(slowestDuration * 0.99 - fastestDuration * 0.5);
      _expectEveryColumnCoversTheFullScreen(tester);
    },
  );
}
