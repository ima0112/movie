import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/splash_screen.dart';
import 'package:movies/shared/widgets/app_logo_mark.dart';
import 'package:movies/shared/widgets/app_wordmark.dart';

/// The native splash already shows PickMe's mark, centered. The in-app splash
/// must start with it in place — no fade-in, which would make it vanish and come
/// back — and hang the wordmark under it.
void main() {
  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(preload: () async {}, onFinished: () {}),
      ),
    );
  }

  testWidgets('the mark is exactly centered and fully there from the first '
      'frame', (tester) async {
    await pump(tester);

    final center = tester.getCenter(find.byType(AppLogoMark));
    expect(center.dx, moreOrLessEquals(195, epsilon: 0.5));
    expect(center.dy, moreOrLessEquals(422, epsilon: 0.5));
    expect(
      find.ancestor(
        of: find.byType(AppLogoMark),
        matching: find.byType(AnimatedOpacity),
      ),
      findsNothing,
      reason: 'a fade-in would blink after the native splash',
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });

  testWidgets('the wordmark unfurls under the mark', (tester) async {
    await pump(tester);

    final mark = tester.getRect(find.byType(AppLogoMark));
    final wordmark = tester.getRect(find.byType(AppWordmark));
    expect(wordmark.top, greaterThanOrEqualTo(mark.bottom - 1));
    expect(wordmark.center.dx, moreOrLessEquals(195, epsilon: 1));

    final fade = find.ancestor(
      of: find.byType(AppWordmark),
      matching: find.byType(AnimatedOpacity),
    );
    expect(tester.widget<AnimatedOpacity>(fade.first).opacity, 0);
    await tester.pump(
      SplashScreen.wordmarkDelay + const Duration(milliseconds: 50),
    );
    expect(tester.widget<AnimatedOpacity>(fade.first).opacity, 1);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
