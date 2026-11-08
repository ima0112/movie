import 'package:flutter/material.dart';

import '../../core/domain/entities/discover_filter.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/l10n_extension.dart';
import '../../l10n/tv_status_localization.dart';
import 'app_chip.dart';

/// H8: "status Airing/Ended (TV shows only)" (`docs/SCREENS.md` H8).
/// Tapping the already-selected option clears it back to `null` (no
/// filter) — H8 doesn't spell out a third "Either" option explicitly,
/// but every other optional single-choice control in this app (e.g.
/// [RatingStarsSelector]) already treats "tap again to clear" as the
/// way to represent "unset", so this matches that convention.
class TvStatusToggle extends StatelessWidget {
  const TvStatusToggle({
    super.key,
    required this.status,
    required this.onChanged,
  });

  final DiscoverTvStatus? status;
  final ValueChanged<DiscoverTvStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        _chip(
          DiscoverTvStatus.airing.localizedLabel(l10n),
          DiscoverTvStatus.airing,
        ),
        _chip(
          DiscoverTvStatus.ended.localizedLabel(l10n),
          DiscoverTvStatus.ended,
        ),
      ],
    );
  }

  Widget _chip(String label, DiscoverTvStatus value) {
    final isSelected = status == value;
    return AppChip(
      label: label,
      state: isSelected ? ChipState.selected : ChipState.normal,
      onTap: () => onChanged(isSelected ? null : value),
    );
  }
}
