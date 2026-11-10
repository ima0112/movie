# Sistema de diseño — PakoTV

Fuente de verdad para `core/theme/`. Todo valor aquí es literal: cópialo,
no lo redondees ni lo aproximes. Si necesitas un valor que no está, añádelo
a este documento primero y luego a código — nunca al revés.

---

## 1. Color

| Token | Hex | Uso |
|---|---|---|
| `surface` | `#0B0B0D` | Fondo de página, modo oscuro (por defecto) |
| `surfaceRaised` | `#161618` | Tarjetas, campos, hojas, chips sin seleccionar |
| `surfaceRaised2` | `#1E1E22` | Un nivel por encima de `surfaceRaised` (tarjetas dentro de hojas) |
| `line` | `#1E1E22` | Separadores finos entre filas del mismo grupo |
| `lineStrong` | `#2A2A2E` | Bordes de chips y botones secundarios |
| `ink` | `#F5F5F7` | Texto primario, iconos activos |
| `glass` / `glassBorder` / `shadow` | `#1C1C20` 62% · `#F5F5F7` 12% · `#000000` 45% | Barra de tabs flotante (relleno, borde, sombra). Solo sobre un desenfoque de fondo. |
| `sheetHandle` | `#F5F5F7` 24% | Asa de arrastre de las hojas inferiores (40×4) |
| `inkMuted` | `#A1A1A8` | Texto secundario, metadatos, iconos inactivos |
| `inkDim` | `#5F5E5A` | Texto terciario (atribuciones, pies de página) |
| `accent` | `#F2B441` | Único acento. Ver "Dónde va el acento" abajo |
| `accentDeep` | `#5A3A10` | Origen del halo radial (nunca se usa como color de texto o icono) |
| `onDanger` | `#1A0606` | Texto sobre fondo `danger` (botón destructivo) |
| `onAccent` | `#1A1204` | Texto/iconos sobre fondo `accent` |
| `success` | `#6FCF97` | Match perfecto, check de participante listo |
| `danger` | `#FF6B6B` | Acciones destructivas, errores, géneros vetados (chip rojo tachado en Mis gustos) |
| Colores de perfil | `#F2B441` (ámbar) · `#FF6B6B` (coral) · `#6FCF97` (menta) · `#A78BFA` (lila) | Solo para la inicial de usuario / avatares de sala. No se usan en ningún otro contexto de UI. |

**Dónde va el acento (`accent`) — lista cerrada, no añadir más sitios sin
actualizar este documento:** wordmark ("TV"), enlaces "Ver todo", estado
seleccionado de chips/tiles, etiqueta "Para ti", botón flotante de Match,
fondo a sangre del resultado del Matcher, barras y celdas de Estadísticas,
icono relleno de acciones activas (favorito/después/vista), caja "Streaming" de Dónde ver. En cualquier
otro sitio, si dudas si algo debería ser ámbar, la respuesta por defecto es
no.

**Modo claro:** se define en una iteración posterior (ver DECISIONES.md).
No implementar todavía — dejar `ThemeMode.dark` fijo con un
`// TODO(light-theme)`.

---

## 2. Tipografía

Familia única: **Manrope** (Google Fonts), pesos 400 (regular) y 600
(semibold, usar como "500" conceptual de las maquetas — Manrope no tiene
500, el escalón usable más cercano es 600).

| Estilo | Tamaño / línea | Peso | Uso |
|---|---|---|---|
| `display` | 32 / 1.15 | 600 | Título de detalle (película/serie) |
| `h1` | 26–28 / 1.15 | 600 | Titulares de flujo (onboarding, resultado, portada) |
| `h2` | 20–22 / 1.2 | 600 | Título de sección, título de tarjeta grande |
| `h3` | 15–16 / 1.25 | 600 | Título de fila destacada, nombre en tarjeta |
| `body` | 14–15 / 1.5 | 400 | Sinopsis, texto de tarjeta |
| `bodySm` | 13 / 1.5 | 400 | Metadatos, subtítulos |
| `caption` | 11–12 / 1.4 | 400 | Etiquetas, pies, atribución |
| `overline` | 11 / 1.4, tracking 1 | 600 | Etiqueta en mayúsculas sobre un bloque ("SINOPSIS"), en gris |
| `action` | 13 / 1.5 | 600 | Acción de texto en ámbar ("Leer más", "Ver todo") |
| `micro` | 9–10 / 1.3 | 400 | Texto dentro de pills muy pequeñas |

