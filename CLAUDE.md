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
5. **Icons**: `phosphor_flutter` package, `regular` weight by default and
   `fill` for active states (favorite, selected tab). Never mix with
   Material's `Icons.*` or `CupertinoIcons.*`. Pako's icons are custom SVGs
   in `assets/icons/pako/`, not an icon package.
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
