# ADR: Family mode is not in v1.0

**Status**: Accepted
**Date**: 2026-10-06

## Context

F9/F11 originally specified a Settings toggle, "Family mode" (off by
default), that would hide titles rated R, NC-17, 18, and TV-MA across
Discover, Explore, and the match engine — implemented as a
`certification`/`certification.lte`/`certification_country` filter on
TMDB's `/discover` calls (`tmdb_discover_params.dart`'s own
`familyMode` parameter, gated behind a hardcoded `'16'` threshold for
Spain).

Before building the Settings UI for this toggle, we checked TMDB's own
API reference for every endpoint this app actually calls, to confirm
`certification` filtering would behave consistently across all of
them.

It doesn't.

**`certification`/`certification.lte`/`certification.gte`/
`certification_country` are only documented on `/discover/movie`.**
None of the following support any certification parameter at all:

- `/discover/tv`
- `/trending/all/week`, `/trending/movie/week`, `/trending/tv/week`
- `/movie/now_playing`, `/movie/top_rated`, `/movie/upcoming`
- `/tv/on_the_air`, `/tv/top_rated`, `/tv/popular`

In other words, every TMDB call this app makes for a TV show, and
every carousel/hero call for *either* type (Discover's own "Popular
this week", "In theaters", "Airing now", etc. — none of these go
through `/discover` at all), would silently ignore the filter. TMDB
does not error on an unsupported query parameter; it just returns the
same unfiltered results.

## Decision

**Family mode is not built in v1.0.** No Settings toggle, no
`certification*` parameters sent to TMDB, no filtering in the match
engine.

A toggle that only filters one of the app's many content-fetching
paths (`/discover/movie`, and only when a user explicitly reaches it
via a filter sheet) while leaving Discover's hero, every carousel, and
every TV result completely unfiltered would be actively misleading: a
user who turns "Family mode" on would reasonably expect it to apply
everywhere, not in one specific corner of Explore. Shipping a partial
filter under a name that implies a complete one is worse than shipping
no filter and being honest about it in the product's own scope
decisions (this ADR, F9, F11).

Minor protection for this app is handled the way most mobile catalog
apps actually handle it: the **app store's own age rating** (declared
as 12+/Teen in each store's listing, same as the rationale already
documented for not collecting a birth date in onboarding — see F9).
This app shows the same TMDB metadata regardless of who's using it,
exactly like the store listing itself already implies.

### What was removed

- `tmdb_discover_params.dart`: the `familyMode` parameter, the
  `if (familyMode) { certification_country / certification.lte }`
  block, and the `region` parameter that only existed to feed it (no
  other caller of `discoverQueryParams` ever needed a region).
- `TmdbMediaRepository._discoverMovies`/`_discoverTv`: the now-unused
  `region:` argument at their own `discoverQueryParams` call sites.
- The corresponding `familyMode` test group in
  `tmdb_discover_params_test.dart`.
- Comment-only references to Family mode in `UserProfile`'s own doc
  comment (the rationale for no age/gender field) and
  `SettingsPreferencesSection`'s own doc comment (why there's no toggle
  row).

`DiscoverFilter` itself never had a family-mode or certification
field — it was already documented as deliberately excluded ("Family
mode is an app-wide preference, not a per-screen filter"), so nothing
there needed to change. The match engine and match hub had zero
references to certification or family mode to begin with.

`MediaDetail.certification` (the "PG-13"-style badge shown on a
movie/TV detail screen) is unrelated to this decision and is untouched
— that's TMDB's per-title certification for *display*, not a filter.

## Future path, if this is revisited

A real implementation would need two separate mechanisms, since no
single TMDB parameter covers both media types and every endpoint:

1. **`/discover/movie`**: keep using `certification`/
   `certification.lte`/`certification_country`, but replace the
   hardcoded `'16'` with a real per-country threshold table built from
   `/certification/movie/list`, which returns each country's own
   certification tiers with a numeric `order` — the one endpoint that
   would make the threshold actually correct outside Spain.
2. **Everywhere else** (`/discover/tv`, every carousel/hero/trending
   call, for both media types): TMDB has no server-side filter at all.
   The only honest option is **client-side filtering** after the fact,
   reading each already-fetched title's own `release_dates` (movies)
   or `content_ratings` (TV) — the same fields `MediaDetail.certification`
   already reads for display — and dropping anything at or above the
   chosen threshold before it reaches the UI. This means fetching a
   certification lookup per title (or batching it into each list
   response, if TMDB's own list endpoints ever expose it directly,
   which they don't today), not a single query parameter.

Either path is real, scoped work for a later version — not a quick
flag flip — which is the other reason this stays out of v1.0 rather
than shipping the easy, incomplete half now.
