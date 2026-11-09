# Screen inventory

Scope: v1.0 + v1.1 (Matcher). v1.2+ screens are not designed yet.

Conventions
- **Screen**: a full route with its own top bar. Counts toward the total.
- **Sheet** (bottom sheet) and **dialog**: overlay a screen. Listed but counted separately.
- Every screen defines: access, purpose, elements, states, exits. Loading/empty/error states are designed once as a global pattern (§G) and each screen only notes which ones apply.

Summary: **24 screens**, **9 sheets**, **3 dialogs**, **1 global state pattern**.

Navigation rule: only the four roots (B1, B2, B4, B5) show the bottom bar and the Pako button. Every pushed screen (details, listings, Settings, Stats, My Tastes, quiz, rooms) has a back button in the top bar and hides the bottom bar.

---

## A. Startup

### A1. Splash
- Access: cold app launch.
- Elements: amber halo, the "P" monogram (104 px amber rounded square) fades in, the "PakoTV" wordmark unfurls → the wordmark slides into its spot on Home.
- Duration: max 1.5 s; while theme, language, `/configuration`, and `/trending/all/week` load.
- Exits: A2 if it's the first launch, otherwise → B1.

### A2. Onboarding (1 flow, 6 screens: welcome + 2 intro slides + 3 steps)
- Access: first launch only.
- Purpose: introduce Pako, collect the minimal user profile, and feed `TasteProfile`.
- Step 0 — Welcome (skippable → skips only the taste steps, not step 1): poster wall (4 staggered columns, 55% opacity, slow vertical drift; static with "reduce motion"), dark overlay over the wall (55% at the top, 35% at 30%, 90% at 62%, solid at 78%), the "PakoTV" wordmark at 48 px with a spaced-out uppercase tagline ("Find what to watch"), TMDB's required attribution line at 12 px, "Get started" button. Offline: same wall with placeholders.
- Steps 0a and 0b — **Intro slides** ("Skip" top right jumps straight to the name step; "Next" advances): a 34 px centered headline with one amber phrase, a 15 px muted body, an amber-outlined phone illustration (250×640, built from widgets — no image assets — clipped at the bottom and faded out) with floating badges, **four pagination dots** (slides 1–2 are dots 1–2; the name step and the genres are dots 3–4) and a "Next" button.
  - 0a: "Find what to watch in seconds" — "Explore TMDB's catalog. It's not a streaming app: we tell you where to watch it." Illustration: a mini Discover.
  - 0b: "No idea? Surprise me" — "Answer a few questions or use your tastes and we'll suggest what to watch." Illustration: a mini result screen.
- Step 1 — **What's your name? (required, no "Skip")**: small Pako in `idle` up top, headline "What's your name?", subtitle "That's what I'll call you, and how others will see you in rooms."; auto-focused field; typing reveals a circular initial and a 4-color picker (amber, coral, mint, lilac). "Next" disabled until there are at least 2 characters (and, ≤ 20 — trimmed either way). Saves `UserProfile { displayName, initialColor }`. No age or gender is asked.
- Step 2 — **"Make it yours"** (the third slide; skippable; fourth pagination dot): "Skip" top right, an amber spaced uppercase eyebrow, a 34 px headline "What do you like?" with "like" in amber, a 15 px muted body ("Pick a few genres to personalize Discover. You can fine-tune later in You › My Tastes."), every normalized genre as a centered wrapping **chip** (selected = amber with `onAccent` text, no limit), "Next" button. Multi-select; "Skip" and "Next" both just move on.
- Step 3 — Genres (skippable): "Step 3 of 3" and "Skip" in gray at 13 px, 24 px headline, 14 px subtitle, **3-column** grid of normalized genres (square tile, 12 px radius, `surfaceRaised` background, 24 px outline icon + 13 px label; selected = amber with `onAccent` text), white pill button fixed at the bottom with a 24 px fade over the grid. No poster wall. No counter. Transition between steps: 24 px slide with fade, 250 ms.
- Step 3 copy: "And which ones never?" (the word "never" in amber) — genres picked in step 2 show at 30% opacity and don't respond to taps. Final button "Done".
- Exits: B1, with a "Tastes saved · Edit in You" snackbar if any genre was picked.

---

## B. Tabs (bottom bar with 4 + Match button)

Bottom bar: Discover · Explore · [Pako button] · My List · You. A floating glass pill (inset 16 px, 68 px tall, blurred) with four icon-only tabs (26 px icon; active in white with a 5 px amber dot, inactive in gray) and in the center a **56 px amber circular button with a sparkle icon, straddling the pill's top edge** that opens B3 as a modal. White dot on the button when a room is active. Visible on the 4 roots; hidden in details, quiz, rooms, and inside the Match modal.

