# Lista de Verificación de Pruebas Manuales (Release Candidate)

Este documento detalla los casos de prueba manuales exhaustivos para validar la aplicación Book Sharing App antes del lanzamiento. Se centra en la funcionalidad completa, la experiencia de usuario y la estabilidad en modo release.

## 1. Instalación e Inicialización
- [ ] **Instalación Limpia**: Instalar el APK de release en un dispositivo limpio (sin datos previos).
- [ ] **Primer Inicio**: Verificar que la app se abre correctamente sin crashes.
- [ ] **Permisos**: Verificar que los permisos se solicitan en el momento adecuado (Cámara para escáner, Almacenamiento para imágenes).
- [ ] **Persistencia de Sesión**: Cerrar y abrir la app para asegurar que el usuario (si hay login) o el estado se mantiene.

## 2. Pestaña Biblioteca (LibraryTab)
### 2.1 Visualización y Filtrado
- [ ] **Lista Vacía**: Verificar el estado vacío ("Tu biblioteca está vacía") con el botón de añadir.
- [ ] **Scroll**: Verificar el scroll suave con una lista de libros (10+ items).
- [ ] **Búsqueda**:
    - [ ] Buscar por título exacto.
    - [ ] Buscar por autor.
    - [ ] Buscar por texto parcial.
    - [ ] Verificar que la lista se filtra en tiempo real.
    - [ ] Verificar "Sin resultados" cuando no hay coincidencias.
- [ ] **Filtros**:
    - [ ] Filtrar por estado (Disponible, Prestado).
    - [ ] Limpiar filtros y verificar que vuelven todos los libros.
- [ ] **Rating Stars**: Verificar que las estrellas de valoración se muestran correctamente en los elementos de la lista (widget restaurado).

### 2.2 Gestión de Libros (CRUD)
- [ ] **Añadir Libro (Manual)**:
    - [ ] Completar todos los campos (Título, Autor, ISBN, Descripción).
    - [ ] Añadir una imagen de portada desde la galería.
    - [ ] Guardar y verificar que aparece en la lista.
- [ ] **Añadir Libro (Escáner)**:
    - [ ] Escanear un código de barras de un libro real.
    - [ ] Verificar que se autocompletan los datos (si hay conexión).
- [ ] **Añadir Libro (Búsqueda Online)**:
    - [ ] Usar la búsqueda de Google Books/Open Library.
    - [ ] Seleccionar un resultado y guardar.
- [ ] **Editar Libro**:
    - [ ] Modificar título y autor.
    - [ ] Cambiar la imagen de portada.
    - [ ] Guardar y verificar cambios.
- [ ] **Eliminar Libro**:
    - [ ] Eliminar un libro y confirmar que desaparece de la lista.
    - [ ] Verificar que se actualizan los contadores si existen.

### 2.3 Detalles del Libro
- [ ] **Vista de Detalles**: Tocar un libro y ver todos sus detalles.
- [ ] **Reseñas**:
    - [ ] Añadir una reseña con calificación y texto.
    - [ ] Verificar que la calificación promedio se actualiza en la lista.

## 3. Pestaña Comunidad (CommunityTab)
### 3.1 Gestión de Grupos
- [ ] **Lista de Grupos**: Verificar la visualización de grupos a los que se pertenece.
- [ ] **Crear Grupo**:
    - [ ] Crear un grupo nuevo con nombre y descripción.
    - [ ] Verificar que se es administrador automáticamente.
- [ ] **Unirse a Grupo**:
    - [ ] Unirse mediante código de invitación.
    - [ ] Unirse mediante escaneo de QR (si implementado).
    - [ ] Verificar que aparecen los libros del grupo.
- [ ] **Editar Grupo**: Cambiar nombre/descripción (solo admin).
- [ ] **Salir del Grupo**: Salir y verificar que desaparece de la lista.
- [ ] **Eliminar Grupo**: Eliminar grupo (solo admin) y verificar desaparición para todos (si es posible simular).

