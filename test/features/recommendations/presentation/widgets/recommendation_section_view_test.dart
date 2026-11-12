import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/app_settings.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/search_result.dart';
import 'package:movies/core/domain/entities/streaming_service.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/core/domain/repositories/settings_repository.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/recommendations/domain/recommendation_builder.dart';
import 'package:movies/features/recommendations/presentation/cubit/recommendations_cubit.dart';
import 'package:movies/features/recommendations/presentation/widgets/recommendation_section_view.dart';
import 'package:movies/l10n/app_localizations.dart';

/// A title long enough, in Spanish, to genuinely stress "Porque te
/// gusta {título}" — CLAUDE.md rule 14's own checklist, applied to this
/// header specifically since it's the one new piece of UI in this
/// branch with a typed placeholder.
const _longSpanishTitle =
    'Una Producción Extraordinariamente Larga Sobre Aventuras '
    'Inolvidables en Tierras Muy, Muy Lejanas';

const _seedKey = MediaKey(type: MediaType.movie, tmdbId: 1);

Movie _movie(int id) => Movie(
  id: id,
  title: 'Movie $id',
  posterUrl: 'poster-$id',
  genres: const [],
  releaseDate: null,
  voteAverage: 7,
);

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._current);
  AppSettings _current;

  @override
  AppSettings get current => _current;

  @override
  Future<void> load() async {}

  @override
  Stream<AppSettings> watch() => Stream.value(_current);

  @override
  Future<Result<void>> save(AppSettings settings) async {
    _current = settings;
    return const Success(null);
  }
}

class _FakeMediaRepository implements MediaRepository {
  @override
  Future<Result<List<MediaItem>>> recommendationsFor(MediaKey seed) async =>
      // Ids start at 100 so none collides with the seed's own id (1) —
      // a collision would get excluded by filterAndThreshold's own
      // library check, one short of minRecommendationCount.
      Success(
        List.generate(
          RecommendationBuilder.minRecommendationCount,
          (i) => _movie(100 + i),
        ),
      );

  @override
  Future<Result<List<MediaItem>>> discover(DiscoverFilter filter) async =>
      const Success([]);

  @override
  Future<Result<List<MediaItem>>> getCarouselSection(
    CarouselSection section, {
    MediaType? type,
  }) => throw UnimplementedError();

  @override
  Future<Result<List<MediaItem>>> getHeroItems({MediaType? type}) =>
      throw UnimplementedError();

  @override
  Future<Result<List<MediaItem>>> getPosterWallItems() =>
      throw UnimplementedError();

  @override
  Future<Result<MediaDetail>> detail(MediaKey key, {String? regionCode}) =>
      throw UnimplementedError();

  @override
  Future<Result<SeasonDetail>> season(int tvId, int seasonNumber) =>
      throw UnimplementedError();

  @override
  Future<Result<List<SearchResult>>> searchMulti(String query) =>
      throw UnimplementedError();

  @override
  Future<Result<List<StreamingService>>> streamingServices({MediaType? type}) =>
      throw UnimplementedError();
}

void main() {
  testWidgets(
    '"Porque te gusta {título}" survives a long Spanish title at 200% '
    'text scale with no RenderFlex overflow',
    (tester) async {
      final userLibraryRepository = InMemoryUserLibraryRepository();
      await userLibraryRepository.upsert(
        const UserMediaEntry(
          key: _seedKey,
          title: _longSpanishTitle,
          isFavorite: true,
          genres: [Genre(id: 'action')],
        ),
      );
      final cubit = RecommendationsCubit(
        _FakeMediaRepository(),
        userLibraryRepository,
        InMemoryTasteProfileRepository(),
        _FakeSettingsRepository(
          const AppSettings(languageCode: 'es', regionCode: 'ES'),
        ),
        VibeCatalog(const []),
      );
      addTearDown(cubit.close);
      await cubit.load(MediaSegment.all);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 667),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(
              body: BlocProvider<RecommendationsCubit>.value(
                value: cubit,
                child: const SingleChildScrollView(
                  child: RecommendationSectionView(
                    slot: RecommendationSlot.becauseYouLike,
                    segment: MediaSegment.all,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Porque te gusta'), findsOneWidget);
      expect(find.textContaining(_longSpanishTitle), findsOneWidget);
    },
  );
}
