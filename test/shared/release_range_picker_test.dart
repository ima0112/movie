import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/release_range_picker.dart';
import 'package:movies/shared/widgets/year_histogram.dart';
import 'package:movies/shared/year_buckets.dart';

Widget _host(Widget child, {Locale? locale}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

ReleaseRangePicker _picker({
  int from = 2010,
  int to = 2026,
  void Function(int, int)? onChanged,
}) => ReleaseRangePicker(
  from: from,
  to: to,
  minYear: 1950,
  maxYear: 2026,
  counts: yearBuckets(const [2011, 2012, 2020], minYear: 1950, maxYear: 2026),
  onChanged: onChanged ?? (_, _) {},
);

void main() {
  group('yearBuckets', () {
    test('counts per 2-year bucket; nulls and years out of the span '
        'count for nothing', () {
      final counts = yearBuckets(
        [1950, 1951, 1952, null, 1900, 2030, 2026],
        minYear: 1950,
        maxYear: 2026,
      );

      expect(counts, hasLength(39)); // 1950-51 ... 2026
      expect(counts[0], 2); // 1950, 1951
      expect(counts[1], 1); // 1952
      expect(counts.last, 1); // 2026 on its own
      expect(counts.fold<int>(0, (a, b) => a + b), 4);
    });
  });

  group('ReleaseRangePicker', () {
    testWidgets('FROM and TO cards say the years; the open end is "Today"', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_picker()));

      expect(find.text('FROM'), findsOneWidget);
      expect(find.text('TO'), findsOneWidget);
      expect(find.text('2010'), findsOneWidget);
      expect(find.text('Today'), findsNWidgets(2)); // the TO card, the track
      expect(find.text('1950'), findsOneWidget);
    });

    testWidgets('a closed end shows its year', (tester) async {
      await tester.pumpWidget(_host(_picker(from: 1980, to: 1999)));

      expect(find.text('1980'), findsOneWidget);
      expect(find.text('1999'), findsOneWidget);
    });

    testWidgets('the preset that matches the range is selected; tapping one '
        'reports its range', (tester) async {
      (int, int)? reported;
      await tester.pumpWidget(
        _host(_picker(from: 2020, onChanged: (a, b) => reported = (a, b))),
      );

      await tester.tap(find.text('2010s'));
      expect(reported, (2010, 2019));
      await tester.tap(find.text('2000s'));
      expect(reported, (2000, 2009));
      await tester.tap(find.text('Earlier'));
      expect(reported, (1950, 1999)); // before 2000
      await tester.tap(find.text('All'));
      expect(reported, (1950, 2026));
      await tester.tap(find.text('2020s'));
      expect(reported, (2020, 2026));
    });

    testWidgets('the histogram colors the bars inside the range amber', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_picker(from: 2010, to: 2026)));

      final colors = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(YearHistogram),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((d) => (d.decoration as BoxDecoration).color)
          .toList();
      expect(colors, hasLength(39));
      // 1950..2009 are the first 30 buckets: out of range, then 9 in range.
      expect(colors.take(30).every((c) => c != AppColors.accent), isTrue);
      expect(colors.skip(30).every((c) => c == AppColors.accent), isTrue);
    });

    testWidgets('the Spanish copy', (tester) async {
      await tester.pumpWidget(_host(_picker(), locale: const Locale('es')));

      expect(find.text('DESDE'), findsOneWidget);
      expect(find.text('HASTA'), findsOneWidget);
      expect(find.text('Hoy'), findsNWidgets(2));
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Anteriores'), findsOneWidget);
    });
  });
}
