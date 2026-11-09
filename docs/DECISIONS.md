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
| TV show detail | `/tv/{id}?append_to_response=credits,videos,similar,content_ratings,watch/providers`; seasons on demand via `/tv/{id}/season/{n}` |
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
  static `GenreCatalog` (16 normalized genres, including `fantasy`,
  added in the `vibe-keywords-curated` branch) plus
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
| F1 | Discover (Home) | Three segments: **All** (default) / Movies / TV Shows. At the top, a **headerless hero**: up to 8 large snap cards (330×440, 3:4), each with a reason tag inside ("For you", "Trending", "In theaters", "New season", "Releases mm dd"). Below, standard carousels with a header and "See all". Pull-to-refresh. |
| F1b | "For you" recommendations | In the All segment: a "For you" section and a "Because you like [genre]" section built with `/discover` from the taste profile (explicit + My List signals), excluding vetoed genres and anything already in My List. With no profile: hero shows trending titles and an **invitation card** with Pako ("Tell me your tastes" → My Tastes) instead of "For you". Domain service `RecommendationBuilder`. |
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
- "Only on my platforms" filter (`with_watch_providers`) in Explore and the quiz, with the user's platforms set in My Tastes (F1c).
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
- `UserMediaEntry` (`core/domain/entities/user_media_entry.dart`) — identified by `key` (`MediaKey`: `mediaType` + `tmdbId`), with **non-exclusive** flags `isFavorite`/`isWatchLater` (an entry can be a favorite and watched at the same time) and `watchedAt` (`null` = not watched). No embedded `MediaItem`/`MediaDetail` snapshot — instead a small set of flattened fields, each populated from whichever catalog object a given save site has on hand at write time:
  - `rating` (1–5, optional, only meaningful once watched).
  - `runtimeMinutes` — movies only, from `MovieDetail.runtimeMinutes`.
  - `episodeCount` / `episodeRuntimeMinutes` — TV only, from `TvShowDetail.numberOfEpisodes` / `episodeRuntimeMinutes`.
  - `genres` — from `MediaItem.genres`; feeds Stats' "Genres you watch most".
  All four are optional/default-empty: an entry saved before a given field existed, or one whose call site didn't have the richer object (e.g. `MediaDetail`) on hand, simply has it unset — never an error, just missing data those callers must expect. The drift table backing this (`UserMediaEntries`) mirrors these fields directly (plus a handful of still-unmapped, unused catalog-snapshot columns — see `app_database.dart`).
- Marking as watched automatically removes it from "Watch later".
- Marking as watched optionally asks for a rating (1–5) and a date.
- TV shows: marked watched at the whole-show level.

### Effects of "Watched"
- Always excluded from Surprise me.
- Can be excluded from the Matcher by any participant who enables the toggle.
- Feed Stats and the taste profile's implicit signals.

### `TasteProfile`
- Fields: `likedGenres`, `vetoedGenres`, `likedVibes`, `yearFrom`, `updatedAt`. Local (same store as `my_list`).
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
- `assets/vibes.json`. **16 vibes on movie, 11 of them also on TV** (5
  are movie-only by design: `indie`, `tearjerker`, `gangster`,
  `musical`, `fantasy` — their TV rule is deliberately empty, either
  because they never had one or because real `/discover` pool
  measurements showed under ~30 titles at `vote_count.gte=200`, too
  thin to ever meaningfully surface; `Vibe.isMeaningfulFor(type)` is
  `false` for an empty rule, so the engine skips it for that type
  entirely rather than returning a near-empty pool). Each vibe has an
  icon, a name, and a rule per media type: a genre set, a keyword-id
  set, and (one case) a year/rating filter.
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

The engine picks with some randomness among the top-5 scored so "Surprise me" doesn't repeat.

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
| Buttons | Primary: white pill with black text. Secondary: pill with a thin gray border. Never two primaries. |
| Bottom bar | **Four tabs** (Discover, Explore · My List, You) and a **60 px amber circular button raised 14 px in the center with Pako's face**, which opens the Match hub as a modal from the bottom. White dot on the button if a room is active. |
| Pako | Mascot: a rounded TV set with two antennas, short legs, and a face on the screen. Off (outline, no face) = logo. A single `.riv` file with a state machine: `powerOn`, `mood` (neutral/searching/celebrating/asleep), `yearSlider`, `idle`. |
| Rive | Only where the animation IS content: splash, empty states, "Searching…", match/Surprise me result, quiz step 3. Micro-interactions stay native Flutter. Runtime `rive` 0.14 (native C++), `RiveNative.init()` at startup. |
| Splash | Static native (logo off) → Rive ~900 ms (Pako powers on, wordmark appears) → 400 ms (Pako powers off and the wordmark slides up into Home). Max 1.5 s; not shown on warm starts. |
| Welcome screen | Poster wall from `/trending/all/week` dimmed to 55% with slow vertical drift, fade to black, halo, Pako in `idle`, headline, one line, "Get started", TMDB attribution. Offline: same wall with placeholders. |
| Home hero | No header; the reason lives inside the card. Fixed amber halo in v1.0; halo dynamically colored from the poster as a v1.2 experiment. |

## 10. Next step
Movie detail screen.
