import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/media_segment_localization.dart';
import '../../../../shared/widgets/streaming_service_logo.dart';
import '../../domain/listing_style.dart';
import '../cubit/section_listing_cubit.dart';
import '../cubit/section_listing_state.dart';

/// The amber pill under the title that says what the screen the user came from
/// had set, and how many titles that gives. From Explore: the picked
/// platform's logo (only when one was picked), a dot, the genre — or "All
/// genres" — a dot and the count. From Home: the segment (All, Movies, TV
/// Shows), a dot and the count. Informational — it isn't a control. The count
/// appears once the first page is in; only it watches the cubit (CLAUDE.md
/// rule 9).
class ListingContextPill extends StatelessWidget {
  const ListingContextPill({super.key, required this.listingContext});

  final ListingContext listingContext;

  static const double height = 36;
  static const double _logoSize = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = listingContext;
    final label = c.showsFilters
        ? c.genre?.localizedName(l10n) ?? l10n.sectionListingAllGenres
        : c.segment.localizedLabel(l10n);
    final platform = c.showsFilters ? c.platform : null;
    return Container(
      constraints: const BoxConstraints(minHeight: height),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (platform != null) ...[
            StreamingServiceLogo(service: platform, size: _logoSize),
            const _Dot(),
          ],
          Flexible(
            child: Text(
              label,
              style: _style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          BlocSelector<SectionListingCubit, SectionListingState, int?>(
            selector: (state) =>
                state is SectionListingLoaded ? state.count : null,
            builder: (context, count) {
              if (count == null) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Dot(),
                  Text(
                    NumberFormat.decimalPattern(l10n.localeName).format(count),
                    style: _style,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Black on the amber, like every amber control.
  static final TextStyle _style = AppTextStyles.bodySmStrong.copyWith(
    color: AppColors.onAccent,
  );
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Text('·', style: ListingContextPill._style),
    );
  }
}
