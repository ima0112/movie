import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/library_row.dart';
import 'package:movies/shared/widgets/library_row_status.dart';

Widget _row({LibraryRowStatus? status, VoidCallback? onMore}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: LibraryRow(
      posterUrl: null,
      title: 'Dune: Part Two',
      metadata: 'Movie · 2024 · 2 h 46 min',
      status: status,
      onMore: onMore,
    ),
  ),
);

void main() {
  group('LibraryRowStatus.rated', () {
    testWidgets('a star, the rating and when it was added, on one line', (
      tester,
    ) async {
      await tester.pumpWidget(
        _row(
          status: const LibraryRowStatus.rated(
            rating: '8.2',
            label: 'Added today',
          ),
        ),
      );

      expect(find.byIcon(AppIcons.starFill), findsOneWidget);
      expect(find.text('8.2'), findsOneWidget);
      expect(find.text('Added today'), findsOneWidget);
      expect(
        tester.getCenter(find.text('8.2')).dy,
        closeTo(tester.getCenter(find.text('Added today')).dy, 2),
      );
    });

    testWidgets('with no rating there is no star; with no date, only the '
        'rating', (tester) async {
      await tester.pumpWidget(
        _row(status: const LibraryRowStatus.rated(label: 'Added today')),
      );
      expect(find.byIcon(AppIcons.starFill), findsNothing);
      expect(find.text('Added today'), findsOneWidget);

      await tester.pumpWidget(
        _row(status: const LibraryRowStatus.rated(rating: '7.0')),
      );
      expect(find.text('7.0'), findsOneWidget);
    });
  });

  group('LibraryRowStatus.watched', () {
    testWidgets('five stars — the rated ones filled, the rest outlined — and '
        'the date', (tester) async {
      await tester.pumpWidget(
        _row(
          status: const LibraryRowStatus.watched(
            stars: 4,
            label: 'Watched 8 Nov, 2026',
          ),
        ),
      );

      expect(find.byIcon(AppIcons.starFill), findsNWidgets(4));
      expect(find.byIcon(AppIcons.star), findsOneWidget);
      expect(find.text('Watched 8 Nov, 2026'), findsOneWidget);
    });

    testWidgets('unrated shows five outlined stars, not none', (tester) async {
      await tester.pumpWidget(
        _row(
          status: const LibraryRowStatus.watched(stars: null, label: 'Watched'),
        ),
      );

      expect(find.byIcon(AppIcons.starFill), findsNothing);
      expect(find.byIcon(AppIcons.star), findsNWidgets(5));
    });
  });

  testWidgets('no status: no third line', (tester) async {
    await tester.pumpWidget(_row());

    expect(find.byIcon(AppIcons.starFill), findsNothing);
    expect(find.text('Dune: Part Two'), findsOneWidget);
  });

  testWidgets('the three dots are there only with onMore, and tapping them '
      'calls it', (tester) async {
    await tester.pumpWidget(_row());
    expect(find.byIcon(AppIcons.more), findsNothing);

    var taps = 0;
    await tester.pumpWidget(_row(onMore: () => taps++));
    await tester.tap(find.byIcon(AppIcons.more));

    expect(taps, 1);
    expect(find.bySemanticsLabel('More actions'), findsOneWidget);
  });
}
