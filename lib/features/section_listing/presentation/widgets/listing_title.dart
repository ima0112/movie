import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../cubit/section_listing_cubit.dart';
import '../cubit/section_listing_state.dart';

/// The top bar's title: the section's name and, under it in muted type, how
/// many titles the list has once the first page is in. Only the count line
/// watches the cubit (CLAUDE.md rule 9).
class ListingTitle extends StatelessWidget {
  const ListingTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTextStyles.h2),
        BlocSelector<SectionListingCubit, SectionListingState, int?>(
          selector: (state) =>
              state is SectionListingLoaded ? state.totalResults : null,
          builder: (context, count) {
            if (count == null) return const SizedBox.shrink();
            return Text(
              context.l10n.sectionListingCount(count),
              style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
            );
          },
        ),
      ],
    );
  }
}
