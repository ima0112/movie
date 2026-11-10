import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../l10n/failure_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../domain/listing_style.dart';
import '../cubit/section_listing_cubit.dart';
import '../cubit/section_listing_state.dart';
import 'listing_grid.dart';
import 'listing_skeleton.dart';

/// The body under the toolbar — the one `BlocBuilder` that switches between
/// the skeleton, the error, the empty state and the grid. It only rebuilds when
/// the *kind* of state changes or a new page/sort arrives; the toolbar and
/// summary above it never rebuild with it (CLAUDE.md rule 9).
class ListingContent extends StatelessWidget {
  const ListingContent({super.key, required this.style});

  final ListingStyle style;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SectionListingCubit, SectionListingState>(
      builder: (context, state) {
        final l10n = context.l10n;
        return switch (state) {
          SectionListingLoading() => const ListingSkeleton(),
          SectionListingError(:final reason) => ErrorStateView(
            title: l10n.commonCouldntLoad,
            body: reason.localizedMessage(l10n),
            onRetry: context.read<SectionListingCubit>().retry,
          ),
          SectionListingLoaded(:final items) when items.isEmpty =>
            EmptyStateView(
              icon: AppIcons.search,
              title: l10n.sectionListingEmptyTitle,
              body: l10n.sectionListingEmptyBody,
            ),
          SectionListingLoaded() => ListingGrid(state: state, style: style),
        };
      },
    );
  }
}
