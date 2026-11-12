import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/listing_sort_localization.dart';
import '../cubit/section_listing_cubit.dart';
import '../cubit/section_listing_state.dart';

/// "1,240 titles · Popularity" — shown once the first page is in. Watches only
/// the count and the sort.
class ListingSummary extends StatelessWidget {
  const ListingSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SectionListingCubit, SectionListingState, (int, int)?>(
      selector: (state) => state is SectionListingLoaded
          ? (state.totalResults, state.sort.index)
          : null,
      builder: (context, value) {
        if (value == null) return const SizedBox.shrink();
        final l10n = context.l10n;
        final sort = context.read<SectionListingCubit>().state.sort;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.sm,
            AppSpacing.screenMargin,
            0,
          ),
          child: Text(
            l10n.sectionListingSummary(value.$1, sort.localizedLabel(l10n)),
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
        );
      },
    );
  }
}
