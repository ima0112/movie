import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/genre_icons.dart';
import '../../../../l10n/l10n_extension.dart';
import '../cubit/my_tastes_cubit.dart';
import '../cubit/my_tastes_state.dart';
import 'taste_genre_section.dart';

/// C5's "Genres you like": every genre as a chip, the picked ones amber.
/// Selects only the liked set (rule 9).
class TasteLikedGenresSection extends StatelessWidget {
  const TasteLikedGenresSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocSelector<MyTastesCubit, MyTastesState, Set<Genre>>(
      selector: (state) => state.likedGenres,
      builder: (context, liked) => TasteGenreSection(
        title: l10n.myTastesGenresLikeTitle,
        hint: l10n.myTastesGenresLikeHint,
        genres: [for (final (genre, _) in genreOptions) genre],
        selected: liked,
        onToggle: context.read<MyTastesCubit>().toggleLikedGenre,
      ),
    );
  }
}
