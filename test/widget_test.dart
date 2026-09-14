import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';

void main() {
  setUpAll(configureDependencies);

  testWidgets('App boots into Discover (/) via the router', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();

    expect(find.text('PakoTV'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
  });
}
