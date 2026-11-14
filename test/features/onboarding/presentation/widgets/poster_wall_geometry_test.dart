import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/onboarding/presentation/widgets/poster_wall_geometry.dart';

void main() {
  // A realistic column's geometry: stride (card + gap) 158, enough
  // slots that loopHeight satisfies the widget's own invariant
  // (loopHeight >= viewportHeight + cardHeight, cardHeight = 150 here).
  const viewportHeight = 800.0;
  const tileHeight = 158.0; // stride: cardHeight (150) + gap (8)
  const loopHeight = 7 * tileHeight; // 1106 >= 800 + 150

  const startPhases = [0.0, 0.35, 0.15, 0.6];

  group('visibleTileRange', () {
    test('200 values of t, both directions, all 4 start phases: the '
        'rendered content always covers the full viewport — no gap at '
        'any point in the loop. This is the test that would have caught '
        'the earlier Padding(top: ...) bug.', () {
      for (var i = 0; i < 200; i++) {
        final t = i / 199;
        for (final goesUp in [true, false]) {
          for (final startPhase in startPhases) {
            final offset = driftOffset(
              startPhase: startPhase,
              t: t,
              goesUp: goesUp,
              loopHeight: loopHeight,
            );
            final range = visibleTileRange(
              offset: offset,
              loopHeight: loopHeight,
              viewportHeight: viewportHeight,
              tileHeight: tileHeight,
            );
            expect(
              range.coversViewport,
              isTrue,
              reason:
                  't=$t goesUp=$goesUp startPhase=$startPhase '
                  'offset=$offset range=$range',
            );
          }
        }
      }
    });

    test('a geometry that violates loopHeight >= viewport + cardHeight '
        'does NOT cover the viewport at every t — proving the test '
        'above is actually sensitive, not vacuously true', () {
      // Only 2 slots: loopHeight = 316, well under 800 + 150 = 950.
      const tooShortLoopHeight = 2 * tileHeight;
      var sawAGap = false;
      for (var i = 0; i < 200; i++) {
        final t = i / 199;
        final offset = driftOffset(
          startPhase: 0,
          t: t,
          goesUp: true,
          loopHeight: tooShortLoopHeight,
        );
        final range = visibleTileRange(
          offset: offset,
          loopHeight: tooShortLoopHeight,
          viewportHeight: viewportHeight,
          tileHeight: tileHeight,
        );
        if (!range.coversViewport) sawAGap = true;
      }
      expect(sawAGap, isTrue);
    });
  });

  group('driftOffset', () {
    test('the loop is continuous: t=0 and t=1 land on the exact same '
        'offset for every phase and direction — the restart is '
        'invisible', () {
      for (final goesUp in [true, false]) {
        for (final startPhase in startPhases) {
          final atStart = driftOffset(
            startPhase: startPhase,
            t: 0,
            goesUp: goesUp,
            loopHeight: loopHeight,
          );
          final atEnd = driftOffset(
            startPhase: startPhase,
            t: 1,
            goesUp: goesUp,
            loopHeight: loopHeight,
          );
          // closeTo, not exact equality: floating-point `%` on t=1 vs
          // t=0 can differ by a sub-pixel epsilon even though they're
          // mathematically identical — irrelevant to "the restart is
          // invisible" at real screen resolutions.
          expect(atEnd, closeTo(atStart, 0.001));
        }
      }
    });

    test('reduce motion (t=0) shows exactly startPhase\'s own position, '
        'not an arbitrary frozen one', () {
      final offset = driftOffset(
        startPhase: 0.35,
        t: 0,
        goesUp: true,
        loopHeight: loopHeight,
      );
      expect(offset, -0.35 * loopHeight - loopHeight);
    });
  });

  group('driftDuration', () {
    test('duration is exactly loopHeight / speed', () {
      final duration = driftDuration(loopHeight: 1200, speed: 6);
      expect(duration, const Duration(seconds: 200));
    });

    test('a fractional result keeps microsecond precision rather than '
        'rounding the whole period down to the nearest millisecond', () {
      final duration = driftDuration(loopHeight: 100, speed: 7);
      // 100 / 7 s = 14.2857...s — not a whole number of milliseconds.
      expect(duration.inMicroseconds, 14285714);
    });

    test("every configured column speed is within PosterWallConfig's own "
        '4-10 px/s range — "slow drift" stays slow even if someone edits '
        'columnSpeeds without noticing the bound', () {
      for (final speed in PosterWallConfig.columnSpeeds) {
        expect(speed, greaterThanOrEqualTo(PosterWallConfig.minAllowedSpeed));
        expect(speed, lessThanOrEqualTo(PosterWallConfig.maxAllowedSpeed));
      }
    });
  });
}
