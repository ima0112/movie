# PakoTV — guide for Claude Code

Movie and TV show catalog app (Flutter, iOS + Android) with a group
recommendation engine (the "Matcher") and an animated mascot (Pako).
Portfolio project, public repo.

**Before writing code for a new screen or feature, read the matching
document in `/docs/` listed below.** Don't assume color, size, or behavior
values — they're all fixed in those documents. If something isn't covered,
ask before inventing it.

## Documents and when to read them

| Document | Read it when... |
|---|---|
| `docs/DESIGN_SYSTEM.md` | You're about to write ANY widget. Colors, typography, spacing, radii, icons. The single source of truth — never hardcode a hex or a size that already exists as a token. |
| `docs/SCREENS.md` | You're about to build a specific screen, sheet, or dialog. Has, per screen: access, exact elements, states, and where it navigates to. |
| `docs/DECISIONS.md` | You need product context, which API to use for what, or a scope decision (what's NOT built and why). |
| `docs/STRUCTURE.md` | You're about to create a new file and don't know which folder it belongs in, or want to confirm a technical choice (Bloc, get_it/injectable, go_router, Dio, drift). |

## Architecture rules (non-negotiable)

1. **Clean Architecture, feature-first.** Each feature lives in
   `lib/features/<x>/` with `domain/` (pure, no Flutter or networking
   packages), `data/` (repos + DTOs), and `presentation/` (UI). `domain`
   never imports from `data` or another feature — only from `core/domain`.
2. **A single network entry point**: `core/network/api_client.dart`. No
   widget or repository builds a TMDB URL by hand.
3. **Custom domain models**, never TMDB DTOs in the `presentation` layer.
   Mapping lives in `data/*/mappers.dart`.
4. **Never hardcode style literals.** Zero `Color(0xFF...)`,
   `fontSize: 16`, `EdgeInsets.all(14)` scattered in a screen widget.
   Everything goes through `AppColors`, `AppTextStyles`, `AppSpacing` (see
   DESIGN_SYSTEM.md). If a value doesn't exist as a token, that's a sign
   it's missing from that document, not a reason to improvise it in the
   widget.
5. **Icons**: `remixicon` package, `_line` variant by default and `_fill`
   for active states (favorite, selected tab). Never mix with Material's
   `Icons.*` or `CupertinoIcons.*`. Pako's icons are custom SVGs in
   `assets/icons/pako/`, not an icon package. (Switched from
   `phosphor_flutter` — see `docs/DESIGN_SYSTEM.md` section 4 for why.)
6. **One single visual look on iOS and Android** (no Cupertino widgets for
   a native feel). What IS respected underneath: system gestures for
   "back", `HapticFeedback` at the points SCREENS.md specifies, real
   `SafeArea` instead of fixed paddings. See the "iOS vs Android" table in
   DESIGN_SYSTEM.md before touching anything platform-related.
7. **Sealed `Result<T>`**, never exceptions crossing from `data` to
   `presentation`. See `core/domain/entities/result.dart`.
8. **Every new screen** must state, in the PR (or the commit), which entry
   of the SCREENS.md inventory it implements (e.g. "implements B1.
   Discover"). If no entry exists yet, don't build it without first adding
   it to that document.
9. **Granular Bloc rebuilds — no exceptions.** A screen-wide `BlocBuilder`
   wrapping the entire widget tree is not acceptable. Every `BlocBuilder`
   must scope to the smallest widget that actually needs to change:
   - Prefer several small, local `BlocBuilder`/`BlocSelector` widgets over
     one wrapping the whole screen. A toggle (favorite/watch later/watched,
     a chip, a tab) rebuilds only itself, never the carousel, list, or
     scaffold around it.
   - Always pass `buildWhen` (or use `BlocSelector`) when a widget only
     cares about part of the state — e.g. a save button watches a `Set<int>`
     of saved ids, not the whole `DiscoverState`.
   - Static structure (app bar, tab bar, layout scaffolding) must never sit
     inside a `BlocBuilder` at all — build it once, outside.
   - When implementing a screen, explicitly identify each independently
     toggleable piece of UI (an icon button, a chip, a single row) before
     writing the `build()` method, and give each one its own narrowly
     scoped builder. If you can't justify why a `BlocBuilder`'s subtree is
     as large as it is, it's too large.
10. **Global vs. screen-local Cubits — decide by lifecycle, not by tree
    position.** A Cubit is global only if its state must outlive the screen
    that first needed it AND be read/reacted to by other, unrelated screens.
    Ask: does this Cubit's lifecycle match a single screen, or does it need
    to persist and be shared beyond it? If it matches one screen, it's
    local — even if several screens instantiate the same Cubit class, each
    gets its own instance via a local `BlocProvider`.
    - **Global** (provided once, in `app/app.dart`, above `MaterialApp.router`):
      `TasteProfileCubit`, `UserProfileCubit`, `ConnectivityCubit` (the app's
      online/offline, read by the offline banner on Home and Explore), and — once v1.1 exists —
      `MatchRoomCubit` for the lifetime of an active room.
    - **NOT global, even though it feels shared**: My List (favorites/watch
      later/watched). Don't create a library-wide Cubit holding an in-memory
      copy of the whole list. Instead, `UserLibraryRepository` exposes
      `Stream`s (see `core/domain/repositories/user_library_repository.dart`)
      and each screen subscribes locally, scoped to only what it needs (e.g.
      a single icon subscribes to "is this one id saved?", not to the whole
      library). This is the same discipline as rule 9, applied to data
      ownership instead of widget rebuilds.
    - Every screen-local Cubit is created where its `BlocProvider` is placed
      (inside that screen's widget), not registered in `di.config.dart` —
      only repositories/services are registered there.
11. **File size — one widget, one class, one file.** A private `_buildX()`
    method inside a giant `build()` does NOT satisfy this rule; the file is
    still one large blob organized into functions. Any widget with its own
    layout logic, state, or Bloc subscription gets its own file:
    - **Soft limit: 150 lines** per presentation file. Hitting this is a
      signal a sub-widget is hiding inside `build()` and should be
      extracted.
    - **Hard limit: 250 lines.** Above this, the file must be decomposed
      before the PR is acceptable — no exceptions for "it's just one big
      screen".
    - Structure: a screen like Discover is `discover_screen.dart` (thin —
      just assembles sub-widgets and provides the Cubit) plus a
      `widgets/` subfolder with one file per sub-widget (e.g.
      `discover_hero.dart`, `discover_section.dart`,
      `discover_segmented_control.dart`). Domain and data files
      (entities, repositories, DTOs, mappers) are exempt from the line
      count but should still be split by single responsibility.
    - This also serves rule 9: a sub-widget in its own file with its own
      narrowly-scoped `BlocBuilder`/`BlocSelector` is much harder to get
      wrong than a method buried inside one giant screen-wide builder.
12. **PR size — one reviewable unit at a time, stacked with Graphite.**
    Never deliver a full new screen (entities + repository + Cubit +
    every sub-widget + the assembled screen) as a single PR. Split the
    work into a stack of small, dependent branches created with
    `gt create`, each reviewable in isolation:
    1. Domain entities + repository interface (no implementation).
    2. Fake/real repository implementation + Cubit + their unit tests.
    3. Presentation sub-widgets (one or two per PR if they're substantial;
       several trivial ones — e.g. a chip variant — can share a PR).
    4. The screen that assembles everything + route registration.
    Submit the stack with `gt submit --stack` once it's ready. If asked to
    "build screen X", default to proposing this breakdown and building it
    stack-by-stack rather than producing one big diff.
13. **Domain entity file grouping — group by sealed family or trivial
    composition, split everything else.** Rule 11 governs presentation
    widgets; domain entities follow a different logic based on identity
    and reuse, not line count:
    - **Group in one file**: a `sealed class` together with its direct
      variants (e.g. `MediaDetail`/`MovieDetail`/`TvShowDetail` all in
      `media_detail.dart`) — splitting a sealed family across files hurts
      readability of the exhaustiveness the compiler is enforcing. Also
      group a type with tiny (2–3 field) value objects that have no
      meaning or use outside that type's context (e.g. `CastMember`/
      `CrewMember`/`MediaCredit` alongside `Person` in `person.dart`).
    - **Split into its own file**: anything with an identity or lifecycle
      independent of where it was first introduced — in particular
      anything reused by more than one other entity or by its own widget/
      screen (e.g. `Episode` and `SeasonSummary`, which the season sheet
      consumes on their own; `WatchProviders`, reused by both `MovieDetail`
      and `TvShowDetail` and likely to grow in v1.2; `Video`).
    - When unsure, ask: "will this type ever be imported somewhere that
      doesn't care about the type I grouped it with?" If yes, split it.
14. **Screen layout checklist.** Every screen is built on `Scaffold`
    with `SafeArea`; there is never content under the status bar, the
    notch, or the home indicator. The page's horizontal margin is
    `AppSpacing.xl`. Any screen with a text field must be scrollable and
    survive the keyboard. Before calling it done, verify it on an iPhone
    with a notch, on a small device (iPhone SE or a small Android), with
    the keyboard open, and at 200% text scale, and state in the PR
    description which of these you checked.
15. **Localization.** All text visible or accessible to the user comes
    from `AppLocalizations`; `domain` and `data` never contain
    user-facing text. Keys are camelCase with a feature prefix (e.g.
    `discoverSeeAll`); messages use typed placeholders and ICU plurals,
    never string concatenation; add an `@key` with a `description` when
    the context isn't obvious from the key name alone. Documented
    exceptions: TMDB's own attribution text, and the exported JSON's own
    (internal, non-display) keys.

16. **Layout and type come from the design system, globally.** A titled
    block of a scrolling screen is an `AppSection` (it owns the gap above
    it and the heading style); gaps are `AppSpacing` roles (`sectionGap`,
    `headingGap`, `cardGap`, `cardPadding`, `itemGap`, `screenMargin`);
    text weight/size comes from an `AppTextStyles` token (add a token, never
    `copyWith(fontWeight/fontSize)`). `test/core/theme/design_tokens_guard_test.dart`
    fails on raw numbers and font overrides. See `docs/DESIGN_SYSTEM.md` §2–3.

17. **Long pages load on demand.** A page made of several network-backed
    blocks (carousels, sections) must not fetch them all when it opens:
    each block that is below the fold is wrapped in `LazyLoad`
    (`shared/widgets/lazy_load.dart`), which calls its callback once the
    block is within about a screen of the visible area (and again when its
    `loadKey` — the filters it depends on — changes). The Cubit exposes an
    idempotent per-block "request" method for it to call. See B2 for the
    reference use.

## Code conventions

- State: `flutter_bloc` — one `Cubit` per screen (plain `Bloc` only if the screen has a real event-driven flow, e.g. the Matcher's room lifecycle).
- DI: `get_it` + `injectable`. Annotate repository/service implementations with
  `@LazySingleton(as: SomeInterface)` (or `@injectable` for non-singleton
  services) — never hand-write a `getIt.registerX(...)` call. After adding or
  changing an annotation, run
  `dart run build_runner build --delete-conflicting-outputs` to regenerate
  `app/di.config.dart`. That file is generated — never edit it by hand, and
  don't hand-roll a registration that duplicates what an annotation already
  produces. Cubits/Blocs are NOT annotated — they're created where the
  screen is built and pull dependencies via `getIt<T>()`.
- Navigation: `go_router`.
- HTTP: `Dio` with interceptors (bearer, `language`/`region`, logging).
- Local persistence: `drift` (SQLite).
- File names: `snake_case.dart`; classes `PascalCase`; the file name matches
  its main public class.
- Tests: everything living in `domain/` (especially `match_engine`) gets a
  unit test with no network and no Flutter. A domain feature isn't approved
  without its test.

## What NOT to do

- Don't add new dependencies without discussing it first — the stack is
  already decided in STRUCTURE.md.
- Don't implement anything marked v1.1/v1.2 in DECISIONS.md while v1.0 is
  being built (Matcher, an advanced Watchmode-equivalent, embedded player,
  etc.) unless explicitly asked.
- Don't invent new copy for buttons or titles that are already written in
  SCREENS.md — copy them as-is, in sentence case.
- Don't use Rive yet if the runtime isn't configured; use the static
  `PakoState` (SVG) as a documented placeholder with a `// TODO(rive)`.

## Git / PR workflow

This repo uses **Graphite (`gt`)** for branches, commits, and pull requests
instead of raw `git`. Create work with `gt create`, amend with
`gt modify`, move through the stack with `gt up`/`gt down`, and open or
update PRs with `gt submit`. Don't use `git commit` or `git push` directly
for feature work — see `.claude/settings.json` for the exact allow-list.
