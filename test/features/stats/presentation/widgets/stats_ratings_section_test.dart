import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/stats/library_insights_calculator.dart';
import 'package:movies/core/domain/stats/stats_period.dart';
import 'package:movies/features/stats/presentation/widgets/stats_ratings_section.dart';
import 'package:movies/l10n/app_localizations.dart';

final _now = DateTime(2026, 11, 14, 12);

UserMediaEntry _w(int id, {int? rating, double? tmdb}) => UserMediaEntry(
  key: MediaKey(type: MediaType.movie, tmdbId: id),
  title: 'Title $id',
  watchedAt: DateTime(2026, 11, 3),
  rating: rating,
  voteAverage: tmdb,
);

Widget _host(List<UserMediaEntry> entries, {Locale? locale}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SingleChildScrollView(
      child: StatsRatingsSection(
        insights: calculateInsights(
          entries,
          period: StatsPeriod.allTime,
          now: _now,
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('nothing rated: no section', (tester) async {
    await tester.pumpWidget(_host([_w(1)]));
    expect(find.text('Your ratings'), findsNothing);
  });

  testWidgets('average, TMDB, the gap and the furthest titles', (tester) async {
    await tester.pumpWidget(
      _host([_w(1, rating: 5, tmdb: 6.4), _w(2, rating: 3, tmdb: 6.0)]),
    );

    expect(find.text('Your ratings'), findsOneWidget);
    expect(find.text('4.0 average'), findsOneWidget);
    expect(find.text('TMDB: 3.1'), findsOneWidget);
    expect(find.text('You rate 0.9 ★ above TMDB on average'), findsOneWidget);
    expect(find.text('Where you differ from TMDB'), findsOneWidget);
    expect(find.text('Title 1'), findsOneWidget);
    expect(find.text('You ★ 5 · TMDB ★ 3.2'), findsOneWidget);
  });
}
