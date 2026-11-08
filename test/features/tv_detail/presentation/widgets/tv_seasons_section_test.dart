import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/features/tv_detail/presentation/widgets/tv_seasons_section.dart';

const _specials = SeasonSummary(
  seasonNumber: 0,
  name: 'Specials',
  episodeCount: 1,
  posterPath: null,
  airDate: null,
);
const _emptySpecials = SeasonSummary(
  seasonNumber: 0,
  name: 'Specials',
  episodeCount: 0,
  posterPath: null,
  airDate: null,
);
const _season1 = SeasonSummary(
  seasonNumber: 1,
  name: 'Season 1',
  episodeCount: 8,
  posterPath: null,
  airDate: null,
);
const _season2 = SeasonSummary(
  seasonNumber: 2,
  name: 'Season 2',
  episodeCount: 10,
  posterPath: null,
  airDate: null,
);

void main() {
  group('TvSeasonsSection', () {
    testWidgets('renders nothing when there are no seasons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TvSeasonsSection(seasons: [])),
        ),
      );

      expect(find.text('Seasons'), findsNothing);
    });

    testWidgets('a non-empty specials season sorts after every regular '
        'season, labeled "Specials"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TvSeasonsSection(seasons: [_specials, _season1, _season2]),
          ),
        ),
      );

      final labels = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();
      // "Seasons" header, then Season 1, Season 2, Specials — in that
      // order, regardless of the input list's own order.
      expect(labels, containsAllInOrder(['Season 1', 'Season 2', 'Specials']));
    });

    testWidgets('an empty specials season (no episodes) is dropped '
        'entirely', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TvSeasonsSection(seasons: [_season1, _emptySpecials]),
          ),
        ),
      );

      expect(find.text('Specials'), findsNothing);
      expect(find.text('Season 1'), findsOneWidget);
    });

    testWidgets('tapping a row calls onSeasonTap with that season', (
      tester,
    ) async {
      SeasonSummary? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TvSeasonsSection(
              seasons: const [_season1],
              onSeasonTap: (season) => tapped = season,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Season 1'));
      expect(tapped, _season1);
    });
  });
}
