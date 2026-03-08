# Plan de Implementación: Libros Digitales e Integración con Lectores Externos — PassTheBook

> **Versión:** 1.0  
> **Fecha:** Febrero 2026  
> **Estimación de esfuerzo:** 3–4 días de trabajo real  
> **Dependencias:** Ninguna. Implementable de forma independiente.

---

## Descripción general

Esta feature se divide en dos componentes independientes pero complementarios:

1. **Extracción de metadatos desde epub/PDF** para añadir libros digitales a la biblioteca personal sin teclear nada.
2. **Integración con lectores externos** para registrar sesiones de lectura automáticamente cuando el usuario lee desde su app favorita.

Lo que esta feature **no incluye** es un lector propio integrado en PassTheBook. La decisión es deliberada: existen apps especializadas (Moon Reader, Lithium, los lectores de PDF del sistema) que hacen esto mejor. PassTheBook se integra con ellas en lugar de competir.

---

## Componente 1 — Extracción de metadatos desde epub/PDF

### Descripción

Al añadir un libro a la biblioteca personal, aparece una nueva opción junto al escáner ISBN: **"Añadir desde archivo (epub/PDF)"**. El usuario selecciona un archivo de su dispositivo, la app extrae los metadatos disponibles y lanza automáticamente una búsqueda en Google Books para completar la ficha.

### Flujo detallado

1. El usuario pulsa "Añadir desde archivo" en la pantalla de añadir libro.
2. Se abre el selector de archivos del sistema, filtrado por `.epub` y `.pdf`.
3. La app extrae los metadatos del archivo:
   - **epub:** lee el archivo `content.opf` interno (estructura XML estándar) y extrae título, autor e ISBN si están disponibles.
   - **PDF:** lee los metadatos del documento (título, autor, subject). Si no hay metadatos útiles, continúa con lo que tenga.
4. Con los datos extraídos, lanza una búsqueda automática en Google Books.
5. Si hay coincidencia, muestra la ficha completa para confirmar (igual que con el escáner ISBN).
6. Si no hay coincidencia o los metadatos estaban vacíos, abre el formulario manual con los campos pre-rellenados con lo que se pudo extraer.
7. El libro se guarda en la biblioteca marcado como **digital** (`isPhysical = false`).
8. El archivo se almacena en local, en el directorio privado de la app.

### Consideraciones técnicas

**epub:** formato ZIP con estructura conocida. Se descomprime en memoria, se lee `content.opf` y se parsea el XML. No requiere librería externa, es manipulación estándar de archivos.

**PDF:** los metadatos están en el diccionario de información del documento. La fiabilidad es variable: algunos PDFs tienen metadatos bien formados, otros no tienen nada útil. En ese caso la búsqueda se lanza con lo poco que haya o se va directamente al formulario manual.

**Almacenamiento local del archivo:** el archivo se copia al directorio privado de la app (`getApplicationDocumentsDirectory`), con el UUID del libro como nombre de archivo. Esto garantiza que el archivo persiste aunque el original se mueva o borre.

### Comportamiento del libro digital en la app

- Se marca automáticamente como `isPhysical = false`.
- **No aparece en ningún grupo de préstamo.** Los libros digitales no son prestables.
- Tiene una ruta local almacenada (`digitalFilePath`, campo nuevo en `Books`).
- En la ficha del libro aparece un botón **"Leer"** que lanza el archivo en el lector externo (ver Componente 2).
- El resto de funcionalidades (sesiones de lectura, timeline, reseñas, wishlist) funcionan exactamente igual que con un libro físico.

### Cambios en el esquema

**Drift — Migración (puede ir en v25 junto con perfiles infantiles):**

Añadir a la tabla `Books`:

| Campo | Tipo | Descripción |
|---|---|---|
| `digitalFilePath` | `TEXT nullable` | Ruta local al archivo epub/PDF |
| `bookOrigin` | `TEXT nullable` | `'regalo'`, `'cole'`, `'biblioteca'`, `'comprado'`, `'digital'`, `null` |

> `bookOrigin` es el mismo campo planificado para perfiles infantiles, simplemente se añade `'digital'` como valor adicional.

**Supabase:** sin cambios. Los archivos digitales son estrictamente locales y no se sincronizan a la nube.

### Legalidad

El almacenamiento local de archivos epub/PDF es legal cuando el archivo es propiedad del usuario (compra en tienda, dominio público, creación propia). La app no puede verificar el origen del archivo, pero tampoco ofrece ningún mecanismo de distribución entre usuarios: el archivo vive exclusivamente en el dispositivo de quien lo subió y no se comparte por ningún canal de la app. Esto mantiene la responsabilidad en el usuario y aleja a PassTheBook de cualquier zona gris legal.

---

## Componente 2 — Integración con lectores externos

### Descripción

Cuando el usuario pulsa "Leer" en la ficha de un libro digital, PassTheBook lanza el archivo en el lector externo instalado en el dispositivo y abre una sesión de lectura en segundo plano. Cuando el usuario vuelve a PassTheBook, aparece automáticamente un diálogo para registrar la sesión: tiempo leído y página alcanzada.

