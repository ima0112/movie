import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/detail_choose_overlay.dart';

Future<GoRouter> _pump(WidgetTester tester, DetailChooseAction? action) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('deck')),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (_, _) => DetailChooseOverlay(
              action: action,
              child: const Scaffold(body: Text('detail')),
            ),
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
  unawaited(router.push('/detail'));
  await tester.pumpAndSettle();
  return router;
}

void unawaited(Future<void> _) {}

void main() {
  testWidgets('without an action there is no button', (tester) async {
    await _pump(tester, null);
    expect(find.text('detail'), findsOneWidget);
    expect(find.text('Choose this'), findsNothing);
  });

  testWidgets('"Choose this" runs the action and leaves the detail', (
    tester,
  ) async {
    var chosen = 0;
    await _pump(tester, DetailChooseAction(onChoose: () async => chosen++));
    expect(find.text('Choose this'), findsOneWidget);

    await tester.tap(find.text('Choose this'));
    await tester.pumpAndSettle();

    expect(chosen, 1);
    expect(find.text('detail'), findsNothing);
    expect(find.text('deck'), findsOneWidget);
  });
}
