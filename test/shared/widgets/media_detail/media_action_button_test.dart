import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/shared/widgets/media_detail/media_action_button.dart';

Widget _host({required bool active, double textScale = 1}) => MaterialApp(
  home: Scaffold(
    body: MediaQuery(
      data: MediaQueryData(
        size: const Size(320, 568),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Center(
        child: MediaActionButton(
          iconOutline: AppIcons.favorite,
          iconFill: AppIcons.favoriteFill,
          label: 'Favorite',
          isActive: active,
          onTap: () {},
        ),
      ),
    ),
  ),
);

BoxDecoration _decoration(WidgetTester tester) =>
    tester
            .widget<Container>(
              find.descendant(
                of: find.byType(MediaActionButton),
                matching: find.byType(Container),
              ),
            )
            .decoration!
        as BoxDecoration;

void main() {
  testWidgets('a 44 px circle with a semantics label and no visible text', (
    tester,
  ) async {
    await tester.pumpWidget(_host(active: false));

    expect(
      tester.getSize(find.byType(MediaActionButton)),
      const Size(MediaActionButton.size, MediaActionButton.size),
    );
    expect(_decoration(tester).shape, BoxShape.circle);
    expect(find.bySemanticsLabel('Favorite'), findsOneWidget);
    expect(find.text('Favorite'), findsNothing);
  });

  testWidgets('off is outlined; on is filled amber with a dark icon', (
    tester,
  ) async {
    await tester.pumpWidget(_host(active: false));
    expect(_decoration(tester).color, isNull);
    expect(find.byIcon(AppIcons.favorite), findsOneWidget);

    await tester.pumpWidget(_host(active: true));
    expect(_decoration(tester).color, AppColors.accent);
    expect(
      tester.widget<Icon>(find.byIcon(AppIcons.favoriteFill)).color,
      AppColors.onAccent,
    );
  });

  testWidgets('it keeps its size at 200% text scale', (tester) async {
    await tester.pumpWidget(_host(active: true, textScale: 2));
    expect(tester.getSize(find.byType(MediaActionButton)), const Size(44, 44));
  });

  testWidgets('wide: a rounded rectangle that fills its width, same states', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: MediaActionButton(
              iconOutline: AppIcons.favorite,
              iconFill: AppIcons.favoriteFill,
              label: 'Favorite',
              isActive: true,
              onTap: () {},
              wide: true,
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(MediaActionButton)),
      const Size(120, MediaActionButton.wideHeight),
    );
    final decoration = _decoration(tester);
    expect(decoration.shape, BoxShape.rectangle);
    expect(decoration.borderRadius, isNotNull);
    expect(decoration.color, AppColors.accent);
  });
}
