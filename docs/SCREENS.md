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
- Duration: max 1.5 s of animation; theme, language, `/configuration`, and `/trending/all/week` load **while** it plays — and the preload starts earlier still: `main()` kicks it off before the first Flutter frame, while the system shows the native splash. **There is one splash only**: the native one is just the page's dark color (no logo), so the animation starts on the same background with nothing to jump from.
- Exits: A2 if it's the first launch, otherwise → B1.

### A2. Onboarding (1 flow, 6 screens, in this order: welcome → **name (required)** → 2 intro slides → 2 genre steps)
- Access: first launch only.
- Purpose: introduce the app, collect the minimal user profile, and feed `TasteProfile`.
- **One look for the whole flow:** every call-to-action is the amber `AccentButton` ("Get started", "Continue", "Next", "Get started" again at the end), on the page margin (20 px); the warm glow behind the steps is never covered by a solid band, and the intro slides' phone fades out to *transparent* over it (a mask, not a solid fade — that left a seam above the home indicator), without its amber glow being cut at the top.
- Step 0 — Welcome (its "Get started" goes straight to the required name step): poster wall (4 staggered columns, 55% opacity, slow vertical drift; static with "reduce motion"), dark overlay over the wall (55% at the top, 35% at 30%, 90% at 62%, solid at 78%), the "PakoTV" wordmark at 48 px with a spaced-out uppercase tagline ("Find what to watch"), TMDB's required attribution line at 12 px, "Get started" button. Offline: same wall with placeholders.
- Step 1 — **What's your name? (required, no "Skip")**, on the warm bottom glow like the other steps: a large (112 px) live **avatar** on top — the typed name's initial, or a person icon while the field is empty, over the picked color (no mascot) —, the amber spaced eyebrow "YOUR PROFILE", a 32 px centered headline "What's your **name**?" ("¿Cómo te **llamas**?", one amber word) and a 16 px muted body ("That's what you'll be called in the app, and how others will see you in rooms."); a **NAME** label and the shared name field (the same as H10: `surfaceRaised`, amber hairline, full amber when focused, "Your name" and a `0/20` counter inside, 20 characters at most, auto-focused); a **COLOR** label and the **six colors** (amber, mint, coral, blue, lilac, white — the same as H10; amber preselected, a check on the picked one); and an amber **"Continue"** button (`AccentButton`) that stays disabled until the name has 2–20 characters (after trimming). Saves `UserProfile { displayName, initialColor }`. No age or gender is asked.
- Steps 1a and 1b — **Intro slides**, right **after the name** ("Skip" top right jumps past both, straight to "Make it yours"; "Next" advances): a 34 px centered headline with one amber phrase, a 15 px muted body, an amber-outlined phone illustration (250×640, built from widgets — no image assets — clipped at the bottom and faded out) with floating badges, **five pagination dots**, one per step after the welcome: the name is dot 1, the two slides dots 2–3, "Make it yours" dot 4 and the "never" step dot 5 (the name step and "never" show them above their button too) and a "Next" button. **Both slides are one layout with different data** (`OnboardingIntroSlide` + an `IntroSlideSpec`: copy, mini screen, callouts, active dot). **The phone is at the same height on both**: the text block reserves the room of the longest of the two texts (measured at the screen's width and text scale, so it holds in any language and text size; it scrolls past half the screen). **It adapts to the screen**: the phone and its callouts (positioned in the phone's own design pixels) are scaled together to fit the width — callouts included, so none leaves a narrow screen — and the height (0.6×–1.25×; a short screen shows a smaller phone, a large one a larger phone), always at the top of its room and centered. The picture ignores the user's text size (it is an illustration). The phone ends where the button begins (nothing of it shows behind or below the button) and the dots float over its faded-out bottom; its stroke stays amber at the corners.
  - 1a: "Find what to watch in seconds" — "Explore TMDB's catalog. It's not a streaming app: we tell you where to watch it." Illustration: a mini Discover.
  - 1b: "No idea? Surprise me" — "Answer a few questions or use your tastes and we'll suggest what to watch." Illustration: a mini result screen.
- Step 2 — **"Make it yours"** (the genres you like; skippable; fourth dot): on the warm glow, "Skip" top right, an amber spaced uppercase eyebrow, a 34 px headline "What do you like?" with "like" in amber, a 15 px muted body ("Pick a few genres to personalize Discover. You can fine-tune later in You › My Tastes."), every normalized genre as a centered wrapping **chip** (a picked one = amber, no limit), the five dots and an amber **"Next"** button (it is no longer the last screen). "Skip" and "Next" both just move on.
- Step 3 — **"And which ones never?"** (the genres you avoid; skippable; fifth dot; the last screen): the **same layout** as step 2 (one shared `OnboardingGenrePage`, which also uses the shared `GenreMultiSelectChips`), with the same "MAKE IT YOURS" eyebrow, the headline with "never" in **red** (`danger`), the body "Pick the ones you'd rather not see and we'll keep them out of your recommendations." and the chips: a picked one is **red and struck through, exactly as in My Tastes' "Genres you avoid"**; the genres liked on step 2 are **dimmed (30%) and can't be tapped**, so one can't be both liked and avoided. "Skip" and the amber **"Get started"** button both finish the flow.
- Exits: B1, with a "Tastes saved · Edit in You" snackbar if any genre was picked.

---

## B. Tabs (bottom bar with 4 + Match button)

