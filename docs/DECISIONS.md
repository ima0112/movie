# Design decisions — Movie & TV show catalog app

Status: conceptualization closed, no code yet. Date: 2026-09-08.

---

## 1. Purpose and constraints

| Decision | Detail |
|---|---|
| Goal | Portfolio app. Public GitHub repo. Must demonstrate professional-quality mobile development. |
| Platforms | iOS and Android, mobile only. |
| Framework | Flutter. |
| Architecture | Clean Architecture with a *feature-first* organization. |
| Backend | None of our own in the first versions. Firebase (managed) only for the Matcher. A custom BFF on Azure remains an optional future phase. |
| Value proposition | "Discover what to watch tonight: explore, save, and decide as a group." |

### Store publishing
- Google Play: one-time $25 registration.
- App Store: requires the Apple Developer Program ($99/year; verify current price). There is no free path to publish on the App Store. Alternatives if not paying: TestFlight for invited testers, or installing from Xcode on your own device, plus a demo video in the README.
- **UI localization: done, Spanish and English.** Every feature's presentation layer (`lib/features/*/presentation`, `lib/shared`) now reads its display text from the app's own `AppLocalizations` (`lib/l10n/`, CLAUDE.md rule 15) — ARB files (`app_en.arb`/`app_es.arb`), `context.l10n`, and `MaterialApp.router`'s `locale`. Settings' one Language row still drives both TMDB's content and the UI at once (F11) — one preference, not two. Spanish copy is tuteo, sentence case, matching `docs/SCREENS.md`'s own short tone; `PakoTV`/`Pako`/`TMDB` are never translated. Dates/numbers go through `intl`'s `DateFormat`/`NumberFormat` for the active locale (comma decimal in Spanish), and plurals use ICU (`{count, plural, ...}`), not string concatenation.
  Enforced automatically, not just by convention: `test/l10n/no_hardcoded_display_text_test.dart` scans `lib/features/*/presentation` and `lib/shared` and fails on a hardcoded `Text(...)`/`label:`/`title:`/etc. literal outside a trailing `// l10n-exempt: <reason>` comment (the debug-only design-system screen is excluded wholesale instead); `test/l10n/arb_parity_test.dart` keeps both ARB files' keys and placeholders in sync; `test/app/main_screens_layout_test.dart` mounts Discover/Explore/My List/You in Spanish, on a small device, with the keyboard open and text at 200%, and fails on any `RenderFlex` overflow — the same CLAUDE.md rule 14 checklist, automated.
  Still outside this scope, a known gap: `Country.name`/`countryName()` (`core/domain/entities/country.dart`) returns ~190 hardcoded English country names with no localization — a `domain`-layer rule 15 violation, not yet fixed. TMDB's own required attribution text also isn't written anywhere yet (no row for it in Settings' About section).

### Public repo and secrets
- No API key or Firebase configuration file goes into the repo.
- Keys injected at build time with `--dart-define-from-file` (file in `.gitignore`) and as GitHub Actions secrets in CI.
- `google-services.json`, `GoogleService-Info.plist`, and `firebase_options.dart` in `.gitignore`. The README explains how to create your own Firebase project and get TMDB keys.
- These DO go into the repo: `firestore.rules`, `firestore.indexes.json`, `firebase.json`, and the rules tests.

---

## 2. APIs

### Evaluated
| API | Status | Decision |
|---|---|---|
| TMDB | Free for non-commercial use; ~40 req/s per IP; movies, TV, people, images, multi-language; OpenAPI 3.1 | **Primary source** |
| OMDb | 1,000 req/day; IMDb/RT/Metacritic ratings; movies only, single-person project | **Optional enrichment (v1.2+)** |
| Watchmode | 2,500 credits/month, up to 3 countries; streaming availability with iOS/Android deeplinks | **Dropped**: TMDB exposes the same data (JustWatch) via `/watch/providers` with no extra quota; we only lose deep links into native apps |
| Official IMDb | $150,000 minimum | Dropped |
| Trakt | Free with OAuth; server-side watchlists; no images of its own | Dropped (unnecessary OAuth complexity; cloud sync is out of scope) |

Each drop is documented as a short ADR in `docs/decisions/`.

### TMDB — endpoints per feature
| Use | Endpoint |
|---|---|
| Auth | Bearer token (v4 read access token). Do not use the v3 key as a query string. |
| Image configuration | `GET /configuration` (cache once) |
| "All" home | `/trending/all/week`; `/discover/movie` + `/discover/tv` with the taste profile (For you, Because you like X) |
| Movies home | `/movie/now_playing`, `/trending/movie/week`, `/movie/top_rated`, `/movie/upcoming` |
| TV shows home | `/tv/on_the_air`, `/trending/tv/week`, `/tv/top_rated`, `/tv/popular` |
| Unified search | `/search/multi` (returns movies, TV shows, and people with `media_type`) |
| Genres | `/genre/movie/list`, `/genre/tv/list` |
| Explore by genre / engine | `/discover/movie`, `/discover/tv` |
| Movie detail | `/movie/{id}?append_to_response=credits,videos,similar,release_dates,watch/providers` (one call) |
| TV show detail | `/tv/{id}?append_to_response=credits,aggregate_credits,videos,similar,content_ratings,watch/providers`; seasons on demand via `/tv/{id}/season/{n}`. Cast and crew come from `aggregate_credits` (the whole run: cast capped at the first 100 by order, the character/job played most), because `credits` for a TV show is only the latest season's regulars (Law & Order: SVU: 7 cast, no crew) — `credits` stays as the fallback for a show with no aggregate yet. Cost: a long-running show's aggregate is a few MB of JSON (SVU ≈ 2.7 MB). |
| Where to watch | `watch/providers` (JustWatch via TMDB): `flatrate` / `rent` / `buy` by region + `link` to TMDB's /watch page. **"Data from JustWatch" attribution mandatory on every detail screen.** No deep links into apps. |
| Person detail | `/person/{id}?append_to_response=movie_credits,tv_credits` |
| Keywords for vibes | `/search/keyword` (resolve IDs once; fix them in the vibes JSON) |
| Localization | `language` and `region` parameters on every call |

### Implementation notes (`tmdb-network-core` … `tmdb-wrap-up`)
What actually shipped, and where it diverges from the table above:
- **Auth, image configuration, localization**: built as specified —
  `BearerInterceptor`, `TmdbConfigurationService` (caches `/configuration`
  once, falling back to TMDB's own well-known-stable defaults until
  that resolves or if it ever fails), `LocaleInterceptor`. `language`/
  `region` are hardcoded `es-ES`/`ES` everywhere (repositories, the
  interceptor, the family-mode certification filter) — no Settings
  screen exists yet to read a real preference from.
- **"All" home / Movies home / TV shows home**: `/trending/all/week`
  and all 8 `/movie`/`/tv`/`/trending` list endpoints are live, composing
  Discover's hero (interleaved, deduped, capped at 8) and carousels.
  The taste-profile-driven "For you"/"Because you like X" half of "All"
  home is **not built** — `TmdbMediaRepository.getCarouselSection`
  returns an empty list for `forYou`/`becauseYouLike` rather than
  crashing; closing this needs `TasteProfileRepository` injected plus
  the `RecommendationBuilder` domain service F1b still describes as
  planned, not yet started.
- **Genres**: `/genre/movie/list`/`/genre/tv/list` were **not
  implemented** — this app's genre system is served entirely by the
  static `GenreCatalog` (18 normalized genres: TMDB's movie list plus `war`
  and `western`, which it used to drop; `availableFor(type)` says which ones
  a kind of title can use — TV folds `adventure` into `action` and `fantasy`
  into `sci-fi`, as TMDB does, and `tvMembers` names those groups) plus
  `core/data/tmdb/tmdb_genre_mapper.dart`'s hand-maintained TMDB-id
  tables (both directions: id→Genre for mapping API responses, Genre→id
  for building `/discover`'s `with_genres`/`without_genres`). No live
  fetch is needed for anything this app actually shows today.
- **Unified search**: live; a `media_type: "person"` entry is dropped
  (`MediaItem` has no Person case — searching stays movie/TV-only, as
  `MediaRepository.searchMulti`'s own doc comment already said it would
  for now).
- **Explore by genre / engine `/discover`**: live for both `movie` and
  `tv`, via a pure, independently-tested `DiscoverFilter` → query-params
  function (`tmdb_discover_params.dart`). `vote_count.gte` comes from
  `DiscoverFilter.minVoteCount` (default `100`); H8's filter sheet has
  no control for it, so Explore always sends the default. The one real
  caller that varies it is `MatchQuery.voteCountGte` (§5): `200` on the
  first attempt, `50` after relaxation step 4. No certification/
  content-rating filter — see `docs/decisions/family-mode-not-in-v1.md`.
- **Movie/TV detail**: live, exactly the `append_to_response` combinations
  above, one call each. Trailer selection ("official + Trailer + user's
  language → official → Teaser → first available") ended up as pure
  logic on `MediaDetail.trailer` itself (needed two new fields on
  `Video`: `official`, `iso6391`), not something the mapper decides —
  it's domain-level business logic, not a TMDB-shape concern.
- **Where to watch**: live, resolved against the hardcoded `'ES'`
  region. "Data from JustWatch"/"Data from TMDB" attribution is present
  on both D1 (movie detail) and D2 (TV show detail, built in a later
  branch than this stack — see `tv_detail/`). Its own region label
  ("Spain", in gray) is shown now, but its tap (→ H6) is a documented
  no-op — H6 (and B5/Settings itself) isn't built, so there's nowhere
  to push to yet (`where_to_watch_section.dart`'s own `onRegionTap`).
- **Seasons on demand**: `/tv/{id}/season/{n}` → `Episode` mapping is
  built and tested; `MediaRepository.season(tvId, n)` (returning the
  season's own `overview` + its episodes as `SeasonDetail`) was added
  once D2/H4 became real consumers, in the `tv-detail-cubit` branch.
- **Person detail**: `PersonRepository` + its real (`TmdbPersonRepository`)
  and fake implementations, `PersonDetailCubit`, and D3's own screen
  were added in the `person-detail` branch once something finally
  consumed the DTO/mapper/datasource call built earlier. That same
  branch added one new wrinkle: when the primary (user-language)
  biography comes back empty, `TmdbPersonRepository` makes a second,
  explicit English-language call and `PersonDetail
  .biographyIsEnglishFallback` flags it, for D3's own "Biography in
  English" note.
- **Keywords for vibes**: done, via `tool/resolve_vibe_keywords.dart`
  (dev-only, not shipped) — a one-time research script that calls
  `/search/keyword` and `/discover` to measure candidate keyword pools,
  never writing to the app itself. The resolved ids were hand-copied
  into `assets/vibes.json`'s real `keywordIds`; see §5 for the curated
  catalog. No runtime call to `/search/keyword` exists in the shipped
  app.

### OMDb (v1.2+)
`GET /?i={imdb_id}` using the `imdb_id` TMDB returns in the detail. Lazy and cached.

---

## 3. Scope by version

### v1.0 — MVP (what ships to stores)
| # | Feature | Detail |
|---|---|---|
| F1 | Discover (Home) | Three segments: **All** (default) / Movies / TV Shows. At the top, a **headerless hero**: up to 8 large snap cards (330×290, radio 20), each with a reason tag inside ("For you", "Trending", "In theaters", "New season", "Releases mm dd"). Below, standard carousels with a header and "See all". Pull-to-refresh. |
| F1b | "For you"/"Because you like X" recommendations | **Built** (`recommendation-builder` branch), in **all 3 segments**, each filtered to that segment's type. "For you": `/discover` from a usable `TasteProfile` (genres + liked vibes' own genre/keyword rules, vetoes excluded), or — with no usable profile — the library's own positive-affinity genres (favorites/well-rated watches). "Because you like X": a deterministic library seed (favorite or ≥4★, most recently watched, id as the final tiebreak) fed into `/{type}/{id}/recommendations`. Either section hides itself entirely (no empty/generic carousel) with no signal, or below 6 results once posterless items and anything already in the library are excluded. Pure domain service `RecommendationBuilder` (`features/recommendations/domain/`); its own `RecommendationsCubit` loads/retries each section independently of `DiscoverCubit`'s 8 named carousels (CLAUDE.md rule 9) — see §5's own "Recommendations" entry for the full design and its reload triggers. |
| F2 | Explore (search + genres + filters, a single tab) | A real search field up top; at rest, recents and genres as image tiles; while typing, `/search/multi` results with a type badge and client-side segment filtering. Filter sheet (type, genres, year, minimum rating, runtime/status, sort, hide watched) that feeds `/discover`; filters don't apply to text search and the UI says so. A single list screen with filters shown as chips for "See all", genre, and results. |
| F3 | — | Merged into F2. |
| F4 | Movie detail | Full-bleed poster fading to black, centered title and metadata, TMDB rating, tappable genres, Trailer button (opens YouTube via `url_launcher`; embedded player in v1.2), Favorite · Watch later · Watched action row, **"Where to watch" section** (subscription / rent / buy by region, logos, link to TMDB /watch, JustWatch attribution), synopsis, cast, director and writer, similar titles. |
| F5 | TV show detail | Same as movie plus: status (airing / ended), creators, number of seasons and episodes, expandable season list. |
| F6 | Person detail | Photo, biography, filmography (movies and TV). |
| F7 | My List | Favorites, Watch later, Watched. Both media types. Local persistence, no account. Rows with their own metadata (date saved / stars and date watched), swipe to remove and mark, sort-and-filter sheet. |
| F8 | Stats | Movies watched and hours; TV shows watched and estimated hours; top genres; most-watched year. |
| F9 | Onboarding + user profile + taste profile | Welcome → **What's your name? (required: display name and initial color)** → two skippable genre steps. Local `UserProfile { displayName, initialColor }`, editable in You. **No age or gender is asked**: minor protection is handled by the stores (12+/Teen rating declared in the listing), and not collecting age avoids COPPA/GDPR-K obligations. No in-app Family mode toggle in v1.0 — see `docs/decisions/family-mode-not-in-v1.md` (TMDB's `certification` filter only covers `/discover/movie`, not `/discover/tv` or any carousel endpoint, so a toggle could only ever be partially effective). Tastes always editable in You → My Tastes. |
| F9b | You tab | Header with initial and name, My Tastes card, Your Activity card (4 numbers + link to Stats), Recent Rooms (v1.1). Gear icon → Settings. |
| F10 | Surprise me | Individual suggestion using the match engine (see §5). |
| F11 | Settings (screen pushed from You) | Language (es/en) and region — one Language setting drives both TMDB's own content and the app's own interface (`AppLocalizations`, CLAUDE.md rule 15) — one preference, not two. Export My List (JSON), deletions, about + TMDB attribution. No theme row and no Family mode in v1.0 — see `docs/decisions/family-mode-not-in-v1.md`. |
| F12 | States | Skeleton loaders, empty, error with retry, offline notice. |
| F13 | TMDB attribution | Mandatory logo and text in Settings and on the store listing. |

### v1.1
- Group **Matcher** with Firebase (see §6). Movies and TV shows.

### v1.2+
- Embedded trailer player (`youtube_player_iframe`).
- "Only on my platforms" filter in the quiz, with the user's platforms set in My Tastes (F1c). (Explore's own **Platform pills** — a plain browse filter by streaming service in the user's region, `with_watch_providers` + `watch_region`, not tied to My Tastes — are v1.0: see B2.)
- External ratings (OMDb).
- Offline cache for carousels and images.
- Share a title as an image or deep link.

### Out of scope (documented in the README)
- Login / user accounts.
- Cloud sync of lists.
- User reviews.
- Per-episode tracking for TV shows (in v1.0 the whole show is marked watched).
- Cloud Functions or other server-side code.
- Bluetooth / Nearby / Multipeer for the Matcher.

---

## 4. My List, Watched, and taste profile

### `my_list` model
- `UserMediaEntry` (`core/domain/entities/user_media_entry.dart`) — identified by `key` (`MediaKey`: `mediaType` + `tmdbId`), with **non-exclusive** flags `isFavorite`/`isWatchLater` (an entry can be a favorite and watched at the same time) and `watchedAt` (`null` = not watched). No embedded `MediaItem`/`MediaDetail` object — instead a small set of flattened fields, each populated from whichever catalog object a given save site (a My List toggle, Mark as watched, Surprise me's "Add to watch later", or a detail screen's own lazy refresh on reopening) has on hand at write time:
  - `rating` (1–5, optional, only meaningful once watched).
  - `runtimeMinutes` — movies only, from `MovieDetail.runtimeMinutes`.
  - `episodeCount` / `episodeRuntimeMinutes` — TV only, from `TvShowDetail.numberOfEpisodes` / `episodeRuntimeMinutes`.
  - `genres` — from `MediaItem.genres`; feeds Stats' "Genres you watch most".
  - `posterUrl` / `voteAverage` / `year` — from `MediaItem.posterUrl` / `.voteAverage` / `.releaseDate?.year`; power My List's offline row (B4) and H9's Year/TMDB rating sort.
  All are optional/default-empty: an entry saved before a given field existed, or one whose call site didn't have the richer object (e.g. `MediaDetail`) on hand, simply has it unset — never an error, just missing data those callers must expect. The drift table backing this (`UserMediaEntries`) mirrors every one of these directly, plus 3 columns that remain unmapped because `MediaItem`/`MediaDetail` carry none of them at all (`backdropPath`, `voteCount`, `popularity` — see `app_database.dart`, and `docs/TODO_AUDIT.md`'s "Limpieza posterior").
- Marking as watched automatically removes it from "Watch later".
- Marking as watched optionally asks for a rating (1–5) and a date.
- TV shows: marked watched at the whole-show level.

### Effects of "Watched"
- Always excluded from Surprise me.
- Can be excluded from the Matcher by any participant who enables the toggle.
- Feed Stats and the taste profile's implicit signals.

### `TasteProfile`
- Fields: `likedGenres`, `vetoedGenres`, `likedVibes`, `yearFrom`, `yearTo` (null = up to today), `preferredType` (movie / TV show / null = both), `platformIds` (TMDB provider ids), `updatedAt`. Local (same store as `my_list`).
- Uses **our own normalized genres** (Action, Comedy, Drama…) that map to TMDB's movie and TV genres.
- Fed from: (a) optional onboarding, (b) Settings → My Tastes. **Not** fed from the quiz (E2) or the Matcher's questionnaire — see `docs/decisions/quiz-answers-not-saved-to-profile.md`; the quiz asks for vetoes, not favorite genres, so there's no clean mapping back into `likedGenres`.
- Implicit signals from `my_list`: favorites and watched items rated ≥ 4 reinforce genres; items rated ≤ 2 subtract. They never replace the explicit profile, only fine-tune it.

---

## 5. Match engine (`MatchEngine`)

Pure domain service: no Flutter, no Firebase, no direct network access (only the `MediaRepository` interface). Covered by unit tests. Used by both Surprise me (N=1, local) and the Matcher (N≥2, Firebase).

### Reference model
The Movie Matcher website: a short per-person questionnaire and a single answer. **It is not a swipe deck.**

### Questionnaire (`ParticipantAnswers`)
| Question | Aggregation across N people | Translation |
|---|---|---|
| Genres I do NOT want (up to 3) | Union | `without_genres` (hard filter) |
| Vibes I DO want (3) | Union with count (each person who picked it adds weight) | Client-side scoring + `with_keywords` with OR |
| How far back? | Max of the minimums (the most restrictive wins) | `primary_release_date.gte` / `first_air_date.gte` |
| Movie: max runtime | Minimum | `with_runtime.lte` |
| TV show: finished or airing? / max seasons | Restrictive | `with_status` / client-side filter |
| Exclude what I've watched (discreet toggle, not a question) | Union of the lists of whoever enables it | Client-side filter by IDs |

The questionnaire is a widget parameterized by `mediaType` with one conditional step. Rule for adding questions: every question must map to a `/discover` parameter or a scoring term; otherwise it's noise.

### Upfront warning
If the union of vetoes leaves too few genres, a warning is shown before searching.

### Fetching candidates
1–3 calls to `/discover/{movie|tv}` with `sort_by=popularity.desc`, `vote_count.gte=200`, `include_adult=false`, and the hard filters. ~60 candidates.

### Scoring
```
score = Σ(vibes satisfied, weighted by how many people requested it)
      + bonus for vote_average
      + penalty if someone has already seen it (when not fully excluded)
```
Returns `MatchResult { winner, alternatives[3–4], satisfaction {participant → % of their vibes met}, relaxations[] }`.

`satisfaction` allows showing "Perfect match" (everyone at 100%) or "Best compromise: Ana 3/3, Luis 2/3".

### Relaxation ladder (fixed, deterministic order)
1. Drop the least-supported vibe.
2. Widen the year range 10 years back.
3. Raise runtime / season limit.
4. Lower `vote_count.gte` to 50.

There is always a result; the screen states what was relaxed.

### Vibe catalog
- `assets/vibes.json`. **19 vibes on movies, 15 on TV.** Two kinds: the two
  **ambientes** — Feel Good (comedy or family) and Date Night (romance or
  comedy; comedy alone on TV) — are defined by genres, and are meant to be
  pruned by the user's vetoes; every other vibe is a keyword **theme**.
  Themes on both types (12): Superhero, Monster, Gangster, Sports, True
  Story, Gritty, Time Travel, Coming of Age, Dystopia, Survival, Revenge,
  Martial Arts — plus Classic (year ≤1999, rating ≥7.5) = 15 on TV. Movie-only
  (4): Tearjerker, Musical, Indie and Heist, whose TV rule is deliberately
  empty (24, 23, 0 and 21 titles with 100+ votes there); `Vibe.isMeaningfulFor
  (type)` is `false` for an empty rule, so the engine skips it for that type.
  **Fantasy, Future, Explosive and Detective were removed**: each was just a
  genre under another name (Fantasy, Sci-Fi, Action, Mystery/Crime), and
  offering one after vetoing its genre was a contradiction. Each vibe has an
  icon, a name, and a rule per media type.
- **Combination rule**: within a rule, genres are OR'd together and
  keyword ids are OR'd together; the genre group and the keyword group
  are then AND'd (`MatchEngine._filterForVibe` → `DiscoverFilter`, sent
  to `/discover` as `with_genres=a|b` AND `with_keywords=c|d`). A vibe
  with genres but no keywords (or vice versa) just omits the empty
  side of the AND.
- **Curated keyword ids actually shipped** (resolved via
  `tool/resolve_vibe_keywords.dart`, hand-copied into `assets/vibes.json`):
  - `monster`: `1299` (monster), `13031` (creature)
  - `indie`: `281237` (independent film) — movie only
  - `superhero`: `9715` (superhero)
  - `tearjerker`: `9872` (grief), `6564` (terminal illness), `156924` (tearjerker) — movie only
  - `sports`: `6075` (sports)
  - `gritty`: `207268` (neo-noir), `286125` (gritty)
  - `true_story`: `9672` (based on true story), `5565` (biography)
  - `gangster`: `3149` (gangster), `10391` (mafia) — movie only
  - `musical`: `4344` (musical) — movie only
  - `classic` uses no genres or keywords at all: `release_date.lte=1999` + `vote_average.gte=7.5`.
  - `feel_good`, `detective`, `date`, `future`, `explosive`, `fantasy` are genre-only (no keyword search ever found a candidate worth adding).
- **Cult, retired.** No TMDB keyword cleared the volume bar once
  crossed with genres (every real candidate — "cult classic", "cult
  film" — produced too few titles to be worth a dedicated vibe), and
  the one thing it offered beyond genre alone (an older, offbeat pick)
  is already covered by `classic`. Removed entirely rather than
  shipped with an empty or misleading rule.
- **Mind-bending, never added.** Of its candidate keyword terms, only
  "psychological thriller" cleared the pool-size threshold — and that
  reads as a *thriller genre*, not "twisty plot / unreliable reality,"
  which is what the vibe was meant to mean. Adding it under that
  keyword would have mislabeled a genre as a vibe, so it was never
  added to `assets/vibes.json` at all (it only ever existed as a
  candidate in `tool/vibe_search_terms.json`).
- **Fantasy, movie only.** TMDB's TV side has no standalone Fantasy
  genre — `10765` is "Sci-Fi & Fantasy," the same id as this catalog's
  own `sci-fi`. Giving `fantasy` a TV rule would mean vetoing it also
  vetoes `sci-fi` (see Paso 4 finding below), so its TV rule is
  deliberately left empty; it only resolves on movie, where `14` is
  its own distinct TMDB id.

### Surprise me (N=1)
First tap: movie or TV show? Then (`SurpriseCubit`, via
`TasteProfileBuilder.build`), in order:
1. **A usable `TasteProfile` exists** (`TasteProfile
   .isUsableForSuggestions`: at least one liked vibe **or** one
   favorite genre — vetoes and `yearFrom` alone don't count, since a
   profile with only vetoes has nothing positive to search for) →
   `ChooseSource` (H11) offers "Use my tastes" or "Answer the quiz
   instead." Choosing "Use my tastes": the profile is used directly,
   refined with `my_list` signals, excludes watched items, result in
   one tap.
2. **No usable profile, but `my_list` has ≥ 5 items** → a provisional
   profile is inferred entirely from those signals. This also reaches
   `ChooseSource` (H11), labeled "Based on your list" instead of
   "Based on your tastes," with the same "Use my tastes" / "Answer the
   quiz instead" choice — not a separate immediate result, and no
   "link to save it" (there is nothing built that would save an
   inferred profile).
3. **Neither** → straight to the guided quiz (same steps as the
   Matcher, `QuizCubit`), no `ChooseSource` step. Quiz answers are
   never saved back to the profile — see
   `docs/decisions/quiz-answers-not-saved-to-profile.md`.

Surprise me uses `SurpriseEngine` (next section) — five different suggestions per batch, never repeating what its session, or the last 30 days of history, already showed.

### Surprise me engine (`SurpriseEngine`)

Replaces the single-page, popularity-only pick above (which always returned the same five: it called `/discover` page 1 only and "randomised" among the top 5 of a deterministic ranking). Five suggestions per batch, no AI, only TMDB. Domain contract in `features/match_engine/domain/` (`SurpriseRequest`, `SurpriseBatch`, `SurpriseEngine`); `MatchEngine` stays as is for the Matcher (v1.1).

- **Hard filters, never broken**: vetoes (`without_genres`), platforms (`with_watch_providers` OR'd with `|` + `watch_region` from Settings → Region; **none chosen = "All platforms" = any service of the region** — `watch_region` + `with_watch_monetization_types` without a provider list, so a title available nowhere in the region is never suggested; measured on movies in ES with 150+ votes: 18,320 with no availability filter, 9,751 by subscription on any service, 13,044 with rent and buy; TV in ES: 3,299 → 2,168), years (from/to), movie max runtime, TV status (finished), "exclude what I've watched" (local), a quality floor (`vote_count.gte` ≈ 150, `vote_average.gte` ≈ 6.0). `with_watch_monetization_types=flatrate` is always sent (with or without platforms); "include rent and buy" adds `rent|buy` — also with "All platforms". Verified live: TMDB caps `page` at 500; `with_status=3` works; no HTTP cache sits in front of Dio.
- **Soft signals, only order**: vibes (genres/keywords of the 16-vibe catalog, 11 on TV), taste (liked genres, history), Bayesian rating `(v·R + m·C)/(v + m)` (C from the candidate set itself), small noise with a per-batch seed.
- **Candidates**: one query per chosen vibe (max 3) plus one general query (the source of the "wildcard outside your tastes"); the first call reads `total_pages`, then 2–3 random pages per query with a bias to the first ones (`page = 1 + floor(min(total_pages, 25)·r²)`), alternating `popularity.desc` and `vote_average.desc` (the latter always with a vote floor). 40–60 unique candidates after removing watched, shown-this-session and shown-recently.
- **Selection**: weighted sampling without replacement from the top ~20; at most 2 of the same main genre, at least 1 per chosen vibe, 1 wildcard. "% for you" = the score scaled to 60–98, relative to the batch.
- **Other 5 / redo**: a `sessionId` and the set of shown ids; a new seed and unused pages. A redone questionnaire also skips the last 30 days of history. History = drift table `surprise_history` (schema v12: `tmdbId`, type, `sessionId`, `shownAt`, **`batch`** — 1 for the first five, 2 after one "other 5"… —, **`genres`** — comma-separated ids, so the engine can learn from a row without another request —, and the outcome) behind `SurpriseHistoryRepository`; local only, wiped by "clear my data", never written into the taste profile.
- **Few results — relaxation ladder** (stops at 15 candidates): lower `vote_count.gte` to 50 → drop the vibes → widen the year **lower bound** 10 years back (and say so). **Never** relaxed: vetoes, platforms, runtime, the upper year. Still too few → a "few options with your platforms" state (not designed yet) offering to widen them.
- **TV genres** (as built): TMDB's TV list has no Horror, Romance, Thriller, History or Music, merges Action & Adventure (10759) and Sci-Fi & Fantasy (10765), calls War "War & Politics" (10768), and id 37 is *Western*. `TmdbGenreMapper` keeps one table per type. **The five missing genres stand in as keywords**, for liking and for vetoing (approximations, not flagged to the user): Horror 315058, Romance 9840, Thriller 316362, History {period drama 15060, historical 15126, history 282633} (156 series with 100+ votes) and Music {music, musical, singer, singing competition, musician, band, music industry, concert} (64; it also leaves Talk, 10767, out). **A like** by stand-in cannot share a request with TV's real genres (TMDB would AND `with_genres` and `with_keywords`), so `discoverQueryParamSets` makes up to three queries — native genres, stand-ins, Music — which `TmdbMediaRepository._discoverTvPage` runs together and weaves into one page, repeats dropped; a filter that already has a vibe's `withKeywords` leaves the stand-ins out (they would be OR-ed into the same parameter). **A veto** uses `without_genres` / `without_keywords`, so it never needs a union. **Combined TV genres**: liking Adventure or Fantasy asks for the combined id, but **vetoing needs every member** (`GenreCatalog.tvMembers`): vetoing Fantasy alone leaves Sci-Fi & Fantasy in, and Action alone leaves Action & Adventure in.
- **Genre lists by kind** (as built): `GenreCatalog.availableFor(type)` — 18 for All/Movies, 16 on TV — drives Explore's pills, H8's chips and the quiz's step 1; `chipsOf(type, genres)` folds Adventure into Action and Fantasy into Sci-Fi on TV (switching segment or kind remaps what was picked, never dropping it). Labels read "Action & Adventure", "Sci-Fi & Fantasy", "War & Politics" only where the list is TV-only. In the quiz a TV combined chip vetoes all its members and counts once toward the cap of 3. My Tastes and onboarding stay type-agnostic (18). A title's own genres (detail, cards) keep the plain names.
- **Talk and News stay out of what we suggest** (as built): TMDB's TV "Talk" (10767) and "News" (10763) are formats (The Tonight Show is Comedy + Talk, The Daily Show News + Comedy), so they used to slip into any Comedy query. `DiscoverFilter.excludeTalkAndNews` adds both to `without_genres` on TV; it is set by Home's recommendation sections, Surprise me and the match engine, **never by browsing** (Explore, H8, "See all"), where they remain findable. No effect on movies.
- **Collections catalog** (as built, 1/3): `assets/collections.json` → `CollectionCatalog` (pure domain, `core/domain/entities/collection*.dart`). 12 collections: **world** — Turkish, Spanish, Latin American, K-dramas, British series (TV), Spanish-language cinema, Korean cinema and **Bollywood** (movies: Hindi-language films *or* films from India — one collection, two queries, merged; there is no separate "Indian cinema"); **formats** — Soaps (TV: the `telenovela` keyword **or** the Soap genre, any country), Anime (Animation + Japan, both kinds), Reality shows (TV `with_type=3`); **occasion** — Kids (movies: **Family required** (AND), without Horror/Thriller/Crime, **rated PG or below** — `certification.lte=PG` on the **US** scale, so a title with no US rating is left out; the first version took Family *or* Animation and let adult anime in (Demon Slayer, Chainsaw Man), TV has no rating at TMDB; TV: the Kids genre; `inTastes: false`, so it is a suggestion collection only). A collection has a rule per kind of title (`null` = doesn't exist there) made of one or more `CollectionQuery`s whose results are unioned; fields inside a query AND together, values inside a field OR. Country series exclude Talk/News (K-dramas Reality too); vote floors are 100 except Turkish and Soaps 30, Spanish series and Reality 50. A new collection is a new JSON row. **Querying** (2/4): `DiscoverFilter.collection` (counts as one active filter); `discoverQueryParamSets` multiplies the filter by the collection's queries — and, since TMDB cannot AND two `with_genres`, by genre pairs (`with_genres=16,35`: Anime + a picked Comedy; Kids' Family|Animation × a picked genre) — and returns **no queries** for a kind of title the collection doesn't exist on, so in "All" only the kinds that have it contribute. The repository runs those requests together for movies as it already did for TV and weaves one page, repeats dropped. A section's own vote floor above the default (Top rated: 300) beats the collection's; the default gives way to it (Turkish: 30). Known limit: a collection keyword (Soaps' "telenovela") plus a picked genre that TV stands in for by keyword (Horror…) can't share `with_keywords`, so that query drops and the Soap-genre one carries the result. **Where the user picks one** (3/4, as corrected): **not on Explore's page** (no pill row — it would push the sections down) but in the **filters sheet (H8)**, a single-select "Collection" section for the kind of title (`FilterCollectionChips`), dropped when the kind changes to one that lacks it, shown as a removable chip in C1. Labels live in `CollectionLocalization` (a runtime switch with a test over every catalog id). **My Tastes** (4a): `TasteProfile.likedCollections` (ids, schema v14, migration adds the column), a "Collections you like" section (all but Kids, no cap), counted in Settings' "delete tastes". Not yet read by the engine or Home. **Engine** (4b-1): `ParticipantAnswers.collectionIds` (at most 2, hard filter, never relaxed — every relaxation step keeps it). Surprise me runs a set of queries (generic + one per vibe) **per chosen collection** and unions them; a collection that doesn't exist for the kind of title is ignored; its vote floor (Turkish 30) replaces the engine's 150 and the rating sort (300 votes) is skipped. A collection keyword (Soaps' "telenovela") and a vibe's keywords are ANDed pair by pair (`with_keywords=199262,1299`, up to 8 pairs). The Matcher (v1.1) doesn't read collections. **What each quiz step offers** is pure (`features/quiz/domain/quiz_options.dart`): a collection hides from the veto list the genres it requires (Kids: Family, Animation) or already excludes (Horror, Thriller, Crime), a vibe is offered only if one of its genres is neither vetoed nor excluded (Kids loses Gritty), and changing the collection prunes what became invalid without a word. **Quiz** (4b-2): 5 steps — collections (optional, one at most) → genres to skip → vibes → platforms → years; the lists of steps 2 and 3 come from `QuizOptions` through `QuizCubit.vetoOptions`/`vibeOptions`, and choosing or changing a collection, or skipping a genre, prunes in silence whatever stopped being valid; **every step is optional** (collections, genres to skip, vibes: up to their caps, or none; the later lists follow whatever was picked), and **going back clears what the step you leave had collected** (back from the vibes empties the vibes) while the earlier steps' answers stay. `SurpriseCubit` loads the collection catalog only when the answers name one. **Using the tastes** (4b-3): a liked collection (never Kids) shares Home's All-tab "Because you like …" slot with the liked genres (`CollectionSeed`, picked day by day like the rest: `DiscoverFilter(collection:)` with the user's vetoes, eras and no Talk/News, for every kind of title it exists for); it does not feed "For you". `TasteProfile.isUsableForSuggestions` counts liked collections, and "Use my tastes" hands them all to Surprise me as `collectionIds` (the engine keeps those that exist for the kind of title, up to 2). Movies/TV Shows tabs still follow My List only.
- **Details of the 5 chosen only**: one `/{movie|tv}/{id}?append_to_response=watch/providers` call each (runtime or seasons, tagline, providers); a failed one is replaced by the next candidate.
- **Dropped**: "Max seasons" (not in the new questionnaire; it would need a detail call per candidate) — removed from the engine when the new one is wired.
- **As built** (`features/match_engine/domain/`: `surprise_candidates.dart`, `surprise_scoring.dart`, `surprise_engine_impl.dart`): score = vibes matched / vibes chosen (×1.0) + taste (×0.25, normalised over the candidates, from `SurpriseRequest.genreAffinity`) + quality (×1.0: the Bayesian rating with a prior of 150 votes, 5.0→0 … 9.0→1) + noise (×0.15). The five are drawn with weight `score³` from the top 20 after: one per chosen vibe, one wildcard outside the liked genres (only when there are any), max 2 per main genre. The taste weight was tuned on a synthetic catalog: 0.8 and 0.5 put 80% of a batch in the one liked genre; 0.25 gives ~60% against ~20% of the catalog. Titles with no poster are dropped. Detail calls go with the request's region; a failed one is replaced by the next-best candidate (2 rounds).
- **History outcomes and what they mean** (`SurpriseOutcome`, weakest to strongest; a later one never replaces a stronger one): `viewed` (only shown, neutral), `rerolled`, `revisited` (the card came back, its detail was opened or it was lingered on 3 s or more — weakly positive), `saved` (to Watch later — medium), `chosen` (double tap / "Choose this" — strong). **Passing a card is never recorded as a rejection.** `rerolled` is a *fact*, not a verdict: "other 5" was asked and nothing in that batch was saved or chosen; its cards still `viewed` get it (revisited ones keep their signal). It carries **weight 0** until real data says what it means — the user's own answers shaped the batch, so penalising its genres would fight those answers and feed a loop. The v11→v12 migration renames `shown`/`discarded` → `viewed`, `seen` → `revisited`.
- **The engine learns from the history** (`SurpriseHistoryAffinity`, added to the taste the cubit already builds from My List and the profile, read at **each** search so a pick in this very session counts for the next batch): every shown card adds its outcome's weight to each of its genres — **chosen +6, saved +4, revisited +2, viewed 0, rerolled 0** — scaled by age (half after 45 days, ignored past 180) and capped at **+8 per genre** so a run of picks can't take the batch over. Nothing in the history is ever negative: passing records nothing and a rerolled batch weighs 0. It stays a soft signal (the taste term is ×0.25 of the score, and the wildcard rule still brings one title from outside the liked genres).
- **The deck's state** (`SurpriseCubit`, no separate Bloc: the PDF's events are its methods): the result is a **circular deck** — `next()` (after the last card, the first; with one card nowhere to go), `toggleSaved(key)` (the card's Watch later button: in → out or out → in, keeping what the library already has on the title — a favorite or a watched date stays, an entry left in no list is deleted; saving records `saved`, taking it out does not undo that), `save()` (the accessible Save control: stays on the card, idempotent), `jumpTo(i)` (a thumbnail), `choose()` (saves it by itself, records `chosen`, and moves to `SurpriseChosen`, once even on a double call), `reroll()` ("other 5": same session and answers, a new seed; the deck stays under "Searching" and **comes back** with a `SurpriseNotice` — offline, or nothing new — if the ask fails or finds nothing, and the batch before is marked `rerolled` only once a new one arrives), `closeDeck()`, `noticeShown()`. Saves are optimistic and go back if the write fails. A card counts as `revisited` when it comes back to the top (the deck cycles, a thumbnail) or stays there 3 s. Cards already in Watch later show as saved from the start; a widened search is announced with a notice, once.
- **Gestures** (`SurpriseDeckStack`): the top card follows the finger with a turn proportional to the drag; **either way** past a third of the width (or a flick above 700 px/s) = pass (no buzz; left and right do the same), a short drag springs back (250 ms); exit 220 ms; **double tap** = choose (medium buzz), **tap** = turn the card over to its back and again to the front (it waits ~300 ms to tell them apart; the full detail is only reachable from the closing screen's chosen card, and turning to the back records `revisited`); with one card dragging is off. There are no edge arrows while dragging (they only appear in the first-time tour's first step); the cards span the page margin to page margin. The first-time tour (3 steps: swipe, tap to turn over, double-tap to choose) shows once over the deck; "Skip" and "Got it" both set its "seen" flag, a `LocalFlagsRepository` flag (`surpriseTourSeen`; drift table `local_flags_table`, schema v13), and it is never replayed; there is no help line under the deck. With reduced motion nothing turns or flies and the hint's rings are still.
- **Where to watch, per card**: `WatchProviders` now carries each service's TMDB id; `platformsFor` lists, for a suggestion, the services it is on that the answers accept — included in a plan, plus rent and buy when asked — and, when platforms were picked, only those (up to three logos and "+N" on the card).
- **Wired into `SurpriseCubit`**: each fresh ask (tastes used or quiz answered) opens a session; the batch is the pool E3's "Another suggestion" walks ("Add to Watch later" is recorded as `saved`, "View details" as `revisited`; passing records nothing; asking for a new batch marks the one before as `rerolled` when nothing in it was picked); "Search again" after the fifth asks for a new batch of the same session, which skips everything shown. An empty batch is "Couldn't find a match" on a first search and "That's all for now" after earlier batches. The profile's platforms and latest year now travel in the answers; "Delete Surprise me history" in Settings → Data wipes the table. The old `MatchEngine` stays for the Matcher (v1.1). "Max seasons" never filtered anything in the old engine (only a relaxation step used it) and is ignored by the new one; its stepper stays in the quiz until the new questionnaire replaces it. Titles with no poster sink below those with one instead of being dropped (a card needs a poster, but the fake catalog has none).
- **Stack**: (1) domain contract, (2) drift history, (3) data layer (TV genre map, keywords, monetization, random pages), (4) the engine + tests, (5) wired into `SurpriseCubit` ("Another suggestion" rotates the 5, "Search again" fetches a new batch).

### Recommendations ("For you" / "Because you…", B1 F1b)

Two pure domain pieces (`features/recommendations/domain/`): **`RecommendationPlanner`** decides *what each section is about* for a segment and a day, and **`RecommendationBuilder`** only cleans up what TMDB returns (drops posterless items and anything already in My List; fewer than 6 left → the section hides). It is not `MatchEngine` (built to resolve one N≥1 answer), but reuses `Vibe.genresFor`/`.keywordIdsFor` and `genreAffinityFrom`.

**Variety without AI — `DailyPicker`.** A deterministic, weighted rotation: candidates are served in *cycles* (a shuffled order of every candidate, a candidate of weight *w* appearing *w* times, one per day), so everything comes up before anything repeats, heavier candidates more often, and the same candidate never shows two days running when there is an alternative (also across cycle boundaries). The shuffle depends only on the cycle number and the slot, so the same day gives the same pick (reopening or refreshing never reshuffles) and a new day gives the next one. **Nothing is persisted** — the sequence is recomputed from the date, so there is no "once a day" job, no storage and no background work; when tastes or My List change, the rotation follows them. No network is involved in choosing: TMDB is only called for the chosen request, and only if it differs from what the slot last fetched.

**The same shuffle for a few static lists.** `DailyPicker.shuffled` (core/domain/services) also gives a day-stable order to lists whose top never moves: B2's *Popular* and *Hidden gems* and B1's *Finished shows* show 10 of the 20 titles of TMDB's page, shuffled by the date. *Top rated* is a ranking and keeps its true order; sections that move on their own (trending, date windows) are untouched.

**All → the taste profile only** (no usable profile → none of the three sections, whatever My List holds): *For you* = a `/discover` mixing up to two liked genres/vibes (vetoed genres excluded), preferring ones the other two sections aren't using; *Because you like {genre}* = one liked genre; *Because you want {vibe}* = one liked vibe, with the vibe's own keywords and limits (e.g. Classic's year and rating). The genre and vibe sections use `/discover`, not `/recommendations`.

**Movies / TV Shows → My List only** (the taste profile is ignored there): *For you* = a `/discover` of that type from up to two genres with positive signal (`genreAffinityFrom`: favorites and ≥4★ watches), with the genres rated badly excluded; *Because you like {title}* = one saved title fed into `/{movie|tv}/{id}/recommendations`. **Seed weights**: favorite 3, rated 5★ 3, rated 4★ 2, Watch later 1 (an unwatched title). **Never a seed**: watched and rated ≤3★ (even if also in Watch later), or watched with no rating and not a favorite — there is no evidence they liked it.

**`RecommendationsCubit`** (`features/recommendations/presentation/cubit/`) — separate from `DiscoverCubit` — has three independent slots (`forYou`, `becauseYouLike`, `becauseYouWant`) with their own loading/error/`retry(slot)`. It recomputes the plan locally on each trigger and refetches only the slots whose request changed.

Reload triggers — exactly 3: (1) language/region change, (2) pull-to-refresh, (3) returning from a pushed detail screen (`RouteAware.didPopNext`). Switching *bottom tabs* does **not** reload (the shell keeps the branch alive, with no lifecycle event to hook) — a known, accepted gap, so a day change is picked up on the next trigger or app start.

---

## 6. Group Matcher (v1.1)

### Transport
**Firebase**, chosen over Supabase, "deterministic deck + QR", and Bluetooth/Nearby. Reasons: cross-platform iOS↔Android, real time, works remotely, free tier is enough, no server code. Bluetooth was dropped because there's no interoperable P2P between iOS (Multipeer) and Android (Nearby), and plain BLE in Flutter is a protocol project in itself.

### Firebase products
| Product | Use |
|---|---|
| Anonymous Auth | Ephemeral per-device `uid` for security rules. No sign-up. |
| Firestore | Rooms, participants, answers, result. Chosen over Realtime Database for more expressive rules. |
| App Check | Ensures only the app can write to Firestore. Mandatory with a public repo. |

Out: Cloud Functions, Analytics, Crashlytics (optional later).

### Flow
1. Host creates the room and **picks movie or TV show** (step 1, before sharing).
2. A 6-character alphanumeric code with no ambiguous characters (no 0/O, 1/I) is generated, plus a QR that encodes the universal link `https://pakotv.app/r/{code}` (opens the app at F2; without the app, a static page with store links). Requires a domain with `apple-app-site-association` and `assetlinks.json` (static hosting, e.g. Firebase Hosting).
3. The others join with the code or QR and give their name.
4. Each participant answers the quiz on their own phone (with a "Use my tastes" button that fills it in from `TasteProfile`).
5. The waiting room shows who's done. **Maximum 6 participants** (match quality, wait time, readability of the satisfaction row, listener cost). After 60 s with everyone but one done, the host can "Search without waiting" for that participant.
6. Once everyone has answered, **the host's phone runs the engine locally** and writes the result.
7. Everyone sees **a single movie/show**, the same for all: "It's a match!".
8. **Only the host** can tap "Find another"; it rotates to the next alternative. Others see "X can ask for another option".
9. Exits: "Add to Watch later" (local, per person) and "We've seen it".

### Firestore model
```
rooms/{code}
  hostUid, hostLastSeen, mediaType: movie|tv, status: answering|resolved
  createdAt, expiresAt (24 h), maxParticipants: 6
  excludedUids?: [...]        ← participants left out of the calculation via "Search without waiting"
  result?: { winnerId, alternativeIds[3-4], satisfaction{uid: n}, relaxations[] }
  participants/{uid}
    name, joinedAt, finishedAt?
    answers?: { excludedGenres[], vibes[], yearFrom, maxRuntime|tvFilter, excludeWatched }
    watchedIds?: [...]   ← only if excludeWatched was enabled; capped at 500
```

Decisions:
- A single writer for the result (the host), N readers. Prevents each client from computing a different winner due to variations in TMDB's ordering.
- `alternativeIds` is stored (4 integers) so "Find another" survives the host closing the app. **Never shown** to anyone.
- Only IDs in Firestore; details are fetched from TMDB by each client (respects TMDB's terms, keeps Firestore lightweight).
- Writes per 5-person session: ~15.

### Security rules (summary)
- Create room: authenticated, `hostUid == request.auth.uid`.
- Read room: any authenticated user who knows the code.
- `mediaType`, `status`, `result`: host only; exception: any participant may write `result` if `hostLastSeen` is more than 2 min old and all non-excluded participants have answered (host handoff for that search only).
- `participants/{uid}`: only that uid can write to it.
- Expired rooms: reads and writes rejected. Firestore TTL policy on `expiresAt` for automatic deletion.
- Nothing is deleted from the client.
- Rules tested with the Firebase emulator in CI.

### Quota
Spark plan (~50k reads / ~20k writes per day; verify when configuring). Guardrails: max 6 participants, 24 h TTL, App Check, `watchedIds` capped at 500.

---

## 7. Code architecture

### Principles
- All network calls go through a single `ApiClient` configured with a base URL and per-environment headers. UI and repositories never build TMDB URLs themselves.
- Custom domain models; TMDB DTOs never reach the UI. Mapping lives in the data layer.
- Per-environment config via `--dart-define`.
- Abstracted pagination (`Page<T>`) — **not built yet**: `MediaRepository`'s list methods return TMDB's own first page only; see `docs/STRUCTURE.md`'s "Technical decisions" table for why and what closing it needs.
- These four rules are what makes it possible to insert a BFF later by only changing the base URL.

### Feature-first structure
Real tree (see `docs/STRUCTURE.md` for the authoritative, actively
maintained version — this is a summary, not a duplicate source of
truth):
```
lib/
  core/            networking (ApiClient), theme, localization, persistence, config
  shared/          common widgets (media card, skeletons, states)
  features/
    discover/        F1 Discover home
    explore/         F2 search + genres + filters (merged search/genres, see F3)
    filtered_list/   the "See all" / filtered results list F2 pushes to
    movie_detail/
    tv_detail/
    person_detail/
    my_list/
    stats/
    onboarding/      welcome + name/color + 2 genre steps
    taste_profile/   TasteProfileBuilder (domain)
    my_tastes/       Settings → My Tastes screen (presentation)
    quiz/            quiz widgets → ParticipantAnswers
    match_engine/    pure domain: MatchQuery, MatchResult, MatchEngine, vibes, relaxation
    match_hub/       B3 hub sheet opened from the center tab-bar button
    suggestion/      Surprise me (E1/E2/E3)
    recommendations/ RecommendationBuilder (domain) + RecommendationsCubit
                     + the "For you"/"Because you like X" section widgets (B1 F1b)
    you/             F9b You tab
    settings/        F11
    debug/           dev-only design-system preview screen, not shipped
```
`streaming_availability` and `external_ratings` are added in v1.2 as
new features without touching existing ones. The Matcher (v1.1) adds a
`matcher/` feature (rooms, Firebase, QR, waiting room, group result) —
not built yet.

### Domain model (to be defined in the next step)
`MediaItem` (abstraction over `Movie` and `TvShow`), `Person`, `Genre` (normalized), `Vibe`, `UserMediaEntry`, `TasteProfile`, **`UserProfile { displayName, initialColor }`** (local, with `UserProfileRepository`), `ParticipantAnswers`, `MatchQuery`, `MatchResult`, `MatchRoom`.

### Repository contracts (to be defined)
`MediaRepository`, `UserLibraryRepository`, `TasteProfileRepository`, `UserProfileRepository`, `MatchRoomRepository`, `PersonRepository` (added once D3 was built — see §2's implementation notes), `OnboardingRepository` (added in the `onboarding-gate` branch, ahead of A2's own real screen — `app/router.dart`'s top-level `redirect` already sends every route to `/welcome` until it's `true`, and `/welcome` is a placeholder until A2 is built for real).

---

## 8. Future path: BFF on Azure (optional)

- A minimal proxy (Azure Function or Container App with scale-to-zero) that holds the keys, caches, and normalizes TMDB/OMDb/Watchmode into the domain model.
- Gradual migration per endpoint thanks to the configurable base URL.
- Matcher rooms could migrate from Firebase to a custom WebSocket/SignalR; that "Firebase → Azure" ADR tells the DevOps story.
- The only debt accepted during the mobile-only phase is the TMDB key living in the client, documented as a conscious decision.

---

## 9. Visual system

| Decision | Detail |
|---|---|
| Name | **PakoTV**. |
| Reference | Howdy (Roku): black background, posters carry the color, one accent, hierarchy through size, brand halo in the header. Its palette and letterboxed thumbnails are not copied. |
| Mode | **Dark by default**; light as an alternative (designed later). |
| Tokens | `surface #0B0B0D` · `surfaceRaised #161618` · `ink #F5F5F7` · `inkMuted #A1A1A8` · `accent #F2B441` (amber) · `accentDeep #5A3A10` (halo source) · `onAccent #1A1204` · `success #6FCF97` · `danger #FF6B6B`. |
| Where the accent is used | Wordmark ("TV"), "See all" links, selected states, "For you" tag, Match button, full-bleed background of the match result. Nowhere else. The active tab in the bar is white. |
| Halo | The only gradient allowed: radial from `accentDeep` to `surface`, in the Discover header and on the welcome screen. |
| Typography | One geometric sans (Manrope or Satoshi), weights 400/500. Section 20/500, detail title 32/500, hero 26/500, metadata 13–14/400. |
| Spacing | 20 px margins; 32 px between sections; 110×165 posters with 12 px gaps, 3.2 visible; no borders or shadows; 12 px radius. |
| Buttons | Primary: white pill with black text. Secondary: pill with a thin gray border. Never two primaries. **Accent** (`AccentButton`): an amber pill with near-black text, always on one line (never taller), only as the single call-to-action of B1's taste card — not a second primary, never next to one. |
| Bottom bar | **Four tabs** (Discover, Explore · My List, You) and a **60 px amber circular button raised 14 px in the center with Pako's face**, which opens the Match hub as a modal from the bottom. White dot on the button if a room is active. |
| Pako | **Dropped as an in-app icon** (the Match button is a sparkle, empty states use icon badges, the assets are gone); the name PakoTV stays. Original idea — Mascot: a rounded TV set with two antennas, short legs, and a face on the screen. Off (outline, no face) = logo. A single `.riv` file with a state machine: `powerOn`, `mood` (neutral/searching/celebrating/asleep), `yearSlider`, `idle`. |
| Rive | Only where the animation IS content: splash, empty states, "Searching…", match/Surprise me result, quiz step 3. Micro-interactions stay native Flutter. Runtime `rive` 0.14 (native C++), `RiveNative.init()` at startup. |
| Splash | **One splash.** The native one is only the page's dark color (`#0B0B0D`, no logo; Android 12+ gets a transparent icon because its system splash can't be removed), so it never shows a second logo; the in-app splash (the "P" monogram over the amber halo, the wordmark unfurls ~500 ms, then ~400 ms to slide up into Home) is the only one the user sees. Max 1.5 s of animation; not shown on warm starts. The preload starts in `main()` before the first frame, while the system still shows the native splash. (The original design — native Pako "off" → Rive Pako "on" — went away with the mascot: the two different logos read as two splashes.) |
| Welcome screen | Poster wall from `/trending/all/week` dimmed to 55% with slow vertical drift, fade to black, halo, Pako in `idle`, headline, one line, "Get started", TMDB attribution. Offline: same wall with placeholders. |
| Home hero | No header; the reason lives inside the card. Fixed amber halo in v1.0; halo dynamically colored from the poster as a v1.2 experiment. |

## 10. Next step
Movie detail screen.

### Offline detection (no connectivity plugin)

The app is "offline" when the **last TMDB request could not reach the server** (a connection error or timeout), and online again with the next request that gets any HTTP answer. `NetworkStatusInterceptor` (in the one `ApiClient`) reports each request to `NetworkStatus`; the global `ConnectivityCubit` mirrors it for the offline banner. Chosen over `connectivity_plus` to add no dependency: it reflects what matters (can we reach TMDB?), not whether a radio is on. The cost: it only notices once a request fails, and it doesn't retry by itself when the connection returns — the screens' "Retry" does.

- **Text matching ignores accents and case** (`core/domain/text/search_text.dart`: `foldForSearch`, `matchesSearch`, `equalsSearch`): whatever the app filters or ranks by a typed name itself — the region sheet, the full cast/crew search, the platforms picker, B2's "exact person name first" rule — compares the folded texts, so "jose" finds José, "espana" España and "zoe saldana" Zoë Saldaña (á→a, ñ→n, ç→c, ö→o, ß→ss…, and accents typed as separate characters). TMDB's own `/search/multi` already ignores accents, so the query is sent as typed.
- **Platform lists** (as built): Explore's pills, H8's streaming chips and the quiz's grid ask `MediaRepository.streamingServices` for **12** services of the region (storefronts left out), the user's **own services (My Tastes) first** — in the region's order inside each group, so one ranked 17th still shows — then the best to fill the cap. The ranking is the region's (`display_priorities`), not the global one. Before, Explore took the top 8 and only *reordered* those, so a chosen Peacock never appeared; C1's chip names now come from the full list. Explore reloads its pills when the user's services change.
- **Collections vs. genres, kept coherent** (as built): `CollectionGenres` says which genres a collection requires (Anime: Animation; For kids: Family) or excludes (For kids: Horror, Thriller, Crime). **My Tastes**: a collection needing an avoided genre can't be liked and a genre a liked collection needs can't be avoided (dimmed and inert, both ways — otherwise the profile's own query comes back empty). **H8**: a genre the picked collection excludes can't be picked, and picking the collection drops one already picked (with All, only what it excludes on *every* kind counts).
- **TV genres a show can't carry, now inferred** (as built): TMDB's TV list has no Horror, Romance, Thriller, History or Music, so a show's own genres never held them and the library-based taste learning could not see them. A TV **detail** is now fetched with `keywords` appended, and the same keywords that stand in for those genres in a search (`TmdbGenreMapper.tvStandInGenres`, Music not for a talk show) add them to the show's genres — so a favorited horror series counts as Horror, and the detail's genre chips show it. Lists (cards, carousels) still carry only TMDB's genres: no keywords there, no extra request per card.
