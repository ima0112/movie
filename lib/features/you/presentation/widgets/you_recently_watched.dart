import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/stats/library_stats.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/media_card.dart';
import '../cubit/you_stats_cubit.dart';

/// B5's "Recently watched": the last titles marked as watched, newest first,
/// as a row of posters (`docs/SCREENS.md` B5); tapping one opens its detail.
/// Draws nothing — not even its heading — until something has been watched.
///
/// Selects only [LibraryStats.recentlyWatched] from [YouStatsCubit] (rule 9).
/// Posters come from each entry's own saved snapshot, no network call.
class YouRecentlyWatched extends StatelessWidget {
  const YouRecentlyWatched({super.key});

  static const MediaCardSize _size = MediaCardSize.carouselSmall;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<YouStatsCubit, LibraryStats?, List<UserMediaEntry>>(
      selector: (stats) => stats?.recentlyWatched ?? const [],
      builder: (context, entries) {
        if (entries.isEmpty) return const SizedBox.shrink();
        return AppSection(
          title: context.l10n.youRecentlyWatchedTitle,
          child: SizedBox(
            height: _size.height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return MediaCard(
                  key: ValueKey(entry.key),
                  size: _size,
                  title: entry.title,
                  posterUrl: entry.posterUrl,
                  showTypeTag: entry.key.type == MediaType.tvShow,
                  onTap: () => context.pushMediaDetail(entry.key),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
