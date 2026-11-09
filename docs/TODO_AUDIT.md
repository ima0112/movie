# TODO audit

Generated for the `todo-and-docs-audit` branch. Method: `grep -rn "TODO("`
across the whole repo (excluding `build/`, `.dart_tool/`, `ios/Pods/`,
`node_modules/`, `.git/`, `pubspec.lock`). 14 occurrences, none in `test/`
or `tool/`. Only `TODO(...)` (parenthesized) was in scope; there are no
bare `// TODO` comments in the repo.

Classification key, per CLAUDE.md and `docs/DECISIONS.md` §3:
- **bloquea publicar v1.0** — an unimplemented piece of a feature that is
  in the v1.0/MVP table, not a cosmetic placeholder.
- **paso 16** — explicitly deferred polish (Rive runtime, light theme,
  native splash/icon) per CLAUDE.md "What NOT to do."
- **v1.1 o posterior** — tied to Matcher, OMDb, streaming availability, or
  family mode.

## Bloquea publicar v1.0 (3)

| Path:Line | TODO | Why |
|---|---|---|
| `lib/core/data/repositories/tmdb_media_repository.dart:166` | Build a real `DiscoverFilter` from the `TasteProfile` for `CarouselSection.forYou`/`.becauseYouLike`; both currently return `const <MediaItem>[]`. | F1b ("For you" recommendations) is in DECISIONS.md §3's v1.0 table. Shipping with it silently empty is a functional gap in an advertised v1.0 feature. |
| `lib/features/explore/presentation/widgets/genre_tile_grid.dart:15` | Real backdrop image per genre tile — no TMDB endpoint resolves "most popular title per genre" today. | Explore (F2/B2) is core v1.0 scope; SCREENS.md specifies a real backdrop per tile. The fallback reuses the documented "offline" look rather than looking broken, which softens this, but the feature itself isn't implemented. |
| `lib/features/explore/presentation/widgets/genre_tile_grid.dart:64` | Pointer back to the file's own top-of-file TODO above. | Same gap, not a second independent issue. |

## Paso 16 (11)

| Path:Line | TODO | Why |
|---|---|---|
| `lib/shared/widgets/pako_state.dart:20-21` | Replace with a `RiveAnimation` driving a state machine once the runtime is integrated. | The canonical example CLAUDE.md itself cites for this bucket. |
| `lib/app/splash_screen.dart:23-25` | Replace the hand-timed mood/opacity sequence with a real `RiveAnimation`. | Same deferred Rive runtime. |
| `lib/core/theme/app_theme.dart:14-15` | Implement light mode, switch to `ThemeMode.system`. | Light theme is explicitly deferred per DECISIONS.md §9. |
| `docs/DESIGN_SYSTEM.md:36-38` | "No implementar todavía" instruction defining the light-theme deferral convention. | Documents the same deferred item `app_theme.dart` implements. |
| `lib/features/settings/presentation/widgets/settings_preferences_section.dart:18-20` | Doc comment explaining no Theme row in Settings yet. | References the same light-theme deferral (also mentions Family mode in prose, but the TODO token itself is `light-theme`). |
| `lib/features/quiz/presentation/widgets/quiz_year_step.dart:14-17` | Doc comment: uses the static PakoState placeholder instead of duplicating the Rive TODO. | Same Rive deferral, not a separate gap. |
| `assets/icons/pako/pako_idle.svg:2` | SVG comment: static placeholder, see `TODO(rive)`. | Same deferred item. |
| `assets/icons/pako/pako_asleep.svg:2` | Same. | Same deferred item. |
| `assets/icons/pako/pako_off.svg:2` | Same. | Same deferred item. |
| `docs/STRUCTURE.md:25-28` | Tree annotation describing `splash_screen.dart`'s Rive TODO. | Documentation of the same already-listed code TODO. |
| `CLAUDE.md:190-191` | The rule that defines this whole convention. | Not a pending code item — the authoritative source for why the other Rive TODOs exist. Listed because it's a literal grep hit. |

## v1.1 o posterior (0)

None. No `TODO(...)` anywhere references Matcher, Firebase rooms, OMDb,
or streaming availability. Family mode is mentioned in prose next to one
`light-theme` TODO but isn't itself the subject of a TODO token.

## Totals

- Bloquea publicar v1.0: **3**
- Paso 16: **11**
- v1.1 o posterior: **0**
- Total: **14**
