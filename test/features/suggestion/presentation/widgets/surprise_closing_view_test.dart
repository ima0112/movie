import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/suggestion/presentation/cubit/surprise_state.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_closing_view.dart';
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
}
