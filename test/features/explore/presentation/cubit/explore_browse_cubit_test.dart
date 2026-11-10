import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/app_settings.dart';
import 'package:movies/core/domain/repositories/settings_repository.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/streaming_service.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/explore/domain/explore_section.dart';
import 'package:movies/features/explore/presentation/cubit/explore_browse_cubit.dart';
import 'package:movies/features/explore/presentation/cubit/explore_browse_state.dart';

const _netflix = StreamingService(id: 8, name: 'Netflix');
const _max = StreamingService(id: 1899, name: 'Max');

/// Records every discover filter; a section can be made to fail or stall.
class _Repo extends FakeMediaRepository {
  final filters = <DiscoverFilter>[];
  ExploreSection? failing;
  Completer<void>? stall;
  List<StreamingService> services = const [_netflix, _max];

  @override
  Future<Result<List<MediaItem>>> discover(DiscoverFilter filter) async {
    filters.add(filter);
    final gate = stall;
    if (gate != null) await gate.future;
    if (failing != null &&
        filter.sortBy == DiscoverSortBy.rating &&
        filter.maxVoteCount != null &&
        failing == ExploreSection.hiddenGems) {
      return Failure(FailureReason.network);
    }
    return super.discover(filter.copyWith(sortBy: filter.sortBy));
  }

  @override
  Future<Result<List<StreamingService>>> streamingServices({type}) async =>
      Success(services);
}

class _Settings implements SettingsRepository {
  _Settings(this._current);

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

void main() {
  late _Repo repo;
  late _Settings settings;
  late ExploreBrowseCubit cubit;

  setUp(() {
    repo = _Repo();
    settings = _Settings(
      const AppSettings(languageCode: 'en', regionCode: 'US'),
    );
    cubit = ExploreBrowseCubit(
      repo,
      settings,
      clock: () => DateTime(2026, 5, 4),
    );
  });
  tearDown(() => cubit.close());

  Future<void> requestAll() async {
    for (final section in ExploreSection.values) {
      await cubit.requestSection(section);
    }
  }

  test(
    'start loads only the platforms — sections wait to be requested',
    () async {
      await cubit.start(MediaSegment.all);

      expect(cubit.state.services, isA<ExploreServicesLoaded>());
      expect(repo.filters, isEmpty);
      for (final section in ExploreSection.values) {
        // Not requested: no entry, which reads as loading.
        expect(cubit.state.sections.containsKey(section), isFalse);
        expect(cubit.state.sectionState(section), isA<ExploreSectionLoading>());
      }
    },
  );

  test('requestSection loads just that section, and only once', () async {
    await cubit.start(MediaSegment.all);

    await cubit.requestSection(ExploreSection.topRated);
    expect(repo.filters, hasLength(1));
    expect(
      cubit.state.sectionState(ExploreSection.topRated),
      isA<ExploreSectionLoaded>(),
    );

    // Asking again (the widget rebuilt, scrolled back…) costs nothing.
    await cubit.requestSection(ExploreSection.topRated);
    expect(repo.filters, hasLength(1));
    // The others were never asked for.
    expect(
      cubit.state.sections.containsKey(ExploreSection.hiddenGems),
      isFalse,
    );
  });

  test('picking a platform clears the sections and bumps the revision; the '
      'next request uses the new filter', () async {
    await cubit.start(MediaSegment.all);
    await requestAll();
    final before = cubit.state.revision;
    repo.filters.clear();

    await cubit.selectService(_netflix);

    expect(cubit.state.revision, before + 1);
    expect(cubit.state.sections, isEmpty);
    expect(repo.filters, isEmpty); // nothing fetched until requested

    await cubit.requestSection(ExploreSection.topToday);
    expect(
      repo.filters.single.withWatchProviders.length == 1 &&
          repo.filters.single.withWatchProviders.contains(8),
      isTrue,
    );

    await cubit.selectService(null);
    repo.filters.clear();
    await cubit.requestSection(ExploreSection.topToday);
    expect(repo.filters.single.withWatchProviders, isEmpty);
  });

  test('selecting what is already selected does nothing', () async {
    await cubit.start(MediaSegment.all);
    final revision = cubit.state.revision;
    await cubit.selectService(null);
    expect(cubit.state.revision, revision);
    expect(repo.filters, isEmpty);
  });

  test('a segment change clears the sections for the new type and drops a '
      'platform the new list lacks', () async {
    await cubit.start(MediaSegment.all);
    await cubit.selectService(_netflix);

    repo.services = const [_max];
    await cubit.setSegment(MediaSegment.movie);

    expect(cubit.state.segment, MediaSegment.movie);
    expect(cubit.state.service, isNull);
    expect(cubit.state.sections, isEmpty);

    await cubit.requestSection(ExploreSection.topToday);
    expect(repo.filters.last.type, isNotNull);
  });

  test('one section failing leaves the others loaded', () async {
    repo.failing = ExploreSection.hiddenGems;
    await cubit.start(MediaSegment.all);
    await requestAll();

    expect(
      cubit.state.sectionState(ExploreSection.hiddenGems),
      isA<ExploreSectionError>(),
    );
    expect(
      cubit.state.sectionState(ExploreSection.topToday),
      isA<ExploreSectionLoaded>(),
    );

    repo.failing = null;
    await cubit.retrySection(ExploreSection.hiddenGems);
    expect(
      cubit.state.sectionState(ExploreSection.hiddenGems),
      isA<ExploreSectionLoaded>(),
    );
  });

  test(
    'a slow response for old filters cannot overwrite the new ones',
    () async {
      await cubit.start(MediaSegment.all);

      final gate = Completer<void>();
      repo.stall = gate;
      final slow = cubit.requestSection(ExploreSection.topToday); // stalls
      repo.stall = null;
      await cubit.selectService(_max); // filters changed meanwhile
      await cubit.requestSection(ExploreSection.topToday); // the new request
      gate.complete();
      await slow;

      expect(cubit.state.service, _max);
      final top = cubit.state.sectionState(ExploreSection.topToday);
      expect(top, isA<ExploreSectionLoaded>());
      // The stale response's filter (no platform) wasn't what ended up shown:
      // the last applied result came from the _max request.
      expect(repo.filters.last.withWatchProviders.contains(1899), isTrue);
    },
  );

  test(
    'sections preview at most ${ExploreBrowseCubit.sectionSize} titles',
    () async {
      await cubit.start(MediaSegment.all);
      await requestAll();
      for (final section in ExploreSection.values) {
        final s = cubit.state.sectionState(section) as ExploreSectionLoaded;
        expect(
          s.items.length,
          lessThanOrEqualTo(ExploreBrowseCubit.sectionSize),
        );
      }
    },
  );

  test('a region change reloads the platforms and sections and clears the '
      'picked platform', () async {
    await cubit.start(MediaSegment.all);
    await cubit.selectService(_netflix);
    final revision = cubit.state.revision;
    repo.filters.clear();

    settings.controller.add(
      const AppSettings(languageCode: 'en', regionCode: 'ES'),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(cubit.state.service, isNull);
    expect(cubit.state.revision, greaterThan(revision));
    expect(cubit.state.sections, isEmpty);
    expect(cubit.state.services, isA<ExploreServicesLoaded>());
  });
}
