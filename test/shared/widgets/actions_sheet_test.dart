import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/actions_sheet.dart';

Widget _app(List<String> log) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Builder(
    builder: (context) => Scaffold(
      body: TextButton(
        onPressed: () => ActionsSheet.show(
          context,
          leading: ActionsSheet.posterSlot(null),
          title: 'Dune: Parte dos',
          subtitle: 'Película · 2024',
          actions: [
            SheetAction(
              icon: Icons.circle,
              label: 'Marcar como vista',
              onTap: () => log.add('watched'),
            ),
            SheetAction(
              icon: Icons.circle,
              label: 'Quitar de Ver después',
              destructive: true,
              onTap: () => log.add('remove'),
            ),
          ],
        ),
        child: const Text('open'),
      ),
    ),
  ),
);

void main() {
  testWidgets('shows the header and the actions; the red one is red', (
    tester,
  ) async {
    await tester.pumpWidget(_app([]));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Dune: Parte dos'), findsOneWidget);
    expect(find.text('Película · 2024'), findsOneWidget);
    expect(find.text('Marcar como vista'), findsOneWidget);
    final red = tester.widget<Text>(find.text('Quitar de Ver después'));
    expect(red.style!.color, AppColors.danger);
    final plain = tester.widget<Text>(find.text('Marcar como vista'));
    expect(plain.style!.color, AppColors.ink);
  });

  testWidgets('tapping an action closes the sheet, then runs it', (
    tester,
  ) async {
    final log = <String>[];
    await tester.pumpWidget(_app(log));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quitar de Ver después'));
    await tester.pumpAndSettle();

    expect(log, ['remove']);
    expect(find.text('Dune: Parte dos'), findsNothing);
  });
}
