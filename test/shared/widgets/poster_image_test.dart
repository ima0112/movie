import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/shared/widgets/poster_image.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

  testWidgets('posterPath null -> the color placeholder, no Image', (
    tester,
  ) async {
    await pump(tester, const PosterImage(posterPath: null));

    expect(find.byType(Image), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == AppColors.surfaceRaised2,
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'posterPath set -> builds the real TMDB URL (no TmdbConfigurationService '
    'registered here, so it resolves against the same well-known fallback '
    'the service itself starts at)',
    (tester) async {
      await pump(
        tester,
        const PosterImage(posterPath: '/abc123.jpg', size: 'w342'),
      );

      final image = tester.widget<Image>(find.byType(Image));
      final provider = image.image as NetworkImage;
      expect(provider.url, 'https://image.tmdb.org/t/p/w342/abc123.jpg');
    },
  );
}
