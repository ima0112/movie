import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_detail/detail_top_controls.dart';
import 'package:movies/shared/widgets/scrim_back_button.dart';
import 'package:movies/shared/widgets/scrim_share_button.dart';

Widget _app(Widget child, {Locale? locale}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  group('ScrimShareButton', () {
    testWidgets('is a 40 px circle top right, labelled "Share", and tapping '
        'calls onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          Stack(
            fit: StackFit.expand,
            children: [ScrimShareButton(onTap: () => taps++)],
          ),
        ),
      );

      final circle = find.descendant(
        of: find.byType(ScrimShareButton),
        matching: find.byType(Container),
      );
      expect(tester.getSize(circle), const Size(40, 40));
      expect(
        tester.getTopRight(circle).dx,
        lessThanOrEqualTo(
          tester.view.physicalSize.width / tester.view.devicePixelRatio,
        ),
      );
      expect(find.bySemanticsLabel('Share'), findsOneWidget);

      await tester.tap(find.byIcon(AppIcons.share));
      expect(taps, 1);
    });

    testWidgets('the Spanish label is "Compartir"', (tester) async {
      await tester.pumpWidget(
        _app(
          Stack(children: [ScrimShareButton(onTap: () {})]),
          locale: const Locale('es'),
        ),
      );

      expect(find.bySemanticsLabel('Compartir'), findsOneWidget);
    });
  });

  group('DetailTopControls share button', () {
    testWidgets('shown only when onShare is given', (tester) async {
      final compact = ValueNotifier(false);
      addTearDown(compact.dispose);
      await tester.pumpWidget(
        _app(
          Stack(
            children: [
              DetailTopControls(showCompact: compact, title: 'Inception'),
            ],
          ),
        ),
      );
      expect(find.byType(ScrimShareButton), findsNothing);
      expect(find.byType(ScrimBackButton), findsOneWidget);

      var shared = 0;
      await tester.pumpWidget(
        _app(
          Stack(
            children: [
              DetailTopControls(
                showCompact: compact,
                title: 'Inception',
                onShare: () => shared++,
              ),
            ],
          ),
        ),
      );
      expect(find.byType(ScrimShareButton), findsOneWidget);

      await tester.tap(find.byIcon(AppIcons.share));
      expect(shared, 1);
    });
  });
}
