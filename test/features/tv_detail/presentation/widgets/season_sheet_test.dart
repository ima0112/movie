import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/features/tv_detail/presentation/widgets/season_sheet.dart';

const _theBearSeason1 = SeasonSummary(
  seasonNumber: 1,
  name: 'Season 1',
  episodeCount: 8,
  posterPath: null,
  airDate: null,
);
const _theBearSpecials = SeasonSummary(
  seasonNumber: 0,
  name: 'Specials',
  episodeCount: 1,
  posterPath: null,
  airDate: null,
);
const _missingSeason = SeasonSummary(
  seasonNumber: 9,
  name: 'Season 9',
  episodeCount: 8,
  posterPath: null,
  airDate: null,
);

void main() {
  setUpAll(() => configureDependencies(fake.name));

  group('SeasonSheet', () {
    testWidgets('shows the season title immediately, then its episodes '
        'once loaded', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SeasonSheet(tvId: 101, seasonSummary: _theBearSeason1),
        ),
      );

      // The title (from SeasonSummary) is there before the fetch settles.
      expect(find.text('Season 1'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('1. System'), findsOneWidget);
      // Episode 2's row is below the fold of the sheet's own (small)
      // viewport — the sliver list only realizes it once scrolled in.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('2. Hands'), findsOneWidget);
    });

    testWidgets('a specials season titles itself "Specials", not '
        '"Season 0"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SeasonSheet(tvId: 101, seasonSummary: _theBearSpecials),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Specials'), findsWidgets);
      expect(find.text('Season 0'), findsNothing);
    });

    testWidgets('a season with no sample data shows the error state', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SeasonSheet(tvId: 101, seasonSummary: _missingSeason),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load"), findsOneWidget);
    });
  });
}
