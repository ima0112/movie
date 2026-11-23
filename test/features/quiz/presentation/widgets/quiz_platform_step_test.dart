import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/streaming_service.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/features/quiz/presentation/cubit/quiz_platforms_cubit.dart';
import 'package:movies/features/quiz/presentation/widgets/quiz_platform_step.dart';
import 'package:movies/features/quiz/presentation/widgets/quiz_platform_tile.dart';
import 'package:movies/l10n/app_localizations.dart';

class _FakeRepo implements MediaRepository {
  _FakeRepo(this.next);

  Future<Result<List<StreamingService>>> Function() next;
  final requests =
      <({MediaType? type, bool all, Set<int> preferred, int limit})>[];

  @override
  Future<Result<List<StreamingService>>> streamingServices({
    MediaType? type,
    bool all = false,
    Set<int> preferredIds = const {},
    int limit = 12,
  }) {
    requests.add((type: type, all: all, preferred: preferredIds, limit: limit));
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
  testWidgets('asks for 12 services of the region for this kind of title, '
      'with the headline and the "All platforms" switch', (tester) async {
    final repo = await _register(() async => Success(_services(12)));

    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(repo.requests.single.type, MediaType.movie);
    expect(repo.requests.single.limit, 12);
    expect(repo.requests.single.all, isFalse);
    expect(find.byType(QuizPlatformTile), findsNWidgets(12));
    expect(find.text('Which platforms shall we search?'), findsOneWidget);
    expect(find.text('All platforms'), findsOneWidget);
    expect(find.text('Include rent and buy'), findsOneWidget);
  });

  Switch allSwitch(WidgetTester tester) => tester.widget<Switch>(
    find.descendant(
      of: find.ancestor(
        of: find.text('All platforms'),
        matching: find.byType(DecoratedBox),
      ),
      matching: find.byType(Switch),
    ),
  );

  testWidgets('"All platforms" is on exactly while nothing is picked, and '
      'tiles show unselected then', (tester) async {
    await _register(() async => Success(_services(6)));

    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    expect(allSwitch(tester).value, isTrue);
    expect(find.byIcon(AppIcons.check), findsNothing);

    await tester.pumpWidget(_host(selected: {3}));
    await tester.pumpAndSettle();
    expect(allSwitch(tester).value, isFalse);
    expect(find.byIcon(AppIcons.check), findsOneWidget);

    await tester.pumpWidget(_host(selected: const {}));
    await tester.pumpAndSettle();
    expect(allSwitch(tester).value, isTrue);
  });

  testWidgets('tapping a tile toggles it; the switch clears the picks when '
      'off and does nothing when on', (tester) async {
    await _register(() async => Success(_services(6)));
    final toggled = <int>[];
    var clears = 0;

    await tester.pumpWidget(
      _host(onToggle: toggled.add, onClear: () => clears++),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Service 3'));
    expect(toggled, [3]);

    // On (nothing picked): tapping it does not clear anything.
    await tester.tap(find.text('All platforms'));
    await tester.tap(find.byType(Switch).first);
    expect(clears, 0);

    // Off (something picked): turning it on clears the picks.
    await tester.pumpWidget(
      _host(selected: {3}, onToggle: toggled.add, onClear: () => clears++),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    expect(clears, 1);
  });

  testWidgets('rent and buy works the same with "All platforms" and with '
      'platforms picked', (tester) async {
    await _register(() async => Success(_services(6)));
    final changes = <bool>[];

    await tester.pumpWidget(_host(rentBuy: true, onRentBuy: changes.add));
    await tester.pumpAndSettle();
    var rentBuy = tester.widget<Switch>(find.byType(Switch).last);
    expect(rentBuy.onChanged, isNotNull);
    expect(rentBuy.value, isTrue);
    await tester.tap(find.byType(Switch).last);
    expect(changes, [false]);

    await tester.pumpWidget(
      _host(selected: {1}, rentBuy: true, onRentBuy: changes.add),
    );
    await tester.pumpAndSettle();
    rentBuy = tester.widget<Switch>(find.byType(Switch).last);
    expect(rentBuy.onChanged, isNotNull);
    await tester.tap(find.byType(Switch).last);
    expect(changes, [false, false]);
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
    expect(find.text('Todas las plataformas'), findsOneWidget);
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

  test('QuizPlatformsCubit asks for 12, with the user\'s own services to '
      'lead', () async {
    final repo = _FakeRepo(() async => Success(_services(12)));
    final cubit = QuizPlatformsCubit(repo, MediaType.tvShow, const {17, 8});
    await Future<void>.delayed(Duration.zero);

    expect((cubit.state as QuizPlatformsLoaded).services, hasLength(12));
    expect(repo.requests.single.type, MediaType.tvShow);
    expect(repo.requests.single.limit, 12);
    expect(repo.requests.single.preferred, {17, 8});
    await cubit.close();
  });
}
