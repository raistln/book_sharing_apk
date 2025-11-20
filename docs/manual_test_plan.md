# Plan de Pruebas Manuales End-to-End

Este plan cubre un recorrido completo por las principales funcionalidades de la aplicación, desde la instalación inicial hasta los flujos avanzados de notificaciones y limpieza de datos. Cada sección incluye precondiciones, pasos detallados y resultados esperados.

## 1. Preparación e Instalación

**Objetivo:** Garantizar que la app arranca y carga dependencias iniciales correctamente.

1. Instalar/actualizar el APK en un dispositivo o emulador Android limpio.
2. Revoke permisos previos (notificaciones, almacenamiento) desde ajustes del sistema si ya existían.
3. Abrir la app por primera vez.
   - **Resultado esperado:** Se muestra la pantalla Splash y después el onboarding inicial.

## 2. Configuración Inicial de Usuario

**Objetivo:** Crear perfil local y configurar PIN.

1. En onboarding, introducir nombre de usuario disponible y avanzar.
   - **Resultado esperado:** Se valida la disponibilidad frente a Supabase; sigue al paso de PIN.
2. Configurar un PIN de 4 dígitos y confirmarlo.
3. Conceder permisos solicitados (notificaciones, almacenamiento) cuando aparezcan.
4. Completar wizard de perfil incluyendo preferencia de notificaciones.
   - **Resultado esperado:** Se crea usuario local, se sincroniza con Supabase y se muestra el Home.

## 3. Navegación Básica por Home

**Objetivo:** Validar carga de datos y paneles principales.

1. Verificar que la biblioteca local aparece vacía inicialmente.
2. Abrir menú lateral y revisar secciones (Estadísticas, Configuración, etc.).
   - **Resultado esperado:** Todas las pantallas cargan sin errores.
3. Cambiar tema claro/oscuro desde ajustes para comprobar que se aplica inmediatamente.

## 4. Gestión de Libros

**Objetivo:** Crear, editar y compartir un libro.

1. Añadir un libro manualmente (título, autor, notas).
   - **Resultado esperado:** El libro aparece en la lista y se persiste en SQLite.
2. Editar el libro (por ejemplo, añadir nota o cambiar estado a "prestado").
3. Compartir el libro con un grupo existente o crear un nuevo grupo y compartirlo.
   - **Resultado esperado:** El estado del libro se sincroniza con Supabase y se marca como compartido.

## 5. Flujos de Grupos y Préstamos

**Objetivo:** Simular ciclo completo de préstamo.

1. Desde otro usuario o utilizando Supabase, enviar una solicitud de préstamo sobre el libro compartido.
   - **Resultado esperado:** Se crea notificación in-app y push (si habilitada) para el propietario.
2. Abrir la campana de notificaciones en Home y aceptar la solicitud.
3. Verificar que el libro cambia a estado "loaned" y que el préstamo aparece en la sección correspondiente.
4. Programar retorno: marcar como devuelto desde el prestatario y confirmar desde el propietario.
   - **Resultado esperado:** Notificaciones y estados se actualizan; el libro vuelve a estar disponible.

## 6. Acciones sobre Notificaciones

**Objetivo:** Probar nuevas operaciones sobre notificaciones in-app.

1. Desde el panel de notificaciones, usar los botones "Aceptar/Rechazar" directamente si hay solicitudes pendientes.
2. Probar botón "Vaciar notificaciones" y confirmar que desaparecen del listado para el usuario actual.
3. Verificar contador de no leídas en la campana.
4. Ejecutar limpieza automática (simular retención de >15/30 días modificando datos en Supabase o DB local) y comprobar que `purgeExpired` elimina registros antiguos.

## 7. Sincronización y Estados de Bloqueo

**Objetivo:** Confirmar sincronización automática y manejo de Auth.

1. Bloquear manualmente la sesión desde ajustes o esperando el temporizador de inactividad.
2. Intentar acceder a secciones restringidas, luego desbloquear con PIN y con biometría (si disponible).
   - **Resultado esperado:** Tras desbloqueo se ejecuta sincronización inicial sin errores.
3. Revisar logs (si se ejecuta en modo debug) y estado de sincronización en la UI si está disponible.

## 8. Exportación y Copias de Seguridad

**Objetivo:** Validar exportación de datos.

1. Desde Home u opciones, exportar la biblioteca a PDF.
2. Verificar que el archivo se genera en storage y contiene datos correctos.
3. Exportar también a CSV y revisar codificación/encabezados.

## 9. Limpieza y Retención

**Objetivo:** Comprobar políticas de limpieza local y remota.

1. Ejecutar acción de "Borrar todas las notificaciones" y comprobar que se invoca `clearAllForUser` y sincroniza.
2. Forzar `purgeExpired` (por ejemplo, ajustando tiempos en base de datos) y revisar que notificaciones antiguas desaparecen tanto local como remotamente (Supabase cron si configura).
3. Confirmar que no quedan notificaciones "dirty" en la tabla local tras sincronizar y que las tablas remotas han sido limpiadas según retención (15/30 días).

## 10. Pruebas de Reingreso y Actualización

**Objetivo:** Probar escenarios tras actualizar app o reinstalar.

1. Cerrar sesión (si aplica) y relanzar la app.
2. Verificar carga de datos desde Supabase en dispositivo limpio (sin SQLite previo).
3. Realizar actualización de la app (instalar versión más reciente sobre la existente) y validar que migraciones locales se ejecutan sin perder datos.

---

**Notas adicionales:**
- Documentar cualquier incidencia con capturas, logs y estados de sincronización.
- Repetir pasos relevantes en dispositivos con distintos niveles de permisos (sin biometría, sin notificaciones, etc.).
- Validar compatibilidad con usuarios sin conexión durante parte del flujo (por ejemplo, solicitar préstamo offline y sincronizar al reconectar).
