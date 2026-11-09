import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/media_type_localization.dart';
import '../../../../shared/widgets/app_segmented_control.dart';

/// C4's "All · Movies · TV Shows" filter (`docs/SCREENS.md` C4), as the
/// app's [AppSegmentedControl].
///
/// Driven entirely by [filterType]/[onSelected] — knows nothing about
/// `StatsCubit`: the screen's own narrowly-scoped `BlocSelector` is what
/// actually reads the Cubit (CLAUDE.md rule 9). `null` selects "All".
class StatsTypeTabs extends StatelessWidget {
  const StatsTypeTabs({
    super.key,
    required this.filterType,
    required this.onSelected,
  });

  final MediaType? filterType;
  final ValueChanged<MediaType?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSegmentedControl<MediaType?>(
      padding: EdgeInsets.zero,
      segments: [
        AppSegment(value: null, label: l10n.mediaSegmentAll),
        AppSegment(
          value: MediaType.movie,
          label: MediaType.movie.localizedPlural(l10n),
        ),
        AppSegment(
          value: MediaType.tvShow,
          label: MediaType.tvShow.localizedPlural(l10n),
        ),
      ],
      selected: filterType,
      onSelected: onSelected,
    );
  }
}
