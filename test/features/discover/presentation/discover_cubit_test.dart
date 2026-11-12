import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/app_settings.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/trailer_item.dart';
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

    DiscoverCubit newCubit() => DiscoverCubit(
      FakeMediaRepository(),
      _FakeSettingsRepository(
        const AppSettings(languageCode: 'en', regionCode: 'US'),
      ),
    );

    test(
      'loadDiscover(movie) loads the movie hero and no carousels yet',
      () async {
        final cubit = newCubit();
        await cubit.loadDiscover(MediaSegment.movie);

        final loaded = cubit.state as DiscoverLoaded;
        expect(loaded.segment, MediaSegment.movie);
        expect(
          loaded.heroItems.every((item) => item.type == MediaType.movie),
          isTrue,
        );
        // On demand: nothing but the hero until a section is requested.
        expect(loaded.carousels, isEmpty);
        expect(loaded.trailers, isNull);
        await cubit.close();
      },
    );

    test('the sections per segment follow B1', () {
      expect(DiscoverCubit.sectionsBySegment[MediaSegment.all], [
        CarouselSection.popularThisWeek,
        CarouselSection.comingSoon,
        CarouselSection.inTheaters,
        CarouselSection.watchLater,
      ]);
      expect(DiscoverCubit.sectionsBySegment[MediaSegment.movie], [
        CarouselSection.trending,
        CarouselSection.topRated,
        CarouselSection.upcoming,
      ]);
      expect(DiscoverCubit.sectionsBySegment[MediaSegment.tvShow], [
        CarouselSection.airingNow,
        CarouselSection.finishedShows,
        CarouselSection.topRated,
        CarouselSection.popular,
      ]);
    });

    test('requestSection loads just that section, once', () async {
      final cubit = newCubit();
      await cubit.loadDiscover(MediaSegment.movie);

      await cubit.requestSection(CarouselSection.topRated);
      final loaded = cubit.state as DiscoverLoaded;
      expect(loaded.carousels.keys, [CarouselSection.topRated]);
      final slot = loaded.carousels[CarouselSection.topRated]!;
      expect(slot, isA<DiscoverSlotLoaded<List<MediaItem>>>());

      // A second ask changes nothing (same state instance).
      final before = cubit.state;
      await cubit.requestSection(CarouselSection.topRated);
      expect(identical(cubit.state, before), isTrue);
      await cubit.close();
    });

    test('requestTrailers loads the trailers once', () async {
      final cubit = newCubit();
      await cubit.loadDiscover(MediaSegment.all);

      await cubit.requestTrailers();
      final slot = (cubit.state as DiscoverLoaded).trailers;
      expect(slot, isA<DiscoverSlotLoaded<List<TrailerItem>>>());
      expect(
        (slot! as DiscoverSlotLoaded<List<TrailerItem>>).value,
        isNotEmpty,
      );
      await cubit.close();
    });

    test('a slow section for the old segment is dropped', () async {
      final cubit = newCubit();
      await cubit.loadDiscover(MediaSegment.movie);
      final slow = cubit.requestSection(CarouselSection.topRated);
      await cubit.loadDiscover(MediaSegment.tvShow);
      await slow;

      final loaded = cubit.state as DiscoverLoaded;
      expect(loaded.segment, MediaSegment.tvShow);
      expect(loaded.carousels, isEmpty);
      await cubit.close();
    });

    group('refresh on locale change', () {
      test('a region change via SettingsRepository.watch() reloads the '
          'current segment exactly once', () async {
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
      });

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

      test('a settings change before any loadDiscover call is a no-op — '
          'there is no segment yet to reload', () async {
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
      });

      test(
        'close() leaves no live subscription on SettingsRepository',
        () async {
          final settingsRepository = _FakeSettingsRepository(
            const AppSettings(languageCode: 'en', regionCode: 'US'),
          );
          final cubit = DiscoverCubit(
            FakeMediaRepository(),
            settingsRepository,
          );
          await pumpEventQueue();
          expect(settingsRepository.controller.hasListener, isTrue);

          await cubit.close();
          await pumpEventQueue();

          expect(settingsRepository.controller.hasListener, isFalse);
        },
      );
    });
  });
}
