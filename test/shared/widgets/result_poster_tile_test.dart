import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/app_chip.dart';
import 'package:movies/shared/widgets/poster_badge.dart';
import 'package:movies/shared/widgets/result_poster_tile.dart';
import 'package:movies/shared/widgets/results_grid.dart';

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

MediaItem _movie(int id, {double rating = 8.2, DateTime? date}) => Movie(
  id: id,
  title: 'Movie $id',
  posterUrl: null,
  genres: const [],
  releaseDate: date ?? DateTime(2021, 5, 1),
  voteAverage: rating,
);

void main() {
  testWidgets('a result tile shows the rating badge and the title under the '
      'poster; a show also carries the TV tag', (tester) async {
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 120,
          child: Column(
            children: [
              SizedBox(
                height: 260,
                child: ResultPosterTile(item: _movie(1), onTap: () {}),
              ),
              SizedBox(
                height: 260,
                child: ResultPosterTile(
                  item: TvShow(
                    id: 2,
                    title: 'Show 2',
                    posterUrl: null,
                    genres: const [],
                    releaseDate: null,
                    voteAverage: 7,
                  ),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Movie 1'), findsOneWidget);
    expect(find.text('Show 2'), findsOneWidget);
    expect(find.text('8.2'), findsOneWidget); // the ratings
    expect(find.text('7.0'), findsOneWidget);
    expect(find.text('TV'), findsOneWidget);
    // The title is under the poster, not over it.
    expect(
      tester.getTopLeft(find.text('Movie 1')).dy,
      greaterThan(tester.getRect(find.text('8.2')).bottom),
    );
  });

  testWidgets('the release year goes under the title; none without a date', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Column(
          children: [
            SizedBox(
              width: 120,
              height: 240,
              child: ResultPosterTile(item: _movie(1), onTap: () {}),
            ),
            SizedBox(
              width: 120,
              height: 240,
              child: ResultPosterTile(
                item: Movie(
                  id: 9,
                  title: 'Undated',
                  posterUrl: null,
                  genres: const [],
                  releaseDate: null,
                  voteAverage: 6,
                ),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.text('2021'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('2021')).dy,
      greaterThan(tester.getBottomLeft(find.text('Movie 1')).dy - 1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a title with no votes has no rating badge', (tester) async {
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 120,
          height: 260,
          child: ResultPosterTile(item: _movie(1, rating: 0), onTap: () {}),
        ),
      ),
    );

    expect(find.byType(PosterBadge), findsNothing);
  });

  testWidgets('the results grid is three columns on the page margin, with '
      'room for the caption', (tester) async {
    await tester.pumpWidget(
      _app(
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth - 40;
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: ResultsGrid.delegate(
                width,
                captionExtent: ResultsGrid.captionExtent(context),
              ),
              itemCount: 6,
              itemBuilder: (_, i) =>
                  ResultPosterTile(item: _movie(i), onTap: () {}),
            );
          },
        ),
      ),
    );

    final tops = {
      for (var i = 0; i < 6; i++) tester.getTopLeft(find.text('Movie $i')).dy,
    };
    expect(tops, hasLength(2)); // 3 per row
    expect(tester.takeException(), isNull); // no overflow
  });

  testWidgets('a selected chip is a dark amber tint with an amber hairline and '
      'amber text; a removable one has its × after the label', (tester) async {
    await tester.pumpWidget(
      _app(
        Center(
          child: AppChip(
            label: 'Netflix',
            state: ChipState.selected,
            trailingIcon: Icons.close,
            onTap: () {},
          ),
        ),
      ),
    );

    final decoration =
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(AppChip),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;
    expect(decoration.color, AppColors.accentSoft);
    expect((decoration.border! as Border).top.color, AppColors.accentLine);
    expect(
      tester.widget<Text>(find.text('Netflix')).style?.color,
      AppColors.accent,
    );
    expect(
      tester.getTopLeft(find.byIcon(Icons.close)).dx,
      greaterThan(tester.getTopRight(find.text('Netflix')).dx),
    );
  });
}
