import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/streaming_service.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/features/quiz/presentation/cubit/quiz_platforms_cubit.dart';
import 'package:movies/features/quiz/presentation/widgets/quiz_platform_step.dart';
import 'package:movies/features/quiz/presentation/widgets/quiz_platform_tile.dart';
import 'package:movies/l10n/app_localizations.dart';

class _FakeRepo implements MediaRepository {
  _FakeRepo(this.next);

  Future<Result<List<StreamingService>>> Function() next;
  final requests = <({MediaType? type, bool all})>[];

  @override
  Future<Result<List<StreamingService>>> streamingServices({
    MediaType? type,
    bool all = false,
  }) {
    requests.add((type: type, all: all));
    return next();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<StreamingService> _services(int n) => [
  for (var i = 1; i <= n; i++) StreamingService(id: i, name: 'Service $i'),
];

Widget _host({
  Set<int> selected = const {},
  bool rentBuy = false,
  ValueChanged<int>? onToggle,
  VoidCallback? onClear,
  ValueChanged<bool>? onRentBuy,
  Locale locale = const Locale('en'),
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SingleChildScrollView(
      child: QuizPlatformStep(
        mediaType: MediaType.movie,
        selected: selected,
        includeRentBuy: rentBuy,
        onToggle: onToggle ?? (_) {},
        onClear: onClear ?? () {},
        onIncludeRentBuyChanged: onRentBuy ?? (_) {},
      ),
    ),
  ),
);

Future<_FakeRepo> _register(
  Future<Result<List<StreamingService>>> Function() next,
) async {
  final repo = _FakeRepo(next);
  await getIt.reset();
  getIt.registerSingleton<MediaRepository>(repo);
  addTearDown(getIt.reset);
  return repo;
}

void main() {
  testWidgets('shows the first 12 services of the region for this kind of '
      'title, with the headline and the "All" link', (tester) async {
    final repo = await _register(() async => Success(_services(15)));

    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(repo.requests.single, (type: MediaType.movie, all: true));
    expect(find.byType(QuizPlatformTile), findsNWidgets(12));
    expect(find.text('Service 12'), findsOneWidget);
    expect(find.text('Service 13'), findsNothing);
    expect(find.text('Which platforms shall we search?'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Include rent and buy'), findsOneWidget);
  });

  testWidgets('tapping a tile toggles it; "All" clears — and does nothing '
      'while nothing is picked', (tester) async {
    await _register(() async => Success(_services(6)));
    final toggled = <int>[];
    var clears = 0;

    await tester.pumpWidget(
      _host(onToggle: toggled.add, onClear: () => clears++),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Service 3'));
    await tester.tap(find.text('All'));
    expect(toggled, [3]);
    expect(clears, 0);

    await tester.pumpWidget(
      _host(selected: {3}, onToggle: toggled.add, onClear: () => clears++),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('All'));
    expect(clears, 1);
  });

  testWidgets('rent and buy: dimmed and inert with no platform, live with '
      'one', (tester) async {
    await _register(() async => Success(_services(6)));
    final changes = <bool>[];

    await tester.pumpWidget(_host(rentBuy: true, onRentBuy: changes.add));
    await tester.pumpAndSettle();
    var switchWidget = tester.widget<Switch>(find.byType(Switch));
    expect(switchWidget.onChanged, isNull);
    expect(switchWidget.value, isTrue); // remembered while dimmed
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(
              of: find.byType(Switch),
              matching: find.byType(Opacity),
            ),
          )
          .opacity,
      lessThan(1),
    );

    await tester.pumpWidget(
      _host(selected: {1}, rentBuy: true, onRentBuy: changes.add),
    );
    await tester.pumpAndSettle();
    switchWidget = tester.widget<Switch>(find.byType(Switch));
    expect(switchWidget.onChanged, isNotNull);
    await tester.tap(find.byType(Switch));
    expect(changes, [false]);
  });

  testWidgets('loading: skeletons first, then the tiles', (tester) async {
    final completer = Completer<Result<List<StreamingService>>>();
    await _register(() => completer.future);

    await tester.pumpWidget(_host());
    await tester.pump();
    expect(find.byType(QuizPlatformTile), findsNothing);

    completer.complete(Success(_services(4)));
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlatformTile), findsNWidgets(4));
  });

  testWidgets('offline: the offline view, and Retry loads again', (
    tester,
  ) async {
    var calls = 0;
    await _register(() async {
      calls++;
      return calls == 1
          ? Failure(FailureReason.network)
          : Success(_services(3));
    });

    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlatformTile), findsNothing);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlatformTile), findsNWidgets(3));
  });

  testWidgets('a region with no services says so; the step still stands', (
    tester,
  ) async {
    await _register(() async => const Success(<StreamingService>[]));

    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.byType(QuizPlatformTile), findsNothing);
    expect(find.textContaining('No streaming services'), findsOneWidget);
  });

  testWidgets('the Spanish copy', (tester) async {
    await _register(() async => Success(_services(3)));

    await tester.pumpWidget(_host(locale: const Locale('es')));
    await tester.pumpAndSettle();

    expect(find.text('¿En qué plataformas buscamos?'), findsOneWidget);
    expect(find.text('Todas'), findsOneWidget);
    expect(find.text('Incluir alquiler y compra'), findsOneWidget);
  });

  testWidgets('a small phone at 200% text: 12 tiles and the switch, no '
      'overflow', (tester) async {
    await _register(() async => Success(_services(12)));
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _host(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(QuizPlatformTile), findsNWidgets(12));
  });

  test('QuizPlatformsCubit caps the list at 12', () async {
    final repo = _FakeRepo(() async => Success(_services(30)));
    final cubit = QuizPlatformsCubit(repo, MediaType.tvShow);
    await Future<void>.delayed(Duration.zero);

    expect((cubit.state as QuizPlatformsLoaded).services, hasLength(12));
    expect(repo.requests.single.type, MediaType.tvShow);
    await cubit.close();
  });
}
