import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/shared/widgets/poster_image.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 110, height: 165, child: child)),
      ),
    ),
  );

  testWidgets('posterPath null -> the flat placeholder, no Image', (
    tester,
  ) async {
    await pump(tester, const PosterImage(posterPath: null));

    expect(find.byType(Image), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == AppColors.imagePlaceholder,
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'posterPath set -> builds the real TMDB URL (no TmdbConfigurationService '
    'registered here, so it resolves against the same well-known fallback '
    'the service itself starts at), at the size the widget is drawn at',
    (tester) async {
      await pump(
        tester,
        const PosterImage(posterPath: '/abc123.jpg', size: 'w342'),
      );

      final image = tester.widget<Image>(find.byType(Image));
      // 110 dp wide: w342 covers it on a 3x screen, decoded at 330 px.
      final provider = image.image as ResizeImage;
      expect(provider.width, 330);
      expect(
        (provider.imageProvider as NetworkImage).url,
        'https://image.tmdb.org/t/p/w342/abc123.jpg',
      );
    },
  );
}
