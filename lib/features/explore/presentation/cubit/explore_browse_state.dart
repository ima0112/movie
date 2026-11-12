import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/streaming_service.dart';
import '../../domain/explore_section.dart';

/// One body section's own load state — each section loads and fails on its
/// own (`docs/SCREENS.md` B2: per-section skeleton / error), so one slow or
/// broken carousel never blanks the others.
sealed class ExploreSectionState {
  const ExploreSectionState();
}

final class ExploreSectionLoading extends ExploreSectionState {
  const ExploreSectionLoading();
}

final class ExploreSectionLoaded extends ExploreSectionState {
  const ExploreSectionLoaded(this.items);

  final List<MediaItem> items;
}

final class ExploreSectionError extends ExploreSectionState {
  const ExploreSectionError(this.reason);

  final FailureReason reason;
}

/// The Platform pills' own load state.
sealed class ExploreServicesState {
  const ExploreServicesState();
}

final class ExploreServicesLoading extends ExploreServicesState {
  const ExploreServicesLoading();
}

final class ExploreServicesLoaded extends ExploreServicesState {
  const ExploreServicesLoaded(this.services);

  final List<StreamingService> services;
}

final class ExploreServicesError extends ExploreServicesState {
  const ExploreServicesError(this.reason);

  final FailureReason reason;
}

/// B2 at rest: the Genre and Platform pills and the four body sections they
/// filter. `null` [genre] / [service] mean "All".
final class ExploreBrowseState {
  const ExploreBrowseState({
    required this.segment,
    this.genre,
    this.service,
    this.services = const ExploreServicesLoading(),
    this.sections = const {},
  });

  final MediaSegment segment;
  final Genre? genre;
  final StreamingService? service;
  final ExploreServicesState services;

  /// A section with no entry yet counts as loading.
  final Map<ExploreSection, ExploreSectionState> sections;

  ExploreSectionState sectionState(ExploreSection section) =>
      sections[section] ?? const ExploreSectionLoading();

  ExploreBrowseState copyWith({
    MediaSegment? segment,
    Genre? Function()? genre,
    StreamingService? Function()? service,
    ExploreServicesState? services,
    Map<ExploreSection, ExploreSectionState>? sections,
  }) {
    return ExploreBrowseState(
      segment: segment ?? this.segment,
      genre: genre == null ? this.genre : genre(),
      service: service == null ? this.service : service(),
      services: services ?? this.services,
      sections: sections ?? this.sections,
    );
  }
}
