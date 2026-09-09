import 'package:flutter_test/flutter_test.dart';

import 'package:movies/main.dart';

void main() {
  testWidgets('App boots into the design system debug screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PakoTvApp());

    expect(find.text('Design system debug'), findsOneWidget);
  });
}
