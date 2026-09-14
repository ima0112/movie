# Folder structure

## Placement rule

- **`core/domain/`**: entities and contracts used by **two or more features** (`MediaItem`, `Genre`, `MediaRepository`, `UserLibraryRepository`…).
- **`features/<x>/domain/`**: entities and contracts **private to that feature** (`MatchRoom` is only used by `matcher`).
- Each feature has three layers, and dependencies only point inward: `presentation → domain ← data`. `domain` never imports Flutter, Firebase, Dio, or another feature (only `core/domain`).
- `data` implements `domain`'s contracts and is the only place where TMDB / Firestore / SQLite DTOs exist.

## Tree

```
lib/
  main.dart
  app/
    app.dart                      MaterialApp, theme, router
    router.dart                   go_router: routes and deep links
    di.dart                       dependency composition

  core/
    config/
      env.dart                    reads --dart-define (TMDB token, flags)
    network/
      api_client.dart             single HTTP exit point; injected base URL
      interceptors/               bearer auth, language/region, logging
    persistence/
      app_database.dart           SQLite (drift) — user_media, taste_profile, search_history, cache
    localization/
      l10n/                       .arb es/en
    theme/
    domain/
      entities/
        media_type.dart
        media_item.dart           sealed: Movie | TvShow  (list level)
        media_detail.dart         sealed: MovieDetail | TvShowDetail
        person.dart
        genre.dart                normalized genre + TMDB mapping
        user_media_entry.dart
        taste_profile.dart
        page.dart
        result.dart               Result<T> | Failure
      repositories/
        media_repository.dart
        user_library_repository.dart
        taste_profile_repository.dart
    data/
      tmdb/
        tmdb_dtos.dart            generated (json_serializable) — never leave data/
        tmdb_mappers.dart         DTO → entity
        tmdb_media_datasource.dart
      local/
        user_library_local_datasource.dart
        taste_profile_local_datasource.dart
      repositories/
        media_repository_impl.dart
        user_library_repository_impl.dart
        taste_profile_repository_impl.dart

  shared/
    widgets/
      media_card.dart
      media_carousel.dart
      poster_image.dart           uses /configuration for sizes
      skeletons.dart
      state_views.dart            empty / error+retry / offline
      genre_chip.dart

  features/
    discover/
      presentation/               Movies/TV Shows tabs, 4 carousels each
    search/
      domain/                     SearchHistoryRepository (private)
      data/
      presentation/
    genres/
      presentation/
    movie_detail/
      presentation/
    tv_detail/
      presentation/               seasons on demand
    person_detail/
      presentation/
    my_list/
      presentation/               favorites / watch later / watched tabs
    stats/
      domain/                     LibraryStats + calculation (pure)
      presentation/
    taste_profile/
      domain/
        taste_profile_builder.dart   explicit + implicit → ParticipantAnswers
      presentation/               onboarding (skippable) + Settings › My Tastes
    quiz/
      presentation/               genre/vibe grids, year slider → ParticipantAnswers
    match_engine/
      domain/
        vibe.dart
        vibe_catalog.dart         loads assets/vibes.json
        participant_answers.dart
        match_query.dart
        match_result.dart
        relaxation.dart
        match_engine.dart         pure, no Flutter or direct network access
    suggestion/
      presentation/               Surprise me (N=1)
    matcher/                      (v1.1)
      domain/
        match_room.dart
        room_participant.dart
        match_room_repository.dart
      data/
        firestore_room_datasource.dart
        match_room_repository_impl.dart
      presentation/               create / join / waiting / group result
    settings/
      presentation/

assets/
  vibes.json
  tmdb_attribution/
docs/
  DECISIONS.md
  STRUCTURE.md
  decisions/                      ADRs
test/
  core/domain/
  features/match_engine/          engine tests (no network, no Firebase)
  features/taste_profile/
firebase/                         (v1.1) firestore.rules, indexes, rules tests
```

## Technical decisions the structure assumes

| Topic | Choice | Note |
|---|---|---|
| State | `flutter_bloc` | One `Cubit` (or `Bloc` for screens with real event flows) per screen in `presentation/`. |
| DI | `get_it` | Repositories and services registered as lazy singletons in `app/di.dart`; Cubits are created per-screen (not singletons) and pull their dependencies from `GetIt.I`. |
| Navigation | go_router | Needed for Matcher deep links (`app://room/K7PM3Q`) and sharing. |
| HTTP | Dio | Interceptors for bearer auth, `language`/`region`, and logging. |
| Persistence | drift (SQLite) | Typed, migrations, queries for Stats. |
| Models | Hand-written immutable classes in `domain`; `freezed` optional for DTOs | Keeping the domain free of codegen makes it readable in review. |
| Serialization | `json_serializable` only in `data/` | |

If you'd rather choose differently on any row (Isar instead of drift, Provider instead of get_it), the structure doesn't change — only the contents of `presentation/` and `core/persistence/`.
