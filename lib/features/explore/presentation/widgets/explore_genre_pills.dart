import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/genre_catalog.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../cubit/explore_browse_cubit.dart';
import '../cubit/explore_browse_state.dart';
import 'explore_pill.dart';
import 'explore_pill_row.dart';

/// B2's "GENRE" row: an "All" pill and one per normalized genre, single
/// select. Watches only the picked genre (CLAUDE.md rule 9), so choosing a
/// platform or loading a section never rebuilds it.
class ExploreGenrePills extends StatelessWidget {
  const ExploreGenrePills({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSection.overline(
      title: l10n.exploreGenreLabel,
      inset: false,
      child: BlocSelector<ExploreBrowseCubit, ExploreBrowseState, Genre?>(
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
              for (final genre in GenreCatalog.all)
                ExplorePill(
                  label: genre.localizedName(l10n),
                  selected: picked == genre,
                  onTap: () => cubit.selectGenre(genre),
                ),
            ],
          );
        },
      ),
    );
  }
}
