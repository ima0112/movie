import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/app_settings.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/streaming_service.dart';
import 'package:movies/core/domain/repositories/settings_repository.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/explore/domain/explore_section.dart';
import 'package:movies/features/explore/presentation/cubit/explore_browse_cubit.dart';
import 'package:movies/features/explore/presentation/widgets/explore_browse_section.dart';
import 'package:movies/l10n/app_localizations.dart';

const _netflix = StreamingService(id: 8, name: 'Netflix');

class _Repo extends FakeMediaRepository {
  final filters = <DiscoverFilter>[];

  @override
  Future<Result<List<MediaItem>>> discover(DiscoverFilter filter) async {
    filters.add(filter);
    return super.discover(filter);
  }

  @override
  Future<Result<List<StreamingService>>> streamingServices({type}) async =>
      const Success([_netflix]);
}

class _Settings implements SettingsRepository {
  final _controller = StreamController<AppSettings>.broadcast();
  final _current = const AppSettings(languageCode: 'en', regionCode: 'US');

  @override
  AppSettings get current => _current;

  @override
  Future<void> load() async {}

  @override
  Stream<AppSettings> watch() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<Result<void>> save(AppSettings settings) async => const Success(null);
}

void main() {
  testWidgets('on a phone only the sections near the top fetch; scrolling '
      'brings the rest; a filter change re-fetches only what is near', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repo = _Repo();
    final cubit = ExploreBrowseCubit(repo, _Settings());
    addTearDown(cubit.close);
    await cubit.start(MediaSegment.all);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: ListView(
              children: [
                for (final section in ExploreSection.values)
                  ExploreBrowseSection(section: section),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Six sections of ~300 px each on a 700 px screen: not all of them.
    final firstBatch = repo.filters.length;
    expect(firstBatch, greaterThan(0));
    expect(firstBatch, lessThan(ExploreSection.values.length));

    // Scroll to the bottom: the rest load.
    await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(repo.filters.length, ExploreSection.values.length);

    // A filter change clears the sections; at the bottom only the sections
    // still near re-fetch, not all six again.
    repo.filters.clear();
    await cubit.selectService(_netflix);
    await tester.pumpAndSettle();
    expect(repo.filters.length, lessThan(ExploreSection.values.length));
    expect(repo.filters.length, greaterThan(0));
    expect(repo.filters.every((f) => f.withWatchProviders.contains(8)), isTrue);
  });
}