### 3.2 Miembros e Invitaciones
- [ ] **Ver Miembros**: Listar miembros del grupo.
- [ ] **Invitar**:
    - [ ] Generar código de invitación.
    - [ ] Compartir código (copiar al portapapeles/share sheet).
    - [ ] Generar QR de invitación.
- [ ] **Gestión de Miembros (Admin)**:
    - [ ] Promover a administrador.
    - [ ] Eliminar miembro del grupo.

### 3.3 Libros Compartidos
- [ ] **Ver Libros del Grupo**: Navegar por la lista de libros compartidos por otros miembros.
- [ ] **Filtrar Libros**: Usar filtros dentro del grupo (si existen).
- [ ] **Detalles de Libro Compartido**: Ver detalles y propietario.

## 4. Flujo de Préstamos (LoanController)
### 4.1 Solicitud y Aprobación
- [ ] **Solicitar Préstamo**:
    - [ ] Seleccionar libro de otro usuario en un grupo.
    - [ ] Solicitar préstamo (con fecha opcional).
    - [ ] Verificar estado "Pendiente" en la UI del solicitante.
- [ ] **Aceptar Préstamo (Dueño)**:
    - [ ] Ver solicitud entrante.
    - [ ] Aceptar solicitud.
    - [ ] Verificar cambio a estado "Activo".
    - [ ] Verificar que el libro aparece como "No disponible" para otros.
- [ ] **Rechazar Préstamo (Dueño)**:
    - [ ] Solicitar otro libro.
    - [ ] Rechazar solicitud.
    - [ ] Verificar estado "Rechazado".

### 4.2 Gestión de Préstamos Activos
- [ ] **Cancelar Solicitud**: Cancelar una solicitud pendiente antes de que sea aceptada.
- [ ] **Devolución (Flujo Completo)**:
    - [ ] Solicitante marca como "Devuelto".
    - [ ] Dueño confirma la recepción.
    - [ ] Verificar estado "Finalizado" y libro "Disponible" nuevamente.
- [ ] **Préstamo Manual**:
    - [ ] Crear un préstamo manual para alguien fuera de la app (nombre externo).
    - [ ] Verificar que el libro queda "No disponible".
    - [ ] Finalizar el préstamo manual.

## 5. Configuración y Perfil
- [ ] **Perfil de Usuario**: Editar nombre de usuario/avatar.
- [ ] **Seguridad**: Configurar/Cambiar PIN de acceso.
- [ ] **Tema**: Cambiar entre Claro/Oscuro y verificar persistencia.
- [ ] **Integraciones**:
    - [ ] Configurar API Key de Google Books.
    - [ ] Configurar conexión Supabase (si aplica).

## 6. Pruebas de Estrés y Estabilidad
- [ ] **Rotación de Pantalla**: Rotar dispositivo en varias pantallas (si está habilitado).
- [ ] **Modo Avión**:
    - [ ] Intentar operaciones de red (buscar online, sincronizar) sin conexión.
    - [ ] Verificar manejo de errores (Snackbars, mensajes amigables).
- [ ] **Minimizar/Restaurar**: Minimizar la app y volver a abrirla. Verificar estado.
- [ ] **Entrada de Datos Inválida**: Probar emojis, textos muy largos, caracteres especiales en campos de texto.

## 7. Verificación de Release
- [ ] **Icono de App**: Verificar que tiene el icono correcto (no el de Flutter por defecto).
- [ ] **Nombre de App**: Verificar el nombre mostrado en el launcher.
- [ ] **Tamaño de APK**: Verificar que el tamaño es razonable (no debug build).
- [ ] **Logs**: Verificar que no hay logs de depuración sensibles visibles en logcat (si es posible conectar por ADB).

---
**Notas de la Sesión de Prueba:**
*Fecha:* _______________
*Dispositivo:* _______________
*Versión de Android:* _______________
*Tester:* _______________
