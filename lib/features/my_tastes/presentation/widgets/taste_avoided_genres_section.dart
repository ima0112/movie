import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/app_section.dart';
import '../cubit/my_tastes_cubit.dart';
import '../cubit/my_tastes_state.dart';
import 'taste_add_genre_sheet.dart';

/// C5's "Genres you avoid": only the avoided genres, as red struck-through
/// chips (tap one to take it back), and a "+ Add" chip that opens the picker
/// of the rest (`docs/SCREENS.md` C5). Avoiding a genre also drops it from
/// the liked ones (`MyTastesCubit` keeps them exclusive). Selects only the
/// avoided set (rule 9).
class TasteAvoidedGenresSection extends StatelessWidget {
  const TasteAvoidedGenresSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSection(
      title: l10n.myTastesGenresNeverTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myTastesGenresNeverHint,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          BlocSelector<MyTastesCubit, MyTastesState, Set<Genre>>(
            selector: (state) => state.vetoedGenres,
            builder: (context, vetoed) {
              final cubit = context.read<MyTastesCubit>();
              final sorted = vetoed.toList()
                ..sort((a, b) => a.id.compareTo(b.id));
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final genre in sorted)
                    AppChip(
                      label: genre.localizedName(l10n),
                      state: ChipState.vetoed,
                      onTap: () => cubit.toggleVetoedGenre(genre),
                    ),
                  AppChip(
                    label: l10n.myTastesAddAvoided,
                    icon: AppIcons.add,
                    onTap: () => showTasteAddGenreSheet(
                      context,
                      avoided: vetoed,
                      onPick: cubit.toggleVetoedGenre,
                    ),
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
