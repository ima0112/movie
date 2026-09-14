import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/media_card.dart';
import '../bloc/saved_ids_cubit.dart';

/// One hero card's save button. Carries its own `BlocSelector` scoped to
/// a single item id — tapping it (or another card's) only rebuilds this
/// 36 px circle, never the card it sits on or the hero carousel around it
/// (CLAUDE.md rule 9). Without a per-item selector like this, the only
/// way to reflect "is this item saved" would be a `BlocBuilder` wrapping
/// the whole hero (or worse, the whole screen) — this is exactly the kind
/// of widget rule 11 wants isolated in its own file, since it carries its
/// own independent Bloc subscription.
class DiscoverHeroSaveButton extends StatelessWidget {
  const DiscoverHeroSaveButton({super.key, required this.itemId});

  final int itemId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SavedIdsCubit, Set<int>, bool>(
      selector: (savedIds) => savedIds.contains(itemId),
      builder: (context, isSaved) {
        return MediaCardSaveButton(
          isSaved: isSaved,
          onTap: () => context.read<SavedIdsCubit>().toggle(itemId),
        );
      },
    );
  }
}
