import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubits/taste_profile_cubit.dart';
import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/genre_catalog.dart';
import '../../../../core/domain/entities/taste_profile.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/priority_first.dart';
import '../../../../shared/widgets/app_section.dart';
import '../cubit/explore_browse_cubit.dart';
import '../cubit/explore_browse_state.dart';
import 'explore_pill.dart';
import 'explore_pill_row.dart';

/// B2's "GENRE" row: an "All" pill and one per normalized genre, single
/// select — **the genres the user likes (C5) come first**, the rest in the
/// catalog's order. Watches only the picked genre and the liked ones
/// (CLAUDE.md rule 9), so choosing a platform or loading a section never
/// rebuilds it.
class ExploreGenrePills extends StatelessWidget {
  const ExploreGenrePills({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSection.overline(
      title: l10n.exploreGenreLabel,
      inset: false,
      child: BlocSelector<TasteProfileCubit, TasteProfile?, Set<Genre>>(
        selector: (profile) => profile?.likedGenres ?? const {},
        builder: (context, liked) =>
            BlocSelector<ExploreBrowseCubit, ExploreBrowseState, Genre?>(
              selector: (state) => state.genre,
              builder: (context, picked) {
                final cubit = context.read<ExploreBrowseCubit>();
                return ExplorePillRow(
                  pills: [
                    ExplorePill(
                      label: l10n.exploreGenreAll,
                      selected: picked == null,
                      onTap: () => cubit.selectGenre(null),
                    ),
                    for (final genre in priorityFirst(
                      GenreCatalog.all,
                      liked.contains,
                    ))
                      ExplorePill(
                        label: genre.localizedName(l10n),
                        selected: picked == genre,
                        onTap: () => cubit.selectGenre(genre),
                      ),
                  ],
                );
              },
            ),
      ),
    );
  }
}
