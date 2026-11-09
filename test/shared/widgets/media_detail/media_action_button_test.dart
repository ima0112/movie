import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/shared/widgets/media_detail/media_action_button.dart';

Widget _row({required double textScale}) {
  return MaterialApp(
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(
          size: const Size(320, 568),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              MediaActionButton(
                iconOutline: AppIcons.favorite,
                iconFill: AppIcons.favoriteFill,
                label: 'Favorite',
                isActive: false,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MediaActionButton(
                  iconOutline: AppIcons.watched,
                  iconFill: AppIcons.watchedFill,
                  label: 'Visto con una etiqueta bastante larga',
                  isActive: true,
                  showLabel: true,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('icon-only is a 44 px square with a semantics label; the '
      'labeled one shows its text', (tester) async {
    await tester.pumpWidget(_row(textScale: 1));

    expect(
      tester.getSize(find.byType(MediaActionButton).first),
      const Size(MediaActionButton.size, MediaActionButton.size),
    );
    expect(find.bySemanticsLabel('Favorite'), findsOneWidget);
    expect(find.text('Visto con una etiqueta bastante larga'), findsOneWidget);
  });

  testWidgets('a long label at 200% text scale on a 320 px screen does not '
      'overflow', (tester) async {
    await tester.pumpWidget(_row(textScale: 2));

    expect(tester.takeException(), isNull);
  });
}
