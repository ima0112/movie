import 'package:flutter_test/flutter_test.dart';

/// Lets Home load and settle in a test **without** `pumpAndSettle`.
///
/// Home's taste card has an amber comet that never stops running round its
/// border (a repeating animation, off only with the system's "reduce motion"),
/// so `pumpAndSettle` on a Home that is showing the card would never return.
/// The fake repository answers within a second, so a bounded run of frames is
/// enough. Once another tab or a pushed screen is on top, Home's tickers are
/// off again and `pumpAndSettle` works as usual.
Future<void> settleHome(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
