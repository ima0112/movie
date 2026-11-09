import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/person_detail/presentation/widgets/person_biography_section.dart';
import 'package:movies/l10n/app_localizations.dart';

void main() {
  group('PersonBiographySection', () {
    testWidgets('renders nothing for an empty biography', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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

    testWidgets('a long bio starts folded to 3 lines and toggles Read more / '
        'Read less', (tester) async {
      final bio = List.filled(40, 'A long biography sentence.').join(' ');
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonBiographySection(
                biography: bio,
                isEnglishFallback: false,
              ),
            ),
          ),
        ),
      );

      expect(tester.widget<Text>(find.text(bio)).maxLines, 3);
      expect(find.text('Read more'), findsOneWidget);

      await tester.tap(find.text('Read more'));
      await tester.pump();

      expect(tester.widget<Text>(find.text(bio)).maxLines, isNull);
      expect(find.text('Read less'), findsOneWidget);
    });

    testWidgets('a short bio that fits has no toggle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: PersonBiographySection(
              biography: 'A short bio.',
              isEnglishFallback: false,
            ),
          ),
        ),
      );

      expect(find.text('Read more'), findsNothing);
      expect(find.text('Read less'), findsNothing);
    });
  });
}