### B1. Discover
- Access: tab 1 (root). Main screen.
- Elements:
  - Fixed amber halo behind the header and the top of the hero; fades with scrolling.
  - Top bar: "PakoTV" wordmark at 24 px on the left (arrives from the splash). Nothing else — search is the field under the hero.
  - Segmented control **All | Movies | TV Shows** (the app's one tab design: a contained pill with a white active pill, like B2/B4/C4/D3b/D1b; remembers the last choice; 200 ms cross-fade on change). "All" by default.
  - **Hero** (no header): up to 8 cards, 330×290, 20 px radius (cropped poster), with snap and a 24 px peek of the next one. Full-bleed poster, fade to black over the bottom 40%; on top of it: reason tag (12 px pill, 60% black background; "For you" in amber), 26 px title, gray 13 px metadata ("2019 · Mystery, Comedy · Movie"). Circular save button (36 px) top right, amber if already in Watch later. No auto-advance, no dots. Tap → detail with Hero transition.
    - All: 3 For You (if there's a profile) + 3 mixed trending + 1 in theaters + 1 airing now. The first card is always "For you" when a profile exists. **Not built**: the hero itself doesn't mix in "For you" cards yet — only the carousel section below does (see F1b, `RecommendationBuilder`); the hero's own `getHeroItems` is unchanged.
    - Movies: 3 in theaters + 3 trending + 2 upcoming.
    - TV Shows: 3 airing now + 3 trending + 2 top rated.
    - Deduplicated; excludes anything already in My List.
  - **"For you" / "Because you like {title}" sections** (F1b) — first, before every segment's own named sections below, in **all 3 segments** (not just All), each filtered to that segment's type: "For you" from a usable taste profile, or the library's own favorites/well-rated genres with no profile; "Because you like {title}" from a deterministic library seed (favorite or ≥4★) via TMDB's `/recommendations`. {title} is a real saved title, never a genre. Either section is simply absent with no signal, or below 6 results after excluding posterless items and anything already in My List — never an empty or generic carousel. Each loads, errors, and retries on its own (see States below) — one failing never blocks the other, or any of the sections below.
  - **Search field** right under the hero: 48 px pill in `surfaceRaised`, search icon + "Movies, TV shows, people" in muted text; tap → B2.
  - Sections (20/500 header + amber 14 px "See all" + poster carousel 110×165, 3.2 visible, no title or year underneath):
    - All: Popular this week · Watch later (if ≥ 3; the title links to B4). TV posters carry a small "TV" pill in the corner; movies don't.
    - Movies: In theaters · Trending · Top rated · Upcoming (the only section with a 13 px release date under the poster).
    - TV Shows: Airing now · Trending · Top rated · Popular.
  - **Cold start** (no taste profile and empty My List), only on All: the hero shows trending titles; instead of the hero's own "For you" card, an **invitation card** in `surfaceRaised` with a small powered-on Pako, "Tell me your tastes" + "And I'll tailor what I show you here." plus a secondary "My Tastes" button (→ C5). Disappears as soon as a profile exists. This is the only place in Home where Pako appears. (The "For you"/"Because you like X" *sections* follow their own, separate signal — see F1b — and can show from a library-only signal even with no profile, independently of this card.)
  - Long-press a poster → H1. Native pull-to-refresh — also refreshes "For you"/"Because you like X" (`RecommendationsCubit.refresh()`), alongside `DiscoverCubit`'s own reload.
  - "For you"/"Because you like X" also reload on a language/region change, and on returning from a pushed detail screen (tapping a title, then back) — never on switching bottom tabs away and back (B1 stays mounted under the tab shell, with no lifecycle event for that), and never just because My List changed (picked up next time one of the 3 triggers above fires). Never re-fetches over the network when the underlying signal hasn't actually changed.
- States: per-section skeleton (exact-sized blocks, subtle shimmer; carousels enter staggered with 60 ms as data arrives); per-section error (90 px row "Couldn't load · Retry") — real today for "For you"/"Because you like X" (`RecommendationsCubit`'s own two independent slots); the 8 sections below `DiscoverCubit` owns still fail and retry together as one segment (`docs/TODO_AUDIT.md`'s own "revisit after v1.0" note). "Offline" banner under the header with cached sections still visible.
- Exits: D1/D2 (card or poster), C1 ("See all"), B2, C5, B4, H1.

### B2. Explore (search + genre browsing + filters)
- Access: tab 2; also from the search icon in B1 (arrives with the field focused and the keyboard open).
- Purpose: everything **intentional** (Discover is the editorial side). No Pako, no halo.
- Common elements: no title (opens on the field); **real search field** ("Movies, TV shows, people") with a filter icon on the right (amber when filters are active → H8); segmented All | Movies | TV Shows, drawn as a contained pill (`surfaceRaised`, white active segment). Discover's same control is outlined chips.
- **State 1 — At rest** (empty field): "Recent" as chips (last 10; tap to run, long-press to remove; "Clear all"); "Genres" as **2-column tiles** (96 px tall, backdrop of the genre's most popular title dimmed to 40% with a fade to black, 16/500 name; fetched once per session and cached 24 h; offline → tile in `surfaceRaised` with just the name). Genres change with the segment; under All they're the normalized genres present in both types.
- **State 2 — Typing** (400 ms debounce): the field gains "×" and "Cancel"; the `/search/multi` results list replaces the grid. Row = thumbnail (circular for people), title, "Year · Movie/TV Show" or "Department · Person". The segment filters client-side (All shows all three types; Movies/TV Shows hide people). People sort last unless there's an exact name match. Infinite scroll. If filters are active, their chips dim with the text "Filters don't apply to text search".
- **State 3 — Listing** (see C1): after tapping a genre tile, applying filters, or arriving from "See all".
- States: tile/row skeleton; "No results" with sleeping Pako (Rive) + "Try another title"; error; offline.
- Exits: D1/D2/D3, C1, H8.

### B3. Match (hub, modal)
- Access: Pako button in the bottom bar. Slides up from the bottom as a near-full-screen modal (Pako gives a small bounce on open); swipe down to close.
- Elements:
  - Drag handle and title "Match".
  - Large "Surprise me" card — subtitle "A suggestion just for you" — icon. → E1.
  - Large "Match with friends" card — subtitle "Decide together in seconds" — icon. → F1.
  - "Join a room" block: code field (6 characters, auto-uppercase) + "Join" button + "Scan" icon button (→ F4).
  - If a recent room is active: "Back to room K7PM3Q" card.
- States: inline field error ("Room not found" / "Room is full" / "Room has expired").
- Exits: E1, F1, F3, F4.

### B4. My List
- Access: tab 3. 100% local data: no skeleton or network error.
- Elements:
  - Top bar: "My List" title and a single icon on the right, filters (→ H9; amber if filters are active).
  - Segmented Favorites · Watch later · Watched, each with a live counter, drawn as a contained pill (same as B2's).
  - Row of amber chips with active filters (each with "×"), only when something differs from the default.
  - Rows: 56×84 poster, 16/500 title, gray 13 px line ("2022 · TV Show · 24 episodes" / "2023 · Movie · 1 h 46 min") — rendered entirely from the saved entry's own catalog snapshot, no network call; the episode count/runtime segment only appears once the entry has picked one up (a toggle or Save from the detail screen, or the detail screen's own lazy refresh on reopening) — until then the line is just "year · type". Right-hand column per tab: Favorites and Watch later → relative date saved; Watched → 1–5 amber stars (empty ones in dark gray; unrated shows all five in gray) and a short date. Tapping the stars → H2 directly.
  - Swipe left → "Remove" (red, snackbar with "Undo" for 4 s, no dialog); swipe right → "Watched" (amber → H2) in Favorites/Watch later, "Favorite" in Watched. Long-press → H1.
  - Default sort: Title A–Z, every tab (there's no "date saved" field to sort Favorites/Watch later by; Watched also offers Date watched from H9, just not as the default).
- States: empty with sleeping Pako (Rive, `mood = asleep`), per-tab headline ("No favorites yet" / "Nothing for later yet" / "You haven't marked anything as watched yet"), a line mentioning what does exist in other tabs, "Explore" CTA. If a filter is what's emptying the list: "No TV shows here" + "See all".
- Exits: D1/D2, H1, H2, H9.

### B5. You
- Access: tab 4.
- Elements:
  - Header: initial in a circle with the chosen color (48 px, small pencil badge bottom right), "Hi, Daniel" 26/600 (no name: Pako's silhouette in the circle, "Hi" and subtitle "Tap to set your name"); tapping the header edits name and color in a sheet (H10). Gear icon top right → C6.
  - **My Tastes** card (`surfaceRaised`, radius 16): liked genres as small chips (max 3 + "+N"), line "3 vibes · since 1990 · never Horror"; tap → C5. No taste profile: the invitation card with a small Pako and a "My Tastes" button.
  - **Your Activity** card: four large numbers in a strip with hairline dividers (watched · hours · favorites · watch later) and an amber "See stats" link → C4. No charts.
  - **Recent Rooms** card (v1.1): up to 10 local matches (thumbnail, title, "with Ana and Luis · yesterday"); tap → D1/D2. Not shown if there are none.
- No halo, no large Pako. Amber only on the initial's circle and the stats link.
- Exits: C4, C5, C6, H10, D1/D2.

---

## C. Secondary catalog screens

### C1. Filtered listing (See all · Genre · Results)
- Access: "See all" from B1 (arrives with the collection's name and no filters), a genre tile in B2, or "See N results" from H8.
- Elements: top bar with back, title ("In theaters" / "Horror" / "Results"), and a filter icon (amber if active → H8); row of active filter chips, each with "×"; line "312 results · Popularity" (the count comes from `total_results`; with "Hide watched" the grid shows fewer items and the count doesn't adjust); 3-column grid with infinite scroll.
- Source: `/discover/{movie|tv}` with the filters; All = both interleaved. "See all" collections use their own endpoint until a filter is touched, at which point they switch to the equivalent `/discover` call.
- States: grid skeleton, empty ("Nothing matches these filters" + "Reset"), error, offline.
- Exits: D1/D2, H8.

### C4. Stats
- Access: "See stats" in B5.
- Elements:
  - "Stats" top bar.
  - Filter tabs: All · Movies · TV Shows (the same contained-pill control as everywhere else).
  - Four metric cards in a 2×2 grid: Movies watched · Hours of movies · TV shows watched · Estimated TV hours.
  - "Genres you watch most": list of 5 horizontal bars with name and count.
  - "Your most-watched year": one large number + subtitle.
  - "Activity over the last 12 months": strip of 12 cells with intensity.
  - "Your average rating": number + stars.
- States: empty ("Mark something as watched to see your stats" + CTA).

### C5. My Tastes
- Access: My Tastes card in B5; invitation card in B1; or from the Surprise me result when saving.
- Elements (vertical scroll, everything editable in place). Top bar: back, centered title, amber "Reset" on the right. Under it, a 14 px muted intro line ("The more we know, the better your recommendations and Surprise me. Everything is saved only on your device."). Each section has a 20 px title and a 13 px muted hint:
  - "Genres you like" section ("Choose as many as you like."): every genre as a wrapping chip, selected = amber.
  - "Genres you never want" section ("We won't show them in recommendations."): the same chips, mutually exclusive with the above; a picked one is red-tinted with a red border and struck through.
  - "Vibes you like" section: 4-column grid of the 16 vibes.
  - "How far back" section: slider with a large number.
  - Auto-saved; discreet "Saved" text on change.
- States: none special.

---

### C6. Settings (pushed)
- Access: gear icon in B5. Back button, no bottom bar.
- Elements (grouped list: each group is a `surfaceRaised` card (radius 16) with hairline dividers; 56 px row, 16 px white label, gray value, chevron; no icons; small spaced-out uppercase gray group header):
  - Preferences: Language ("Español" → H5) — one setting for both the app's own interface and TMDB's content, not two separate preferences — Region ("Spain" → H6, with search). No Theme row and no Family mode in v1.0 — see `docs/decisions/family-mode-not-in-v1.md` for why Family mode specifically was dropped rather than built partially.
  - Data: "Export My List" (JSON → the system share sheet); "Delete My List", "Delete My Tastes" in red → I1 (the dialog states how many items it deletes).
  - About: "Attribution and credits" (→ C7), Version (long-press copies the build number), Source code (GitHub, external link), Licenses (`showLicensePage`).
- Sheets H5–H6 are lists with an amber check on the active option; tapping applies and closes.
- No Pako.

### C7. Attribution and credits (pushed)
- Access: "Attribution and credits" in C6's About group. Back button, no bottom bar.
- Elements: two `surfaceRaised` cards, each a neutral name chip ("TMDB", "JustWatch"), one 15 px line and one 13 px gray line. TMDB: the required wording "This product uses the TMDB API but is not endorsed or certified by TMDB." + "Posters, images, synopses, cast and ratings." JustWatch: "Streaming availability data is provided by JustWatch." + "Streaming, rent and buy options for your region." Below: 13 px gray note "PakoTV is a free personal project. All trademarks belong to their respective owners."
- Provider names are never translated. No Pako.

---

## D. Details

### D1. Movie detail
- Access: any movie card, poster, or row. Pushed screen; poster Hero transition.
- Header (320 px): TMDB's 16:9 backdrop, full width (the poster when TMDB has no backdrop), with a 35% dark scrim at the top and a fade into the page color starting at 30%; back circle (translucent black) top left and a Share circle (same style) top right that opens the system share sheet with the title and its TMDB link ("Title\nhttps://www.themoviedb.org/movie/{id}"). Over the fade, left-aligned: the 32 px title (max 2 lines) with the italic muted tagline under it, if any. When the title scrolls past the top, a compact black bar appears with back, the title at 16 px and a Share icon at the end; once shown it stays for the rest of the scroll, however far down, and turns back into the transparent header only when the scroll returns to the top.
- White pill "Trailer" button with a play icon, full width (opens YouTube: app scheme, then browser; selection: official + Trailer + user's language → official → Teaser → first available). No trailer: the button becomes "See similar" and scrolls to that section. Multiple trailers: an icon on the right with a menu.
- Info card under the button (`surfaceRaised`, radius 16, hairline border): the 100×150 poster on the left; on the right "year · country · genres" in muted text (the main production country by its name in the app's language, e.g. "2010 · United States" / "2010 · Estados Unidos", via `flutter_localized_locales`; each genre tappable → C1 with that genre and type Movies), info chips (★ rating and the original language's name in the app's language, "English" / "Inglés"), and the row of three actions in 44 px bordered rounded boxes: Favorite and Watch later as icon-only squares (their names are accessibility labels), Watched as a wide button with icon and label. Active = filled icon, amber border and a faint amber tint. "Watched" opens H2; if it was in Watch later it's removed with a snackbar "Marked as watched · Removed from Watch later". Tapping "Watched" again opens H2 with current values and a red "Remove from Watched" link.
- **Where to watch**: a `surfaceRaised` card (radius 16, hairline border) with the title and a "JustWatch" badge on the right. Inside, the **Streaming** box on top (amber label and a faint amber border; up to 5 services as 56 px logos with their names under them), then **Rent** and **Buy** side by side (neutral boxes; up to 3 services each as 36 px logos), each with "+N" when there are more. A service with no logo shows its first letter. Under the title, a **country pill** (globe, country name, chevron; outlined, 36 px tall) that opens H6 — choosing a country reloads the detail in place for that screen only (no loading screen, scroll kept) and does not change the saved region; leaving and re-entering shows the saved region again. Under the boxes: "Tap a service to open it in JustWatch"; any service tile opens TMDB's `link` in the browser. Groups with no data are omitted; no data anywhere: the card stays, with "Not available to stream, rent or buy in {country}. Try another country." under the pill, so the country can always be changed. Mandatory 11 px footer "Data from JustWatch".
- Two stat cards under the info card, side by side: **Duration** ("2 h 28 min") and **Classification** ("PG-13"); a card without data is omitted, and neither data means no row.
- Synopsis under a "SYNOPSIS" caption (muted, capitals), folded to 4 lines. The amber toggle appears only when the text is really cut: "Read more" expands, then it becomes "Read less" to fold it back; a synopsis that fits has no toggle (the tagline lives in the header).
- Cast: a "Cast" heading with "See all" (amber, → D1b, shown when there are more than 10) on the right, then 10 circles at 64 px with name and character (→ D3).
- Similar movies: standard carousel under a "Similar movies" heading, no "See all".
- Footer: "Data from TMDB".
- States: skeleton with the poster already visible via the Hero and centered blocks; full-screen error with "Retry"; offline with a snapshot if it's in My List (poster, title, year, genres) and network sections shown as "Not available offline".
- Exits: D1b, D3, C1, H2, H6.

### D1b. Full cast & crew (pushed)
- Access: "See all" in D1/D2's Cast section (shown past 10 people). Pushed screen (it replaces the old H3 bottom sheet): back button, the movie's/show's title centered as the screen title, no bottom bar. Receives the already-loaded cast and crew (no network call of its own).
- Elements: a "Cast | Crew" pill (selected = white pill), an internal search box ("Search cast and crew"; case-insensitive by name, with a clear button) and a 3-column grid (built lazily). Cast and Crew each keep their **own scroll position** — scrolling one never moves the other. Searching looks through **both** lists whichever tab is selected: the pill stays visible at all times and its labels show the match counts ("Cast · 3", "Crew · 1"); the matches show under a "CAST" and a "CREW" heading (a heading with no matches is omitted), the selected tab's group first of 4:5 rounded portraits with the name and the character (Cast) or job (Crew) under each. No matches: "No matches". A person with no photo shows a colored monogram.
- Layout: scrollable page; with the keyboard open the grid stays reachable; survives a small device at 200% text.
- Exits: D3.

### D2. TV show detail
- Same as D1 with these changes:
  - The info card's meta line: "Year–Year · N seasons · M episodes · Rating", then the main origin country's name (in the app's language) and the genres; D2's chips are the rating and the original language's name (no runtime/certification chips or stat cards).
  - Status pill next to the title: "Airing" (accent) / "Ended" / "Cancelled" (neutral).
  - "Created by": names (→ D3).
  - **Seasons** card under the info card: "Seasons · 5 (62 ep.)" with a chevron → D2b (it replaces the inline season list).
  - No runtime; shows "≈ 45 min per episode" instead — not on this screen itself (the metadata line above has no runtime slot to begin with), already covered by C4's "Estimated TV hours" (`TvShowDetail.estimatedHours`).
  - "Where to watch" same as D1 (the show's own providers; a season's own providers, if they ever differ, aren't modeled yet — `MediaRepository.season()`'s `SeasonDetail` has no `watchProviders` field).
- Exits: D3, H4, H2.

### D2b. Seasons (pushed)
- Access: the "Seasons" card in D2. Pushed screen: back button, centered "Seasons" title, no bottom bar. Receives the already-loaded show (no network call of its own).
- Elements (vertical scroll):
  - Header card (`surfaceRaised`): the show's name and three info chips — status ("Airing" / "Ended" / "Cancelled"), "N seasons", "M episodes".
  - "NEXT EPISODE" caption + card: the next scheduled episode (still, "S2 · E6 · Name", air date chip) or, with none, "No next episode" and a line — "This show has ended and has no new episodes planned." when ended or cancelled, otherwise "No upcoming episode has been announced yet."
  - "LAST AIRED EPISODE" caption + card: still (92×56), "S5 · E16 · Name", air-date and ★ rating chips (rating only if TMDB has one). Omitted when TMDB reports none.
  - "SEASONS" caption + one bordered card per season (44×64 thumbnail, "Season N", year, "X episodes", chevron) → H4. A specials season (TMDB's season 0) sorts last, labeled "Specials", and only appears at all if it has episodes.
- No Pako.
- Exits: H4.

### D3. Person detail
- Access: cast, crew, or search result.
- Elements:
  - Top bar with back; a compact bar with the name (no Share) appears once scrolled past the header and stays for the rest of the scroll, same as D1/D2. The header's height is remembered, because the header itself stops being built once it is far off-screen.
  - The header content starts below the back button's row (status bar + the 40 px circle and its padding, plus 8), never beside it, and is centered in the full column whatever the width of its lines. A warm glow behind the header; 112 px circular photo, 26 px name, and one muted line "department · age · place of birth" ("Acting" / "Directing"; age computed from `birthday` or, once there's a `deathday`, years lived instead — no raw date shown for either; place of birth with no date attached).
  - Layout: everything is centered in the header and left-aligned to the 20 px screen margin below it, which the back circle shares; the header adds no space below, so the biography, "Known for" and "Filmography" are each one `sectionGap` (24) apart.
  - Biography folded to 3 lines; the amber "Read more" appears only when the text is really cut, turns into "Read less" once expanded and folds it back. A "Biography in English" note appears above it when TMDB had no translation in the user's own language and the repository fell back to English.
  - "Known for": row of their 6 most popular titles, each poster with its title underneath (by `voteAverage`, the closest proxy — `MediaItem` has no dedicated popularity field).
  - "Filmography": the title and one card, "View full filmography · N titles ›" → D3b (the inline list moved there).
- States: skeleton, error, offline.
- Exits: D1/D2, D3b.

### D3b. Filmography (pushed)
- Access: the "View full filmography" card in D3. Pushed screen: back button, the person's name centered as the title, no bottom bar. Receives the already-loaded person (no network call of its own).
- Elements: the app's tabs (contained pill) **All · Movies · TV Shows · As director** — a tab appears only when it would show something different from All (a person with only movies has no "Movies" tab; one who never directed has no "As director" tab), and with no tab beyond All the control isn't drawn at all. Under it, a flat list, newest first (credits with no release date ahead of the rest). Row: 52×76 poster, the title, a muted "role · year" line ("Coming soon" in place of the year for an undated credit) and the ★ rating at the far end (hidden while TMDB has no score), with a hairline between rows. "As director" narrows to `job == 'Director'` specifically, not every crew department. No infinite scroll — the one combined-credits call already has everything.
- Exits: D1/D2.

---

## E. Surprise me (solo)

### E1. Choose type
- Access: "Surprise me" card in B3.
- Elements: headline "What are you in the mood for today?", two large cards "A movie" / "A TV show", each with an icon.
- Rule: usable tastes exist (a profile with at least one liked genre or vibe, or — with no such profile — My List has 5+ entries) → picking a type opens H11 to choose between using them or answering the quiz anyway. No usable tastes at all → picking a type goes straight to E2.
- Exits: H11, E2, or E3.

### E2. Quiz (1 screen, 4 steps) — shared with the Matcher
- Access: E1 when no usable `TasteProfile`/inferred list exists at all (otherwise E1 reaches H11 first, which offers "Use my tastes" before ever reaching this screen — see H11 below), or Matcher F2.
- Common elements: back button, "Step X of 4" indicator, large conversational headline, step content, full-width "Next" button (disabled until the step's rule is met). **Not built: a second "Use my tastes" button on step 1 of this screen itself** — `QuizCubit`'s own doc comment documents this as deliberately out of scope (it would couple this Cubit to one specific prior-answer source). Superseded in practice by H11, which already handles "use my tastes" one step earlier, before this screen is ever reached with a usable profile on hand.
- Step 1 — "Pick up to 3 you're NOT in the mood for": 4-column grid of genres for the chosen type; icon + name; max 3; counter "1 of 3".
- Step 2 — "Now pick 3 you ARE in the mood for": 4-column grid of the 16 vibes; exactly 3; counter "3 of 3".
- Step 3 — "How far back do you want to go?": large year number, full-width slider (1950–present), room for an illustration.
- Step 4 — Movie: "Max runtime" slider (60–240 min, large number, "No limit" at the far end). TV show: "Finished | Either" toggle + "Max seasons" stepper (1–10, "No limit"). Under both: a discreet "Exclude what I've already watched" toggle. Final button "Search".
- States: in the Matcher, if submission fails → inline error with retry.
- Exits: E3 (solo) or F3 (group).

### E3. Surprise me result
- Access: E1 (via H11) or E2.
- Elements:
  - Standard background. Headline "Your suggestion".
  - Subtitle per source: from the profile → "Based on your tastes"; from the inferred list → "Based on your list"; from the quiz → "Based on your answers".
  - White card: large poster, title, "Year · Genres", rating, 2-line synopsis, "View details" link (→ D1/D2).
  - If filters were relaxed: discreet note "We widened the search to 1990".
  - Primary button "Add to Watch later".
  - Secondary button "Another suggestion".
  - If it came from the profile or the inferred list: link "Answer the quiz instead" (→ E2, same media type; finishing the quiz replaces this screen rather than stacking a second E3 on top).
- States: loading (card skeleton with "Searching…" text), error with "Retry", offline.

---

## F. Matcher (group) — v1.1

### F1. Create room
- Access: "Match with friends" card in B3; the hub sheet expands to a full screen, halo at the top.
- Elements: "What are you watching?"; two type cards (Movie preselected, TV Show) with a check; "how it works" row of three icons (Share the code · Everyone answers 4 questions · Pako picks one for all); "You'll join as Daniel · Host" row with initial and color, and a "Change" link (→ H10); "Create room" button.
- States: button loading; inline error "Couldn't create the room · Retry"; offline, button dimmed with "Needs a connection".
- Exits: F3 (host).

### F2. Join: confirm
- Access: a valid code from the hub's boxes, from F4, or from the universal link `https://pakotv.app/r/{code}` (opens the app directly here; without the app, a web page with the code and store links). The room has already been read before this screen is shown.
- Elements: large code, amber type pill, "Ana's room · 2 people inside" with their avatars, "how it works" row (Answer 4 questions · Wait for the others · Pako picks one for all), "You'll join as Daniel" row with "Change" (→ H10 with a "Also save to my profile" toggle off by default and a color suggestion if yours is already taken), "Join" button (→ F3b, where you choose how to answer).
- States: room full / expired after having read it → sleeping Pako with an explanation and "Back to hub"; already answered in this room → jumps to F3; offline → button dimmed.
- Exits: F3b.

### F3. Waiting room (host)
- Access: after creating (host); after answering (guest, see guest flow).
- Header: "×" (→ I2) on the left, type pill on the right.
- State 1 — Just created: 32 px spaced-out code, large QR (encodes the universal link), "Copy" (code only) and "Share" (system sheet with the link) buttons; list with only the host ("hasn't answered"); a **"Your answer"** block with two options: **"Use my tastes"** (only if a profile with genres or vibes exists; shows a summary of what it will send; fills in vetoes, the 3 strongest vibes, and the year, then opens E2 at step 4, prefilled, with the "Filled in from your tastes · Review" banner) and **"Answer the quiz"** (→ E2 from step 1; "Send" at the end). The host can answer before or after others join.
- State 2 — Waiting: the QR collapses into an icon next to the code (tap to reopen it large); participant list with a colored avatar, name, "host" tag, green check or "answering…"; entries appear in real time with a slide-in and haptic; line "5 of 6 have answered"; disabled button "Waiting for Luis" / "Waiting for 2 people"; after 60 s with everyone but one done, a "Search without waiting for Luis" link (excludes them from the calculation and notifies them).
- State 3 — Everyone's ready: green line "Everyone's ready · 6 of 6"; **amber** button "Find our match" (the only amber button in the app); the room closes to new entries. On tap: I3 if vetoes cover more than half the genres; then, "Searching for the 6 of you…" with Pako `searching` and group-oriented lines. Only the host computes and writes the result.
- States: "Reconnecting…" banner; expired room → notice screen with "Go back".
- Exits: E2, F5, I2, I3, H10.

### F3b. Waiting room (guest)
- Access: after F2 "Join".
- Header: "×" (→ I2, softer version: "You can come back with the code"), type pill; small code with an icon to resend it; "Ana's room · 3 of 6". Halo lower than in the host's room.
- State 1 — You just joined: list with your row marked "· you" and "hasn't answered"; "Your answer" block with the same two options as the host.
- State 2 — Waiting for the host: your row with a check; waiting card "Once everyone answers, Ana will find the match" with a "Change my answer" link (until the room moves to `resolved`). No button: resolved by the listener. On leaving the screen, the Pako button shows the white dot and the hub shows the "Back to room" card.
- State 3 — Everyone answered but the host isn't searching: "Waiting for Ana to find the match"; after 2 min of host inactivity (`hostLastSeen`), a "Search myself" option appears for the first guest to tap it, who acts as host just for that search.
- State 4 — Excluded via "Search without waiting": sleeping Pako, "Ana searched without waiting for you", "Your answer wasn't part of the calculation, but you can see the result", "See the match" button.
- When the host launches the search, the guest sees the same "Searching for the 6 of you…" screen even though they aren't computing anything.
- Exits: E2, F5b, I2.

### F4. QR scanner
- Access: icon in B3.
- Elements: full-screen camera, focus frame, "Point at the room code", close button, "Type the code" link. Reads the universal link and jumps to F2.
- States: permission denied (explanation + "Open settings"). The phone's native camera also opens F2 when it reads the link, without going through this screen.
- Exits: F2.

### F5. Match result (host)
- Access: when the host publishes the result (everyone navigates via their listener).
- Elements: **full-bleed amber** background; header "Room K7PM3Q · 6 people" and "×" (→ I2); headline "It's a match!"; **black** card with poster, title, "Year · Genres · Runtime", "Perfect match" pill (green) or "Best compromise" (gray), row of group avatars with "Everyone 3/3" or the number under each avatar and a check for those at 100%, a first-person relaxation note if there was one, "View details" link (→ D1/D2). Buttons: "Add to Watch later" (local), **"Find another"** (host only; rotates alternatives and writes the new `winnerId`; others see a cross-fade), footer "Only you can ask for another option". Once the 4 alternatives are exhausted, the button becomes "No more options · Change filters" and reopens the room in `answering`.
- On close: the match is saved to "Recent Rooms" in You (title, participants, date; max 10).
- States: winner changes in real time; offline keeps the last result.

### F5b. Match result (guest)
- Same as F5 except: header "Ana's room · 6 people"; **no "Find another"**, instead the line "Only Ana can ask for another option" with a refresh icon; your avatar has a white ring in the satisfaction row; the excluded participant doesn't appear in the row. Winner change: cross-fade + soft haptic on every phone. "×" doesn't affect anyone and saves the match to Recent Rooms.
- Room closed by the host or expired (in F3b or F5b): sleeping Pako, "Ana closed the room", with the result if there was one ("The match was Knives Out. It's in Recent Rooms.") or "You didn't get to search"; "Back to start" button.

---

## G. Global state pattern (designed once)

- **Skeleton**: version for carousel, grid, row list, detail.
- **Empty**: outline icon in a 72 px `surfaceRaised` circle (no mascot), one-line headline, one-line body, optional CTA.
- **Error**: same layout with "Retry".
- **Offline**: persistent top banner "Offline" (rounded box with a wifi-off icon, neutral colors) + screens use local data when available.
- **Snackbar**: short confirmations ("Added to Watch later", "Copied") with an "Undo" action when applicable.

---

## H. Sheets (bottom sheets)

| # | Sheet | Opens from | Content |
|---|---|---|---|
| H1 | Quick actions | Long-press a card | Thumbnail + title, three rows: Favorite / Watch later / Mark watched |
| H2 | Mark as watched | "Watched" button in D1/D2, swipe in B4, H1 | Title ("Mark as watched" for a movie, "Have you finished {title}?" for a TV show — asking about a show commits to having finished it, not just pressed a button), 5-star selector (optional), date (today by default, editable), "Save" button, "Remove from Watched" link if it already was |
| H4 | Season N | Season card in D2b | Header card (poster, show name, "Season N", episode-count chip and, when TMDB has one, a ★ rating chip); season synopsis folded to 2 lines with "Read more"; "EPISODES" list of compact rows (112×64 still with a number badge, name, date · runtime, 2-line synopsis) |
| H4b | Episode | Episode row in H4 | Sheet over H4: a 16:9 still, "S1 · E1" caption ("Specials · E1" for season 0), the episode name, info chips (air date, runtime, ★ rating when TMDB has one), the full synopsis, and a "GUEST STARS" row of 64 px circles with name and character (→ D3) when the episode lists any |
| H5 | Language | B5 | Single-select list: Español / English — one setting for the interface and TMDB's content |
| H6 | Region | B5 | Searchable list of countries, with a one-line subtitle ("Sets which services you see in Where to watch") |
| H7 | Theme | B5 | Dark / Light / System |
| H8 | Filters | B2, C1 | Type (All/Movies/TV Shows); multi-select genres; year (range slider 1950–present); minimum rating (0–9 slider, `vote_count.gte=100` fixed); max runtime (movies only); status Airing/Ended (TV shows only); sort by Popularity/Rating/Date/Title; "Hide what I've watched" toggle (client-side). "Reset" and "See N results" (N live) buttons. Only applies to `/discover`, not text search. |
| H9 | Sort and filter My List | B4 | Type (All/Movies/TV Shows); sort by Title A–Z / Year / TMDB rating and, in Watched, My rating / Date watched; in Watched, minimum rating (★1–5); in Favorites and Watch later, "Hide what I've watched". Remembers state per tab. "Reset" (only if something's active) and "Apply"; swiping to close discards. |
| H10 | Edit profile | B5 | Name and initial color (4). Same controls as onboarding step 1. |
| H11 | Choose source | E1 | Subtitle naming the source ("Based on your tastes" / "Based on your list"); "Use my tastes" (primary) / "Answer the quiz instead" (secondary) |

## I. Dialogs

| # | Dialog | Opens from | Content |
|---|---|---|---|
| I1 | Confirm deletion | B5 | Floating card: red trash badge, "Delete your list? This can't be undone.", Cancel / Delete (destructive) side by side |
| I2 | Leave the room | F3, F5 | Host: "If you leave, the room closes for everyone". Guest: "You can come back with the code". Cancel / Leave |
| I3 | Too many vetoes | F3 when searching | "You've vetoed 10 of 16 genres between you. There isn't much left to pick from." Search anyway / Back to room |

---

## J. Components to design (component sheet)

1. Bottom tab bar (5, with Match highlighted).
2. Poster card (carousel) and poster card (grid) with a "TV" tag.
3. List row (My List, search, filmography) with variants.
4. Genre chip (default / selected) and filter chip.
5. Movies | TV Shows segmented control.
6. Primary, secondary, tertiary/link, destructive buttons; icon button with state (favorite / watch later / watched).
7. Quiz/genre tile (default / selected / disabled).
8. Slider with a large number (year, runtime).
9. Stepper (seasons) and toggle.
10. Metric card and genre bar (Stats).
11. Participant row (initial avatar, name, tag, status).
12. Status pill: Perfect match / Best compromise / Airing / Ended.
13. Result card (Surprise me and Match).
14. Skeletons, empty state, error state, offline banner, snackbar.
15. TMDB attribution block.

---

## K. Flows to wire up in the design
- F-A: Splash → Onboarding → Discover.
- F-B: Discover → Movie detail → Mark as watched sheet → snackbar.
- F-C: Explore → chips → TV show detail → Season sheet.
- F-D: Match hub → Surprise me → (type) → Quiz → Result → Save tastes.
- F-E: Match hub → Create room → Waiting room → Quiz → Waiting room → Result (host).
- F-F: Match hub → Scanner → Name → Quiz → Waiting room → Result (guest).
