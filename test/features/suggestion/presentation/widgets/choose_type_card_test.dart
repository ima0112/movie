import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/features/suggestion/presentation/widgets/choose_type_card.dart';
import 'package:movies/shared/widgets/app_halo.dart';

Widget _host({required VoidCallback onTap, double textScale = 1}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: SingleChildScrollView(
            child: ChooseTypeCard(
              icon: AppIcons.movie,
              label: 'A movie',
              subtitle: 'A plan for a couple of hours',
              onTap: onTap,
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('a tall tile: the icon above the label and its line', (
    tester,
  ) async {
    await tester.pumpWidget(_host(onTap: () {}));

    final card = tester.getRect(find.byType(ChooseTypeCard));
    expect(card.height, greaterThanOrEqualTo(160));
    expect(
      tester.getTopLeft(find.byIcon(AppIcons.movie)).dy,
      lessThan(tester.getTopLeft(find.text('A movie')).dy),
    );
    expect(
      tester.getTopLeft(find.text('A movie')).dy,
      lessThan(tester.getTopLeft(find.text('A plan for a couple of hours')).dy),
    );
  });

  testWidgets('tapping it runs onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(onTap: () => taps++));

    await tester.tap(find.byType(ChooseTypeCard));

    expect(taps, 1);
  });

  testWidgets('at 200% text it grows instead of overflowing', (tester) async {
    await tester.pumpWidget(_host(onTap: () {}, textScale: 2));

    expect(tester.takeException(), isNull);
  });

  testWidgets('the halo is Home\'s by default and softer on request', (
    tester,
  ) async {
    Color topColor(AppHalo halo) {
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byWidget(halo),
          matching: find.byType(DecoratedBox),
        ),
      );
      final gradient =
          (box.decoration as BoxDecoration).gradient! as RadialGradient;
      return gradient.colors.first;
    }

    const full = AppHalo();
    const soft = AppHalo(intensity: 0.5);
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(children: [full, soft]),
      ),
    );

    expect(topColor(full), const Color(0xFF5A3A10));
    expect(topColor(soft), isNot(topColor(full)));
  });
}
