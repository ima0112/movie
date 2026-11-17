import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movies/app/router.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';

/// From a flow's last screen (Surprise me's closing one) the detail opens in one
/// step with Home beneath it: going back from it lands on Home, not on the
/// flow.
void main() {
  testWidgets('back from the detail lands on Home, with the flow gone', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => context.push('/flow'),
                child: const Text('home'),
              ),
            ),
          ),
          routes: [
            GoRoute(
              path: 'detail/movie/:id',
              builder: (_, s) => Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: context.pop,
                    child: Text('detail ${s.pathParameters['id']}'),
                  ),
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/flow',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => context.push('/flow/closing'),
                child: const Text('flow'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/flow/closing',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => context.goToMediaDetailOverHome(
                  const MediaKey(type: MediaType.movie, tmdbId: 7),
                ),
                child: const Text('closing'),
              ),
            ),
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('flow'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('closing'));
    await tester.pumpAndSettle();
    expect(find.text('detail 7'), findsOneWidget);

    await tester.tap(find.text('detail 7'));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(find.text('closing'), findsNothing);
    expect(find.text('flow'), findsNothing);
    expect(router.canPop(), isFalse);
  });

  test('the real router resolves the Home-nested detail paths, under Home', () {
    for (final key in const [
      MediaKey(type: MediaType.movie, tmdbId: 7),
      MediaKey(type: MediaType.tvShow, tmdbId: 9),
    ]) {
      final uri = Uri.parse(AppRoutes.homeDetail(key));
      final match = appRouter.configuration.findMatch(uri);
      expect(match.isError, isFalse, reason: '$uri');
      // The stack is [the tab shell showing Home, the detail on top].
      expect(match.matches.first, isA<ShellRouteMatch>());
      final shell = match.matches.first as ShellRouteMatch;
      expect((shell.matches.single.route as GoRoute).path, '/');
      expect((match.matches.last.route as GoRoute).path, startsWith('detail/'));
    }
  });
}
