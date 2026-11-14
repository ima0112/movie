import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/shared/widgets/app_segmented_control.dart';

Widget _host(Widget child, {double scale = 1, Size? size}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(
      size: size ?? const Size(390, 844),
      textScaler: TextScaler.linear(scale),
    ),
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('the selected option is the white pill; tapping another '
      'reports its value', (tester) async {
    String? tapped;
    await tester.pumpWidget(
      _host(
        AppSegmentedControl<String>(
          segments: const [
            AppSegment(value: 'a', label: 'Alpha'),
            AppSegment(value: 'b', label: 'Beta'),
          ],
          selected: 'a',
          onSelected: (v) => tapped = v,
        ),
      ),
    );

    final selectedBox = tester.widget<AnimatedContainer>(
      find.ancestor(
        of: find.text('Alpha'),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect((selectedBox.decoration! as BoxDecoration).color, AppColors.ink);

    await tester.tap(find.text('Beta'));
    expect(tapped, 'b');
  });

  testWidgets('four options survive a small device at 200% text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        AppSegmentedControl<int>(
          segments: [
            for (var i = 0; i < 4; i++)
              AppSegment(value: i, label: 'Películas $i'),
          ],
          selected: 0,
          onSelected: (_) {},
        ),
        scale: 2,
        size: const Size(320, 568),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the glass variant has a translucent, blurred track with a '
      'hairline border — same options and behavior', (tester) async {
    String? tapped;
    await tester.pumpWidget(
      _host(
        AppSegmentedControl<String>(
          glass: true,
          segments: const [
            AppSegment(value: 'a', label: 'Alpha'),
            AppSegment(value: 'b', label: 'Beta'),
          ],
          selected: 'a',
          onSelected: (v) => tapped = v,
        ),
      ),
    );

    expect(find.byType(BackdropFilter), findsOneWidget);
    final track = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(BackdropFilter),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = track.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.glass);
    expect(decoration.border, isNotNull);

    await tester.tap(find.text('Beta'));
    expect(tapped, 'b');
  });

  testWidgets('the default (solid) track has no blur', (tester) async {
    await tester.pumpWidget(
      _host(
        AppSegmentedControl<int>(
          segments: const [
            AppSegment(value: 1, label: 'One'),
            AppSegment(value: 2, label: 'Two'),
          ],
          selected: 1,
          onSelected: (_) {},
        ),
      ),
    );
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
