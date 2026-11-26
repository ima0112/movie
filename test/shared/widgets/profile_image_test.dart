import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/shared/widgets/profile_image.dart';

void main() {
  group('ProfileImage', () {
    testWidgets('a raw profile_path resolves to a real TMDB URL — never '
        'painted into Image.network as-is', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: SizedBox(
              width: 64,
              height: 64,
              child: ProfileImage(
                profilePath: '/chalamet.jpg',
                name: 'Timothée',
              ),
            ),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      // A 64 dp circle on a 3x screen: w185, decoded at 192 px.
      final provider = image.image as ResizeImage;
      expect(provider.width, 192);
      expect(
        (provider.imageProvider as NetworkImage).url,
        'https://image.tmdb.org/t/p/w185/chalamet.jpg',
      );
    });

    testWidgets('no profile_path shows the name\'s initial over '
        'surfaceRaised, not an empty circle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileImage(profilePath: null, name: 'Zendaya'),
        ),
      );

      expect(find.text('Z'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('no profile_path and no name falls back to a plain '
        'placeholder (no crash)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ProfileImage(profilePath: null)),
      );

      expect(find.byType(Text), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
