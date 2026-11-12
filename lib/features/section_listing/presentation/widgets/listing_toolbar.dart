import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../domain/listing_source.dart';
import '../../domain/listing_style.dart';
import '../cubit/section_listing_cubit.dart';
import '../cubit/section_listing_state.dart';
import 'listing_context_pill.dart';
import 'listing_sort_sheet.dart';

/// Under the title bar: the context pill on the left, the sort icon on the
/// right. The pill is static (built once); only the icon watches the sort, to
/// turn amber when the list is not in its own order (CLAUDE.md rule 9).
class ListingToolbar extends StatelessWidget {
  const ListingToolbar({super.key, required this.listingContext});

  final ListingContext listingContext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.sm,
        AppSpacing.sm,
        0,
      ),
      child: Row(
        children: [
          Flexible(child: ListingContextPill(listingContext: listingContext)),
          const Spacer(),
          const _SortButton(),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton();

  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SectionListingCubit, SectionListingState, ListingSort>(
      selector: (state) => state.sort,
      builder: (context, sort) {
        return IconButton(
          tooltip: context.l10n.sectionListingSortTooltip,
          iconSize: _iconSize,
          visualDensity: VisualDensity.compact,
          icon: Icon(
            AppIcons.sort,
            color: sort == ListingSort.byDefault
                ? AppColors.ink
                : AppColors.accent,
          ),
          onPressed: () => _open(context, sort),
        );
      },
    );
  }

  // The sheet's builder gets a context under the Navigator, a sibling of this
  // subtree — the cubit is handed down explicitly (same as C1's filter sheet).
  void _open(BuildContext context, ListingSort selected) {
    final cubit = context.read<SectionListingCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ListingSortSheet(
        options: cubit.source.sorts,
        selected: selected,
        onSelected: cubit.setSort,
      ),
    );
  }
}
