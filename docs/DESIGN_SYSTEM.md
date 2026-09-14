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
| `inkMuted` | `#A1A1A8` | Texto secundario, metadatos, iconos inactivos |
| `inkDim` | `#5F5E5A` | Texto terciario (atribuciones, pies de página) |
| `accent` | `#F2B441` | Único acento. Ver "Dónde va el acento" abajo |
| `accentDeep` | `#5A3A10` | Origen del halo radial (nunca se usa como color de texto o icono) |
| `onAccent` | `#1A1204` | Texto/iconos sobre fondo `accent` |
| `success` | `#6FCF97` | Match perfecto, check de participante listo |
| `danger` | `#FF6B6B` | Acciones destructivas, errores |
| Colores de perfil | `#F2B441` (ámbar) · `#FF6B6B` (coral) · `#6FCF97` (menta) · `#A78BFA` (lila) | Solo para la inicial de usuario / avatares de sala. No se usan en ningún otro contexto de UI. |

**Dónde va el acento (`accent`) — lista cerrada, no añadir más sitios sin
actualizar este documento:** wordmark ("TV"), enlaces "Ver todo", estado
seleccionado de chips/tiles, etiqueta "Para ti", botón flotante de Match,
fondo a sangre del resultado del Matcher, barras y celdas de Estadísticas,
icono relleno de acciones activas (favorito/después/vista). En cualquier
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
| `micro` | 9–10 / 1.3 | 400 | Texto dentro de pills muy pequeñas |

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
| `xxxl` | 32 (separación entre secciones de Descubrir) |

Radios: `radiusSm` 8 · `radiusMd` 12 (pósters, tarjetas, tiles) ·
`radiusLg` 16 (tarjetas grandes, hojas del resultado) · `radiusPill` 999
(botones, chips) · hojas inferiores: 20 arriba, 0 abajo.

---

## 4. Iconografía

Paquete: **`phosphor_flutter`**, peso `PhosphorIconsRegular` por defecto,
`PhosphorIconsFill` para estados activos. Tamaños: 24 (filas, acciones,
barra de tabs), 20 (chips, campos, elementos secundarios), 18 (dentro de
pills pequeñas). El icono de Match en la barra/FAB es un SVG propio (Pako
apagado), no Phosphor.

| Concepto | Icono Phosphor |
|---|---|
| Buscar | `MagnifyingGlass` |
| Filtros | `SlidersHorizontal` |
| Favorito (inactivo/activo) | `Heart` / `HeartFill` |
| Ver después (inactivo/activo) | `BookmarkSimple` / `BookmarkSimpleFill` |
| Vista (inactivo/activo) | `Eye` / `EyeFill` |
| Reproducir / Trailer | `Play` |
| Compartir | `ShareNetwork` |
| Volver | `ArrowLeft` |
| Cerrar | `X` |
| Casa / Descubrir | `House` |
| Brújula / Explorar | `Compass` |
| Perfil / Tú | `User` |
| Ajustes | `Gear` |
| Estadísticas | `ChartBar` |
| Código QR | `QrCode` |
| Copiar | `Copy` |
| Reintentar / Buscar otra | `ArrowClockwise` |
| Check | `Check` |
| Chevron derecha/abajo | `CaretRight` / `CaretDown` |
| Info | `Info` |
| Reloj de espera | `HourglassMedium` |
| Grupo | `UsersThree` |
| Dado (Sorpréndeme) | `Dice5` |
| Gustos / corazón con persona | `UserCirclePlus` (aprox. "usar mis gustos") |

Si falta un concepto al implementar, añádelo a esta tabla antes de elegir el
icono a ojo, para que quede consistente entre pantallas.

---

## 5. Componentes base (hoja de componentes)

Construir estos ocho antes que ninguna pantalla completa, en una ruta de
depuración (`/debug/components`) que los liste todos:

1. **Tarjeta de póster** — carrusel (110×165) y grid (2:3 fluido), con
   variante "grande" (330×440, 3:4) para la portada de Descubrir.
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
