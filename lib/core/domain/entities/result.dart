/// The outcome of a repository call: [Success] with a value, or
/// [Failure] identified by a [FailureReason].
///
/// Source of truth: the project's CLAUDE.md, architecture rule 7 ("Sealed
/// `Result<T>`, never exceptions crossing from `data` to `presentation`.")
/// and rule 15 ("domain and data never contain user-facing text").
/// Repository implementations in `data/` catch whatever TMDB/Dio/SQLite
/// throws and turn it into a [Failure] — nothing throws past that
/// boundary, and nothing it carries is already-English display text:
/// `Failure` is identified **only** by its [FailureReason], never a
/// message string. Presentation translates it in exactly one place —
/// `Failure.localizedMessage` (`lib/l10n/failure_localization.dart`) —
/// rather than each screen inventing its own mapping.
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

/// Why a [Failure] happened — lets presentation code branch (an offline
/// banner for [network], a distinct empty state for [notFound], a
/// "slow down" message for [quota]) and is also the only thing
/// `Failure.localizedMessage` switches on. [storage] is every local
/// (drift/SQLite) read/write failure — not network-shaped, but still
/// distinct from [unknown] (a request that failed for no identifiable
/// reason at all).
enum FailureReason { network, server, notFound, quota, storage, unknown }

final class Failure<T> extends Result<T> {
  const Failure(this.reason);

  final FailureReason reason;
}
