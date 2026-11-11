import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/shared/widgets/poster_badge.dart';

void main() {
  testWidgets('a long label shrinks with an ellipsis instead of overflowing a '
      'narrow poster', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 60,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: PosterBadge(label: 'Dec 16, 2026'),
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(PosterBadge)).width,
      lessThanOrEqualTo(60),
    );
  });

  testWidgets('the rating variant carries the star', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PosterBadge.rating(label: '8.5')),
      ),
    );
    expect(find.text('8.5'), findsOneWidget);
  });
}
