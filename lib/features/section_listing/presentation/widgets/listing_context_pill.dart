import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/media_segment_localization.dart';
import '../../../../shared/widgets/streaming_service_logo.dart';
import '../../domain/listing_style.dart';

/// The pill under the title that says what the screen the user came from had
/// set. From Explore: the platform's logo (only when one was picked), a dot,
/// and the genre — or "All genres". From Home: just the segment (All, Movies,
/// TV Shows). Informational — it isn't a control.
class ListingContextPill extends StatelessWidget {
  const ListingContextPill({super.key, required this.listingContext});

  final ListingContext listingContext;

  static const double height = 36;
  static const double _logoSize = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = listingContext;
    final style = AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted);
    final label = c.showsFilters
        ? c.genre?.localizedName(l10n) ?? l10n.sectionListingAllGenres
        : c.segment.localizedLabel(l10n);
    final platform = c.showsFilters ? c.platform : null;
    return Semantics(
      label: [if (platform != null) platform.name, label].join(', '),
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: height),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: AppColors.lineStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (platform != null) ...[
              StreamingServiceLogo(service: platform, size: _logoSize),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text('·', style: style),
              ),
            ],
            Flexible(
              child: Text(
                label,
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
