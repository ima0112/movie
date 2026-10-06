import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movies/app/router.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';

/// A tiny, standalone [GoRouter] — deliberately not the real `appRouter`
/// — isolating [MediaDetailNavigation] from the rest of the app's own
/// route tree and DI. Each destination just echoes back the path
/// parameter it received, which is all a test of *routing* (not of
/// whatever screen eventually lives at each path) needs.
GoRouter _testRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Builder(
        builder: (context) => Scaffold(
          body: Column(
            children: [
              TextButton(
                onPressed: () => context.pushMediaDetail(
                  const MediaKey(type: MediaType.movie, tmdbId: 42),
                ),
                child: const Text('push movie 42'),
              ),
              TextButton(
                onPressed: () => context.pushMediaDetail(
                  const MediaKey(type: MediaType.tvShow, tmdbId: 42),
                ),
                child: const Text('push tv 42'),
              ),
              TextButton(
                onPressed: () => context.pushPersonDetail(7),
                child: const Text('push person 7'),
              ),
            ],
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/movie/:id',
      builder: (context, state) =>
          Text('movie screen: ${state.pathParameters['id']}'),
    ),
    GoRoute(
      path: '/tv/:id',
      builder: (context, state) =>
          Text('tv screen: ${state.pathParameters['id']}'),
    ),
    GoRoute(
      path: '/person/:id',
      builder: (context, state) =>
          Text('person screen: ${state.pathParameters['id']}'),
    ),
  ],
);

void main() {
  group('pushMediaDetail', () {
    testWidgets('a movie MediaKey pushes /movie/:id', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: _testRouter()));

      await tester.tap(find.text('push movie 42'));
      await tester.pumpAndSettle();

      expect(find.text('movie screen: 42'), findsOneWidget);
    });

    testWidgets('a tvShow MediaKey pushes /tv/:id, not /movie/:id', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: _testRouter()));

      await tester.tap(find.text('push tv 42'));
      await tester.pumpAndSettle();

      expect(find.text('tv screen: 42'), findsOneWidget);
      expect(find.text('movie screen: 42'), findsNothing);
    });

    testWidgets(
      'the same tmdbId pushes a different route for a movie than for a '
      'TV show',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(routerConfig: _testRouter()),
        );

        await tester.tap(find.text('push movie 42'));
        await tester.pumpAndSettle();
        expect(find.text('movie screen: 42'), findsOneWidget);

        final router = GoRouter.of(
          tester.element(find.text('movie screen: 42')),
        );
        router.pop();
        await tester.pumpAndSettle();

        await tester.tap(find.text('push tv 42'));
        await tester.pumpAndSettle();
        expect(find.text('tv screen: 42'), findsOneWidget);
        expect(find.text('movie screen: 42'), findsNothing);
      },
    );
  });

  testWidgets('pushPersonDetail pushes /person/:id', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: _testRouter()));

    await tester.tap(find.text('push person 7'));
    await tester.pumpAndSettle();

    expect(find.text('person screen: 7'), findsOneWidget);
  });
}
