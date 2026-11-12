import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_text_styles.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_detail/media_detail_compact_bar.dart';

/// Every app bar title is one size: the detail screens' compact bar title
/// (`AppTextStyles.h3`), from the theme — no screen sets its own.
void main() {
  Future<void> pump(WidgetTester tester, Widget home) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );

  double sizeOf(WidgetTester tester, String text) => tester
      .widget<RichText>(
        find.descendant(of: find.text(text), matching: find.byType(RichText)),
      )
      .text
      .style!
      .fontSize!;

  testWidgets('a plain AppBar title is as big as the detail compact bar\'s', (
    tester,
  ) async {
    await pump(tester, Scaffold(appBar: AppBar(title: const Text('Settings'))));
    final appBar = sizeOf(tester, 'Settings');

    await pump(
      tester,
      const Scaffold(body: MediaDetailCompactBar(title: 'Dune')),
    );
    final compact = sizeOf(tester, 'Dune');

    expect(appBar, AppTextStyles.h3.fontSize);
    expect(appBar, compact);
  });

  test('no screen sets its own app bar title style: the theme owns it', () {
    final offenders = <String>[];
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))
            .where((f) => !f.path.endsWith('app_theme.dart'))
            .where((f) => !f.path.contains('/features/debug/'))) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('titleTextStyle:')) {
          offenders.add('${file.path}:${i + 1}');
        }
      }
      // An `AppBar(` whose title carries its own style.
      final source = lines.join('\n');
      for (final m in RegExp(r'AppBar\(').allMatches(source)) {
        final end = source.indexOf('body:', m.end);
        final slice = source.substring(m.end, end == -1 ? source.length : end);
        final title = RegExp(r'title:[^,]*Text\([\s\S]*?\),').firstMatch(slice);
        if (title != null && title.group(0)!.contains('style:')) {
          offenders.add(file.path);
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
