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
