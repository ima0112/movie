import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_tour_overlay.dart';
import 'package:movies/l10n/app_localizations.dart';

Widget _host(
  VoidCallback onFinished, {
  Locale locale = const Locale('en'),
  bool still = true,
  double textScale = 1,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(360, 640),
      disableAnimations: still,
      textScaler: TextScaler.linear(textScale),
    ),
    child: Scaffold(
      body: Stack(
        children: [
          const Center(child: Text('under the tour')),
          Positioned.fill(child: SurpriseTourOverlay(onFinished: onFinished)),
        ],
      ),
    ),
  ),
);

void main() {
  testWidgets('three steps: swipe, tap ("1×") and double-tap ("2×")', (
    tester,
  ) async {
    var finished = 0;
    await tester.pumpWidget(_host(() => finished++));

    expect(find.text('Swipe to pass a card'), findsOneWidget);
    expect(find.text('Whichever way you like.'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Back'), findsNothing);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Tap the card to turn it over'), findsOneWidget);
    expect(find.text('1×'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Double-tap to choose it'), findsOneWidget);
    expect(find.text('2×'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
    expect(finished, 0);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Tap the card to turn it over'), findsOneWidget);
    expect(finished, 0);
  });

  testWidgets('"Skip" finishes from any early step; "Got it" finishes the '
      'last', (tester) async {
    var finished = 0;
    await tester.pumpWidget(_host(() => finished++));
    await tester.tap(find.text('Skip'));
    expect(finished, 1);

    await tester.pumpWidget(const SizedBox.shrink()); // (a fresh tour)
    await tester.pumpWidget(_host(() => finished++));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    expect(finished, 2);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_host(() => finished++));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Got it'));
    expect(finished, 3);
  });

  testWidgets('the scrim takes every touch away from what is under it', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 640),
            disableAnimations: true,
          ),
          child: Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => taps++,
                    child: const ColoredBox(color: Colors.black),
                  ),
                ),
                Positioned.fill(child: SurpriseTourOverlay(onFinished: () {})),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(180, 40));
    expect(taps, 0);
  });

  testWidgets('in Spanish', (tester) async {
    await tester.pumpWidget(_host(() {}, locale: const Locale('es')));
    expect(find.text('Desliza para pasar de carta'), findsOneWidget);
    expect(find.text('Hacia el lado que quieras.'), findsOneWidget);
    expect(find.text('Omitir'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Toca dos veces para elegirla'), findsOneWidget);
    expect(find.text('Atrás'), findsOneWidget);
    expect(find.text('Entendido'), findsOneWidget);
  });

  testWidgets('moving, it loops; at 200 % text nothing overflows', (
    tester,
  ) async {
    await tester.pumpWidget(_host(() {}, still: false, textScale: 2));
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  });
}
