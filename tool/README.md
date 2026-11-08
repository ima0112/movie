# tool/

Dev-only Dart scripts — pure Dart, no Flutter, run with `dart run`, not
part of the shipped app.

## resolve_vibe_keywords.dart

`VibeRule.keywordIds` (`lib/features/match_engine/domain/vibe.dart`)
ships empty for every vibe in `assets/vibes.json` — nobody has ever
resolved real TMDB keyword ids for them. This script helps pick which
ones are actually worth adding, for the vibes whose genre-only rule is
too broad to need no help: **Indie, Tearjerker, Sports, True story,
Superhero, Gangster, Gritty, Cult, Monster, Musical**.

It does **not** write to `assets/vibes.json`. It only produces a
report; adding a keyword id to the real catalog is a deliberate,
manual edit after reading it.

### What it needs

- `env/dev.json` with a real TMDB v4 bearer token (`TMDB_TOKEN`) — copy
  `env/dev.example.json` if you don't have one yet. This script reads
  that file directly (plain file I/O, not `--dart-define`), since it
  isn't compiled through Flutter's build.
- `tool/vibe_search_terms.json` — candidate English search terms per
  vibe, one list per vibe id. **Add more terms (or a new vibe id) here
  without touching the script** — it reads whichever vibe ids are in
  this file.

### How to run it

```
dart run tool/resolve_vibe_keywords.dart
```

Or limit it to one vibe while you're tuning its search terms (much
faster, and kinder to TMDB's rate limit):

```
dart run tool/resolve_vibe_keywords.dart superhero
```

### What it does, per vibe

1. For each candidate term, calls `/search/keyword?query=<term>` and
   keeps the top 5 hits (TMDB already ranks these by relevance).
2. For each resulting keyword id (deduplicated across terms for the
   same vibe), calls `/discover/movie` and `/discover/tv` four times:
   - the keyword alone ("solo"),
   - the keyword AND'd with that vibe's own current `genreIds` for
     that type ("cross") — the same `with_genres`/`with_keywords`
     combination `MatchEngine._filterForVibe` would actually send,
     including the same fixed `include_adult=false`/`vote_count.gte=100`
     every real `/discover` call already carries
     (`tmdb_discover_params.dart`), so the counts mean what they'd mean
     in the app, not a raw unfiltered total.
3. Pauses 300ms between every TMDB call, and retries with exponential
   backoff (honoring a `Retry-After` header when TMDB sends one) on a
   429, up to 5 attempts, before giving up on that call.

### Reading the report

Written to `tool/out/vibe_keywords_report.md` (gitignored — it's a
scratch artifact, not source data), one table per vibe, rows sorted by
`cross movie + cross tv` descending (the number that actually matters:
how many titles this keyword would add once it's combined with the
vibe's own genres, which is the only way it's ever used).

Two flags, independent of each other:

- 🔸 **low volume** — both cross totals are below ~50. Too few titles
  for this keyword, crossed with this vibe's genres, to be worth
  adding.
- ⚠️ **wide solo / narrow cross** — the keyword alone has 500+
  results, but crossed with the vibe's genres it drops below ~50. A
  broad, generic keyword that doesn't actually narrow anything useful
  for *this* vibe specifically (it might still be the right keyword
  for a different vibe).

No flag at all means the keyword crosses 50+ for at least one media
type — a real candidate to consider adding to `VibeRule.keywordIds` by
hand.
