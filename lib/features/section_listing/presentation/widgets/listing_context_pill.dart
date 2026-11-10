import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/media_segment_localization.dart';
import '../../domain/listing_style.dart';

/// The pill under the title that says what the screen the user came from had
/// set: from Explore, the genre and the platform (with "All genres" / "All
/// platforms" when not narrowed) and the segment when it isn't All; from
/// Home, just the segment. Informational — it isn't a control.
class ListingContextPill extends StatelessWidget {
  const ListingContextPill({super.key, required this.listingContext});

  final ListingContext listingContext;

  static const double height = 36;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = listingContext;
    final parts = <String>[
      if (!c.showsFilters || c.segment.mediaType != null)
        c.segment.localizedLabel(l10n),
      if (c.showsFilters) ...[
        c.genre?.localizedName(l10n) ?? l10n.sectionListingAllGenres,
        c.platform?.name ?? l10n.sectionListingAllPlatforms,
      ],
    ];
    return Container(
      constraints: const BoxConstraints(minHeight: height),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.lineStrong),
      ),
      child: Text(
        parts.join(' · '),
        style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