Variantes ya definidas para no tocar el peso en el widget: `bodyStrong`,
`bodySmStrong`, `captionStrong`, `h3Regular` y los pares seleccionado /
no seleccionado `bodySmToggle(bool)`, `captionToggle(bool)`, `h3Toggle(bool)`.

Regla: el tamaño, el peso y el interlineado salen siempre de un estilo de
la tabla; `copyWith` solo cambia el **color** (o el decorado puntual). Si
hace falta otro peso o tamaño, falta un estilo aquí: se añade, no se
improvisa en el widget.

Esto se **verifica automáticamente** (`test/core/theme/design_tokens_guard_test.dart`):
falla si un widget escribe `fontSize:`/`fontWeight:` o un número suelto en
`EdgeInsets`/`SizedBox` (excepciones puntuales con un comentario
`// type-exempt:` o `// layout-exempt:` y su motivo).

Regla: nunca introducir una segunda familia tipográfica, ni para números
(las cifras de Estadísticas usan la misma Manrope). Nunca usar cursiva salvo
para el `tagline` de una película.

---

## 3. Espaciado

Escala nombrada — usar siempre el nombre, nunca el número suelto:

| Token | Valor |
|---|---|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 20 (margen lateral estándar de pantalla) |
| `xxl` | 24 |
| `xxxl` | 32 (márgenes grandes de portadas/diálogos; las secciones usan `sectionGap`) |

### Roles de espaciado (distancias con nombre)

Las pantallas hechas de secciones usan estos nombres en vez de elegir un
número de la escala cada vez:

| Rol | Valor | Dónde |
|---|---|---|
| `screenMargin` | 20 (`xl`) | Margen lateral del contenido |
| `sectionGap` | 24 (`xxl`) | Espacio **encima** de cada sección (sinopsis, dónde ver, reparto, similares…) |
| `headingGap` | 12 (`md`) | Título de sección → su contenido |
| `cardGap` | 12 (`md`) | Entre tarjetas apiladas del mismo grupo (tarjeta de info → tarjetas Duración/Clasificación, Temporadas) |
| `cardPadding` | 16 (`lg`) | Relleno interior de una tarjeta |
| `itemGap` | 8 (`sm`) | Entre elementos pequeños relacionados |

**`AppSection`** (`shared/widgets/app_section.dart`) es la pieza única para
un bloque con título de una pantalla que se desplaza: pone `sectionGap`
arriba, el título `h2` con su acción ámbar opcional ("Ver todo"),
`headingGap` y el contenido (`inset: false` si el contenido va de borde a
borde). Reparto, Similares, Conocida por, las secciones de Descubrir y las
recomendaciones la usan; una pantalla nueva compone secciones con ella en
vez de colocar huecos y títulos a mano.

Piezas compartidas del mismo sistema, para no repetirlas por pantalla:
`AppSection.overline` (sección con etiqueta pequeña en mayúsculas),
`OverlineLabel` (la etiqueta: "SINOPSIS", "ACTORES INVITADOS", el nombre de
un grupo de ajustes), `ExpandableText` ("Leer más" / "Leer menos", solo si
el texto se corta; sinopsis, biografía y sinopsis de temporada) y
`TmdbFooter` (el "Datos de TMDB" del final de un detalle).

Una sección es dueña de su espacio **superior** (`sectionPadding` si su
contenido va dentro del margen, `sectionTopPadding` si desplaza de borde a
borde) y nunca lleva espacio inferior: así, una sección que se oculta por
no tener datos no deja un hueco, y el ritmo vertical es idéntico en todas
las pantallas. El pie de la pantalla usa el mismo `sectionGap`.

Radios: `radiusSm` 8 · `radiusMd` 12 (pósters, tarjetas, tiles) ·
`radiusLg` 16 (tarjetas grandes, hojas del resultado) · `radiusXl` 20
(tarjeta héroe de Descubrir) · `radiusXxl` 24 (diálogos) · `radiusPill` 999
(botones, chips) · hojas inferiores: 28 arriba, 0 abajo, con asa de arrastre.

---

## 4. Iconografía

