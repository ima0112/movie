# tool/

Dev-only Dart scripts — pure Dart, no Flutter, run with `dart run`, not
part of the shipped app.

## resolve_vibe_keywords.dart

`VibeRule.keywordIds` (`lib/features/match_engine/domain/vibe.dart`)
ships empty for every vibe in `assets/vibes.json` — nobody has ever
resolved real TMDB keyword ids for them. This script helps pick which
ones are actually worth adding, and also reports raw `/discover` pool
sizes for vibes that work by genre alone (keywords or not).

It does **not** write to `assets/vibes.json`. It only produces a
report; adding a keyword id (or a whole new vibe) to the real catalog
is a deliberate, manual edit after reading it.

### What it needs

- `env/dev.json` with a real TMDB v4 bearer token (`TMDB_TOKEN`) — copy
  `env/dev.example.json` if you don't have one yet. This script reads
  that file directly (plain file I/O, not `--dart-define`), since it
  isn't compiled through Flutter's build.
- `tool/vibe_search_terms.json` — one entry per vibe id:
  ```json
  {
    "superhero": { "terms": ["superhero", "based on comic"] },
    "mind_bending": {
      "terms": ["twist ending", "time loop"],
      "genres": { "movie": [878, 53], "tv": [10765, 9648] }
    },
    "feel_good": { "terms": [] }
  }
  ```
  - `terms`: candidate English `/search/keyword` queries. **Empty
    (`[]`) means "genre pool only, no keyword search"** — the script
    just reports `/discover` totals for the vibe's own genres instead
    of hunting for keyword candidates. Useful for a vibe that works
    fine on genres alone and never needed this script's keyword-search
    half — you still get its pool size for comparison.
  - `genres` (optional): `{"movie": [TMDB ids], "tv": [TMDB ids]}`.
    **Only consulted when the vibe id isn't in `assets/vibes.json` at
    all** (e.g. a vibe you're prototyping before adding it for real) —
    a vibe that's already there always keeps using its own actual
    `genreIds`, resolved through `TmdbGenreMapper` like the app itself
    does. Needed for a vibe whose genre has no normalized `Genre` in
    `GenreCatalog.all` either — "fantasy" is the example: TMDB's own
    Fantasy (14) has no equivalent in the catalog at all, so there's no
    vibes.json-style entry to fall back on.
  - **Add a term, a new vibe id, or a `genres` override here without
    touching the script** — it reads whichever vibe ids you pass it
    (see below), all pulled from this one file.

### How to run it

```
dart run tool/resolve_vibe_keywords.dart
```

Processes every vibe id in `tool/vibe_search_terms.json`. Pass one or
more ids to limit it (faster, kinder to TMDB's rate limit, useful while
tuning a vibe's own terms):

```
dart run tool/resolve_vibe_keywords.dart mind_bending fantasy
```

"classic" is always computed too, regardless of args — it isn't in
`vibe_search_terms.json` at all (no genres or keywords, just
`assets/vibes.json`'s own real "classic" vibe filters: release year and
rating), so there's nothing to opt into.

### What it does, per vibe

**A vibe with candidate `terms`:**

1. For each term, calls `/search/keyword?query=<term>` and keeps the
   top 5 hits (TMDB already ranks these by relevance).
2. For each resulting keyword id (deduplicated across terms for the
   same vibe), calls `/discover/movie` and `/discover/tv` for:
   - the keyword alone ("solo"),
   - the keyword AND'd with the vibe's own genres, OR'd together with
     `|` ("cross") — the same `with_genres`/`with_keywords` combination
     `MatchEngine._filterForVibe` would actually send.
3. Also reports the vibe's own genre pool with no keyword at all, for
   comparison (same numbers a `terms: []` vibe would get).

**A vibe with `terms: []`** (genre pool only): just the two
`/discover` totals (movie/tv) for its own genres, OR'd — no keyword
search.

**"classic"**: `/discover/movie` and `/discover/tv` with
`primary_release_date.lte`/`first_air_date.lte = 1999-12-31` and
`vote_average.gte=7.5` — no genres, no keywords, matching
`assets/vibes.json`'s own real "classic" vibe.

Every `/discover` total is actually **two** calls, always: `raw` (no
`vote_count.gte` at all) and `vote_count.gte=200` — `MatchQuery`'s own
default field (`match_query.dart`) and `docs/DECISIONS.md` §5's
documented first-attempt threshold, used as this script's single,
consistent vote criterion across every number in the report (see the
report's own preamble for why 200, not the `100`
`discoverQueryParams` actually sends today — a separate, pre-existing
gap).

Rate limits: 300ms pause between every TMDB call, retry with
exponential backoff (honoring a `Retry-After` header when TMDB sends
one) on a 429, up to 5 attempts, before giving up on that call.

### Reading the report

Written to `tool/out/vibe_keywords_report_round2.md` (gitignored — a
scratch artifact, not source data). Sections:

1. **One table per keyword vibe** (any vibe with non-empty `terms`),
   rows sorted by `cross movie + cross tv` (at the `≥200` threshold)
   descending — the number that actually matters: how many titles this
   keyword would add once it's combined with the vibe's own genres,
   which is the only way it's ever used.
2. **Genre-only vibes** — one row per `terms: []` vibe (plus
   "classic"), showing the *resolved* TMDB genre ids actually used per
   type and the movie/tv pool totals.
3. **TMDB genre resolution — verification** — a few ids resolved live
   via `TmdbGenreMapper.toTmdbId` (action/sci-fi's TV-side merges into
   "Action & Adventure"/"Sci-Fi & Fantasy"; fantasy's total absence
   from `GenreCatalog.all`), so the mapping claims in the rest of the
   report are never hand-typed guesses.
4. **Summary** — one row per vibe covered by this run (keyword vibes
   included, via their own genre-pool baseline), for an at-a-glance
   comparison.

Every number is a `raw / ≥200` pair — read the report's own preamble
for what each side means, and for why a `raw` of exactly `20001` isn't
a real count (TMDB's own cap on any sufficiently broad, unfiltered
`/discover` call — confirmed directly against the live API, not a
script quirk).

Two flags on the keyword tables, computed off the `≥200` figure (the
realistic one), independent of each other:

- 🔸 **low volume** — both cross totals are below ~50. Too few titles
  for this keyword, crossed with this vibe's genres, to be worth
  adding.
- ⚠️ **wide solo / narrow cross** — the keyword alone has 500+
  results, but crossed with the vibe's genres it drops below ~50. A
  broad, generic keyword that doesn't actually narrow anything useful
  for *this* vibe specifically (it might still be the right keyword
  for a different vibe).

No flag at all means the keyword crosses 50+ (at `≥200`) for at least
one media type — a real candidate to consider adding to
`VibeRule.keywordIds` by hand.
