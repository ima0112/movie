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
- Elements: static native (Pako's logo, off, centered on `#0B0B0D`) → Rive animation: amber halo, Pako powers on, "PakoTV" wordmark unfurls → Pako powers off and the wordmark slides into its spot on Home.
- Duration: max 1.5 s; while theme, language, `/configuration`, and `/trending/all/week` load.
- Exits: A2 if it's the first launch, otherwise → B1.

### A2. Onboarding (1 flow, 4 screens: welcome + 3 steps)
- Access: first launch only.
- Purpose: introduce Pako, collect the minimal user profile, and feed `TasteProfile`.
- Step 0 — Welcome (skippable → skips only the taste steps, not step 1): poster wall (4 staggered columns, 55% opacity, slow vertical drift; static with "reduce motion"), fade to black from 30% to 62% of the height, amber halo, Pako in `idle` sitting on the fade line, "Hi, I'm Pako" at 28 px, one line ("I'll help you find something to watch, alone or with friends."), "Get started" button, TMDB attribution at 11 px. No pagination dots. Offline: same wall with placeholders.
- Step 1 — **What's your name? (required, no "Skip")**: small Pako in `idle` up top, headline "What's your name?", subtitle "That's what I'll call you, and how others will see you in rooms."; auto-focused field; typing reveals a circular initial and a 4-color picker (amber, coral, mint, lilac). "Next" disabled until there are at least 2 characters. Saves `UserProfile { displayName, initialColor }`. No age or gender is asked.
- Steps 2 and 3 — Genres (skippable): "Step X of 3" and "Skip" in gray at 13 px, 24 px headline, 14 px subtitle, **3-column** grid of normalized genres (square tile, 12 px radius, `surfaceRaised` background, 24 px outline icon + 13 px label; selected = amber with `onAccent` text), white pill button fixed at the bottom with a 24 px fade over the grid. No poster wall. No counter. Transition between steps: 24 px slide with fade, 250 ms.
- Step 2: "What genres do you like?" — multi-select, no limit.
- Step 3: "And which ones never?" (the word "never" in amber) — genres picked in step 2 show at 30% opacity and don't respond to taps. Final button "Done".
- Exits: B1, with a "Tastes saved · Edit in You" snackbar if any genre was picked.

---

## B. Tabs (bottom bar with 4 + Match button)

Bottom bar: Discover · Explore · [Pako button] · My List · You. Four tabs (24 px icon + 11 px label; active in white, inactive in gray) and in the center a **60 px amber circular button raised 14 px with Pako's face** that opens B3 as a modal. White dot on the button when a room is active. Visible on the 4 roots; hidden in details, quiz, rooms, and inside the Match modal.

### B1. Discover
- Access: tab 1 (root). Main screen.
- Elements:
  - Fixed amber halo behind the header and the top of the hero; fades with scrolling.
  - Top bar: "PakoTV" wordmark at 24 px on the left (arrives from the splash), search icon on the right (→ B2 with the field focused). Nothing else.
  - Segmented control **All | Movies | TV Shows** (white active pill; remembers the last choice; 200 ms cross-fade on change). "All" by default.
  - **Hero** (no header): up to 8 cards, 330×440 (3:4, cropped poster), with snap and a 24 px peek of the next one. Full-bleed poster, fade to black over the bottom 40%; on top of it: reason tag (12 px pill, 60% black background; "For you" in amber), 26 px title, gray 13 px metadata ("2019 · Mystery, Comedy · Movie"). Circular save button (36 px) top right, amber if already in Watch later. No auto-advance, no dots. Tap → detail with Hero transition.
    - All: 3 For You (if there's a profile) + 3 mixed trending + 1 in theaters + 1 airing now. The first card is always "For you" when a profile exists.
    - Movies: 3 in theaters + 3 trending + 2 upcoming.
    - TV Shows: 3 airing now + 3 trending + 2 top rated.
    - Deduplicated; excludes anything already in My List.
  - Sections (20/500 header + amber 14 px "See all" + poster carousel 110×165, 3.2 visible, no title or year underneath):
    - All: For You · Popular this week · Because you like [genre] · Watch later (if ≥ 3; the title links to B4). TV posters carry a small "TV" pill in the corner; movies don't.
    - Movies: In theaters · Trending · Top rated · Upcoming (the only section with a 13 px release date under the poster).
    - TV Shows: Airing now · Trending · Top rated · Popular.
  - **Cold start** (no taste profile and empty My List), only on All: the hero shows trending titles; instead of "For you" and "Because you like…", an **invitation card** in `surfaceRaised` with a small powered-on Pako, "Tell me your tastes" + "And I'll tailor what I show you here." plus a secondary "My Tastes" button (→ C5). Disappears as soon as a profile exists. This is the only place in Home where Pako appears.
  - Long-press a poster → H1. Native pull-to-refresh.
- States: per-section skeleton (exact-sized blocks, subtle shimmer; carousels enter staggered with 60 ms as data arrives); per-section error (90 px row "Couldn't load · Retry"); "Offline" banner under the header with cached sections still visible.
- Exits: D1/D2 (card or poster), C1 ("See all"), B2, C5, B4, H1.

### B2. Explore (search + genre browsing + filters)
- Access: tab 2; also from the search icon in B1 (arrives with the field focused and the keyboard open).
- Purpose: everything **intentional** (Discover is the editorial side). No Pako, no halo.
- Common elements: "Explore" title; **real search field** ("Movies, TV shows, people") with a filter icon on the right (amber when filters are active → H8); segmented All | Movies | TV Shows.
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
  - Segmented Favorites · Watch later · Watched, each with a live counter.
  - Row of amber chips with active filters (each with "×"), only when something differs from the default.
  - Rows: 56×84 poster, 16/500 title, gray 13 px line ("2022 · TV Show · 2 seasons" / "2023 · Movie · 1 h 46 min"); right-hand column per tab: Favorites and Watch later → relative date saved; Watched → 1–5 amber stars (empty ones in dark gray; unrated shows all five in gray) and a short date. Tapping the stars → H2 directly.
  - Swipe left → "Remove" (red, snackbar with "Undo" for 4 s, no dialog); swipe right → "Watched" (amber → H2) in Favorites/Watch later, "Favorite" in Watched. Long-press → H1.
  - Default sort: Recent (by date saved); in Watched, by date watched.
- States: empty with sleeping Pako (Rive, `mood = asleep`), per-tab headline ("No favorites yet" / "Nothing for later yet" / "You haven't marked anything as watched yet"), a line mentioning what does exist in other tabs, "Explore" CTA. If a filter is what's emptying the list: "No TV shows here" + "See all".
- Exits: D1/D2, H1, H2, H9.

### B5. You
- Access: tab 4.
- Elements:
  - Header: initial in a circle with the chosen color (36 px), "Hi, Daniel" 24/500 (no name: Pako's silhouette in the circle, "Hi" and subtitle "Tap to set your name"); tapping the header edits name and color in a sheet (H10). Gear icon top right → C6.
  - **My Tastes** card (`surfaceRaised`, radius 14): liked genres as small chips (max 3 + "+N"), line "3 vibes · since 1990 · never Horror"; tap → C5. No taste profile: the invitation card with a small Pako and a "My Tastes" button.
  - **Your Activity** card: four large numbers (watched · hours · favorites · watch later) and an amber "See stats" link → C4. No charts.
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
  - Filter chips: All · Movies · TV Shows.
  - Four metric cards in a 2×2 grid: Movies watched · Hours of movies · TV shows watched · Estimated TV hours.
  - "Genres you watch most": list of 5 horizontal bars with name and count.
  - "Your most-watched year": one large number + subtitle.
  - "Activity over the last 12 months": strip of 12 cells with intensity.
  - "Your average rating": number + stars.
- States: empty ("Mark something as watched to see your stats" + CTA).

### C5. My Tastes
- Access: My Tastes card in B5; invitation card in B1; or from the Surprise me result when saving.
- Elements (vertical scroll, everything editable in place):
  - "Genres you like" section: 3-column grid.
  - "Genres you never want" section: 3-column grid (mutually exclusive with the above).
  - "Vibes you like" section: 4-column grid of the 16 vibes.
  - "How far back" section: slider with a large number.
  - Auto-saved; discreet "Saved" text on change.
  - "Reset" link.
- States: none special.

---

### C6. Settings (pushed)
- Access: gear icon in B5. Back button, no bottom bar.
- Elements (grouped list; 52 px row, 16 px white label, 15 px gray value, chevron; no icons or group backgrounds; 13 px gray group header):
  - Preferences: Language ("Español" → H5), Region ("Spain" → H6, with search), Theme ("Dark" → H7), **Family mode** (toggle, off by default; subtitle "Hides titles rated R, NC-17, 18, and TV-MA"; applies `certification.lte` in `/discover` and filters in the match engine).
  - Data: "Export My List" (JSON → the system share sheet); "Delete My List", "Delete My Tastes" in red → I1 (the dialog states how many items it deletes).
  - About: Version (long-press copies the build number), Source code (GitHub, external link), Licenses (`showLicensePage`), TMDB attribution block with the official logo (the one exception to using a color that isn't ours) and 11 px text.
- Sheets H5–H7 are lists with an amber check on the active option; tapping applies and closes. Changing the theme does a 300 ms cross-fade.
- No Pako.

---

## D. Details

### D1. Movie detail
- Access: any movie card, poster, or row. Pushed screen; poster Hero transition.
- Header (55% of the height): full-bleed poster with slow parallax on scroll, fade to black starting at 60% of the poster; back circle (60% black) top left. Over the fade, centered: 32/500 title (max 2 lines, then 28), "2019 · 2 h 10 min · PG-13", "★ 7.9 · 12k votes", genres as tappable amber text separated by "·" (→ C1 with that genre and type Movies). When the title scrolls past the top, a compact black bar appears with back and the title at 16 px.
- White pill "Trailer" button, full width (opens YouTube: app scheme, then browser; selection: official + Trailer + user's language → official → Teaser → first available). No trailer: the button becomes "See similar" and scrolls to that section. Multiple trailers: an icon on the right with a menu.
- Row of three actions with a 24 px icon + 12 px label: Favorite · Watch later · Watched. Active = filled and amber label. "Watched" opens H2; if it was in Watch later it's removed with a snackbar "Marked as watched · Removed from Watch later". Tapping "Watched" again opens H2 with current values and a red "Remove from Watched" link.
- **Where to watch**: title with the region in gray on the right (tappable → H6); Subscription / Rent / Buy rows shown only if they have data, with 40 px provider logos (8 px radius, max 6 and "+N"); tap → opens TMDB's `link` in the browser. No data for the region: "Not available to stream in Spain". No data anywhere: the section doesn't appear. Mandatory 11 px footer "Data from JustWatch".
- Synopsis folded to 4 lines with an amber "Read more"; italic tagline if present.
- Cast: 10 circles at 64 px with name and character (→ D3); "See full cast" → H3.
- Director and writer: tappable names separated by "·" (→ D3).
- Similar: standard carousel, no "See all".
- Footer: "Data from TMDB".
- States: skeleton with the poster already visible via the Hero and centered blocks; full-screen error with "Retry"; offline with a snapshot if it's in My List (poster, title, year, genres) and network sections shown as "Not available offline".
- Exits: D3, C1, H2, H3, H6.

### D2. TV show detail
- Same as D1 with these changes:
  - Metadata line: "Year–Year · N seasons · M episodes · Rating".
  - Status pill next to the title: "Airing" (accent) / "Ended" (neutral).
  - "Created by": names (→ D3).
  - "Seasons" section: list of rows (thumbnail, "Season N", year, "X episodes", chevron) → H4.
  - No runtime; shows "≈ 45 min per episode" instead.
  - "Where to watch" same as D1 (providers are for the show; inside H4, the season's own providers show if they differ).
- Exits: D3, H4, H2.

### D3. Person detail
- Access: cast, crew, or search result.
- Elements:
  - Top bar with back.
  - Large circular photo, name, department ("Acting" / "Directing"), "Born: date · place".
  - Biography folded to 5 lines with "Read more".
  - "Known for": carousel of their 6 most popular titles.
  - "Filmography": filter chips All · Movies · TV Shows; reverse-chronological list (thumbnail, title, year, role).
- States: skeleton, error, offline.
- Exits: D1/D2.

---

## E. Surprise me (solo)

### E1. Choose type
- Access: "Surprise me" card in B3.
- Elements: headline "What are you in the mood for today?", two large cards "A movie" / "A TV show", each with an icon.
- Rule: if a taste profile exists, picking a type goes straight to E3 (no quiz). If not, → E2.
- Exits: E2 or E3.

### E2. Quiz (1 screen, 4 steps) — shared with the Matcher
- Access: E1 with no profile, or Matcher F2.
- Common elements: back button, "Step X of 4" indicator, large conversational headline, step content, full-width "Next" button (disabled until the step's rule is met). On step 1, at the top, a secondary "Use my tastes" button (only if a profile exists; fills answers in and jumps to step 4's confirmation).
- Step 1 — "Pick up to 3 you're NOT in the mood for": 4-column grid of genres for the chosen type; icon + name; max 3; counter "1 of 3".
- Step 2 — "Now pick 3 you ARE in the mood for": 4-column grid of the 16 vibes; exactly 3; counter "3 of 3".
- Step 3 — "How far back do you want to go?": large year number, full-width slider (1950–present), room for an illustration.
- Step 4 — Movie: "Max runtime" slider (60–240 min, large number, "No limit" at the far end). TV show: "Finished | Either" toggle + "Max seasons" stepper (1–10, "No limit"). Under both: a discreet "Exclude what I've already watched" toggle. Final button "Search".
- States: in the Matcher, if submission fails → inline error with retry.
- Exits: E3 (solo) or F3 (group).

### E3. Surprise me result
- Access: E1 or E2.
- Elements:
  - Standard background. Headline "Your suggestion".
  - If it came from the profile: subtitle "Based on your tastes"; if from the inferred list: "Based on your list".
  - White card: large poster, title, "Year · Genres", rating, 2-line synopsis, "View details" link (→ D1/D2).
  - If filters were relaxed: discreet note "We widened the search to 1990".
  - Primary button "Add to Watch later".
  - Secondary button "Another suggestion".
  - If it came from the quiz and there's no profile: link "Save these answers as my tastes" (→ saves and shows "Saved").
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
- **Empty**: outline icon, one-line headline, one-line body, optional CTA.
- **Error**: same layout with "Retry".
- **Offline**: persistent top banner "Offline" + screens use local data when available.
- **Snackbar**: short confirmations ("Added to Watch later", "Copied") with an "Undo" action when applicable.

---

## H. Sheets (bottom sheets)

| # | Sheet | Opens from | Content |
|---|---|---|---|
| H1 | Quick actions | Long-press a card | Thumbnail + title, three rows: Favorite / Watch later / Mark watched |
| H2 | Mark as watched | "Watched" button in D1/D2, swipe in B4, H1 | Title, 5-star selector (optional), date (today by default, editable), "Save" button, "Remove from Watched" link if it already was |
| H3 | Full cast | "See all" in D1/D2 | Cast and crew list with an internal search box |
| H4 | Season N | Season row in D2 | Title, season synopsis, episode list (number, name, runtime, date, still) |
| H5 | Language | B5 | Single-select list: Español / English |
| H6 | Region | B5 | Searchable list of countries |
| H7 | Theme | B5 | Dark / Light / System |
| H8 | Filters | B2, C1 | Type (All/Movies/TV Shows); multi-select genres; year (range slider 1950–present); minimum rating (0–9 slider, `vote_count.gte=100` fixed); max runtime (movies only); status Airing/Ended (TV shows only); sort by Popularity/Rating/Date/Title; "Hide what I've watched" toggle (client-side). "Reset" and "See N results" (N live) buttons. Only applies to `/discover`, not text search. |
| H9 | Sort and filter My List | B4 | Type (All/Movies/TV Shows); sort by Recent / Title A–Z / Year / TMDB rating and, in Watched, My rating / Date watched; in Watched, minimum rating (★1–5); in Favorites and Watch later, "Hide what I've watched". Remembers state per tab. "Reset" (only if something's active) and "Apply"; swiping to close discards. |
| H10 | Edit profile | B5 | Name and initial color (4). Same controls as onboarding step 1. |

## I. Dialogs

| # | Dialog | Opens from | Content |
|---|---|---|---|
| I1 | Confirm deletion | B5 | "Delete your list? This can't be undone." Cancel / Delete (destructive) |
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
