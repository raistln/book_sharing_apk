# Plan de onboarding y UX inicial

## Objetivos
- Facilitar los primeros pasos de un nuevo usuario.
- Reducir abandonos en la primera sesión.
- Alinear feedback visual y mensajes de ayuda con el flujo de préstamos.

## Líneas de acción

### 1. Primer arranque guiado
- Pantallas intro (3-4) explicando biblioteca personal, grupos y préstamos.
- Wizard para crear usuario, añadir/unirse a primer grupo y registrar un libro.

### 2. Estados vacíos
- Mensajes con CTA específicos cuando no hay libros, grupos o préstamos.
- Ilustraciones o iconografía ligera para reforzar el contexto.

### 3. Ayuda contextual
- Tooltips/coach marks sobre acciones clave en Discover y ficha de libro.
- Sección "¿Cómo funciona?" accesible desde el menú con mini tutoriales.

### 4. Feedback coherente
- Estandarizar uso de SnackBars/banners para éxitos y errores.
- Indicadores de progreso al sincronizar biblioteca o enviar solicitudes.

### 5. Accesibilidad y personalización
- Revisión de contraste, tamaño de fuente y soporte de modo oscuro.
- Opciones básicas de idioma y recordatorios configurables.

## Iteraciones sugeridas
1. Estados vacíos + sincronización inicial.
2. Primer arranque guiado + coach marks.
3. Accesibilidad y personalización.

## Roadmap detallado

### Iteración 1 · Estados vacíos y sincronización (1‑1.5 sprints)
- Mensajes con CTA consistentes para listas vacías (libros, grupos, préstamos).
- Reutilizar SnackBars/Banners actuales para feedback y añadir indicador de progreso durante la sincronización.
- Tras crear usuario y PIN, sincronizar inmediatamente para validar nombre y persistir el perfil.
- Entregables: widgets reutilizables para estados vacíos, hook de sincronización post-registro, pruebas básicas de flujo.

### Iteración 2 · Primer arranque guiado y overlays (1‑2 sprints)
- Pantallas intro (3‑4) explicando biblioteca personal, grupos y préstamos con opción de omitir.
- Wizard modular con pasos opcionales: crear grupo, unirse vía código, registrar libro.
- Coach marks/overlays en Discover y ficha de libro, activados tras el wizard y accesibles desde “¿Cómo funciona?”.
- Entregables: motor de pasos opcionales, sistema de overlays reutilizable, pruebas de navegación y estados.

#### Estado actual (nov 2025)
- Wizard implementado con Stepper de 3 pasos en `OnboardingWizardScreen` (crear grupo, unirse por código, registrar libro). Todos los pasos se pueden omitir individualmente, pero el flujo se marca completado indistintamente.
- No existe selección previa de perfil ni se captura avatar; se asume usuario local creado antes del wizard.
- Las pantallas intro están listas como carrusel (`OnboardingIntroScreen`) con copy genérico pero sin assets definitivos.
- OnboardingService guarda `introSeen`, `currentStep`, `completed` y banderas para `discoverCoachPending`/`detailCoachPending`.

#### Definición propuesta de pasos
1. **Pantallas intro (obligatorio/omitable completo)**
   - Slide 1 “Organiza tu biblioteca” → Copy: *"Agrega tus libros físicos y llévalos en tu bolsillo."* Asset: ilustración vertical de librero + móvil.
   - Slide 2 “Comparte con tu grupo” → Copy: *"Crea un grupo o únete a uno existente para prestar y reservar libros."* Asset: composición de personas compartiendo libros.
   - Slide 3 “Gestiona préstamos fácilmente” → Copy: *"Recibe recordatorios, registra devoluciones y mantén tu historial al día."* Asset: iconografía de calendario + checklists.
   - CTA final: botón primario “Empezar” + botón secundario “Ver más tarde”.

