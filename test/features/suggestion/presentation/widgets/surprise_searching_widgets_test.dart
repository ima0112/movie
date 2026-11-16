import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/suggestion/presentation/widgets/surprise_card_fan.dart';
import 'package:movies/features/suggestion/presentation/widgets/surprise_deck_card.dart';
import 'package:movies/features/suggestion/presentation/widgets/surprise_star_row.dart';

Widget _host(Widget child, {bool disableAnimations = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Scaffold(body: Center(child: child)),
  ),
);

Offset _center(WidgetTester tester, int i) =>
    tester.getCenter(find.byKey(ValueKey('surprise-card-$i')));

void main() {
  testWidgets('a card is 150×214 with a "?" in the middle', (tester) async {
    await tester.pumpWidget(
      _host(const SurpriseDeckCard(colors: [Colors.red, Colors.blue])),
    );

    expect(tester.getSize(find.byType(SurpriseDeckCard)), const Size(150, 214));
    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('the fan: five cards, open and symmetric when still', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const SurpriseCardFan(), disableAnimations: true),
    );

    for (var i = 0; i < 5; i++) {
      expect(find.byKey(ValueKey('surprise-card-$i')), findsOneWidget);
    }
    final mid = _center(tester, 2).dx;
    expect(_center(tester, 0).dx, closeTo(mid - 96, 0.5));
    expect(_center(tester, 1).dx, closeTo(mid - 48, 0.5));
    expect(_center(tester, 3).dx, closeTo(mid + 48, 0.5));
    expect(_center(tester, 4).dx, closeTo(mid + 96, 0.5));
    // Y: 8, 4, 0, −4, −8 around the middle card.
    expect(_center(tester, 0).dy - _center(tester, 2).dy, closeTo(8, 0.5));
    expect(_center(tester, 4).dy - _center(tester, 2).dy, closeTo(-8, 0.5));
  });

  testWidgets('the fan shuffles: the cards move toward the centre and back', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const SurpriseCardFan()));
    final open = _center(tester, 0).dx;

    // Quarter of a cycle later card 0 is somewhere between rest and centre.
    await tester.pump(const Duration(milliseconds: 600));
    final moving = _center(tester, 0).dx;
    expect(moving, isNot(closeTo(open, 0.5)));

    // The middle card never moves sideways.
    final mid = _center(tester, 2).dx;
    await tester.pump(const Duration(milliseconds: 500));
    expect(_center(tester, 2).dx, closeTo(mid, 0.5));

    // Unmount so the repeating animation doesn't outlive the test.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('five stars; with reduced motion all at full opacity', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const SurpriseStarRow(), disableAnimations: true),
    );

    expect(find.byType(Icon), findsNWidgets(5));
    for (final o in tester.widgetList<Opacity>(find.byType(Opacity))) {
      expect(o.opacity, 1);
    }
  });

  testWidgets('the stars pulse out of step with each other', (tester) async {
    await tester.pumpWidget(_host(const SurpriseStarRow()));
    await tester.pump(const Duration(milliseconds: 300));

    final opacities = [
      for (final o in tester.widgetList<Opacity>(find.byType(Opacity)))
        o.opacity,
    ];
    expect(opacities.toSet().length, greaterThan(1));
    expect(opacities.every((o) => o >= 0.25 && o <= 1), isTrue);

    await tester.pumpWidget(const SizedBox());
  });
}
