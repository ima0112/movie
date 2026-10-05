# movies

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Configuration (TMDB token)

This app talks to [TMDB](https://www.themoviedb.org/) for its catalog data.
No key ships in this repo — you provide your own at build/run time.

1. Create a free TMDB account, then generate a **v4 read access token**
   (not the v3 API key) from your account's
   [API settings](https://www.themoviedb.org/settings/api).
2. Copy `env/dev.example.json` to `env/dev.json` (gitignored) and paste
   your token into `TMDB_TOKEN`.
3. Run with that file: `flutter run --dart-define-from-file=env/dev.json`.

Without a token, run against bundled fake data instead —
`flutter run --dart-define=USE_FAKE=true` — no TMDB account needed.
