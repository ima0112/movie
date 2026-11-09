import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/locale_names.dart';
import '../../../../app/router.dart';
import '../../../../shared/widgets/media_detail/media_byline.dart';
import '../../../../shared/widgets/media_detail/media_detail_scroll_view.dart';
import '../../../../shared/widgets/media_detail/media_stat_cards.dart';
import '../cubit/movie_detail_cubit.dart';
import 'movie_metadata.dart';

/// D1 once `MovieDetailCubit` has loaded: hands `MediaDetailScrollView` (the
/// assembly D1 and D2 share) the movie's own values — the meta line, the
/// language chip and the Duration / Classification cards.
///
/// [detail] arrives already loaded and narrowed to [MovieDetail] — the only
/// place that reads `MovieDetailCubit`'s state at all is
/// `movie_detail_screen.dart`'s top-level `BlocBuilder` (CLAUDE.md rule 9).
class MovieDetailContent extends StatelessWidget {
  const MovieDetailContent({
    super.key,
    required this.detail,
    required this.mediaKey,
    required this.scrollController,
    required this.similarSectionKey,
    this.regionCode,
  });

  final MovieDetail detail;
  final MediaKey mediaKey;
  final ScrollController scrollController;
  final GlobalKey similarSectionKey;

  /// `null` = the saved region (see `*DetailLoaded.regionCode`).
  final String? regionCode;

  /// D1's Duration / Classification stat cards — each only when TMDB has it.
  List<MediaStat> _stats(BuildContext context) {
    final l10n = context.l10n;
    final runtime = detail.runtimeMinutes;
    final certification = detail.certification;
    return [
      if (runtime != null)
        MediaStat(
          label: l10n.mediaDetailDuration,
          value: movieRuntimeLabel(runtime, l10n),
        ),
      if (certification != null && certification.isNotEmpty)
        MediaStat(label: l10n.mediaDetailClassification, value: certification),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final language = detail.originalLanguage;
    return MediaDetailScrollView(
      detail: detail,
      mediaKey: mediaKey,
      scrollController: scrollController,
      similarSectionKey: similarSectionKey,
      userLibraryRepository: getIt<UserLibraryRepository>(),
      regionCode: regionCode ?? getIt<SettingsRepository>().current.regionCode,
      onRegionSelected: (code) =>
          context.read<MovieDetailCubit>().setRegion(mediaKey, code),
      metaPrefix: movieMetaPrefix(context, detail),
      extraChips: [
        if (language != null && language.trim().isNotEmpty)
          languageDisplayName(context, language),
      ],
      stats: _stats(context),
      castByline: MediaByline(
        label: context.l10n.mediaDirectedByLabel,
        people: movieDirectors(detail),
        onPersonTap: (person) => context.pushPersonDetail(person.id),
      ),
      similarTitle: context.l10n.mediaSimilarMoviesTitle,
    );
  }
}
