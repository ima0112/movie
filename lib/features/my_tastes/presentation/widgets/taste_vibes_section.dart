import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/vibe_localization.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/vibe_icon.dart';
import '../cubit/my_tastes_cubit.dart';
import '../cubit/my_tastes_state.dart';

/// C5's "Favorite vibes": every vibe as a chip with its icon, **up to 5**
/// (`docs/SCREENS.md` C5). Once 5 are picked the rest are dimmed and inert
/// until one is deselected. Selects only the liked vibes (rule 9).
class TasteVibesSection extends StatelessWidget {
  const TasteVibesSection({super.key});

  static const double _dimmed = 0.4;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<MyTastesCubit>();
    final vibes = cubit.state.availableVibes;
    return AppSection(
      title: l10n.myTastesVibesTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myTastesVibesHint(MyTastesState.maxVibes),
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          BlocSelector<MyTastesCubit, MyTastesState, Set<String>>(
            selector: (state) => state.likedVibes,
            builder: (context, selected) {
              final full = selected.length >= MyTastesState.maxVibes;
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final vibe in vibes)
                    Opacity(
                      opacity: full && !selected.contains(vibe.id)
                          ? _dimmed
                          : 1,
                      child: AppChip(
                        label: vibe.localizedName(l10n),
                        icon: vibeIconFor(vibe),
                        state: selected.contains(vibe.id)
                            ? ChipState.selected
                            : ChipState.normal,
                        onTap: () => cubit.toggleVibe(vibe.id),
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
