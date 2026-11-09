import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/locale_names.dart';
import '../../../../shared/widgets/media_detail/media_detail_scroll_view.dart';
import '../../../../shared/widgets/media_detail/media_stat_cards.dart';
import '../cubit/tv_detail_cubit.dart';
import 'tv_creators_section.dart';
import 'tv_metadata.dart';
import 'tv_status.dart';

/// D2 once `TvDetailCubit` has loaded: hands `MediaDetailScrollView` (the
/// assembly D1 and D2 share) the show's own values — the air years and
/// country, the language chip, the Status / Seasons cards (Seasons → D2b)
/// and "Created by" between the cast and the similar shows
/// (`docs/SCREENS.md` D2).
///
/// [detail] arrives already loaded and narrowed to [TvShowDetail] — the only
/// place that reads `TvDetailCubit`'s state at all is
/// `tv_detail_screen.dart`'s top-level `BlocBuilder` (CLAUDE.md rule 9).
class TvDetailContent extends StatelessWidget {
  const TvDetailContent({
    super.key,
    required this.detail,
    required this.mediaKey,
    required this.scrollController,
    required this.similarSectionKey,
    this.regionCode,
  });

  final TvShowDetail detail;
  final MediaKey mediaKey;
  final ScrollController scrollController;
  final GlobalKey similarSectionKey;

  /// `null` = the saved region (see `*DetailLoaded.regionCode`).
  final String? regionCode;

  /// D2's Status and Seasons cards; Seasons is the tappable one (→ D2b) and
  /// only exists when the show has regular seasons.
  List<MediaStat> _stats(BuildContext context) {
    final l10n = context.l10n;
    final seasonCount = detail.seasons.where((s) => s.seasonNumber != 0).length;
    return [
      MediaStat(
        label: l10n.tvStatusCardLabel,
        value: tvStatusLabel(detail.status, l10n),
      ),
      if (seasonCount > 0)
        MediaStat(
          label: l10n.tvSeasonsLinkLabel,
          value: l10n.tvSeasonsLinkValue(seasonCount, detail.numberOfEpisodes),
          onTap: () => context.push(
            AppRoutes.tvSeasons,
            extra: TvSeasonsRouteArgs(detail: detail),
          ),
        ),
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
          context.read<TvDetailCubit>().setRegion(mediaKey, code),
      metaPrefix: tvMetaPrefix(context, detail),
      extraChips: [
        if (language != null && language.trim().isNotEmpty)
          languageDisplayName(context, language),
      ],
      stats: _stats(context),
      afterCast: TvCreatorsSection(
        creators: detail.creators,
        onPersonTap: (person) => context.pushPersonDetail(person.id),
      ),
      similarTitle: context.l10n.mediaSimilarTvTitle,
    );
  }
}
