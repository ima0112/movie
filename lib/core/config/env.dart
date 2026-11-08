/// Compile-time configuration injected via --dart-define-from-file.
/// Values must be read with `const` + `String.fromEnvironment`; reading them
/// at runtime any other way returns the default.
abstract final class Env {
  static const tmdbToken = String.fromEnvironment('TMDB_TOKEN');
  static const tmdbBaseUrl = String.fromEnvironment(
    'TMDB_BASE_URL',
    defaultValue: 'https://api.themoviedb.org/3',
  );

  /// Fail fast at startup with a readable message instead of a cryptic 401
  /// on the first request.
  static void validate() {
    assert(
      tmdbToken.isNotEmpty,
      'TMDB_TOKEN is empty. Copy env/dev.example.json to env/dev.json, '
      'add your token, and run with --dart-define-from-file=env/dev.json',
    );
  }
}