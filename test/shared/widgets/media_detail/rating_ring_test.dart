import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_detail/rating_ring.dart';
import 'package:movies/shared/widgets/progress_ring.dart';

Widget _host(
  double rating, {
  double textScale = 1,
  Locale? locale,
  bool reduceMotion = false,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(textScale),
      disableAnimations: reduceMotion,
    ),
    child: child!,
  ),
  home: Scaffold(
    body: Center(child: RatingRing(rating: rating)),
  ),
);

void main() {
  testWidgets('shows the rating and its source in a fixed-size ring', (
    tester,
  ) async {
    await tester.pumpWidget(_host(9));
    expect(find.text('9.0'), findsOneWidget);
    expect(find.text('TMDB'), findsOneWidget);
    expect(tester.getSize(find.byType(RatingRing)), const Size(56, 56));
  });

  testWidgets('the number follows the app language', (tester) async {
    await tester.pumpWidget(_host(8.7, locale: const Locale('es')));
    expect(find.text('8,7'), findsOneWidget);
  });

  testWidgets('it keeps its size at 200% text', (tester) async {
    await tester.pumpWidget(_host(9.4, textScale: 2));
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(RatingRing)), const Size(56, 56));
  });

  testWidgets('it reads as one semantics label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(9));
    expect(find.bySemanticsLabel('Rating 9.0 out of 10'), findsOneWidget);
    handle.dispose();
  });

  /// The arc's sweep fraction, read from the ring's painter.
  double sweep(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(RatingRing),
        matching: find.byType(CustomPaint),
      ),
    );
    return (paint.painter! as ProgressRingPainter).fraction;
  }

  testWidgets('the arc fills from empty to the rating, the number already '
      'there', (tester) async {
    await tester.pumpWidget(_host(8));
    expect(find.text('8.0'), findsOneWidget);
    expect(sweep(tester), 0);

    await tester.pump(ProgressRing.duration * 0.6);
    final mid = sweep(tester);
    expect(mid, greaterThan(0));
    expect(mid, lessThan(0.8));

    await tester.pumpAndSettle();
    expect(sweep(tester), moreOrLessEquals(0.8));
  });

  testWidgets('with reduce motion the arc is full at once', (tester) async {
    await tester.pumpWidget(_host(8, reduceMotion: true));
    expect(sweep(tester), moreOrLessEquals(0.8));
  });
}
