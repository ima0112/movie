import '../core/domain/stats/viewer_label.dart';
import 'app_localizations.dart';
import 'genre_localization.dart';

/// The display text of a [ViewerLabel] — CLAUDE.md rule 15.
extension ViewerLabelLocalization on ViewerLabel {
  String localized(AppLocalizations l10n) => switch (kind) {
    ViewerKind.newcomer => l10n.viewerNewcomer,
    ViewerKind.seriesBinger => l10n.viewerSeriesBinger,
    ViewerKind.exigentCritic => l10n.viewerExigentCritic,
    ViewerKind.enthusiast => l10n.viewerEnthusiast,
    ViewerKind.genreFan => l10n.viewerGenreFan(genre!.localizedName(l10n)),
    ViewerKind.cinephile => l10n.viewerCinephile,
    ViewerKind.explorer => l10n.viewerExplorer,
  };
}
