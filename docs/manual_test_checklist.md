# Lista de pruebas manuales completa

Este documento recopila casos de prueba manuales para validar el funcionamiento de la app Book Sharing App desde la primera ejecución hasta los flujos avanzados. Agrupa pruebas por área funcional. Se recomienda ejecutar las secciones en orden para simular la experiencia completa del usuario.

## 1. Instalación, arranque e inicialización
1. Instalar la aplicación en un dispositivo limpio (sin datos previos) en modo debug o release.
2. Abrir la app y verificar que se muestre la pantalla de bienvenida o login inicial.
3. Confirmar que no se produce ningún crash durante la carga inicial.

## 2. Seguridad y autenticación local (PIN)
1. Configurar un PIN inicial desde el flujo de primer uso o desde Ajustes si ya existía.
2. Bloquear la app y reabrirla para comprobar que solicita el PIN configurado.
3. Introducir un PIN incorrecto y validar el mensaje de error o el comportamiento esperado (p.ej. reintento).
4. Cambiar el PIN desde Ajustes y confirmar que el nuevo PIN funciona.
5. Eliminar el PIN (Ajustes > "Eliminar PIN y bloquear") y verificar que la app obliga a configurar uno nuevo antes de seguir.
6. Confirmar que el bloqueo por inactividad se respeta si está configurado.

## 3. Tema y apariencia
1. En Ajustes > Apariencia, alternar entre Sistema, Claro y Oscuro usando el selector segmentado.
2. Comprobar que el cambio se aplica inmediatamente a toda la app.
3. Cerrar y reabrir la app para verificar que la preferencia persiste.

## 4. Gestión de biblioteca local
### 4.1 Creación y edición
1. Añadir un libro manualmente completando título, autor, estado y notas.
2. Editar un libro existente; modificar datos y guardar.
3. Cambiar el estado del libro (disponible, prestado, etc.) y comprobar que se refleja en la lista.
4. Eliminar un libro y confirmar que desaparece de la biblioteca.

### 4.2 Portadas e imágenes
1. Adjuntar una portada desde la galería o cámara (según disponibilidad).
2. Verificar que la miniatura se muestra en la lista y en el formulario.
3. Sustituir la portada por otra imagen y confirmar que la anterior se elimina.
4. Eliminar la portada y comprobar que vuelve a mostrarse el icono por defecto.

### 4.3 Escaneo y búsquedas externas
1. Buscar un libro por título desde el formulario y verificar que aparecen resultados de **Open Library** y **Google Books** indicando la fuente.
2. Seleccionar un resultado y confirmar que título, autor, ISBN, descripción y portada (si existe) se rellenan automáticamente.
3. Probar la búsqueda únicamente con ISBN o código de barras (si se usa escáner) y validar resultados.
4. Verificar manejo de errores cuando Google Books no tiene API key configurada.

## 5. Importación y exportación
### 5.1 Exportación
1. Exportar la biblioteca a CSV y verificar que el archivo contiene los libros esperados.
2. Exportar a JSON y confirmar la estructura (incluyendo notas, estados y campos opcionales).
3. Exportar a PDF y revisar el contenido visual básico (cabeceras, filas, totales).
4. Usar la acción de compartir (`share_plus`) y comprobar que ofrece apps disponibles.

### 5.2 Importación
1. Importar un CSV válido y verificar que crea o actualiza los libros esperados.
2. Importar un JSON válido exportado previamente y confirmar que los campos se restauran correctamente.
3. Probar un CSV/JSON vacío o con errores y validar los mensajes de feedback.

## 6. Estadísticas
1. Navegar a la pestaña Estadísticas y comprobar la carga de totales (libros, préstamos, etc.).
2. Validar que los top de libros prestados coinciden con el histórico de préstamos.
3. Forzar un error controlado (p.ej. desconectar datos necesarios) y confirmar el mensaje de fallo.