Bottom bar: Discover · Explore (a **search** icon) · [Pako button] · My List (a **bookmark** icon) · You. A floating glass pill (inset 16 px, 68 px tall, blurred) with four icon-only tabs (26 px icon; active in white with a 5 px amber dot, inactive in gray) and in the center a **56 px amber circular button with a sparkle icon, straddling the pill's top edge** that opens B3 as a modal. White dot on the button when a room is active. Visible on the 4 roots; hidden in details, quiz, rooms, and inside the Match modal. The page scrolls under the bar and fades into the background behind it (an eased transparent-to-page-color gradient that starts ~72 px above the bar's top edge and is fully the page color at the very bottom, so content disappears gradually; it doesn't take touches); every root tab's list ends with padding equal to the bar's height, so the last item can be scrolled up above it.

### B1. Discover
- Access: tab 1 (root). Main screen.
- Elements:
  - Fixed amber halo behind the header and the top of the hero; fades with scrolling.
  - Top bar: "PakoTV" wordmark at 24 px on the left (arrives from the splash). Nothing else — search is the field under the hero.
  - Segmented control **All | Movies | TV Shows** (the app's one tab design — a contained pill with a white active pill, like B2/B4/C4/D3b/D1b — here in its **glass** variant: the track is the bottom bar's blurred translucent glass with a hairline border, so the halo shows through while the labels keep their contrast; remembers the last choice; 200 ms cross-fade on change). "All" by default.
  - **Hero** (no header): up to 8 cards, 330×380 at most (78% of the screen's width, so narrower on a small phone), 20 px radius (cropped poster); the title and the "year · genres · type" line are **centered at the bottom**, and the poster's lower part fades into the page's black the way D1/D2's header does — a long eased ramp from 30% down the card, nearly opaque by 90% and exactly the page's black at the foot — so the card has no visible bottom edge, with snap. **The banner in focus is centered and full size, with the previous and the next peeking in on both sides, smaller (88%) and dimmer (70% opacity)**; 12 px between cards. The zoom and the dimming follow the finger as it swipes (each card's distance to the page being shown), the hero's height never changes, tapping any card — a neighbour too — opens its detail, and with the system's "reduce motion" on every card stays at full scale (the dimming stays). Scrolling up, B1's content dissolves under the title and tabs with a short top fade instead of being cut by a hard line. **It loops**: swiping past the last banner brings the first back (a single banner doesn't loop); changing segment starts again at the first. Each card's round **save button** (top right) toggles that title in **Watch later** for real (stored through the library, shared with D1/D2 and B4, keeping its Favorite/Watched state); amber and filled while it's in Watch later. Full-bleed poster, fade to black over the bottom 40%; on top of it: reason tag (12 px pill, 60% black background; "For you" in amber), 26 px title, gray 13 px metadata ("2019 · Mystery, Comedy · Movie"). Circular save button (36 px) top right, amber if already in Watch later. No auto-advance, no dots. Tap → detail with Hero transition.
    - All: 3 For You (if there's a profile) + 3 mixed trending + 1 in theaters + 1 airing now. The first card is always "For you" when a profile exists. **Not built**: the hero itself doesn't mix in "For you" cards yet — only the carousel section below does (see F1b, `RecommendationBuilder`); the hero's own `getHeroItems` is unchanged.
    - Movies: 3 in theaters + 3 trending + 2 upcoming.
    - TV Shows: 3 airing now + 3 trending + 2 top rated.
    - Deduplicated; excludes anything already in My List.
  - **"For you" / "Because you…" sections** (F1b) — first, before every segment's own named sections below, and **rotating day to day** (no AI: a deterministic, day-stable rotation over the user's own signal, see DECISIONS §5 "Recommendations"). **All** follows the user's *taste profile* and only exists with a usable one (no liked genres/vibes → none of these sections, whatever My List holds): "For you" (a mix of up to two liked genres/vibes), "Because you like {genre}" (one liked genre) and "Because you want {vibe}" (one liked vibe). **Movies / TV Shows** follow *My List* and only exist with a signal there: "For you" (up to two genres from favorites and well-rated watches, minus genres rated badly) and "Because you like {title}" (one saved title: a favorite, or watched and rated ≥4★ — or, with the least weight, in Watch later; never something watched and rated ≤3★ or watched with no rating). Posterless items and anything already in My List are excluded, and a section below 6 results is simply absent. Each loads, errors, and retries on its own (see States below).
  - **Search field** right under the hero: 48 px pill in `surfaceRaised`, search icon + "Movies, TV shows, people" in muted text; tap → B2 **with its search field already focused and the keyboard up** (the bar is a shortcut to B2's field; every tap asks again, even if B2 was already open; opening B2 from its own tab doesn't grab the keyboard).
  - Sections (20/500 header + amber 14 px "See all" + a carousel, no title or year underneath). **Each section has its own size and shape**, as in B2, so the page has a rhythm: **Popular this week / Trending** large 150×225 posters; **Top rated** wide ~300×170 backdrop cards with the rating; **In theaters / Airing now** medium 130×195; **Finished shows** medium with an amber rating badge (bottom-left, like every poster's rating; only Top rated's wide cards put it top-left); **Coming soon / Upcoming** small 90×135 with the release date and year under each; **Watch later / Popular (TV)** the standard 110×165; **For you** large 150×225 and **Because you like X** standard:
    - All: **Recently viewed** (right under the search field, above "For you") · Popular this week · **Latest trailers** · Coming soon · In theaters · Watch later (if ≥ 3; the title links to B4). TV posters carry a small "TV" pill in the corner; movies don't. **Recently viewed**: the last titles whose detail (D1/D2) the user opened — at most 10, newest first, movies and shows mixed (the "TV" tag on shows), the standard 110×165 poster carousel with no "See all"; stored on the device (a local table, schema v7) and updated each time a detail loads: re-opening a title moves it to the front, the 11th drops the oldest. All tab only, and nothing is drawn until something has been viewed. **Latest trailers**: up to 8 current/upcoming movies, each a wide 16:9 card (the size of B2's Top rated) with the trailer's own YouTube thumbnail (16:9 first; the film's backdrop only if no thumbnail loads), a centered play button and the title; tapping opens the trailer in YouTube (the YouTube app, else the browser) — nothing plays in the app. Needs one request per title, so it loads on demand like the rest.
    - Movies: Trending · Top rated · Upcoming (the only section with a 13 px release date under the poster).
    - TV Shows: Airing now · Finished shows · Top rated · Popular. **Finished shows** shows 10 of the 20 titles TMDB returns, in a day-stable shuffle (same all day, different tomorrow); the other sections keep TMDB's order.
    - **Every section below the hero loads on demand** (only when it nears the viewport), each with its own skeleton and "Couldn't load · Retry".
  - **Taste card** (until the user has chosen their tastes — a usable taste profile), only on All: a full-width card in the feed, right after "Latest trailers" — a dark `surfaceRaised` card (20 px radius) with a soft amber glow in its top-left corner. **Left:** a sparkle + "FOR YOU" eyebrow in amber, the title "Recommendations tailored to you" and the one action, the **amber "Choose my tastes"** button (`AccentButton`, in its **dense** size — less padding and a `bodySm` label, 44 pt tall at most: amber with near-black text, always one line; → C5, My Tastes) — the card itself isn't tappable, and there is no round icon or arrow. **Right:** three real posters stacked with different tilts (88 pt wide, bleeding a little into the card's padding; static, bundled images in `assets/illustrations/taste_card/`: *Breaking Bad* (green), *Stranger Things* (red) and *Spider-Man: Into the Spider-Verse* (blue); poster art from TMDB). **The text column never gets less than 170 pt** (what "Recomendaciones" needs): on a narrow card the stack goes compact (two smaller posters) and on a very narrow one (≈ 320 pt screens) the posters are left out. **Its border carries a comet**: an amber glint with a fading tail and a soft blurred glow behind it that moves with it (`CometBorder`), a lap every 5 seconds, endlessly; with the system's "reduce motion" on it stands still (no animation runs at all). No Pako (it replaces the old invitation card in the hero's place, which no longer exists). It disappears as soon as a usable taste profile exists; **saving titles (Favorites, Watch later, Watched) does not hide it** — that isn't choosing tastes. (The "For you"/"Because you like X" *sections* follow their own, separate signal — see F1b — and can show from a library-only signal even with no profile, independently of this card.)
  - Long-press a poster → H1. Native pull-to-refresh — also refreshes "For you"/"Because you like X" (`RecommendationsCubit.refresh()`), alongside `DiscoverCubit`'s own reload.
  - "For you"/"Because you like X" also reload on a language/region change, and on returning from a pushed detail screen (tapping a title, then back) — never on switching bottom tabs away and back (B1 stays mounted under the tab shell, with no lifecycle event for that), and never just because My List changed (picked up next time one of the 3 triggers above fires). Never re-fetches over the network when the underlying signal hasn't actually changed.
