import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_help_row.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_reroll_button.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_thumbnail_strip.dart';
import 'package:movies/l10n/app_localizations.dart';

Widget _host(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: child)),
);

SurpriseThumbnailStrip _strip({
  int current = 0,
  Set<int> saved = const {},
  int? chosen,
  ValueChanged<int>? onTap,
  int count = 5,
}) => SurpriseThumbnailStrip(
  posterUrls: List<String?>.filled(count, null),
  currentIndex: current,
  savedIndexes: saved,
  chosenIndex: chosen,
  onTap: onTap,
);

void main() {
  group('SurpriseThumbnailStrip', () {
    testWidgets('five thumbnails drawn small, each with a 48 dp touch area', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_strip(onTap: (_) {})));

      final cells = find.descendant(
        of: find.byType(SurpriseThumbnailStrip),
        matching: find.byType(GestureDetector),
      );
      expect(cells, findsNWidgets(5));
      for (var i = 0; i < 5; i++) {
        final size = tester.getSize(cells.at(i));
        expect(size.width, SurpriseThumbnailStrip.touchWidth);
        expect(size.height, SurpriseThumbnailStrip.touchHeight);
      }
      // Close together (a few dp of air between posters), still 48 tall.
      expect(SurpriseThumbnailStrip.touchHeight, 48);
      expect(
        SurpriseThumbnailStrip.touchWidth - SurpriseThumbnailStrip.thumbWidth,
        lessThanOrEqualTo(8),
      );
    });

    testWidgets('tapping a thumbnail reports its card', (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(_host(_strip(onTap: taps.add)));

      final cells = find.descendant(
        of: find.byType(SurpriseThumbnailStrip),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(cells.at(3));
      await tester.tap(cells.at(0));

      expect(taps, [3, 0]);
    });

    testWidgets('a saved card has the bookmark badge; the current one an '
        'accent border; the others neither', (tester) async {
      await tester.pumpWidget(_host(_strip(current: 2, saved: {1})));

      expect(find.byIcon(AppIcons.watchLaterFill), findsOneWidget);
      expect(find.byIcon(AppIcons.check), findsNothing);

      final borders = [
        for (final box in tester.widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(SurpriseThumbnailStrip),
            matching: find.byType(DecoratedBox),
          ),
        ))
          if ((box.decoration as BoxDecoration).border != null)
            (box.decoration as BoxDecoration).border!.top.color,
      ];
      expect(borders.where((c) => c == AppColors.accent), hasLength(1));
    });

    testWidgets('the current card that is also saved shows both', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_strip(current: 1, saved: {1})));

      expect(find.byIcon(AppIcons.watchLaterFill), findsOneWidget);
    });

    testWidgets('closing: the chosen card has a check instead of the '
        'bookmark, nothing is "current", and the strip is inactive', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(_strip(current: 2, saved: {2, 4}, chosen: 2)),
      );

      expect(find.byIcon(AppIcons.check), findsOneWidget);
      expect(find.byIcon(AppIcons.watchLaterFill), findsOneWidget); // card 5
      final accentBorders = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where((b) {
            final border = (b.decoration as BoxDecoration).border;
            return border != null && border.top.color == AppColors.accent;
          });
      expect(accentBorders, isEmpty);

      // Inactive: no tap callback to call.
      final cells = find.descendant(
        of: find.byType(SurpriseThumbnailStrip),
        matching: find.byType(GestureDetector),
      );
      expect(tester.widget<GestureDetector>(cells.first).onTap, isNull);
    });

    testWidgets('fewer cards, fewer thumbnails', (tester) async {
      await tester.pumpWidget(_host(_strip(count: 2, onTap: (_) {})));

      expect(
        find.descendant(
          of: find.byType(SurpriseThumbnailStrip),
          matching: find.byType(GestureDetector),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('a screen reader hears the card number, and "saved"', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(_strip(saved: {1}, onTap: (_) {})));

      expect(find.bySemanticsLabel('Card 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Card 2, saved'), findsOneWidget);
      handle.dispose();
    });
  });

  group('SurpriseHelpRow', () {
    testWidgets('the double-tap hint, in both languages — text, not a '
        'button', (tester) async {
      await tester.pumpWidget(_host(const SurpriseHelpRow()));
      expect(find.text('Double-tap to choose'), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);

      await tester.pumpWidget(
        _host(const SurpriseHelpRow(), locale: const Locale('es')),
      );
      expect(find.text('Toca dos veces para elegir'), findsOneWidget);
    });
  });

  group('SurpriseRerollButton', () {
    testWidgets('full width, at least 48 dp high, and taps once', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 300,
            child: SurpriseRerollButton(onTap: () => taps++),
          ),
        ),
      );

      expect(find.text('Ask for another 5'), findsOneWidget);
      expect(find.byIcon(AppIcons.dice), findsOneWidget);
      final size = tester.getSize(find.byType(SurpriseRerollButton));
      expect(size.width, 300);
      expect(size.height, greaterThanOrEqualTo(48));

      await tester.tap(find.byType(SurpriseRerollButton));
      expect(taps, 1);
    });

    testWidgets('the Spanish copy', (tester) async {
      await tester.pumpWidget(
        _host(SurpriseRerollButton(onTap: () {}), locale: const Locale('es')),
      );

      expect(find.text('Volver a pedir otras 5'), findsOneWidget);
    });
  });
}