### Flujo detallado

**Al pulsar "Leer":**

1. PassTheBook registra la hora de inicio de sesión en memoria.
2. Lanza el archivo mediante el intent del sistema operativo (Android) o share/open (iOS), que abre la app de lectura que el usuario tenga configurada por defecto.
3. Muestra una notificación persistente discreta: *"Sesión de lectura activa — PassTheBook"*, con un botón de acceso rápido para volver a la app.

**Al volver a PassTheBook** (por cualquier vía: notificación, gesto, icono):

1. La app detecta que hay una sesión abierta sin cerrar.
2. Muestra el diálogo de registro de sesión:
   - Tiempo leído (calculado automáticamente desde el inicio, editable).
   - Página donde se ha quedado (campo numérico, obligatorio si el libro tiene páginas).
   - Nota opcional (igual que en las sesiones manuales).
3. El usuario confirma y la sesión queda registrada en `ReadingSessions` y `ReadingTimelineEntries`.
4. Se actualiza el progreso del libro (`currentPage`, `percentageRead`).

**Si el usuario no vuelve a PassTheBook:**

La sesión queda pendiente. La próxima vez que abra la app, si hay una sesión sin cerrar de menos de 24 horas, se muestra el diálogo igualmente. Si han pasado más de 24 horas, la sesión se descarta silenciosamente para no confundir al usuario con datos obsoletos.

### Lo que no se puede detectar automáticamente

La página exacta alcanzada en el lector externo. Cada app de lectura es independiente y no expone esa información al exterior. El usuario siempre introduce la página manualmente en el diálogo, igual que en las sesiones manuales actuales. El valor añadido está en que el diálogo aparece solo, sin que el usuario tenga que recordar ir a registrarlo.

### Implementación técnica

**Android:**

- Lanzar el archivo: `Intent(Intent.ACTION_VIEW)` con el tipo MIME correspondiente (`application/epub+zip` o `application/pdf`). El sistema abre el lector por defecto o muestra el selector si hay varios.
- Detectar el regreso a PassTheBook: lifecycle observer en el `AppLifecycleState`. Cuando el estado pasa de `paused` a `resumed` y hay una sesión abierta, se lanza el diálogo.
- Notificación persistente: `flutter_local_notifications`, que ya está en el proyecto.
- Tarea en segundo plano: `Workmanager`, que también está en el proyecto, para limpiar sesiones huérfanas de más de 24 horas.

**iOS:**

- Lanzar el archivo: `Share` / `open in` mediante el plugin `open_file` o similar.
- Detectar el regreso: mismo lifecycle observer. En iOS el comportamiento es equivalente aunque el sistema es más restrictivo con las apps en segundo plano.
- La notificación persistente funciona igual con `flutter_local_notifications`.

### Experiencia para libros físicos

El diálogo de registro de sesión al volver a la app es opcional también para libros físicos. En ajustes el usuario puede activar un modo en el que PassTheBook le pregunta al abrir la app si ha estado leyendo, para registrar sesiones de libros físicos con el mismo flujo. Esto es una extensión natural del mismo mecanismo, no requiere trabajo adicional relevante.

---

## Estimación de esfuerzo

| Componente | Tarea | Estimación |
|---|---|---|
| **C1** | Selector de archivo + extracción de metadatos epub | 4 horas |
| **C1** | Extracción de metadatos PDF | 2 horas |
| **C1** | Integración con búsqueda Google Books | 2 horas |
| **C1** | Almacenamiento local del archivo | 1 hora |
| **C1** | Migración de esquema | 1 hora |
| **C2** | Lanzar archivo en lector externo | 2 horas |
| **C2** | Lifecycle observer + detección de regreso | 2 horas |
| **C2** | Notificación persistente durante sesión | 2 horas |
| **C2** | Diálogo de registro automático de sesión | 3 horas |
| **C2** | Limpieza de sesiones huérfanas (Workmanager) | 1 hora |
| | **Total** | **~3,5 días** |

---

## Resumen de decisiones de diseño

| Decisión | Opción elegida | Motivo |
|---|---|---|
| Lector propio vs integración externa | Integración externa | Las apps especializadas lo hacen mejor. PassTheBook no compite, se integra. |
| Archivos en nube vs local | Solo local | Legalidad. El archivo nunca sale del dispositivo del usuario. |
| Compartir archivos en grupos | No permitido | Línea roja legal. Solo se comparten libros físicos. |
| Página alcanzada | Manual en el diálogo | No es posible leerla del lector externo. El diálogo automático minimiza la fricción. |
| Sesiones huérfanas | Descarte a las 24h | Evita registrar datos incorrectos por sesiones olvidadas. |
| Metadatos PDF sin información | Formulario manual pre-rellenado | Mejor experiencia que un error o una búsqueda vacía. |

---

*Feature documentada a partir de conversación de diseño — Febrero 2026.*
