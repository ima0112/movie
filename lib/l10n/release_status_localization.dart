import 'package:intl/intl.dart';

import '../core/domain/entities/release_status.dart';
import 'app_localizations.dart';

/// The single mapper from a [ReleaseStatus] to its words — CLAUDE.md rule 15.
extension ReleaseStatusLocalization on ReleaseStatus {
  String _date(AppLocalizations l10n, DateTime d) =>
      DateFormat.yMMMd(l10n.localeName).format(d);

  /// The tag in D1/D2's header: "Coming Mar 14, 2027", "Coming soon" (no
  /// date), or "In theaters".
  String headerLabel(AppLocalizations l10n) => switch (stage) {
    ReleaseStage.inTheaters => l10n.releaseStatusInTheaters,
    ReleaseStage.upcoming =>
      date == null
          ? l10n.releaseStatusComingSoon
          : l10n.releaseStatusComingOn(_date(l10n, date!)),
  };

  /// What the Where to watch card says when no service lists the title.
  String whereToWatchMessage(AppLocalizations l10n) => switch (stage) {
    ReleaseStage.inTheaters =>
      streamingDate == null
          ? l10n.whereToWatchInTheaters
          : l10n.whereToWatchInTheatersStreamingOn(_date(l10n, streamingDate!)),
    ReleaseStage.upcoming =>
      date == null
          ? l10n.whereToWatchNotReleased
          : l10n.whereToWatchNotReleasedOn(_date(l10n, date!)),
  };
}
