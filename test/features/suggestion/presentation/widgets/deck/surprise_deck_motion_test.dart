import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_deck_stack.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_suggestion_card.dart';
import 'package:movies/l10n/app_localizations.dart';

import '../../../surprise_test_data.dart';

/// How the deck moves: the deck moves on as a swipe starts (no pause), and a
/// card brought up from the thumbnails zooms one way toward a higher number and
/// the other way toward a lower one.
final _cards = batchOf(5).suggestions;

Widget _host(ValueNotifier<int> index, VoidCallback onNext) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SizedBox(
      width: 360,
      height: 560,
      child: ValueListenableBuilder<int>(
        valueListenable: index,
        builder: (context, i, _) => SurpriseDeckStack(
          suggestions: _cards,
          index: i,
          onNext: onNext,
          onChoose: () {},
          onOpenDetail: () {},
        ),
      ),
    ),
  ),
);

Finder _card(int number) => find.byWidgetPredicate(
  (w) => w is SurpriseSuggestionCard && w.number == number,
);

final _leaving = find.byKey(const ValueKey('leaving'));

/// The fading Opacity wrappers around card [number] (the zoom's own).
List<double> _fades(WidgetTester tester, int number) => [
  for (final o in tester.widgetList<Opacity>(
    find.ancestor(of: _card(number).last, matching: find.byType(Opacity)),
  ))
    o.opacity,
];

void main() {
  testWidgets('a swipe moves the deck on as it starts, not after it ends', (
    tester,
  ) async {
    var nexts = 0;
    final index = ValueNotifier(0);
    await tester.pumpWidget(_host(index, () => nexts++));

    final drag = await tester.startGesture(tester.getCenter(_card(1).last));
    await drag.moveBy(const Offset(40, 0));
    await drag.moveBy(const Offset(160, 0));
    await drag.up();
    await tester.pump(const Duration(milliseconds: 40));

    // The exit takes 200 ms; the deck was already told.
    expect(nexts, 1);
    expect(_leaving, findsOneWidget);

    await tester.pumpAndSettle();
    expect(_leaving, findsNothing);
  });

  /// The combined scale of every Transform around card [number].
  double scaleOf(WidgetTester tester, int number) => tester
      .widgetList<Transform>(
        find.ancestor(of: _card(number).last, matching: find.byType(Transform)),
      )
      .fold(1.0, (p, t) => p * t.transform.storage[0]);

  testWidgets('to a higher number (3 → 5): the old top grows and fades, the '
      'new one comes from small and faint', (tester) async {
    final index = ValueNotifier(2);
    await tester.pumpWidget(_host(index, () {}));

    index.value = 4;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(_leaving, findsOneWidget);
    expect(
      tester
          .widget<Transform>(
            find
                .descendant(of: _leaving, matching: find.byType(Transform))
                .first,
          )
          .transform
          .storage[0],
      greaterThan(1),
    );
    expect(_fades(tester, 5).any((o) => o < 1 && o > 0), isTrue);
    expect(scaleOf(tester, 5), lessThan(1));

    await tester.pumpAndSettle();
    expect(_leaving, findsNothing);
    expect(_fades(tester, 5).where((o) => o < 1), isEmpty);
  });

  testWidgets('to a lower number (5 → 3): the old top shrinks back and fades, '
      'the new one comes from large and faint', (tester) async {
    final index = ValueNotifier(4);
    await tester.pumpWidget(_host(index, () {}));

    index.value = 2;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(_leaving, findsOneWidget);
    expect(
      tester
          .widget<Transform>(
            find
                .descendant(of: _leaving, matching: find.byType(Transform))
                .first,
          )
          .transform
          .storage[0],
      lessThan(1),
    );
    expect(_fades(tester, 3).any((o) => o < 1 && o > 0), isTrue);
    expect(scaleOf(tester, 3), greaterThan(1));

    await tester.pumpAndSettle();
    expect(_leaving, findsNothing);
    expect(_fades(tester, 3).where((o) => o < 1), isEmpty);
  });
}
