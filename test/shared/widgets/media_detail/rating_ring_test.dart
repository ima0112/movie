import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_detail/rating_ring.dart';

Widget _host(double rating, {double textScale = 1, Locale? locale}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
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
}
