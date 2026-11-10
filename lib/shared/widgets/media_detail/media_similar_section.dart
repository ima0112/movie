import 'package:flutter/material.dart';

import '../../../core/domain/entities/media_item.dart';
import '../../../l10n/l10n_extension.dart';
import '../app_section.dart';
import '../media_carousel.dart';

/// D1/D2's "Similar" carousel — no "See all" (`docs/SCREENS.md` D1,
/// reused unchanged by D2). Pure presentation — [similar] arrives as a
/// plain value (CLAUDE.md rule 9 — the assembling screen already knows
/// it's loaded).
class MediaSimilarSection extends StatelessWidget {
  const MediaSimilarSection({
    super.key,
    required this.similar,
    this.onItemTap,
    this.title,
  });

  final List<MediaItem> similar;
  final void Function(MediaItem item)? onItemTap;

  /// Overrides the default "Similar" heading (D1 says "Similar movies").
  final String? title;

  @override
  Widget build(BuildContext context) {
    if (similar.isEmpty) return const SizedBox.shrink();

    return AppSection(
      title: title ?? context.l10n.mediaSimilarTitle,
      child: MediaCarousel.standard(
        items: similar,
        showTypeTag: true,
        onItemTap: onItemTap,
      ),
    );
  }
}
