import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/stats/library_insights_calculator.dart';
import 'package:movies/core/domain/stats/stats_period.dart';
import 'package:movies/features/stats/presentation/widgets/stats_activity_section.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/activity_calendar.dart';

final _now = DateTime(2026, 11, 14, 12);

UserMediaEntry _w(int id, DateTime at) => UserMediaEntry(
  key: MediaKey(type: MediaType.movie, tmdbId: id),
  title: 'Title $id',
  watchedAt: at,
);

Widget _host(StatsPeriod period, List<UserMediaEntry> entries) {
  final insights = calculateInsights(entries, period: period, now: _now);
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: StatsActivitySection(insights: insights, today: _now),
      ),
    ),
  );
}

void main() {
  test('activityCellColor deepens with the count', () {
    expect(activityCellColor(0), isNot(activityCellColor(1)));
    expect(activityCellColor(1), isNot(activityCellColor(2)));
    expect(activityCellColor(2), isNot(activityCellColor(3)));
    expect(activityCellColor(9), activityCellColor(3));
  });

  testWidgets('month: a numbered calendar, no future days, with the legend', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(StatsPeriod.thisMonth, [_w(1, DateTime(2026, 11, 3))]),
    );

    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('14'), findsOneWidget);
    expect(find.text('15'), findsNothing); // after today
    expect(find.text('Less'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });

  testWidgets('year and all time: week columns with month captions', (
    tester,
  ) async {
    await tester.pumpWidget(_host(StatsPeriod.thisYear, const []));
    expect(find.byType(ActivityCalendar), findsOneWidget);
    expect(find.text('J'), findsWidgets); // Jan / Jun / Jul — one letter

    await tester.pumpWidget(_host(StatsPeriod.allTime, const []));
    await tester.pump();
    expect(find.text('NOV'), findsOneWidget);
  });
}
