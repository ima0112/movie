import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/suggestion/presentation/cubit/surprise_state.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_affinity_ring.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_closing_view.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_in_watch_later_badge.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_sparkles.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_suggestion_card.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_thumbnail_strip.dart';
import 'package:movies/l10n/app_localizations.dart';

import '../../surprise_test_data.dart';

/// The closing screen on a small phone at 200 % text: nothing overflows, the
/// content scrolls instead, and the key texts are still there.
void main() {
  testWidgets('fits a small screen at 200 % text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final batch = batchOf(5);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: SurpriseClosingView(
          chosen: SurpriseChosen(
            suggestions: batch.suggestions,
            index: 2,
            savedKeys: {const MediaKey(type: MediaType.movie, tmdbId: 2)},
            source: SuggestionSource.quiz,
          ),
          onClose: () {},
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.text('YOUR SURPRISE OF THE DAY'), findsOneWidget);
    expect(find.text('In Watch later'), findsOneWidget);
  });

  testWidgets('the expected design: label under the strip, an "In Watch later" '
      'pill and the affinity ring on the card, no "% for you" tag', (
    tester,
  ) async {
    final batch = batchOf(5);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SurpriseClosingView(
          chosen: SurpriseChosen(
            suggestions: batch.suggestions,
            index: 2,
            savedKeys: const {},
            source: SuggestionSource.quiz,
          ),
          onClose: () {},
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    // The label sits below the strip, centred on the page.
    final strip = tester.getRect(find.byType(SurpriseThumbnailStrip));
    final label = tester.getRect(find.text('YOUR SURPRISE OF THE DAY'));
    expect(label.top, greaterThanOrEqualTo(strip.bottom));
    expect(label.center.dx, closeTo(400, 1)); // the test window is 800 wide

    // The pill is inside the card, top-right; the ring bottom-right with its %.
    final card = tester.getRect(find.byType(SurpriseSuggestionCard));
    final pill = tester.getRect(find.byType(SurpriseInWatchLaterBadge));
    expect(find.text('In Watch later'), findsOneWidget);
    expect(pill.right, lessThanOrEqualTo(card.right));
    expect(pill.top, lessThan(card.top + 60));
    final ring = tester.getRect(find.byType(SurpriseAffinityRing));
    expect(ring.right, lessThanOrEqualTo(card.right));
    expect(ring.bottom, lessThanOrEqualTo(card.bottom));
    expect(find.textContaining('% for you'), findsNothing);
  });

  testWidgets('sparkles both behind and over the chosen card', (tester) async {
    final batch = batchOf(5);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SurpriseClosingView(
          chosen: SurpriseChosen(
            suggestions: batch.suggestions,
            index: 2,
            savedKeys: const {},
            source: SuggestionSource.quiz,
          ),
          onClose: () {},
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    // In paint order: the back layer, the card, the front layer.
    final order = tester
        .widgetList(
          find.byWidgetPredicate(
            (w) => w is SurpriseSparkles || w is SurpriseSuggestionCard,
          ),
        )
        .toList();
    expect(order, hasLength(3));
    expect((order[0] as SurpriseSparkles).front, isFalse);
    expect(order[1], isA<SurpriseSuggestionCard>());
    expect((order[2] as SurpriseSparkles).front, isTrue);
  });
}
