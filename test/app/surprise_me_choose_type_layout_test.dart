import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_spacing.dart';
import 'package:movies/features/suggestion/presentation/widgets/choose_type_card.dart';

import 'surprise_me_test_helpers.dart';

/// E1's real geometry, on a phone-sized window: both cards span the page
/// (same width, inside the margins) and the headline sits right under the
/// app bar — widget tests that only look for text can't see either problem.
void main() {
  setUpAll(configureSurpriseMeDependencies);

  testWidgets('both cards fill the width between the margins and the '
      'headline starts just under the app bar', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // The test font (Ahem) is far wider than Manrope: shrink the text so the
    // cards' content is narrower than the page, as on a device — only a card
    // that is told to stretch then fills the width.
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpSurpriseMe(tester);

    expect(find.byType(ChooseTypeCard), findsNWidgets(2));
    for (var i = 0; i < 2; i++) {
      final rect = tester.getRect(find.byType(ChooseTypeCard).at(i));
      expect(rect.left, AppSpacing.xl);
      expect(rect.width, 390 - 2 * AppSpacing.xl);
    }

    final top = tester
        .getTopLeft(find.text('What are you in the mood for today?'))
        .dy;
    expect(top, greaterThanOrEqualTo(kToolbarHeight));
    expect(top, lessThanOrEqualTo(kToolbarHeight + AppSpacing.lg));
  });
}
