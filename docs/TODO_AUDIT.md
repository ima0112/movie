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

## Bloquea publicar v1.0 (0)

None. The one row this bucket had (`tmdb_media_repository.dart:166`,
F1b's "For you"/"Because you like X") is **retired** — built in the
`recommendation-builder` branch: `RecommendationBuilder` +
`RecommendationsCubit` + `MediaRepository.recommendationsFor`.
`CarouselSection.forYou`/`.becauseYouLike` (and the TODO's own
`getCarouselSection` branch) were removed entirely rather than filled
in, since that enum/method's shape didn't fit a feature needing local
signal (`TasteProfile`/`UserLibraryRepository`) and its own independent
loading per section — see `docs/DECISIONS.md` §5's own
"Recommendations" entry.

## Paso 16 — opcional (13)

| Path:Line | TODO | Why |
|---|---|---|
| `lib/features/explore/presentation/widgets/genre_tile_grid.dart:15` | Real backdrop image per genre tile — no TMDB endpoint resolves "most popular title per genre" today. | **Reclassified** from "bloquea publicar v1.0": the fallback already reuses the documented "offline" look (`surfaceRaised`, name only) rather than looking broken, so Explore ships correctly either way — this is visual polish, not a functional gap, and has no clear path to a real fix without a data source TMDB doesn't offer. |
| `lib/features/explore/presentation/widgets/genre_tile_grid.dart:64` | Pointer back to the file's own top-of-file TODO above. | Same reclassification, not a second independent issue. |
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

## Limpieza posterior (no son `TODO(...)`, añadido fuera del grep)

- **Columnas muertas de `UserMediaEntries`**: `backdropPath`, `voteCount`,
  `popularity` (`lib/core/persistence/app_database.dart`). `title`/
  `genres`/`posterPath` (as `posterUrl`)/`voteAverage`/`year` were mapped
  in the `my-list-sort-fix` branch; these 3 remain unmapped because
  `MediaItem`/`MediaDetail` carry none of them at all — closing this
  needs extending that entity (every TMDB mapper, every carousel/hero
  call site, every test fixture), not just a repository change. Each
  column's own doc comment in `app_database.dart` explains this.
- **`DiscoverCubit` sigue siendo todo-o-nada para sus propias 8
  secciones** (`inTheaters`/`trending`/`topRated`/`upcoming`/
  `airingNow`/`popular`/`popularThisWeek`/`watchLater`) — un fallo en
  cualquiera de ellas sigue marcando todo el segmento como
  `DiscoverError`, sin reintento por sección. `RecommendationsCubit`
  (F1b, `recommendation-builder` branch) resuelve esto para sus propias
  2 secciones con un Cubit aparte en lugar de tocar ese bucle — revisar
  tras v1.0 si merece la pena el mismo tratamiento para las otras 8, o
  si el riesgo real (todas sirven desde el mismo `FakeMediaRepository`/
  TMDB, rara vez fallan de forma aislada) no lo justifica.

## Totals

- Bloquea publicar v1.0: **0**
- Paso 16 (incl. 2 reclassified): **13**
- v1.1 o posterior: **0**
- Total `TODO(...)`: **13**
