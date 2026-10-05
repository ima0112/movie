/// Compile-time configuration injected via --dart-define-from-file.
/// Values must be read with `const` + `String.fromEnvironment`; reading them
/// at runtime any other way returns the default.
abstract final class Env {
  static const tmdbToken = String.fromEnvironment('TMDB_TOKEN');
  static const tmdbBaseUrl = String.fromEnvironment(
    'TMDB_BASE_URL',
    defaultValue: 'https://api.themoviedb.org/3',
  );

/// When true, the app runs against FakeMediaRepository (no network, no token).
  static const useFake = bool.fromEnvironment('USE_FAKE');

  static void validate() {
    assert(
      useFake || tmdbToken.isNotEmpty,
      'TMDB_TOKEN is empty. Copy env/dev.example.json to env/dev.json, '
      'add your token, and run with --dart-define-from-file=env/dev.json '
      '(or run with --dart-define=USE_FAKE=true to use fake data).',
    );
  }
}