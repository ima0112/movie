import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/shared/widgets/outlined_text.dart';
import 'package:movies/features/suggestion/presentation/widgets/choose_type_card.dart';
import 'package:movies/shared/widgets/app_halo.dart';

Widget _host({required VoidCallback onTap, double textScale = 1}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: SingleChildScrollView(
            child: ChooseTypeCard(
              number: 1,
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
  testWidgets('the number on the left, the label above its line, the icon at '
      'the top right', (tester) async {
    await tester.pumpWidget(_host(onTap: () {}));

    final card = tester.getRect(find.byType(ChooseTypeCard));
    final number = tester.getRect(find.byType(OutlinedText));
    final label = tester.getTopLeft(find.text('A movie'));
    final line = tester.getTopLeft(find.text('A plan for a couple of hours'));
    final icon = tester.getRect(find.byIcon(AppIcons.movie));

    expect(number.left, lessThan(label.dx));
    expect(label.dy, lessThan(line.dy));
    expect(icon.left, greaterThan(label.dx));
    expect(icon.right, lessThanOrEqualTo(card.right));
    expect(icon.top, lessThan(card.top + card.height / 2));
  });

  testWidgets('the number is two digits, the card\'s place', (tester) async {
    await tester.pumpWidget(_host(onTap: () {}));
    expect(find.text('01'), findsWidgets); // the outline and its faint fill
  });

  testWidgets('it lights up while pressed: amber border, back to neutral '
      'after', (tester) async {
    await tester.pumpWidget(_host(onTap: () {}));
    Color border() {
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(ChooseTypeCard),
              matching: find.byType(Material),
            )
            .first,
      );
      return ((material.shape! as RoundedRectangleBorder).side.color);
    }

    expect(border(), AppColors.lineStrong);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ChooseTypeCard)),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(border(), AppColors.accent);
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 300));
    expect(border(), AppColors.lineStrong);
  });

  testWidgets('tapping it runs onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(onTap: () => taps++));

    await tester.tap(find.byType(ChooseTypeCard));

    expect(taps, 1);
  });

  testWidgets('on a 320 px phone at 200% text the long Spanish texts wrap, '
      'nothing overflows', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ChooseTypeCard(
                number: 2,
                icon: AppIcons.tvShow,
                label: 'Una serie',
                subtitle: 'Para engancharte varias noches',
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
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

  testWidgets('"01" and "02" take the same column: both cards\' titles start '
      'at the same x', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ChooseTypeCard(
                number: 1,
                icon: AppIcons.movie,
                label: 'A movie',
                subtitle: 'One',
                onTap: () {},
              ),
              ChooseTypeCard(
                number: 2,
                icon: AppIcons.tvShow,
                label: 'A TV show',
                subtitle: 'Two',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.text('A movie')).dx,
      tester.getTopLeft(find.text('A TV show')).dx,
    );
    expect(
      tester.getTopLeft(find.text('One')).dx,
      tester.getTopLeft(find.text('Two')).dx,
    );
  });
}
