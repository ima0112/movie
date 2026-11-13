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

/// Under the title bar: Explore's context pill (none from Home) and, when
/// [sortEnabled], the sort icon. With sorting on, the pill sits on the left and the icon on the right;
/// with it off (the screen's default for now) the pill is **centered** in the
/// row. The pill is static (built once); only the icon watches the sort, to
/// turn amber when the list is not in its own order (CLAUDE.md rule 9).
class ListingToolbar extends StatelessWidget {
  const ListingToolbar({
    super.key,
    required this.listingContext,
    required this.sortEnabled,
  });

  final ListingContext listingContext;
  final bool sortEnabled;

  /// Room under the pill, so it clears the grid's top fade.
  static const double _gapBelow = AppSpacing.lg;

  @override
  Widget build(BuildContext context) {
    // Home's "See all" says nothing about what was set (no segment pill); with
    // sorting off there is then nothing to show in this row at all.
    final showsPill = listingContext.showsFilters;
    if (!showsPill && !sortEnabled) return const SizedBox.shrink();
    final pill = ListingContextPill(listingContext: listingContext);
    return Padding(
      // With the icon, its glyph lines up with the grid's right edge: the page
      // margin minus the empty space around the glyph in its touch target.
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.sm,
        sortEnabled
            ? AppSpacing.screenMargin -
                  (_SortButton.target - _SortButton.glyph) / 2
            : AppSpacing.screenMargin,
        _gapBelow,
      ),
      child: sortEnabled
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showsPill) Flexible(child: pill) else const SizedBox(),
                const _SortButton(),
              ],
            )
          : Center(child: pill),
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
