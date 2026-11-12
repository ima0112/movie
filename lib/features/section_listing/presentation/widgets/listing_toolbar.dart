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
      // The icon's glyph lines up with the grid's right edge: the page margin
      // minus the empty space around the glyph inside its touch target.
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.sm,
        AppSpacing.screenMargin - (_SortButton.target - _SortButton.glyph) / 2,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: ListingContextPill(listingContext: listingContext)),
          const _SortButton(),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton();

  static const double glyph = 20;
  static const double target = 40;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SectionListingCubit, SectionListingState, ListingSort>(
      selector: (state) => state.sort,
      builder: (context, sort) {
        return IconButton(
          tooltip: context.l10n.sectionListingSortTooltip,
          iconSize: glyph,
          // Exactly [target] square (no padded 48 px minimum), so the glyph's
          // position is the one the row's padding was worked out for.
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size.square(target),
            fixedSize: const Size.square(target),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
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
