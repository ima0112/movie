import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_card_back.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_deck_stack.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_edge_arrows.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_suggestion_card.dart';
import 'package:movies/l10n/app_localizations.dart';

import '../../../surprise_test_data.dart';

class _Calls {
  int next = 0;
  int choose = 0;
  int flipped = 0;
}

Widget _host(
  _Calls calls, {
  int cards = 5,
  int index = 0,
  bool disableAnimations = false,
}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(360, 640),
      disableAnimations: disableAnimations,
    ),
    child: Scaffold(
      body: SizedBox(
        width: 360,
        height: 560,
        child: SurpriseDeckStack(
          suggestions: batchOf(cards).suggestions,
          index: index,
          onNext: () => calls.next++,
          onChoose: () => calls.choose++,
          onFlipped: () => calls.flipped++,
        ),
      ),
    ),
  ),
);

Finder get _top =>
    find.byWidgetPredicate((w) => w is SurpriseSuggestionCard && w.number == 1);

void main() {
  List<int> shown(WidgetTester tester) => [
    for (final w in tester.widgetList<SurpriseSuggestionCard>(
      find.byType(SurpriseSuggestionCard),
    ))
      w.number,
  ];

  testWidgets('only the card on top and the next one are built (the swiper '
      'draws two)', (tester) async {
    await tester.pumpWidget(_host(_Calls()));
    await tester.pumpAndSettle();

    // Painted back to front: the next card, then the top one.
    expect(shown(tester), [2, 1]);
  });

  testWidgets('the order is circular: with card 5 on top, card 1 is next', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_Calls(), index: 4));
    await tester.pumpAndSettle();

    expect(shown(tester), [1, 5]);
  });

  testWidgets('drag LEFT past a third of the width: pass, once', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(_host(calls));

    await tester.drag(_top, const Offset(-200, 0));
    await tester.pumpAndSettle();

    expect(calls.next, 1);
  });

  testWidgets('drag RIGHT past a third of the width: pass, once', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(_host(calls));

    await tester.drag(_top, const Offset(200, 0));
    await tester.pumpAndSettle();

    expect(calls.next, 1);
  });

  testWidgets('a drag that stops short springs back and does nothing', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(_host(calls));
    final start = tester.getCenter(_top).dx;

    final gesture = await tester.startGesture(tester.getCenter(_top));
    await gesture.moveBy(const Offset(-20, 0)); // past the touch slop
    await gesture.moveBy(const Offset(-60, 0));
    await tester.pump();
    expect(tester.getCenter(_top).dx, lessThan(start)); // follows the finger
    await gesture.up();
    await tester.pumpAndSettle();

    expect(tester.getCenter(_top).dx, closeTo(start, 0.5));
    expect(calls.next, 0);
  });

  testWidgets('with one card there is nowhere to go: dragging does nothing', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(_host(calls, cards: 1));

    await tester.drag(_top, const Offset(-250, 0));
    await tester.pumpAndSettle();

    expect(calls.next, 0);
  });

  testWidgets('double tap chooses; a single tap turns the card over', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(_host(calls));

    await tester.tap(_top);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(_top);
    await tester.pumpAndSettle();
    expect(calls.choose, 1);
    expect(calls.flipped, 0);

    await tester.tap(_top);
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(calls.flipped, 1);
    expect(calls.choose, 1);
  });

  testWidgets('dragging shows no edge arrows (they are only in the tour)', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_Calls()));
    expect(find.byType(SurpriseEdgeArrows), findsNothing);

    final gesture = await tester.startGesture(tester.getCenter(_top));
    await gesture.moveBy(const Offset(-20, 0)); // past the touch slop
    await gesture.moveBy(const Offset(-100, 0));
    await tester.pump();
    expect(find.byType(SurpriseEdgeArrows), findsNothing);

    await gesture.moveBy(const Offset(220, 0));
    await tester.pump();
    expect(find.byType(SurpriseEdgeArrows), findsNothing);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion: the deck changes at once, nothing turns', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(_host(calls, disableAnimations: true));

    await tester.drag(_top, const Offset(220, 0));
    await tester.pumpAndSettle();

    expect(calls.next, 1);
    final rotations = [
      for (final card in tester.widgetList(find.byType(SurpriseSuggestionCard)))
        for (final t in tester.widgetList<Transform>(
          find.ancestor(
            of: find.byWidget(card),
            matching: find.byType(Transform),
          ),
        ))
          t.transform.getRotation().storage[1].abs(),
    ];
    expect(rotations, isNotEmpty);
    expect(rotations.every((r) => r < 0.001), isTrue);
  });

  testWidgets('buzzes: none for passing, medium on choose', (tester) async {
    final buzzes = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          buzzes.add(call.arguments as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(_host(_Calls()));

    await tester.drag(_top, const Offset(-220, 0));
    await tester.pumpAndSettle();
    // Card 2 is on top now.
    final top = find.byType(SurpriseSuggestionCard).last;
    await tester.tap(top);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(top);
    await tester.pumpAndSettle();

    expect(buzzes, ['HapticFeedbackType.mediumImpact']);
  });

  testWidgets('a tap turns the top card over, another turns it back', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(_host(calls));
    expect(find.byType(SurpriseCardBack), findsNothing);

    await tester.tap(_top);
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.byType(SurpriseCardBack), findsOneWidget);
    expect(calls.flipped, 1);

    await tester.tap(find.byType(SurpriseCardBack));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.byType(SurpriseCardBack), findsNothing);
    expect(calls.flipped, 1, reason: 'only turning to the back is reported');
  });
}
