import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/app_settings.dart';
import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/streaming_service.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../domain/explore_section.dart';
import 'explore_browse_state.dart';

/// B2 at rest (`docs/SCREENS.md` B2): the Genre and Platform pills and the
/// four sections they filter. Screen-local (CLAUDE.md rule 10), separate from
/// [ExploreCubit] — typing a search and browsing share nothing but the
/// segment, which the screen passes in through [setSegment].
///
/// Every section loads on its own, in parallel, and is emitted as it
/// arrives; monotonic generation counters are checked before each result is
/// applied, so a slow response for filters the user has since changed can't
/// overwrite the current ones (one counter for the pills, one for the
/// sections, so reloading one never discards the other). A language/region change reloads the pills and
/// the sections (platforms are per region).
class ExploreBrowseCubit extends Cubit<ExploreBrowseState> {
  ExploreBrowseCubit(
    this._mediaRepository,
    this._settingsRepository, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const ExploreBrowseState(segment: MediaSegment.all)) {
    _settingsSubscription = _settingsRepository
        .watch()
        .distinct()
        .skip(1)
        .listen(_onSettingsChanged);
  }

  final MediaRepository _mediaRepository;
  final SettingsRepository _settingsRepository;
  final DateTime Function() _clock;
  late final StreamSubscription<AppSettings> _settingsSubscription;
  int _servicesGeneration = 0;
  int _sectionsGeneration = 0;

  /// How many titles a section previews.
  static const int sectionSize = 10;

  /// The first load — call once, right after creating.
  Future<void> start(MediaSegment segment) async {
    emit(state.copyWith(segment: segment));
    await Future.wait([_loadServices(), _loadSections()]);
  }

  /// The segmented control changed: reload the platforms (they differ for
  /// movies and TV) and the sections for the new type. A picked platform that
  /// the new list doesn't have is dropped.
  Future<void> setSegment(MediaSegment segment) async {
    if (segment == state.segment) return;
    emit(
      state.copyWith(
        segment: segment,
        services: const ExploreServicesLoading(),
        sections: const {},
      ),
    );
    await Future.wait([_loadServices(), _loadSections()]);
  }

  /// A Genre pill: `null` = "All".
  Future<void> selectGenre(Genre? genre) async {
    if (genre == state.genre) return;
    emit(state.copyWith(genre: () => genre, sections: const {}));
    await _loadSections();
  }

  /// A Platform pill: `null` = "All".
  Future<void> selectService(StreamingService? service) async {
    if (service == state.service) return;
    emit(state.copyWith(service: () => service, sections: const {}));
    await _loadSections();
  }

  Future<void> retryServices() async {
    emit(state.copyWith(services: const ExploreServicesLoading()));
    await _loadServices();
  }

  Future<void> retrySection(ExploreSection section) async {
    final generation = _sectionsGeneration;
    _emitSection(section, const ExploreSectionLoading());
    await _loadSection(section, generation);
  }

  Future<void> _loadServices() async {
    final generation = ++_servicesGeneration;
    final result = await _mediaRepository.streamingServices(
      type: state.segment.mediaType,
    );
    if (generation != _servicesGeneration || isClosed) return;
    switch (result) {
      case Success<List<StreamingService>>(:final value):
        final picked = state.service;
        emit(
          state.copyWith(
            services: ExploreServicesLoaded(value),
            // A platform the new list doesn't have no longer applies.
            service: () =>
                picked != null && value.contains(picked) ? picked : null,
          ),
        );
      case Failure<List<StreamingService>>(:final reason):
        emit(state.copyWith(services: ExploreServicesError(reason)));
    }
  }

  Future<void> _loadSections() async {
    final generation = ++_sectionsGeneration;
    await Future.wait([
      for (final section in ExploreSection.values)
        _loadSection(section, generation),
    ]);
  }

  Future<void> _loadSection(ExploreSection section, int generation) async {
    final filter = exploreSectionFilter(
      section,
      today: _clock(),
      type: state.segment.mediaType,
      genre: state.genre,
      providerId: state.service?.id,
    );
    final result = await _mediaRepository.discover(filter);
    if (generation != _sectionsGeneration || isClosed) return;
    _emitSection(section, switch (result) {
      Success(:final value) => ExploreSectionLoaded(
        value.take(sectionSize).toList(),
      ),
      Failure(:final reason) => ExploreSectionError(reason),
    });
  }

  void _emitSection(ExploreSection section, ExploreSectionState value) {
    emit(state.copyWith(sections: {...state.sections, section: value}));
  }

  void _onSettingsChanged(AppSettings _) {
    if (isClosed) return;
    emit(
      state.copyWith(
        services: const ExploreServicesLoading(),
        service: () => null,
        sections: const {},
      ),
    );
    unawaited(Future.wait([_loadServices(), _loadSections()]));
  }

  @override
  Future<void> close() {
    unawaited(_settingsSubscription.cancel());
    return super.close();
  }
}
