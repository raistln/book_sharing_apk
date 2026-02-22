# Plan de Implementación: Grupos Temáticos — PassTheBook

> **Versión:** 1.0  
> **Fecha:** Febrero 2026  
> **Estimación de esfuerzo:** 1–2 días de trabajo real  
> **Dependencias:** Ninguna. Implementable de forma independiente.

---

## Descripción de la feature

El dueño de un grupo puede asignarle uno o varios géneros literarios. Estos géneros actúan como un **filtro maestro de exposición**: solo los libros de la biblioteca personal del dueño cuyo género coincida con los géneros del grupo aparecerán disponibles para préstamo en ese grupo.

Adicionalmente, cada grupo temático muestra un color de fondo distintivo basado en su género principal (el primero de la lista), lo que permite identificar visualmente la temática de cada grupo de un vistazo.

---

## Motivación

La lógica actual expone en cada grupo todos los libros físicos no privados de la biblioteca personal. Esto es correcto para grupos generalistas, pero genera ruido en grupos con una temática concreta: si un usuario tiene 80 libros y está en un grupo de novela negra con amigos, sus libros de cocina o manuales técnicos aparecen disponibles sin que aporten nada al grupo.

El filtro maestro resuelve esto sin cambiar la experiencia de los miembros: ellos simplemente ven una lista más relevante.

---

## Comportamiento detallado

### Configuración por el dueño del grupo

Al crear o editar un grupo, el dueño puede seleccionar uno o varios géneros de una lista predefinida (la misma que ya usa la app para los libros). La selección es opcional: si no se elige ningún género, el grupo funciona exactamente como ahora, sin filtro.

El primer género seleccionado es el **género principal** y determina el color del grupo.

### Filtro de exposición

Cuando el grupo tiene géneros asignados, la lógica de sincronización biblioteca→grupo aplica el filtro antes de insertar o actualizar en `SharedBooks` **para todos los miembros del grupo**, incluido el dueño:

- Solo pasan al grupo los libros físicos, no privados, **cuyo género esté en la lista de géneros permitidos del grupo**.
- Los libros sin género asignado (`genre = null`) **se excluyen** cuando el grupo tiene filtro activo.
- El filtro es automático y transparente: el miembro no necesita marcar nada manualmente. Sus libros fuera de la temática simplemente no aparecen en ese grupo.

Cualquier miembro puede ver en los ajustes del grupo cuántos de sus libros están excluidos por no tener género o por no encajar, con un enlace directo para editarlos.

### Aviso al unirse a un grupo temático

Cuando un usuario acepta una invitación a un grupo que tiene géneros asignados, antes de completar la incorporación se muestra un mensaje informativo:

> "Este grupo está centrado en **[géneros del grupo]**. Solo tus libros de estos géneros serán visibles para los demás miembros. El resto de tu biblioteca no se verá afectada."

El usuario confirma y se une. No es un paso bloqueante, es simplemente para que no se extrañe de ver su biblioteca "incompleta" dentro del grupo. Este aviso también aparece en la pantalla de detalle del grupo con un texto secundario discreto, visible en cualquier momento.

### Color por género principal

Cada género tiene asignado un color. El grupo muestra ese color como fondo suave (sombreado, no fondo sólido) en su tarjeta dentro del listado de grupos. Esto permite distinguir de un vistazo los grupos temáticos de los generalistas y diferenciar unos de otros.

**Paleta de colores sugerida por género:**

| Género | Color | Hex |
|---|---|---|
| Novela negra / Thriller | Gris antracita | `#4A4A5A` |
| Fantasía | Púrpura | `#7B5EA7` |
| Ciencia ficción | Azul índigo | `#3D5A99` |
| Romance | Rosa palo | `#C47A8A` |
| Terror | Rojo oscuro | `#8B2020` |
| Historia / Histórica | Marrón cuero | `#8B6347` |
| Aventura | Verde selva | `#3A7D44` |
| Infantil / Juvenil | Naranja | `#E07B39` |
| Poesía | Dorado | `#C9A84C` |
| Ensayo / No ficción | Azul pizarra | `#4A6B8A` |
| Clásicos | Beige tostado | `#A08060` |
| Sin género / General | Gris neutro | `#7A7A7A` |

