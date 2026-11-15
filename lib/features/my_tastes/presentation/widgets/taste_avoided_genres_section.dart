import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/genre_icons.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../cubit/my_tastes_cubit.dart';
import '../cubit/my_tastes_state.dart';
import 'taste_genre_section.dart';

/// C5's "Genres you avoid": every genre as a chip, laid out like "Genres you
/// like" — the avoided ones red and struck through. Avoiding a genre also
/// drops it from the liked ones (`MyTastesCubit` keeps them exclusive).
/// Selects only the avoided set (rule 9).
class TasteAvoidedGenresSection extends StatelessWidget {
  const TasteAvoidedGenresSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocSelector<MyTastesCubit, MyTastesState, Set<Genre>>(
      selector: (state) => state.vetoedGenres,
      builder: (context, vetoed) => TasteGenreSection(
        title: l10n.myTastesGenresNeverTitle,
        hint: l10n.myTastesGenresNeverHint,
        genres: [for (final (genre, _) in genreOptions) genre],
        selected: vetoed,
        onToggle: context.read<MyTastesCubit>().toggleVetoedGenre,
        selectedState: ChipState.vetoed,
      ),
    );
  }
}