## 7. Flujo de préstamos
1. Desde tu biblioteca o grupo, solicitar un préstamo para un libro disponible.
2. Aceptar el préstamo desde el punto de vista del propietario y revisar el cambio de estado.
3. Marcar el préstamo como devuelto y comprobar que el libro vuelve a estado disponible.
4. Probar los estados adicionales: cancelar pendiente, rechazar solicitud, dejar que expire (ajustando fechas) y validar cada transición.
5. Verificar que las secciones "Entrantes", "Salientes" e "Historial" muestran los préstamos adecuados.

## 8. Notificaciones
1. Confirmar que al aceptar o rechazar préstamos se programan notificaciones locales (si procede).
2. Probar el recordatorio de vencimiento configurando una fecha próxima y ejecutando la tarea de background (Workmanager) si es posible.
3. Verificar que las notificaciones se cancelan cuando el préstamo se cierra.

## 9. Grupos y sincronización Supabase (opcional)
1. Configurar Supabase en Ajustes > Integraciones externas con URL y anon key válidas.
2. Sincronizar grupos y validar el banner de estado (en progreso, éxito, error).
3. Crear un grupo nuevo, añadir miembros y compartir libros.
4. Probar invitaciones o códigos si están implementados.
5. Realizar un préstamo dentro de un grupo y verificar la sincronización.
6. Forzar un error (credenciales inválidas) y confirmar que se muestra feedback adecuado.
7. Probar la opción "Restablecer Supabase" y "Limpiar error".

## 10. API de Google Books
1. Configurar la API key desde Ajustes > Integraciones externas.
2. Repetir una búsqueda que antes fallaba por falta de key y confirmar que ahora funciona.
3. Probar la opción para eliminar la API key y validar que se vuelve a mostrar el aviso al buscar.

## 11. Donación y otros ajustes
1. En Ajustes > "Apoya el proyecto", pulsar el botón de Buy Me a Coffee y confirmar que abre el navegador externo con la URL configurada.
2. Revisar que se muestran mensajes de error si la URL no es válida o el navegador no se abre.

## 12. Exportaciones/Backups externos (si aplica)
1. Si se implementó respaldo en la nube (Drive/Dropbox), validar autenticación, subida y recuperación de un backup.
2. Confirmar el manejo de cancelaciones o permisos denegados.

## 13. Flujo de comunidad/offline-first
1. Usar la app sin conexión y comprobar que:
   - Se pueden consultar libros locales.
   - Se puede registrar un préstamo local.
2. Vuelve a conectar y sincroniza con Supabase, asegurando que no se pierden datos locales.

## 14. Integración con QR (cuando se implemente)
1. Generar el QR para un libro y escanearlo con otra instancia de la app.
2. Validar que el libro se añade correctamente en el dispositivo receptor.

## 15. Rendimiento y estabilidad
1. Cargar bibliotecas con más de 200 libros y asegurar que la UI sigue siendo fluida.
2. Ejecutar la app durante un periodo prolongado y revisar consumo de memoria/batería básico.

## 16. Validaciones finales para release APK
1. Revisar íconos y nombre del paquete (AndroidManifest, `applicationId`).
2. Confirmar que el número de versión (`pubspec.yaml`) está actualizado.
3. Ejecutar `flutter test` y, si aplica, pruebas de integración.
4. Ejecutar `flutter analyze` para asegurar que no hay lints críticos.
5. Generar un APK/App Bundle de prueba (`flutter build apk --release` o `appbundle`).
6. Instalar el build release en dispositivo real y repetir un smoke test corto (inicio, libros, préstamo, ajustes).
7. Verificar permisos solicitados (cámara, almacenamiento) y su declaración en `AndroidManifest.xml`.
8. Revisar políticas de privacidad y textos legales si se van a publicar en tiendas.

---

> **Sugerencia:** marca cada caso de prueba conforme lo completes y anota observaciones, bugs encontrados y conclusiones. Esto facilitará la repetición de pruebas en futuras versiones.
