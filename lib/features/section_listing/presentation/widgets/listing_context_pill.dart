import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/media_segment_localization.dart';
import '../../../../shared/widgets/streaming_service_logo.dart';
import '../../domain/listing_style.dart';

/// The pill under the title (the app's selected-pill look: a dark amber tint,
/// an amber hairline, amber text) that says what Explore had set: the picked
/// platform's logo (only when one was picked), a dot and the genre — or "All
/// genres". Home's "See all" has none (the segment isn't shown). Informational —
/// it isn't a control. (No count: a listing
/// is never longer than 100 titles.)
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
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.accentLine),
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
        ],
      ),
    );
  }

  /// Amber on the dark amber tint, like every selected pill of the app.
  static final TextStyle _style = AppTextStyles.bodySmStrong.copyWith(
    color: AppColors.accent,
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
