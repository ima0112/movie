import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/app_settings.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/core/domain/repositories/settings_repository.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/discover/presentation/cubit/discover_cubit.dart';

/// A controllable stand-in for [SettingsRepository] — `watch()` replays
/// [_current] to every new subscriber (same "current value first, then
/// whatever's pushed" shape `DriftSettingsRepository.watch` has) and
/// forwards whatever the test pushes through [controller] afterwards.
class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._current);

  AppSettings _current;
  final StreamController<AppSettings> controller =
      StreamController<AppSettings>.broadcast();

  @override
  AppSettings get current => _current;

  @override
  Future<void> load() async {}

  @override
  Stream<AppSettings> watch() async* {
    yield _current;
    yield* controller.stream;
  }

  @override
  Future<Result<void>> save(AppSettings settings) async {
    _current = settings;
    return const Success(null);
  }
}

/// Counts [loadDiscover] calls as they happen (synchronously, before any
/// `await`) — a locale-triggered reload is `unawaited`, so a test can't
/// just count "how many times `await cubit.loadDiscover(...)` resolved".
class _CountingDiscoverCubit extends DiscoverCubit {
  _CountingDiscoverCubit(super.mediaRepository, super.settingsRepository);

  int loadCount = 0;

  @override
  Future<void> loadDiscover(MediaSegment segment) {
    loadCount++;
    return super.loadDiscover(segment);
  }
}

void main() {
  group('DiscoverCubit', () {
    test('starts in DiscoverInitial', () {
      final cubit = DiscoverCubit(
        FakeMediaRepository(),
        _FakeSettingsRepository(
          const AppSettings(languageCode: 'en', regionCode: 'US'),
        ),
      );
      expect(cubit.state, isA<DiscoverInitial>());
      cubit.close();
    });

    test('loadDiscover emits DiscoverLoading before settling', () async {
      final cubit = DiscoverCubit(
        FakeMediaRepository(),
        _FakeSettingsRepository(
          const AppSettings(languageCode: 'en', regionCode: 'US'),
        ),
      );

      // `emitsInOrder` subscribes right away, so it can't race the
      // eventual emit the way manually collecting into a list would.
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<DiscoverLoading>(), isA<DiscoverLoaded>()]),
      );

      await cubit.loadDiscover(MediaSegment.movie);
      await expectation;

      await cubit.close();
    });

    test(
      'loadDiscover(movie) ends in DiscoverLoaded with movie-only data '
      'and the Movies-segment carousels',
      () async {
        final cubit = DiscoverCubit(
          FakeMediaRepository(),
          _FakeSettingsRepository(
            const AppSettings(languageCode: 'en', regionCode: 'US'),
          ),
        );

        await cubit.loadDiscover(MediaSegment.movie);

        final loaded = cubit.state as DiscoverLoaded;
        expect(loaded.segment, MediaSegment.movie);
        expect(loaded.heroItems, isNotEmpty);
        expect(
          loaded.heroItems.every((item) => item.type == MediaType.movie),
          isTrue,
        );
        expect(loaded.carousels.keys, [
          CarouselSection.inTheaters,
          CarouselSection.trending,
          CarouselSection.topRated,
          CarouselSection.upcoming,
        ]);
        for (final items in loaded.carousels.values) {
          expect(items.every((item) => item.type == MediaType.movie), isTrue);
        }

        await cubit.close();
      },
    );

    test('loadDiscover(all) uses the All-segment carousels', () async {
      final cubit = DiscoverCubit(
        FakeMediaRepository(),
        _FakeSettingsRepository(
          const AppSettings(languageCode: 'en', regionCode: 'US'),
        ),
      );

      await cubit.loadDiscover(MediaSegment.all);

      final loaded = cubit.state as DiscoverLoaded;
      expect(loaded.carousels.keys, [
        CarouselSection.popularThisWeek,
        CarouselSection.watchLater,
      ]);

      await cubit.close();
    });

    group('refresh on locale change', () {
      test(
        'a region change via SettingsRepository.watch() reloads the '
        'current segment exactly once',
        () async {
          final settingsRepository = _FakeSettingsRepository(
            const AppSettings(languageCode: 'en', regionCode: 'US'),
          );
          final cubit = _CountingDiscoverCubit(
            FakeMediaRepository(),
            settingsRepository,
          );
          await cubit.loadDiscover(MediaSegment.movie);
          expect(cubit.loadCount, 1);

          settingsRepository.controller.add(
            const AppSettings(languageCode: 'en', regionCode: 'MX'),
          );
          await pumpEventQueue();

          // The reload has started (exactly once) but the fake
          // repository's own network delay hasn't resolved yet.
          expect(cubit.loadCount, 2);
          expect((cubit.state as DiscoverLoading).segment, MediaSegment.movie);

          // Let it fully settle before close() — an in-flight
          // loadDiscover() emitting after close() would be exactly the
          // Cubit-used-after-close failure this branch exists to avoid.
          await cubit.stream.firstWhere((s) => s is DiscoverLoaded);
          await cubit.close();
        },
      );

      test(
        'an emission with the same language/region does not reload',
        () async {
          final settingsRepository = _FakeSettingsRepository(
            const AppSettings(languageCode: 'en', regionCode: 'US'),
          );
          final cubit = _CountingDiscoverCubit(
            FakeMediaRepository(),
            settingsRepository,
          );
          await cubit.loadDiscover(MediaSegment.movie);
          expect(cubit.loadCount, 1);

          settingsRepository.controller.add(
            const AppSettings(languageCode: 'en', regionCode: 'US'),
          );
          await pumpEventQueue();

          expect(cubit.loadCount, 1);

          await cubit.close();
        },
      );

      test(
        'a settings change before any loadDiscover call is a no-op — '
        'there is no segment yet to reload',
        () async {
          final settingsRepository = _FakeSettingsRepository(
            const AppSettings(languageCode: 'en', regionCode: 'US'),
          );
          final cubit = _CountingDiscoverCubit(
            FakeMediaRepository(),
            settingsRepository,
          );

          settingsRepository.controller.add(
            const AppSettings(languageCode: 'en', regionCode: 'MX'),
          );
          await pumpEventQueue();

          expect(cubit.loadCount, 0);
          expect(cubit.state, isA<DiscoverInitial>());

          await cubit.close();
        },
      );

      test('close() leaves no live subscription on SettingsRepository', () async {
        final settingsRepository = _FakeSettingsRepository(
          const AppSettings(languageCode: 'en', regionCode: 'US'),
        );
        final cubit = DiscoverCubit(FakeMediaRepository(), settingsRepository);
        await pumpEventQueue();
        expect(settingsRepository.controller.hasListener, isTrue);

        await cubit.close();
        await pumpEventQueue();

        expect(settingsRepository.controller.hasListener, isFalse);
      });
    });
  });
}
