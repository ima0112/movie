import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/quiz/presentation/widgets/quiz_limits_card.dart';
import 'package:movies/features/quiz/presentation/widgets/quiz_year_limits_step.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/app_segmented_control.dart';
import 'package:movies/shared/widgets/release_range_picker.dart';

class _Calls {
  final ranges = <(int, int, int)>[];
  final runtimes = <int?>[];
  final statuses = <DiscoverTvStatus?>[];
  final watched = <bool>[];
}

Widget _host(
  _Calls calls, {
  MediaType type = MediaType.movie,
  int yearFrom = 1950,
  int? yearTo,
  int? runtime,
  DiscoverTvStatus? status,
  bool excludeWatched = false,
  Locale locale = const Locale('en'),
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SingleChildScrollView(
      child: QuizYearLimitsStep(
        mediaType: type,
        yearFrom: yearFrom,
        yearTo: yearTo,
        onYearRangeChanged: (f, t, c) => calls.ranges.add((f, t, c)),
        maxRuntimeMinutes: runtime,
        onMaxRuntimeChanged: calls.runtimes.add,
        tvStatus: status,
        onTvStatusChanged: calls.statuses.add,
        excludeWatched: excludeWatched,
        onExcludeWatchedChanged: calls.watched.add,
        currentYear: 2026,
      ),
    ),
  ),
);

void main() {
  testWidgets('movie: headline, the range picker open on all years, the '
      'five presets and the limits card', (tester) async {
    await tester.pumpWidget(_host(_Calls()));

    expect(find.text('Which years?'), findsOneWidget);
    expect(find.text('Choose a release range'), findsOneWidget);
    expect(find.byType(ReleaseRangePicker), findsOneWidget);
    expect(find.text('1950'), findsWidgets); // the FROM card and the track
    expect(find.text('Today'), findsWidgets);
    for (final preset in ['All', '2020s', '2010s', '2000s', 'Earlier']) {
      expect(find.text(preset), findsOneWidget);
    }
    expect(find.text('Limits'), findsOneWidget);
    expect(find.text('Max duration'), findsOneWidget);
    expect(find.text('No limit'), findsOneWidget);
    expect(find.text("Exclude what I've already watched"), findsOneWidget);
  });

  testWidgets('a preset reports its range with this year as the top end', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(_host(calls, yearFrom: 1995, yearTo: 2015));

    await tester.tap(find.text('2000s'));
    await tester.tap(find.text('2020s'));

    expect(calls.ranges, [(2000, 2009, 2026), (2020, 2026, 2026)]);
  });

  testWidgets('the duration shows as hours and minutes; the far end is no '
      'limit', (tester) async {
    await tester.pumpWidget(_host(_Calls(), runtime: 150));

    expect(find.text('2 h 30 min'), findsWidgets);
    expect(find.text('No limit'), findsNothing);
  });

  test('formatRuntime: minutes, whole hours, hours and minutes', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(formatRuntime(60, l10n), '1 h');
    expect(formatRuntime(90, l10n), '1 h 30 min');
    expect(formatRuntime(120, l10n), '2 h');
    expect(formatRuntime(45, l10n), '45 min');
  });

  testWidgets('dragging the slider reports minutes in steps of 5; its end is '
      'null (no limit)', (tester) async {
    final calls = _Calls();
    await tester.pumpWidget(_host(calls, runtime: 150));

    final slider = find.byType(Slider);
    final box = tester.getRect(slider);
    await tester.tapAt(Offset(box.right - 1, box.center.dy));
    await tester.pump();

    expect(calls.runtimes, isNotEmpty);
    expect(calls.runtimes.last, isNull);

    await tester.tapAt(Offset(box.left + 1, box.center.dy));
    await tester.pump();
    expect(calls.runtimes.last! % 5, 0);
    expect(calls.runtimes.last, lessThan(75));
  });

  testWidgets('the exclude switch reports', (tester) async {
    final calls = _Calls();
    await tester.pumpWidget(_host(calls));

    await tester.tap(find.byType(Switch));

    expect(calls.watched, [true]);
  });

  testWidgets('TV: Status Any | Finished instead of the duration', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(_host(calls, type: MediaType.tvShow));

    expect(find.text('Max duration'), findsNothing);
    expect(find.byType(Slider), findsNothing);
    expect(find.text('Status'), findsOneWidget);
    expect(find.byType(AppSegmentedControl<bool>), findsOneWidget);

    await tester.tap(find.text('Finished'));
    await tester.pump();
    expect(calls.statuses, [DiscoverTvStatus.ended]);

    await tester.pumpWidget(
      _host(calls, type: MediaType.tvShow, status: DiscoverTvStatus.ended),
    );
    await tester.tap(find.text('Any'));
    await tester.pump();
    expect(calls.statuses.last, isNull);
  });

  testWidgets('the Spanish copy', (tester) async {
    await tester.pumpWidget(
      _host(_Calls(), runtime: 150, locale: const Locale('es')),
    );

    expect(find.text('¿De qué años?'), findsOneWidget);
    expect(find.text('Elige un rango de estreno'), findsOneWidget);
    expect(find.text('Límites'), findsOneWidget);
    expect(find.text('Duración máxima'), findsOneWidget);
    expect(find.text('Excluir lo que ya vi'), findsOneWidget);
    expect(find.text('Anteriores'), findsOneWidget);
  });

  testWidgets('a small phone at 200% text: no overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _host(_Calls(), runtime: 150),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
