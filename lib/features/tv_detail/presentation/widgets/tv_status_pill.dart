import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_chip.dart';

/// D2's status pill next to the title — `docs/SCREENS.md` D2: "Status
/// pill next to the title: 'Airing' (accent) / 'Ended' (neutral)."
///
/// Built on [AppChip] rather than a new widget with its own color
/// literal: `ChipState.selected`/`.normal` are already the exact
/// accent/neutral look this needs, and `.selected`'s accent fill is
/// already on `docs/DESIGN_SYSTEM.md`'s closed accent-site list ("estado
/// seleccionado de chips/tiles") — `tv_status_toggle.dart` (H8's own
/// Airing/Ended filter) already leans on this same mapping.
///
/// [status] is TMDB's raw `TvShowDetail.status` string ("Returning
/// Series", "Planned", "In Production", "Pilot", "Ended", "Canceled").
/// Only "Ended"/"Canceled" render as the neutral "Ended"/"Cancelled"
/// pill; anything else (including a status TMDB might add later) is
/// treated as still airing — matching this screen's own "is it done or
/// not" framing rather than trying to enumerate every in-production
/// nuance TMDB has.
class TvStatusPill extends StatelessWidget {
  const TvStatusPill({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, state) = switch (status) {
      'Ended' => ('Ended', ChipState.normal),
      'Canceled' => ('Cancelled', ChipState.normal),
      _ => ('Airing', ChipState.selected),
    };
    return AppChip(label: label, state: state);
  }
}