Paquete: **`remixicon`**, variante `_line` por defecto, `_fill` para
estados activos. Tamaños: 24 (filas, acciones, barra de tabs), 20 (chips,
campos, elementos secundarios), 18 (dentro de pills pequeñas). El icono de
Match en la barra/FAB es un SVG propio (Pako apagado), no RemixIcons.

Cambiado desde `phosphor_flutter` (ver `docs/DECISIONS.md`): al subir el
SDK de Dart/Flutter para poder generar drift, `phosphor_flutter ^2.1.0`
dejó de compilar (subclasea `IconData`, que el SDK nuevo declaró
`final class`) y no existe una versión más nueva que lo arregle.
`remixicon` no subclasea `IconData` y sí mantiene el mismo patrón
regular/fill para los 8 conceptos que lo necesitan.

| Concepto | Icono RemixIcons |
|---|---|
| Buscar | `search_line` |
| Filtros | `equalizer_line` |
| Favorito (inactivo/activo) | `heart_line` / `heart_fill` |
| Ver después (inactivo/activo) | `bookmark_line` / `bookmark_fill` |
| Vista (inactivo/activo) | `eye_line` / `eye_fill` |
| Reproducir / Trailer | `play_line` |
| Compartir | `share_line` |
| Volver | `arrow_left_line` |
| Cerrar | `close_line` |
| Casa / Descubrir (inactivo/activo, tab bar) | `home_line` / `home_fill` |
| Búsqueda / Explorar (inactivo/activo, tab bar) | `search_line` / `search_fill` |
| Lista / Mi lista (inactivo/activo, tab bar) | `file_list_line` / `file_list_fill` |
| Perfil / Tú (inactivo/activo, tab bar) | `user_line` / `user_fill` |
| Ajustes | `settings_line` |
| Estadísticas | `bar_chart_line` |
| Código QR | `qr_code_line` |
| Copiar | `file_copy_line` |
| Reintentar / Buscar otra | `refresh_line` |
| Check | `check_line` |
| Chevron derecha/abajo | `arrow_right_s_line` / `arrow_down_s_line` |
| Info | `information_line` |
| Reloj de espera | `hourglass_line` |
| Grupo | `team_line` |
| Dado (Sorpréndeme) | `dice_5_line` |
| Gustos / corazón con persona | `user_add_line` (aprox. "usar mis gustos") |
| Estrella de valoración (vacía/llena) | `star_line` / `star_fill` |
| Vibe: Feel Good | `sun_line` |
| Vibe: Indie | `seedling_line` |
| Vibe: Monster | `ghost_line` |
| Vibe: Detective | `search_eye_line` |
| Vibe: Classic | `medal_line` |
| Vibe: Superhero | `shield_flash_line` |
| Vibe: Cult | `moon_line` |
| Vibe: Tearjerker | `heart_pulse_line` |
| Vibe: Sports | `football_line` |
| Vibe: Date Night | `hand_heart_line` |
| Vibe: Future | `rocket_line` |
| Vibe: Explosive | `fire_line` |
| Vibe: Gritty | `knife_line` |
| Vibe: True Story | `newspaper_line` |
| Vibe: Gangster | `money_dollar_circle_line` |
| Vibe: Musical | `music_line` |
| Género: Action | `boxing_line` |
| Género: Adventure | `map_line` |
| Género: Animation | `palette_line` |
| Género: Comedy | `emotion_laugh_line` |
| Género: Crime | `police_badge_line` |
| Género: Documentary | `camera_line` |
| Género: Drama | `emotion_line` |
| Género: Family | `parent_line` |
| Género: History | `ancient_pavilion_line` |
| Género: Horror | `ghost_line` |
| Género: Music | `music_2_line` |
| Género: Mystery | `question_line` |
| Género: Romance | `hearts_line` |
| Género: Science Fiction | `aliens_line` |
| Género: Thriller | `timer_flash_line` |
| Stepper: incrementar / decrementar (E2 "Max seasons") | `add_circle_line` / `indeterminate_circle_line` |
| E1: Película / Serie | `movie_line` / `tv_line` |

Si falta un concepto al implementar, añádelo a esta tabla antes de elegir el
icono a ojo, para que quede consistente entre pantallas.

---

## 5. Componentes base (hoja de componentes)

