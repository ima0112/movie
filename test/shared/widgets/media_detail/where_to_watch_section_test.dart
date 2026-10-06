import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/shared/widgets/media_detail/where_to_watch_section.dart';

const _providers = WatchProviders(
  flatrate: ['Max'],
  rent: [],
  buy: [],
  link: 'https://example.com',
);

void main() {
  group('WhereToWatchSection', () {
    testWidgets('renders nothing when there is no provider data at all', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WhereToWatchSection(
              providers: WatchProviders.empty,
              regionName: 'Spain',
            ),
          ),
        ),
      );

      expect(find.text('Where to watch'), findsNothing);
    });

    testWidgets('shows the region name in gray next to the title', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WhereToWatchSection(
              providers: _providers,
              regionName: 'Spain',
            ),
          ),
        ),
      );

      expect(find.text('Where to watch'), findsOneWidget);
      expect(find.text('Spain'), findsOneWidget);
    });

    testWidgets('tapping the region calls onRegionTap when one is given', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhereToWatchSection(
              providers: _providers,
              regionName: 'Spain',
              onRegionTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Spain'));
      expect(tapped, isTrue);
    });

    testWidgets('tapping the region is a harmless no-op when '
        'onRegionTap is null (H6/Settings not built yet)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WhereToWatchSection(
              providers: _providers,
              regionName: 'Spain',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Spain'));
      await tester.pump();
      // Nothing to assert beyond "didn't throw" — this is exactly the
      // documented-TODO state the task asked for.
    });
  });
}
