import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/expandable_text.dart';

Widget _host(String overview) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SingleChildScrollView(child: ExpandableText(overview, maxLines: 4)),
  ),
);

void main() {
  final longText = List.filled(60, 'A long synopsis sentence.').join(' ');

  testWidgets('a long synopsis toggles Read more <-> Read less', (
    tester,
  ) async {
    await tester.pumpWidget(_host(longText));

    expect(find.text('Read more'), findsOneWidget);
    expect(find.text('Read less'), findsNothing);

    await tester.tap(find.text('Read more'));
    await tester.pump();
    expect(find.text('Read less'), findsOneWidget);
    expect(find.text('Read more'), findsNothing);

    await tester.ensureVisible(find.text('Read less'));
    await tester.tap(find.text('Read less'));
    await tester.pump();
    expect(find.text('Read more'), findsOneWidget);
  });

  testWidgets('a short synopsis that fits has no toggle at all', (
    tester,
  ) async {
    await tester.pumpWidget(_host('Short and sweet.'));

    expect(find.text('Short and sweet.'), findsOneWidget);
    expect(find.text('Read more'), findsNothing);
    expect(find.text('Read less'), findsNothing);
  });
}
