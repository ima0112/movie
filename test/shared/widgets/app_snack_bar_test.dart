import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/shared/widgets/app_snack_bar.dart';

Widget _app(void Function(BuildContext) onTap) => MaterialApp(
  theme: AppTheme.dark,
  home: Builder(
    builder: (context) => Scaffold(
      body: TextButton(
        onPressed: () => onTap(context),
        child: const Text('go'),
      ),
    ),
  ),
);

void main() {
  testWidgets('a floating surfaceRaised pill with the message', (tester) async {
    await tester.pumpWidget(_app((c) => AppSnackBar.show(c, 'Copied')));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(find.text('Copied'), findsOneWidget);
    expect(bar.duration, AppSnackBar.duration);
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(SnackBar),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color, AppColors.surfaceRaised);
  });

  testWidgets('with an action: a button that runs it', (tester) async {
    var undone = 0;
    await tester.pumpWidget(
      _app(
        (c) => AppSnackBar.show(
          c,
          'Shōgun removed',
          actionLabel: 'Undo',
          onAction: () => undone++,
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Undo'));
    expect(undone, 1);
  });

  testWidgets('a new snackbar replaces the one showing', (tester) async {
    await tester.pumpWidget(
      _app((c) {
        AppSnackBar.show(c, 'First');
        AppSnackBar.show(c, 'Second');
      }),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Second'), findsOneWidget);
    expect(find.text('First'), findsNothing);
  });

  test('every snackbar goes through AppSnackBar — no raw SnackBar( or '
      'showSnackBar anywhere else', () {
    final hits = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      if (file.path.endsWith('app_snack_bar.dart')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].trimLeft().startsWith('//')) continue;
        if (RegExp(r'\bSnackBar\(|\.showSnackBar\(').hasMatch(lines[i])) {
          hits.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(hits, isEmpty);
  });
}
