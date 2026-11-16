import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../cubit/my_tastes_cubit.dart';
import '../cubit/my_tastes_state.dart';
import 'taste_era_range.dart';

/// C5's "Eras": the release-year range the user leans towards
/// (`docs/SCREENS.md` C5), 1950 to today. A range that ends today is stored
/// as "no upper bound". Selects only the years (rule 9).
class TasteErasSection extends StatelessWidget {
  const TasteErasSection({super.key});

  static const int minYear = 1950;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final latest = DateTime.now().year;
    return AppSection(
      title: l10n.myTastesErasTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myTastesErasHint,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          BlocSelector<MyTastesCubit, MyTastesState, (int, int?)>(
            selector: (state) => (state.yearFrom, state.yearTo),
            builder: (context, years) => TasteEraRange(
              from: years.$1,
              to: years.$2 ?? latest,
              minYear: minYear,
              maxYear: latest,
              onChanged: (from, to) => context
                  .read<MyTastesCubit>()
                  .setYearRange(from, to, latestYear: latest),
            ),
          ),
        ],
      ),
    );
  }
}
