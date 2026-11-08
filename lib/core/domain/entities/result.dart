/// The outcome of a repository call: [Success] with a value, or
/// [Failure] with an error message.
///
/// Source of truth: the project's CLAUDE.md, architecture rule 7 ("Sealed
/// `Result<T>`, never exceptions crossing from `data` to `presentation`.")
/// and `docs/STRUCTURE.md` (`core/domain/entities/result.dart`).
/// Repository implementations in `data/` catch whatever TMDB/Dio/SQLite
/// throws and turn it into a [Failure] — nothing throws past that
/// boundary.
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

/// Why a [Failure] happened — lets presentation code branch (an offline
/// banner for [network], a distinct empty state for [notFound], a
/// "slow down" message for [quota]) without parsing [Failure.message].
///
/// Source of truth: this project's CLAUDE.md rule 7 and
/// `docs/DECISIONS.md` §2/§7 — `core/network`'s Dio-to-`Failure` mapping
/// is the one place that assigns these; everything else defaults to
/// [unknown] (e.g. local/drift failures, which aren't network-shaped at
/// all).
enum FailureReason { network, server, notFound, quota, unknown }

final class Failure<T> extends Result<T> {
  const Failure(this.message, {this.reason = FailureReason.unknown});

  final String message;
  final FailureReason reason;
}
