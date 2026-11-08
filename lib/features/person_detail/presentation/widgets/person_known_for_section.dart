import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/media_carousel.dart';

/// D3's "Known for" — `docs/SCREENS.md` D3: "carousel of their 6 most
/// popular titles." [items] arrives already selected/deduped/sorted
/// (`PersonKnownFor.knownForItems`, `known_for.dart`) — pure
/// presentation otherwise, same as `MediaSimilarSection`.
class PersonKnownForSection extends StatelessWidget {
  const PersonKnownForSection({super.key, required this.items, this.onItemTap});

  final List<MediaItem> items;
  final void Function(MediaItem item)? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Known for', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.md),
          MediaCarousel.standard(
            items: items,
            showTypeTag: true,
            onItemTap: onItemTap,
          ),
        ],
      ),
    );
  }
}