Los grupos sin género asignado no muestran ningún color especial, mantienen la apariencia actual.

---

## Cambios técnicos necesarios

### Base de datos local (Drift) — Migración

Añadir a la tabla `Groups`:

| Campo | Tipo | Descripción |
|---|---|---|
| `allowedGenres` | `TEXT nullable` | JSON array de géneros permitidos. `null` = sin filtro |
| `primaryColor` | `TEXT nullable` | Hex del color del género principal, calculado al guardar |

Guardar `primaryColor` directamente evita recalcularlo en cada render.

### Base de datos Supabase

Añadir a la tabla `groups`:

```sql
ALTER TABLE public.groups ADD COLUMN allowed_genres JSONB DEFAULT NULL;
ALTER TABLE public.groups ADD COLUMN primary_color TEXT DEFAULT NULL;
```

### Lógica de sincronización biblioteca → grupo

En el servicio que gestiona qué libros se exponen en cada grupo, añadir antes de insertar/actualizar en `SharedBooks`:

1. Leer `allowedGenres` del grupo.
2. Si está vacío o es `null`, continuar sin filtro (comportamiento actual).
3. Si tiene valores, comprobar que `book.genre` está en la lista.
4. Si `book.genre` es `null` y el grupo tiene filtro, excluir el libro.

### UI — Pantalla de creación/edición de grupo

Añadir un selector múltiple de géneros (chips seleccionables) en el formulario de grupo. Opcional, sin valor por defecto. Al seleccionar el primero, se muestra una previsualización del color que tendrá el grupo.

### UI — Listado de grupos

Las tarjetas de grupos temáticos muestran un fondo suave con el `primaryColor` del grupo (opacidad ~15-20%, no fondo sólido para mantener legibilidad). Los grupos sin género mantienen el aspecto actual.

### UI — Ajustes del grupo (solo dueño)

Añadir un bloque informativo que muestre:

- Géneros activos del filtro.
- Número de libros propios que pasan el filtro.
- Número de libros propios excluidos (por género no coincidente o por `genre = null`), con botón para ir a editarlos.

### UI — Detalle del grupo (todos los miembros)

Texto secundario discreto bajo el nombre del grupo indicando los géneros activos del filtro, visible en cualquier momento para que el miembro entienda por qué su biblioteca aparece filtrada en ese grupo.

---

## Decisiones de diseño tomadas

| Decisión | Opción elegida | Motivo |
|---|---|---|
| Libros sin género con filtro activo | Se excluyen | Más predecible. El usuario sabe exactamente qué aparece. |
| Filtro restrictivo vs orientativo | Restrictivo (no aparecen en SharedBooks) | Más limpio. El miembro ve solo lo relevante. |
| Color | Fondo suave ~15% opacidad | Diferencia sin romper la coherencia visual de la app. |
| Alcance del filtro | Aplica a todos los miembros | El dueño define la temática del grupo y eso aplica a todos. Los miembros no necesitan gestionar qué comparten manualmente. |
| Géneros del grupo | Lista predefinida (misma que libros) | Consistencia. Evita géneros escritos a mano incompatibles. |
| Género principal | El primero seleccionado | Simple y predecible para el usuario. |

---

## Estimación de esfuerzo

| Componente | Estimación |
|---|---|
| Migración de esquema (Drift + Supabase) | 2 horas |
| Lógica de filtro en sincronización biblioteca→grupo | 2 horas |
| UI selector de géneros en formulario de grupo | 3 horas |
| Color en tarjetas del listado de grupos | 2 horas |
| Bloque informativo de libros excluidos | 2 horas |
| Aviso al unirse al grupo temático | 1 hora |
| **Total** | **~2 días** |

---

## Lo que esta feature no hace

- No impide a los miembros tener libros de otros géneros en su biblioteca personal. Solo controla qué se expone en ese grupo concreto.
- No crea un tipo de entidad nueva en la base de datos. Un grupo temático es el mismo `Group` con `allowedGenres` relleno.

---

*Feature documentada a partir de conversación de diseño — Febrero 2026.*
