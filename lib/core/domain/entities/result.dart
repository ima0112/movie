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

final class Failure<T> extends Result<T> {
  const Failure(this.message);

  final String message;
}
