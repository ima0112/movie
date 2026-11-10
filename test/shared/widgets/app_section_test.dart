import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_spacing.dart';
import 'package:movies/shared/widgets/app_section.dart';

void main() {
  testWidgets('puts sectionGap above, a heading with its action, then '
      'headingGap before the child', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppSection(
                title: 'Cast',
                actionLabel: 'See all',
                onAction: () => taps++,
                child: const SizedBox(key: Key('body'), height: 10),
              ),
            ],
          ),
        ),
      ),
    );

    final top = tester.getTopLeft(find.byType(AppSection)).dy;
    expect(
      tester.getTopLeft(find.text('Cast')).dy - top,
      moreOrLessEquals(AppSpacing.sectionGap, epsilon: 3),
    );
    final headingBottom = tester.getBottomLeft(find.text('Cast')).dy;
    expect(
      tester.getTopLeft(find.byKey(const Key('body'))).dy - headingBottom,
      moreOrLessEquals(AppSpacing.headingGap, epsilon: 3),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('body'))).dx,
      AppSpacing.screenMargin,
    );

    await tester.tap(find.text('See all'));
    expect(taps, 1);
  });

  testWidgets('inset: false lets the child use the full width', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppSection(
            title: 'T',
            inset: false,
            child: SizedBox(key: Key('body'), height: 10),
          ),
        ),
      ),
    );
    expect(tester.getTopLeft(find.byKey(const Key('body'))).dx, 0);
  });
}
