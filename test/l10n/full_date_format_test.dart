import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/l10n/full_date_format.dart';

Future<AppLocalizations> _l10n(WidgetTester tester, String locale) async {
  late AppLocalizations l10n;
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          l10n = AppLocalizations.of(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return l10n;
}

void main() {
  testWidgets('a full date is "12 Jan, 2026" in English', (tester) async {
    final l10n = await _l10n(tester, 'en');

    expect(l10n.fullDate(DateTime(2026, 1, 12)), '12 Jan, 2026');
    expect(l10n.fullDate(DateTime(2026, 5, 25)), '25 May, 2026');
    expect(l10n.fullDate(DateTime(2022, 6, 3)), '3 Jun, 2022'); // no zero pad
  });

  testWidgets('and its Spanish equivalent, "12 ene, 2026"', (tester) async {
    final l10n = await _l10n(tester, 'es');

    expect(l10n.fullDate(DateTime(2026, 1, 12)), '12 ene, 2026');
    expect(l10n.fullDate(DateTime(2026, 12, 25)), '25 dic, 2026');
  });

  test('no screen formats a full date its own way: only fullDate does '
      '(never 2026-5-25, never "Jan 12, 2026")', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      // The data layer writes ISO dates for TMDB's API — not UI.
      if (file.path.endsWith('full_date_format.dart') ||
          file.path.contains('app_localizations') ||
          file.path.contains('/data/')) {
        continue;
      }
      final source = file.readAsStringSync();
      for (final pattern in [
        'DateFormat.yMMMd',
        'DateFormat.yMd',
        'DateFormat.yMMMMd',
        "padLeft(2, '0')",
      ]) {
        if (source.contains(pattern)) offenders.add('${file.path}: $pattern');
      }
    }
    expect(offenders, isEmpty);
  });
}
