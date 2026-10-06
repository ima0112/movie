import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/person_detail/presentation/widgets/person_biography_section.dart';

void main() {
  group('PersonBiographySection', () {
    testWidgets('renders nothing for an empty biography', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PersonBiographySection(
              biography: '',
              isEnglishFallback: false,
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('no "Biography in English" note by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PersonBiographySection(
              biography: 'A short bio.',
              isEnglishFallback: false,
            ),
          ),
        ),
      );

      expect(find.text('Biography in English'), findsNothing);
      expect(find.text('A short bio.'), findsOneWidget);
    });

    testWidgets('shows the note when isEnglishFallback is set', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PersonBiographySection(
              biography: 'A short bio.',
              isEnglishFallback: true,
            ),
          ),
        ),
      );

      expect(find.text('Biography in English'), findsOneWidget);
    });

    testWidgets('starts folded to 5 lines and expands on "Read more"', (
      tester,
    ) async {
      const bio = 'A short bio.';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PersonBiographySection(
              biography: bio,
              isEnglishFallback: false,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(bio));
      expect(textWidget.maxLines, 5);
      expect(find.text('Read more'), findsOneWidget);

      await tester.tap(find.text('Read more'));
      await tester.pump();

      final expandedText = tester.widget<Text>(find.text(bio));
      expect(expandedText.maxLines, isNull);
      expect(find.text('Read more'), findsNothing);
    });
  });
}
