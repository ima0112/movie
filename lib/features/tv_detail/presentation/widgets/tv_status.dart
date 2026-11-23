import 'package:flutter/painting.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// The localized status text ("Airing" / "Ended" / "Cancelled") for TMDB's
/// raw `TvShowDetail.status` string ("Returning Series", "Planned", "In
/// Production", "Pilot", "Ended", "Canceled"). Only "Ended"/"Canceled" read
/// as finished; anything else (including a status TMDB might add later) is
/// treated as still airing — this screen's own "is it done or not" framing.
/// Shared by D2's Status card and D2b's header chip.
String tvStatusLabel(String status, AppLocalizations l10n) => switch (status) {
  'Ended' => l10n.tvStatusEnded,
  'Canceled' => l10n.tvStatusCancelled,
  _ => l10n.tvStatusAiring,
};

/// Whether a show with this status will never get a new episode.
bool tvStatusIsFinished(String status) =>
    status == 'Ended' || status == 'Canceled';

/// The dot colour of D2b's status line: green while it airs, red when it was
/// cancelled, grey when it ended.
Color tvStatusColor(String status) => switch (status) {
  'Ended' => AppColors.inkMuted,
  'Canceled' => AppColors.danger,
  _ => AppColors.success,
};