**Carga bajo demanda — `LazyLoad`** (`shared/widgets/lazy_load.dart`): envuelve
un bloque de una página larga y llama a `onNear` una sola vez cuando el
bloque está a menos de ~400 px del área visible (antes o después), en
cualquier scroll (lista perezosa, `Column` en `SingleChildScrollView`,
slivers). Un `loadKey` nuevo lo vuelve a armar (los filtros de los que
depende el bloque). Es lógica de presentación pura; el trabajo de datos es el
callback. Regla 17 de `CLAUDE.md`.

**Tabs / segmented control — un solo diseño.** `AppSegmentedControl`
(`shared/widgets/app_segmented_control.dart`): una pastilla contenedora
(`surfaceRaised`, radio pill, 4 de margen interior, 40 de alto que crece con
el tamaño de texto) con la opción elegida como pastilla blanca (`ink`, texto
`surface`, `bodySm` seminegrita) y las demás en gris (`inkMuted`). Es el
único componente de pestañas: Descubrir, Explorar, Mi lista (con contadores
en vivo), Estadísticas, Filmografía y Reparto/Equipo lo usan, y cualquier
lugar nuevo que necesite pestañas también. Los chips sueltos
(`AppChip`) quedan para filtros de selección múltiple dentro de hojas de
filtros, no para cambiar de vista.

Construir estos ocho antes que ninguna pantalla completa, en una ruta de
depuración (`/debug/components`) que los liste todos:

1. **Tarjeta de póster** — carrusel (110×165) y grid (2:3 fluido), con
   variante "grande" (330×380, radio 20) para la portada de Descubrir.
2. **Chip** — default / seleccionado (fondo `accent`) / con borde punteado
   (sugerencia).
3. **Tile de cuestionario/género** — default / seleccionado / deshabilitado
   (30% opacidad).
4. **Botones** — primario (pill blanca), secundario (borde), texto/enlace
   (ámbar), destructivo (rojo), botón icono con estado.
5. **Barra de tabs + FAB de Match** — 4 pestañas + botón circular elevado.
6. **Tarjeta métrica** (Estadísticas) y barra horizontal de género.
7. **Fila de biblioteca** (Mi lista / búsqueda / filmografía) — variantes
   con estrellas, con fecha, con chevron.
8. **Estados**: skeleton (shimmer sutil), vacío (Pako dormido + texto +
   CTA), error (+ Reintentar), banner sin conexión.

---

## 6. iOS vs Android — qué se adapta y qué no

| Elemento | Comportamiento |
|---|---|
| Apariencia visual general | **Idéntica** en ambas plataformas. No usar Cupertino widgets por "verse nativo". |
| Transiciones de pantalla | Custom (`PageTransitionsBuilder` compartido, deslizamiento 250 ms) — no el default de cada plataforma |
| Gesto de "volver" | Se respeta el nativo de cada una (swipe-back iOS, gesto de sistema Android) |
| Bottom sheets / diálogos | Un solo estilo custom Material re-skinado, igual en ambas |
| Haptics | `HapticFeedback.lightImpact()` / `.selectionClick()` en los puntos que indique PANTALLAS.md — Flutter ya delega al motor correcto de cada SO |
| Safe areas | Siempre `SafeArea` / `MediaQuery.padding`, nunca un padding-top fijo en píxeles |
| Tipografía | Manrope vía `google_fonts` en ambas — nunca dejar caer a Roboto/San Francisco |
| Deep links del Matcher | Trabajo específico por plataforma: `apple-app-site-association` (iOS) y `assetlinks.json` + intent filters (Android). Ver DECISIONES.md §6. |

---

## 7. Motion

- Transición entre pasos (onboarding, cuestionario): 250 ms, desliza 24px + fundido.
- Selección de tile/chip: escala 0.96 → 1, 120 ms.
- Cross-fade de resultado (Sorpréndeme "otra sugerencia", Matcher cambio de ganador): 300–400 ms.
- Nunca fade-and-slide-up genérico en cada tarjeta al cargar — los carruseles de Descubrir entran escalonados una sola vez (60 ms entre secciones), no cada tarjeta individualmente.
- Respetar siempre "reducir movimiento" del sistema: cuando esté activo, cualquier animación continua (muro de pósters, Pako `idle`) pasa a estática.
