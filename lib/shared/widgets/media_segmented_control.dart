import 'package:flutter/material.dart';

import '../../core/domain/entities/media_segment.dart';
import '../../l10n/l10n_extension.dart';
import '../../l10n/media_segment_localization.dart';
import 'app_segmented_control.dart';

/// All | Movies | TV Shows as an [AppSegmentedControl] — used by Discover
/// (B1) and Explore (B2). Driven entirely by [segment] and [onSelected]:
/// purely presentational, so it updates instantly on tap regardless of
/// whether the caller re-fetches synchronously (`DiscoverScreen`'s own local
/// `setState`) or through a Cubit (`ExploreCubit.selectSegment`) (CLAUDE.md
/// rule 9).
class MediaSegmentedControl extends StatelessWidget {
  const MediaSegmentedControl({
    super.key,
    required this.segment,
    required this.onSelected,
    this.glass = false,
  });

  final MediaSegment segment;
  final ValueChanged<MediaSegment> onSelected;

  /// The translucent track (Discover); see [AppSegmentedControl.glass].
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSegmentedControl<MediaSegment>(
      segments: [
        for (final value in MediaSegment.values)
          AppSegment(value: value, label: value.localizedLabel(l10n)),
      ],
      selected: segment,
      onSelected: onSelected,
      glass: glass,
    );
  }
}
