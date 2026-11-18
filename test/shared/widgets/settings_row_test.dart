import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/shared/widgets/settings_row.dart';

Widget _host(List<Widget> rows, {double textScale = 1}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(360, 800),
      textScaler: TextScaler.linear(textScale),
    ),
    child: Scaffold(
      body: SingleChildScrollView(
        child: SettingsGroup(title: 'Group', children: rows),
      ),
    ),
  ),
);

void main() {
  testWidgets('the value and the chevron hug the right edge, and every '
      'chevron is in the same column', (tester) async {
    await tester.pumpWidget(
      _host(const [
        SettingsRow(label: 'Language', value: 'English'),
        SettingsRow(label: 'Attribution'),
        SettingsRow(label: 'Version', value: '1.0.0 (1)', showChevron: false),
      ]),
    );

    final chevrons = find.byIcon(AppIcons.chevronRight);
    expect(chevrons, findsNWidgets(2));
    final withValue = tester.getRect(chevrons.at(0));
    final plain = tester.getRect(chevrons.at(1));
    expect(withValue.right, plain.right, reason: 'one chevron column');

    // The value sits right before its chevron, not in the middle of the row.
    final english = tester.getRect(find.text('English'));
    expect(withValue.left - english.right, lessThan(16));
    expect(english.left, greaterThan(180), reason: 'right half of a 360 row');

    // With no chevron the value takes the chevron's place at the edge.
    final version = tester.getRect(find.text('1.0.0 (1)'));
    expect(version.right, closeTo(plain.right, 0.5));
  });

  testWidgets('a long value is cut, not squeezing the label; nothing overflows '
      'at 200 % text', (tester) async {
    await tester.pumpWidget(
      _host(const [
        SettingsRow(
          label: 'Region',
          value: 'United States of America and its territories',
        ),
      ], textScale: 2),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Region'), findsOneWidget);
    final value = tester.getRect(
      find.text('United States of America and its territories'),
    );
    expect(value.width, lessThanOrEqualTo(180));
  });
}
