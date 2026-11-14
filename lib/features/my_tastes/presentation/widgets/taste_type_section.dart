import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/media_type_localization.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/app_segmented_control.dart';
import '../cubit/my_tastes_cubit.dart';
import '../cubit/my_tastes_state.dart';

/// C5's "What do you usually watch?" — Movies · TV Shows · Both
/// (`docs/SCREENS.md` C5). It sets which segment Home opens on. Selects only
/// the preferred type (rule 9).
class TasteTypeSection extends StatelessWidget {
  const TasteTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSection(
      title: l10n.myTastesTypeTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myTastesTypeHint,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          BlocSelector<MyTastesCubit, MyTastesState, MediaType?>(
            selector: (state) => state.preferredType,
            builder: (context, selected) => AppSegmentedControl<MediaType?>(
              padding: EdgeInsets.zero,
              segments: [
                AppSegment(
                  value: MediaType.movie,
                  label: MediaType.movie.localizedPlural(l10n),
                ),
                AppSegment(
                  value: MediaType.tvShow,
                  label: MediaType.tvShow.localizedPlural(l10n),
                ),
                AppSegment(value: null, label: l10n.myTastesTypeBoth),
              ],
              selected: selected,
              onSelected: context.read<MyTastesCubit>().setPreferredType,
            ),
          ),
        ],
      ),
    );
  }
}