- States: per-section skeleton (exact-sized blocks, subtle shimmer; carousels enter staggered with 60 ms as data arrives); per-section error (90 px row "Couldn't load · Retry") — real today for "For you"/"Because you like X" (`RecommendationsCubit`'s own two independent slots); the 8 sections below `DiscoverCubit` owns still fail and retry together as one segment (`docs/TODO_AUDIT.md`'s own "revisit after v1.0" note). "Offline" banner under the header with cached sections still visible.
- Exits: D1/D2 (card or poster), C1 ("See all"), B2, C5, B4, H1.

### B2. Explore (search + genre browsing + filters)
- Access: tab 2; also from the search icon in B1 (arrives with the field focused and the keyboard open).
- Purpose: everything **intentional** (Discover is the editorial side). No Pako, no halo.
- Common elements: no title (opens on the field). The **search field** ("Movies, TV shows, people") spans the page's **full content width** and, while focused, shows a **1.5 px primary-color (amber) ring** (it adds no size, so nothing moves) (20 px margins like Home); at rest (empty, unfocused) its trailing icon is the **filter** (equalizer) icon, which opens H8; once focused or with text it becomes a "×" that clears the search (or dismisses the field) — there is no "Cancel". Under it the segmented **All | Movies | TV Shows** (and **People** joins at the end while a search is on), the app's contained pill (`surfaceRaised`, white active segment). Everything below sits on the same 20 px margin and `sectionGap` rhythm as B1; the page scrolls under the floating bar like every root tab and its content fades under the field and tabs.
- **State 1 — At rest** (empty field): two pill rows, both single select and both filtering everything below them in place together with the segment (a genre and a platform combine): **GENRE** — "All" + the normalized genres — and **PLATFORM** — "All" + the streaming services TMDB lists for the user's region from Settings (the region's top 8 in TMDB's own ranking there — storefronts and re-sold channels such as "Apple TV Store", "JustWatch TV" or "… Amazon Channel" left out —, each with its 24 px logo; hidden when the region has none, a retry row on error). The picked genre persists across segment changes; the platform is dropped if the new list lacks it. Then six **sections**, each with its heading and an amber "See all" (→ C1b with exactly that section's filter, genre and platform included) and — deliberately — **its own size and shape**, so the page has a rhythm and the lead section stands out: **Top today** (large 150×225 posters, a big outlined rank number in Manrope extra-bold, and a focus zoom: the poster at the leading edge is full size while the others shrink and dim slightly with distance as it scrolls; none with reduced motion), **Popular** (standard 110×165), **Top rated** (the lead: wide ~300×170 backdrop cards with the title, year and ★ rating on them, and a supporting line under its heading), **New releases** (130×195, no badge — the heading already says it), **Coming soon** (small 90×135 with the release date and year under each), **Hidden gems** (130×195 posters laid out like the results lists: the "TV" tag top-left on shows (All segment), the amber-star rating bottom-left and the title under the poster). In order and meaning: **Top today** (the most popular right now, a big 1, 2, 3… over each poster), **Popular** (the most voted of all time — the classics), **Top rated**, **New releases** (released in the last 60 days, most popular first), **Coming soon** (releasing from tomorrow to 90 days ahead, most popular first) and **Hidden gems** (rated 7.3+ with 150–1,500 votes). **Popular** and **Hidden gems** show a day-stable shuffle of the page TMDB returned (10 of its 20 titles, the same all day, a different slice tomorrow) so these all-time lists don't look identical every day; **Top rated** and the rest keep TMDB's own order ("See all" always lists the full, ordered result). Each **loads on demand**, only when it nears the viewport (and again when the platform or segment changes while it is near) — the page opens with just the first sections fetched — with its own skeleton and per-section "Couldn't load · Retry", a section that comes back empty is omitted, and if all are empty a "Nothing for these filters" state shows. **Recent searches** appear as a **panel that drops from under the search field** while the field is focused and empty — over the segmented control and the page, which dims behind it (a tap on the dim dismisses). The panel is `surfaceRaised` with a 24 px radius and a fixed first row — **RECENT** (small spaced capitals) on the left and an amber **"Clear all"** on the right — a hairline, then one row per saved search (last 10): a clock, the text, and a **×** that removes it; tapping the row runs the search. The rows scroll when there are more than fit, **the first row never scrolls**, with a plain scrollbar (no edge fade) and the page behind the panel blurred and dimmed. **A fixed size**: the panel is the header plus **five and a half rows** — the half-cut sixth tells the user there is more to scroll to — whatever the number of searches (at most 10 are kept); fewer searches make it shorter. That leaves a good part of the dimmed page under it, above the tab bar, to **tap and dismiss**. It shrinks only where the screen is too short for that (a small phone with the keyboard up): it keeps the floating tab bar's inset and at least 64 px of page free under it. It **only exists when the saved history has something in it**; typing swaps it for the results, and the pills and sections below are untouched. While the field is focused it also carries a **×** (empty: it dismisses the field and the panel; with text: it clears the search). Changing the Settings region reloads the platforms and clears the picked one.
- **State 2 — Typing** (400 ms debounce): the field gains "×" and "Cancel"; the `/search/multi` results list replaces the page's sections. **Each row is D3b's list tile** on the 20 px page margin with a hairline under it: a 52×76 leading slot, a 15 px title (up to 2 lines), a muted **subtitle**, an optional **third line**, and a **chevron** at the end that says tapping goes to more info. A **title**'s row: poster; title; **"Year · Movie/TV Show · Genre"** (one genre — the first, which identifies it best — and parts TMDB doesn't know are left out); third line the **★ rating** with its number (none while TMDB has no score). A **person**'s row: a round photo in the same slot (their initial when there is none), the name, and "Department · Person" ("Person" alone with no known department); tap → D3. The segment filters client-side: **All** shows everything, **Movies** and **TV Shows** hide people, **People** shows only people. People sort last in All unless there's an exact name match (a person whose name is exactly the query goes first; titles keep TMDB's order). Infinite scroll. If filters are active, their chips dim with the text "Filters don't apply to text search".
- **People** is a segment only **while searching** (a person is found by name; there is nothing to browse for them at rest): the control shows All | Movies | TV Shows | People once the field has text, and People narrows the results to people. Clearing or emptying the field goes back to rest on **All**, with the three segments.
- **State 3 — Listing** (see C1): after tapping a genre tile, applying filters, or arriving from "See all".
- States: tile/row skeleton; "No results" (icon badge + title, a body naming the query — "We couldn't find anything for “{query}”. Try another title, show or person." — and a secondary "Clear search" button that clears the field and returns to rest); error; offline.
- Exits: D1/D2/D3, C1.

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
  - Segmented Favorites · Watch later · Watched · **People**, drawn as a contained pill (same as B2's). **No counts** in the labels. **People** lists the people saved with the heart on D3 (`SavedPeopleRepository`), by name A–Z, each as the same row as a person in B2's search (round photo, name, "Department · Person", chevron; tap → D3); swipe left → "Remove" (red, "Removed from People" snackbar with "Undo" for 4 s). On People the filter icon is hidden (people have no type, sort or rating to filter by) and the filter row never shows. Empty: icon badge, "No people yet", "Tap the heart on a person's page to keep them here." and "Explore" (centered clear of the bar).
  - Row of amber chips with active filters (each with "×"), only when something differs from the default.
  - Rows: 56×84 poster, 16/500 title, gray 13 px line ("2022 · TV Show · 24 episodes" / "2023 · Movie · 1 h 46 min") — rendered entirely from the saved entry's own catalog snapshot, no network call; the episode count/runtime segment only appears once the entry has picked one up (a toggle or Save from the detail screen, or the detail screen's own lazy refresh on reopening) — until then the line is just "year · type". Right-hand column per tab: Favorites and Watch later → relative date saved; Watched → 1–5 amber stars (empty ones in dark gray; unrated shows all five in gray) and a short date. Tapping the stars → H2 directly.
  - Swipe left → "Remove" (red, snackbar with "Undo" for 4 s, no dialog); swipe right → "Watched" (amber → H2) in Favorites/Watch later, "Favorite" in Watched. Long-press → H1.
  - Default sort: Title A–Z, every tab (there's no "date saved" field to sort Favorites/Watch later by; Watched also offers Date watched from H9, just not as the default).
- States (centered in the room the floating bar leaves free, `ClearOfTabBar`): empty with sleeping Pako (Rive, `mood = asleep`), per-tab headline ("No favorites yet" / "Nothing for later yet" / "You haven't marked anything as watched yet"), a line mentioning what does exist in other tabs, "Explore" CTA. If a filter is what's emptying the list: "No TV shows here" + "See all".
- Exits: D1/D2, H1, H2, H9.

### B5. You
- Access: tab 4.
- Elements:
  - Header: initial in a circle with the chosen color (48 px, small pencil badge bottom right), "Hi, Daniel" 26/600 (no name: a person icon in the circle, "Hi" and subtitle "Tap to set your name"); tapping the header edits name and color in a sheet (H10). Gear icon top right → C6.
  - **My Tastes** card (`surfaceRaised`, radius 16): liked genres as small chips (max 3 + "+N"), line "3 vibes · since 1990 · never Horror"; tap → C5. No taste profile: the invitation card with a small Pako and a "My Tastes" button.
  - **Your Activity** card: four large numbers in a strip with hairline dividers (watched · hours · favorites · watch later) and an amber "See stats" link → C4. No charts.
  - **Recent Rooms** card (v1.1): up to 10 local matches (thumbnail, title, "with Ana and Luis · yesterday"); tap → D1/D2. Not shown if there are none.
- No halo, no large Pako. Amber only on the initial's circle and the stats link.
- Exits: C4, C5, C6, H10, D1/D2.

---

## C. Secondary catalog screens

### C1. Filtered listing (See all · Genre · Results)
- Access: "See all" from B1 (arrives with the collection's name and no filters), a genre tile in B2, or "See results" from H8.
- Elements: top bar with back, the centered title ("Results" / "Horror" / …) and the **filter icon with an amber badge** counting the filters set (none: no badge; the kind of title and the sort never count) → H8. Under the bar, one line of **active-filter chips**, each amber with "×" (the preset, the streaming service by name, each genre, the years, the rating range, the original language) that scrolls sideways when it doesn't fit; "×" drops just that filter. There is **no count line and no quick sort** here: the results are the grid itself, and the order is chosen in the filters (H8's "Sort by", whose Top rated asks for 300 votes). There is deliberately **no alphabetical order**: TMDB sorts by the *original* title (not the one shown) and stops at page 500 (10,000 results, about the letter M of a big catalog). Then the **3-column grid** (the app's one results layout, 20 px between rows and 12 between columns: each tile is the poster with its **platform logo** top-right when the filter has no platform picked (one small request per title, as in C1b), its **rating badge** bottom-left and the **"TV" tag** top-left if it is a show, and its **title under it** on one line with the **release year** under that) with infinite scroll; the header's last line keeps a margin above the grid, whose top edge fades like Home's: the first page loads with the screen and the next ones as the grid nears its end (titles repeated across pages are dropped).
- **No filters left** (every chip dropped, or "Clear" in H8) is a valid state, not an empty one: the list is every title of the segment, most popular first, with no chips and no badge.
- Source: `/discover/{movie|tv}` with the filters; All = both interleaved. "See all" collections use their own endpoint until a filter is touched, at which point they switch to the equivalent `/discover` call.
- States: grid skeleton; **no results** ("Nothing with those filters" / "Try fewer filters or a lower minimum rating." and a secondary "Clear filters" button that goes back to the segment's default) — the chips and the badge stay visible above it so a filter can be dropped right there; error ("Retry"); offline.
- Exits: D1/D2, H8.

### C1b. Section listing ("See all" of a section)
- Access: "See all" on any Explore section (B2) or Home carousel (B1). Pushed on the root navigator (back button, bottom bar hidden). It replaces C1 for those two entry points; C1 remains for a genre tapped in D1/D2.
- Elements: top bar with back and the **section's title** (centered). Under the bar, **from Explore only**, the **context pill** (the app's selected-pill look: dark amber tint, amber hairline, amber text; informational, not a control), **centered** in its row, showing what Explore had set — the picked **platform's logo + a dot + the genre** (or "All genres"; with no platform, just the genre) —; **from Home there is no row at all** (the segment isn't shown) and the grid starts right under the bar, with a page gap below it so it clears the grid's top fade. There is no count: a listing is never longer than 100 titles. Then the **3-column grid** of posters (the same layout as C1); posters scrolling up under the toolbar fade out, as on Home.
- **Sorting is switched off for now**: there is no sort icon on this screen (`SectionListingScreen.sortEnabled`, false by default). The Cubit's re-sorting and the sort sheet are built and tested; only the entry point is hidden. When it comes back, the pill moves to the left of the row and the icon (two arrows, small, its glyph lined up with the grid's right edge, amber off the section's own order) goes at the far right.
- **Every poster of the grid is the results-list tile** (as in C1): the "TV" tag top-left on shows, the amber-star rating bottom-left, and **always the title under the poster with its subtitle below it** — the release year, or the full date (`12 Jan, 2026` / `12 ene, 2026`, see DESIGN_SYSTEM) in the upcoming sections (Coming soon, Upcoming; also under Newest first there). Nothing is laid over the poster's foot but the rating (or the rank).
- **Platform logos**: when Explore had no platform picked (whatever the genre), each poster shows a small logo of the platform it streams on (the most relevant subscription service in the user's region; nothing when it has none) in its **top-right corner** — the one corner no other dressing uses (the "TV" tag and rating badge are top-left, the rank, date and year bottom-left, the title along the foot), so it never covers anything. There is no bulk lookup: each title costs one small request, made when its poster is first built (only what is on or near the screen), remembered for the life of the screen. Not shown from Home, nor when a platform is picked (every title is on it).
- **The list is a fixed set: the section's first 100 titles in its own order** ("Top 100"). It opens with one request and **pages in on demand** (CLAUDE.md rule 17) while in its own order: the next page is requested when the end of the grid is about a screen away, and again after each page that arrives (also when the first page doesn't fill the screen); a footer spinner while it loads, "Couldn't load more · Retry" if it fails; titles repeated across pages are dropped; it stops at the last page or at 100 titles, whichever comes first. Pull to refresh starts over.
- **Re-sorting reorders that same list, on the client — it never asks TMDB for a different one.** The first time another order is picked, the missing pages (up to 100 titles) are fetched in parallel (a skeleton shows meanwhile); from then on any order, including going back to the section's own, is instant and costs no request, and the list no longer pages (it is all there). The titles are held in memory by the screen only — nothing is persisted or shared; leaving the screen discards them. Ties keep the section's own order (equal ratings: more votes first).
- **The sort only changes the order, plus one thing**: with **Popularity** each poster's bottom-left shows its position (a small outlined rank, same type as the carousel's big one) instead of the rating. Every other order keeps the rating; the title and year/date under each poster never change. (Top today keeps the rank in its own order.)
- **Sort sheet** (only while sorting is switched on; single select, amber check): **Default order** (what the section previewed; the listing opens in it), **Popularity** (TMDB's popularity score), **Rating**, **Most voted** (vote count), **Newest first**. A section whose window is in the future (Coming soon, Upcoming) offers only Default, Popularity and Newest first — unreleased titles have no votes to rate.
- Source: Explore — `/discover/{movie|tv}` with the section's filter plus the genre and platform, in the section's own sort; All interleaves both types page by page. Home — the collection's own endpoint (exactly what the carousel previewed). Either way the first 100 titles; every other order is computed from them.
- States: grid skeleton, error with "Retry", empty ("Nothing to show here"), next-page error in the footer.
- Exits: D1/D2.

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
- Header (420 px, up from 320 so the key art has more presence): TMDB's 16:9 backdrop, full width (the poster when TMDB has no backdrop), with a 35% dark scrim at the top and a fade into the page color starting at 30%; back circle (translucent black) top left and a Share circle (same style) top right — **pinned over the page, they don't scroll with the header**, so they can never be carried up under the status bar — that opens the system share sheet with the title and its TMDB link ("Title\nhttps://www.themoviedb.org/movie/{id}"). Over the fade, left-aligned: the 32 px title (max 2 lines) with the italic muted tagline under it, if any. When the title scrolls past the top, a compact black bar appears with back, the title at 16 px and a Share icon at the end; once shown it stays for the rest of the scroll, however far down, and turns back into the transparent header only when the scroll returns to the top.
- **Not out yet / only in cinemas** (D1, and D2 for a series whose first episode is ahead): the header carries a **status tag above the title** (the shared poster tag): amber **"Coming {date}"** (or **"Coming soon"** when TMDB gives no date) for a title that isn't out, and the same amber design for **"In theaters"** on a movie that opened in cinemas and has no digital, physical or TV release yet. It is worked out for the region being viewed (Settings, or the one picked on the Where to watch card) from TMDB's per-region release dates — a festival premiere never counts as the release; a movie counts as "in theaters" for up to 90 days after opening; with no reliable dates and TMDB's own status (Planned, In Production, Post Production, Rumored) it is "Coming soon"; and an ordinary released title, or one whose data can't say, shows **no tag** rather than a wrong one. For a title **not out yet**: the **rating chip is hidden** (TMDB reports 0.0), **Watched is hidden** (nothing to have watched) and **Watch later becomes the wide labeled action** beside Favorite; the trailer stays the primary button. Its **Where to watch** card, with no service listed, says why instead of "Not available": "It isn't out yet. It comes out on {date}." For one **in theaters**: "In theaters now. Expected on streaming on {date}." (or "…and not on any service yet." with no date); Watched and the rating stay. (Poster tags in lists are a later pass.)
- White pill "Trailer" button with a play icon, full width (opens YouTube: app scheme, then browser; selection: official + Trailer + user's language → official → Teaser → first available). The button always leads somewhere: no trailer → "See similar" (scrolls to that section, only when there are similar titles) → none either → "Where to watch" (scrolls to that card, only when a service is listed) → nothing to jump to → **no button** at all (the info card simply follows the header). D2 behaves the same. Multiple trailers: an icon on the right with a menu.
- Info card under the button (`surfaceRaised`, radius 16, hairline border): the 100×150 poster on the left; on the right "year · country · genres" in muted text (the main production country by its name in the app's language, e.g. "2010 · United States" / "2010 · Estados Unidos", via `flutter_localized_locales`; each genre tappable → C1 with that genre and type Movies), info chips (★ rating and the original language's name in the app's language, "English" / "Inglés"), and the row of three actions in 44 px bordered rounded boxes: Favorite and Watch later as icon-only squares (their names are accessibility labels), Watched as a wide button with icon and label. Active = filled icon, amber border and a faint amber tint. "Watched" opens H2; if it was in Watch later it's removed with a snackbar "Marked as watched · Removed from Watch later". Tapping "Watched" again opens H2 with current values and a red "Remove from Watched" link.
- **Where to watch**: a `surfaceRaised` card (radius 16, hairline border) with the title and a "JustWatch" badge on the right. Inside, the **Streaming** box on top (amber label and a faint amber border; up to 5 services as 56 px logos with their names under them), then **Rent** and **Buy** side by side (neutral boxes; up to 3 services each as 36 px logos), each with "+N" when there are more. A service with no logo shows its first letter. Under the title, a **country pill** (globe, country name, chevron; outlined, 36 px tall) that opens H6 — choosing a country reloads the detail in place for that screen only (no loading screen, scroll kept) and does not change the saved region; leaving and re-entering shows the saved region again. Under the boxes: "Tap a service to open it in JustWatch"; any service tile opens TMDB's `link` in the browser. Groups with no data are omitted; no data anywhere: the card stays, with "Not available to stream, rent or buy in {country}. Try another country." under the pill, so the country can always be changed. Mandatory 11 px footer "Data from JustWatch".
- Two stat cards under the info card, side by side: **Duration** ("2 h 28 min") and **Classification** ("PG-13"); a card without data is omitted, and neither data means no row.
- Synopsis under a "SYNOPSIS" caption (muted, capitals), folded to 4 lines. The amber toggle appears only when the text is really cut: "Read more" expands, then it becomes "Read less" to fold it back; a synopsis that fits has no toggle (the tagline lives in the header).
- Cast: a "Cast" heading with "See all" (amber, → D1b) on the right — shown whenever the full page has more to show: more than 10 cast **or any crew** (D1b has the Crew tab) — then a muted credit line (**"Directed by …"**, the film's director(s), names → D3; D2 shows **"Created by …"**; hidden when there is no one), then 10 circles at 64 px with name and character (→ D3). No list of crew names inline.
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
- Same as D1 (one shared assembly: header → trailer → info card → cards → synopsis → where to watch → cast → … → similar → footer) with these changes:
  - The info card's meta line is "Year–Year · country · genres" (the country's name in the app's language; the air years, just the first when the last is unknown or the same); the chips are the rating and the original language's name. Seasons, episodes and status moved to the cards below, so the line no longer carries them or the certification.
  - **Two cards** under the info card, side by side (the same stat cards as D1's Duration / Classification): **Status** ("Airing" / "Ended" / "Cancelled") and **Seasons** ("5 · 62 episodes" / "5 · 62 episodios": seasons, a dot, the episode count and its word, pluralised; one line, ending in an ellipsis if it doesn't fit) with a chevron → D2b (it replaces the inline season list; it's omitted when the show has no regular season). There is no status pill in the header.
  - Section order: cards → **Synopsis → Where to watch → Cast** (the "Cast" heading, then the **"Created by"** line with the creators' names → D3, then the circles; "See all" → D1b as in D1) → **Similar TV shows** → footer.
  - No runtime; shows "≈ 45 min per episode" instead — not on this screen itself, already covered by C4's "Estimated TV hours" (`TvShowDetail.estimatedHours`).
  - "Where to watch" same as D1 (the show's own providers, the region pill and picking a country for this screen only; a season's own providers, if they ever differ, aren't modeled yet — `MediaRepository.season()`'s `SeasonDetail` has no `watchProviders` field).
- Exits: D1b, D2b, D3, H2.

### D2b. Seasons (pushed)
- Access: the "Seasons" card in D2. Pushed screen: back button, centered "Seasons" title, no bottom bar. Receives the already-loaded show (no network call of its own).
- Elements (vertical scroll):
  - Header card (`surfaceRaised`): the show's name and three info chips — status ("Airing" / "Ended" / "Cancelled"), "N seasons", "M episodes".
  - "NEXT EPISODE" caption + card: the next scheduled episode (still, "S2 · E6 · Name", air date chip) or, with none, "No next episode" and "No upcoming episode has been announced yet.". **Omitted entirely for a show that has ended or been cancelled** (it can't have one).
  - Every card (header, episode, season) is the full content width, whatever its text.
  - "LAST AIRED EPISODE" caption + card: still (92×56), "S5 · E16 · Name", air-date and ★ rating chips (rating only if TMDB has one). Omitted when TMDB reports none.
  - "SEASONS" caption + one bordered card per season (44×64 thumbnail, "Season N", year, "X episodes", chevron) → D2c. A specials season (TMDB's season 0) sorts last, labeled "Specials", and only appears at all if it has episodes.
- No Pako.
- Exits: D2c.

### D2c. Season (pushed)
- Access: a season card in D2b (it replaces the old H4 bottom sheet). Pushed screen: back button and the show's name centered as the title (none when the name isn't known), no bottom bar. Receives the show's id and what D2b already has on the season, so the header shows at once; the synopsis and episodes are fetched on demand.
- Elements (vertical scroll): header card (poster, "Season N" — "Specials" for season 0 —, an episode-count chip and, when TMDB has one, a ★ rating chip); the season synopsis folded to 2 lines (the amber Read more / Read less appears only when it is cut); an "EPISODES" caption and a list of compact rows (112×64 still with a number badge, name, date · runtime, 2-line synopsis, chevron) → H4b.
- States: the header immediately, a skeleton for the episodes, an error with its message.
- Exits: H4b.

### D3. Person detail
- Access: cast, crew, or search result.
- Elements:
  - Top bar with back and, top right, a **heart** (the translucent circle, `ScrimIconButton`) that saves the person to My List's **People** tab (B4) or forgets them — outline when not saved, filled amber when saved; no snackbar. Saved locally (`SavedPeopleRepository`, drift schema v8). A compact bar with the name (the same heart at its end, no Share) appears once scrolled past the header and stays for the rest of the scroll, same as D1/D2. The header's height is remembered, because the header itself stops being built once it is far off-screen.
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
| H4b | Episode | Episode row in D2c | Sheet over D2c: a 16:9 still, "S1 · E1" caption ("Specials · E1" for season 0), the episode name, info chips (air date, runtime, ★ rating when TMDB has one), the full synopsis, and a "GUEST STARS" row of 64 px circles with name and character (→ D3) when the episode lists any |
| H5 | Language | B5 | Single-select list: Español / English — one setting for the interface and TMDB's content |
| H6 | Region | B5 | Searchable list of countries, with a one-line subtitle ("Sets which services you see in Where to watch") |
| H7 | Theme | B5 | Dark / Light / System |
| H8 | Filters | B2, C1 | Bottom sheet (opens above the floating bar, **at most 90% of the screen tall**: the header and the kind tabs stay at the top, the filters scroll, and **"See N results" is pinned at the bottom**). Header: "Filters" and, only while something is set, an amber **Clear** that goes back to the default of the picked kind. Under it the **All | Movies | TV Shows** tabs (the app's one segmented control, on a `surfaceRaised2` track so it shows against the sheet; they start on the screen's segment; changing the kind drops the preset and the platform). Then, in order: **Sort by** (Popular · Top rated · Newest · Oldest, plus presets of the kind: **Movies** Coming soon (tomorrow to 90 days ahead) · In theaters (released in the last 45 days); **TV Shows** Finished · Airing now; **All** none — one choice among all of them, a preset is ordered by popularity and a release-window preset hides Years), **Streaming on** (only the region's top 8, as in B2 — a shortcut: searching without a platform already mixes every service —, as logo chips, single select, the region's name at the right; left out when the region has none), **Genres** (multi-select, any of them), **Years** (two text fields, first and last year, typed — digits only, 4 at most; each year must be 1900–(current year + 2) and the first can't be after the last: a wrong field gets the danger border and nothing is applied until both are right; a half-typed year is left alone, an empty field is an open end, and leaving a field without a valid year puts the filter's value back. The sheet keeps the button above the keyboard), **Rating** (range slider 0–10 in half points; `vote_count.gte=100` fixed) and **Original language** (Any · English · Español · Français · Deutsch · Italiano · Português · 日本語 · 한국어 · 中文 · हिन्दी · Русский · Türkçe, each written in itself, single select, scrolls sideways; `with_original_language`). Runtime and "hide what I've watched" are deliberately not offered. The button **"See results"** — no number (TMDB's `total_results` for the draft is still checked, debounced, only so that the button is disabled and says "No results" at 0). Drafts only apply on that button; swiping closed discards. Only applies to `/discover`, not text search. |
| H9 | Sort and filter My List | B4 | Type (All/Movies/TV Shows); sort by Title A–Z / Year / TMDB rating and, in Watched, My rating / Date watched; in Watched, minimum rating (★1–5); in Favorites and Watch later, "Hide what I've watched". Remembers state per tab. "Reset" (only if something's active) and "Apply"; swiping to close discards. |
| H10 | Edit profile | B5 | Sheet: a large (72 px) live **avatar** on top (the initial over the picked color, a person icon while the name is empty), the title and body, a **NAME** label with the shared name field (`surfaceRaised`, amber hairline — full amber when focused — hint "Your name" and a `0/20` counter inside, 20 characters at most), a **COLOR** label with the **six colors** (amber, mint, coral, blue, lilac, white; amber preselected, a check on the picked one, spread across the width) and "Save" (disabled under 2 characters). The same controls as onboarding's name step (`ProfileNameField`, `ProfileColorPicker`, `ProfileAvatar`). |
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
- F-C: Explore → chips → TV show detail → Seasons → Season page.
- F-D: Match hub → Surprise me → (type) → Quiz → Result → Save tastes.
- F-E: Match hub → Create room → Waiting room → Quiz → Waiting room → Result (host).
- F-F: Match hub → Scanner → Name → Quiz → Waiting room → Result (guest).
