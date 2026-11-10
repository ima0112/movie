import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/app_settings.dart';
import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/streaming_service.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../../../core/domain/services/daily_picker.dart';
import '../../domain/explore_section.dart';
import 'explore_browse_state.dart';

/// B2 at rest (`docs/SCREENS.md` B2): the Platform pills and the sections
/// they filter. Screen-local (CLAUDE.md rule 10), separate from
/// [ExploreCubit] — typing a search and browsing share nothing but the
/// segment, which the screen passes in through [setSegment].
///
/// **Sections load on demand** (CLAUDE.md rule 17): [start] only fetches the
/// pills; a section's data is fetched when its widget calls [requestSection]
/// (via `LazyLoad`, as it nears the viewport). [requestSection] is
/// idempotent. Any filter change clears the sections and bumps
/// [ExploreBrowseState.revision], so the ones already on screen ask again.
///
/// Monotonic generation counters are checked before each result is applied,
/// so a slow response for filters the user has since changed can't overwrite
/// the current ones (one counter for the pills, one for the sections, so
/// reloading one never discards the other). A language/region change reloads
/// the pills and clears the sections (platforms are per region).
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

  /// The first load: the pills (sections wait to be requested).
  Future<void> start(MediaSegment segment) async {
    emit(state.copyWith(segment: segment));
    await _loadServices();
  }

  /// The segmented control changed: reload the platforms (they differ for
  /// movies and TV) and clear the sections for the new type. A picked
  /// platform that the new list doesn't have is dropped.
  Future<void> setSegment(MediaSegment segment) async {
    if (segment == state.segment) return;
    _clearSections(segment: segment, services: const ExploreServicesLoading());
    await _loadServices();
  }

  /// A Platform pill: `null` = "All".
  Future<void> selectService(StreamingService? service) async {
    if (service == state.service) return;
    _clearSections(service: () => service);
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

  /// Loads [section] if it has not been requested for the current filters —
  /// called by the section's `LazyLoad` when it nears the viewport. Safe to
  /// call any number of times.
  Future<void> requestSection(ExploreSection section) async {
    if (state.sections.containsKey(section)) return;
    final generation = _sectionsGeneration;
    _emitSection(section, const ExploreSectionLoading());
    await _loadSection(section, generation);
  }

  /// A filter changed: drop every section and start a new revision; the ones
  /// on screen request again, the rest wait until they are near.
  void _clearSections({
    MediaSegment? segment,
    ExploreServicesState? services,
    StreamingService? Function()? service,
  }) {
    _sectionsGeneration++;
    emit(
      state.copyWith(
        segment: segment,
        services: services,
        service: service,
        sections: const {},
        revision: state.revision + 1,
      ),
    );
  }

  Future<void> _loadSection(ExploreSection section, int generation) async {
    final filter = exploreSectionFilter(
      section,
      today: _clock(),
      type: state.segment.mediaType,
      providerId: state.service?.id,
    );
    final result = await _mediaRepository.discover(filter);
    if (generation != _sectionsGeneration || isClosed) return;
    _emitSection(section, switch (result) {
      Success(:final value) => ExploreSectionLoaded(
        _preview(section, value, filter),
      ),
      Failure(:final reason) => ExploreSectionError(reason),
    });
  }

  /// The titles a section previews: the first [sectionSize], or — for the
  /// sections that rotate — [sectionSize] of the whole page in today's
  /// day-stable shuffle (a different slice tomorrow, the same one all day).
  List<MediaItem> _preview(
    ExploreSection section,
    List<MediaItem> results,
    DiscoverFilter filter,
  ) {
    if (!exploreSectionRotates(section)) {
      return results.take(sectionSize).toList();
    }
    final salt =
        'explore-${section.name}-${filter.type?.name}-'
        '${filter.withWatchProviders.join(',')}';
    return DailyPicker(
      _clock(),
    ).shuffled(results, salt: salt).take(sectionSize).toList();
  }

  void _emitSection(ExploreSection section, ExploreSectionState value) {
    emit(state.copyWith(sections: {...state.sections, section: value}));
  }

  void _onSettingsChanged(AppSettings _) {
    if (isClosed) return;
    _clearSections(
      services: const ExploreServicesLoading(),
      service: () => null,
    );
    unawaited(_loadServices());
  }

  @override
  Future<void> close() {
    unawaited(_settingsSubscription.cancel());
    return super.close();
  }
}