2. **Wizard de primeros pasos**
   - **Paso obligatorio 0 (nuevo)**: *Configura tu perfil local*
     - Campos: nombre para mostrar (obligatorio), foto opcional (placeholder circular), preferencia de notificaciones (toggle). Validación rápida.
     - Resulta en actualización de `LocalUser` y sincronización inmediata (`userSyncController.sync()` + `groupSyncController.syncGroups()`).
   - **Paso 1 (opcional)**: *Crea tu primer grupo*
     - Igual al paso actual, pero mostrar CTA secundaria “Aprender sobre grupos” que abre `¿Cómo funciona?`.
   - **Paso 2 (opcional)**: *Únete con un código*
     - Copy propuesto: “Si alguien ya te invitó, escribe el código. Este paso es opcional.”
   - **Paso 3 (opcional)**: *Registra tu primer libro*
     - Copy propuesto: “Agrega un libro que quieras compartir o prestar. Puedes hacerlo más tarde desde Biblioteca.”
   - **Paso final (obligatorio)**: *Revisión rápida*
     - Resumen de los pasos completados + CTA “Ir a mi biblioteca” (dispara `groupSyncController.syncGroups()` + marca `discoverCoachPending/detailCoachPending`).

#### Requerimientos de assets y copy
- **Ilustraciones**: 3 SVG/PNG (tema claro/oscuro) para pantallas intro (tamaño mínimo 1200×1200, estilo flat).
- **Íconos**: 4 íconos outline (Material o personalizados) para cada paso del wizard.
- **Copy**: revisar con UX writer las traducciones y tono, mantener “tú” informal, máximo 2 líneas por mensaje.
- **Feedback**: reutilizar `_showFeedbackSnackBar` y `_SyncBanner` para cualquier acción dentro del wizard.

### Iteración 3 · Accesibilidad y personalización (1 sprint)
- Revisión de contraste, tamaños de fuente y soporte de modo oscuro para flujos anteriores.
- Personalización mínima: recordatorios configurables (p. ej. recordatorio de devolución).
- Preparar estructura para internacionalización futura manteniendo textos en español por ahora.
- Entregables: checklist WCAG interna, parámetros de personalización persistidos, cobertura de pruebas.

---

## Notas de seguimiento (17 nov 2025)
- 🚩 Integrar definitivamente los coach marks en `home_shell.dart`, limpiando duplicados y referencias al banner de datasets.
- 🧹 Ejecutar `flutter analyze`/`flutter test` tras cerrar los avisos pendientes y asegurar que los nuevos helpers usan correctamente `onboardingServiceProvider`.
- 📝 Verificar entrada "¿Cómo funciona?" en Ajustes y revisar textos antes de la demo.

### Próximos entregables
- **Iteración 1 (cierre):** indicador visual reutilizable para sincronización, hook post-registro que dispare `groupSyncController`, pruebas de integración del flujo alta → sync → biblioteca vacía.
- **Iteración 2 (preparación):** definición de pasos obligatorios/opcionales del onboarding wizard, copy + assets para pantallas intro, especificación técnica del sistema de coach marks (targets, triggers, persistencia).
- **Operativo:** integrar nuevos coach marks en `home_shell.dart` cuando se implemente el sistema definitivo, validar la sección “¿Cómo funciona?” en Ajustes con contenidos aprobados, mantener `flutter analyze` y `flutter test` como check obligatorio al cerrar cada bloque.

### Especificación técnica preliminar de coach marks
- **Targets principales**
  1. Botón “Compartir libro” en tarjeta de Discover (`_DiscoverBookCard`).
  2. Filtro “Mis grupos” / chips de propietarios en Discover.
  3. Botón “Solicitar préstamo” dentro del detalle (`_DiscoverBookDetailPage`).
  4. Botón “Gestionar invitaciones” en tarjetas de grupo (visible solo para admins).

- **Triggers**
  - Desencadenar secuencia automática al completar el wizard (flag `discoverCoachPending`).
  - Repetir en la primera visita a Discover con datos sincronizados (`mounted && sharedBooksAsync.hasValue`).
  - Permitir relanzar manualmente desde Ajustes → “¿Cómo funciona?” respetando flags de visto.

- **Persistencia**
  - Extender `OnboardingService` con llaves `discoverCoachSeenStepX` para granularidad.
  - Guardar progresos en `SharedPreferences`; limpiar cuando el usuario escoja “Rever tutorial”.
  - Mantener `discoverCoachPending/detailCoachPending` como triggers globales; al completar cada colección de marks, establecer `pending=false` y `seen=true`.

- **Implementación**
  - Crear `CoachMarkController` singleton (Riverpod provider) que gestione la cola de targets y overlay.
  - Usar `OverlayEntry` + `Semantics` para accesibilidad; bloquear interacción solo cuando sea necesario.
  - Proveer API `registerTarget(GlobalKey)` para que cada widget se subscribe en `initState`/`didChangeDependencies`.
  - Tests: widget tests para secuencia básica y verificación de persistencia de flags.

