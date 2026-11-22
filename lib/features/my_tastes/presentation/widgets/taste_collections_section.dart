import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/collection_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/genre_multi_select_chips.dart';
import '../cubit/my_tastes_cubit.dart';
import '../cubit/my_tastes_state.dart';

/// C5's "Collections you like": every collection the user can keep (all but
/// For kids) as a chip, no limit. Hidden when the catalog has none. Watches
/// only the liked collections (rule 9).
class TasteCollectionsSection extends StatelessWidget {
  const TasteCollectionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<MyTastesCubit>();
    final collections = cubit.state.availableCollections;
    if (collections.isEmpty) return const SizedBox.shrink();
    return AppSection(
      title: l10n.myTastesCollectionsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myTastesCollectionsHint,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          // A collection needing a genre the user avoids is dimmed and inert,
          // like a genre both liked and avoided: so it watches the avoided
          // genres too.
          BlocSelector<MyTastesCubit, MyTastesState, (Set<String>, Set<Genre>)>(
            selector: (state) => (state.likedCollections, state.vetoedGenres),
            builder: (context, current) {
              final (selected, _) = current;
              final blocked = cubit.collectionsBlockedByVetoes;
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final collection in collections)
                    if (blocked.contains(collection.id) &&
                        !selected.contains(collection.id))
                      Opacity(
                        opacity: GenreMultiSelectChips.disabledOpacity,
                        child: IgnorePointer(
                          child: AppChip(label: collection.localizedName(l10n)),
                        ),
                      )
                    else
                      AppChip(
                        label: collection.localizedName(l10n),
                        state: selected.contains(collection.id)
                            ? ChipState.selected
                            : ChipState.normal,
                        onTap: () => cubit.toggleCollection(collection.id),
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
