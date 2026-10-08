import '../core/domain/entities/result.dart';
import 'app_localizations.dart';

/// The single mapper from a [FailureReason] to user-facing text —
/// CLAUDE.md rule 15: `domain`/`data` never contain user-facing text, so
/// [Failure] carries only a [FailureReason] and every screen that needs
/// to show it calls `.localizedMessage(context.l10n)` rather than
/// inventing its own copy.
extension FailureReasonLocalization on FailureReason {
  String localizedMessage(AppLocalizations l10n) => switch (this) {
    FailureReason.network => l10n.failureNetwork,
    FailureReason.server => l10n.failureServer,
    FailureReason.notFound => l10n.failureNotFound,
    FailureReason.quota => l10n.failureQuota,
    FailureReason.storage => l10n.failureStorage,
    FailureReason.unknown => l10n.failureUnknown,
  };
}

/// Convenience for the (less common) case of holding the whole
/// [Failure], not just its [FailureReason] — e.g. a repository result
/// passed straight to a widget. Delegates to [FailureReasonLocalization]
/// so there's still exactly one switch over [FailureReason].
extension FailureLocalization<T> on Failure<T> {
  String localizedMessage(AppLocalizations l10n) =>
      reason.localizedMessage(l10n);
}
