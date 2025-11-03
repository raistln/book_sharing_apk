# 📚 Book Sharing App – Prompt Revisado para IA (Cursor, GPT Engineer, etc.)

## 🧩 Descripción general del proyecto
El objetivo es desarrollar una **aplicación móvil multiplataforma (Android/iOS)** para compartir libros entre amigos o comunidades.  
La app debe funcionar **sin depender de un backend remoto** (offline-first) y usar **Supabase** únicamente como módulo opcional para comunidades y sincronización.  
Debe ser gratuita, ligera y fácil de probar en local durante el desarrollo.

---

## 🛠️ Tecnologías recomendadas
- **Frontend móvil:** Flutter (Dart)
- **Base de datos local:** Drift (SQLite) o Hive
- **Base de datos remota (opcional):** Supabase (Postgres, Auth, Realtime)
- **Autenticación local:** PIN, patrón o biometría (`flutter_secure_storage`, `local_auth`)
- **Escaneo de ISBN/código de barras:** `mobile_scanner` o `flutter_barcode_scanner`
- **Imágenes:** `image_picker` + `image_compression_flutter`
- **Notificaciones:** `flutter_local_notifications` y/o `awesome_notifications`
- **Background tasks / reminders:** `workmanager` o `android_alarm_manager_plus`
- **Exportación:** `csv`, `pdf`, `json_serializable`, `share_plus`
- **Estado:** Riverpod (recomendado) o Bloc
- **Gráficas (estadísticas):** `charts_flutter` u otra librería ligera
- **Tests:** `flutter_test` y `integration_test`

---

## ⚙️ Estructura del proyecto sugerida
```
/book_sharing_app
 ├── lib/
 │   ├── main.dart
 │   ├── app.dart
 │   ├── config/
 │   │   ├── supabase_config.dart
 │   ├── data/
 │   │   ├── local/      # Drift/Hive setup
 │   │   ├── remote/     # Supabase clients
 │   │   ├── models/
 │   ├── services/
 │   │   ├── auth_service.dart
 │   │   ├── book_service.dart
 │   │   ├── loan_service.dart
 │   │   ├── backup_service.dart
 │   │   ├── notification_service.dart
 │   ├── ui/
 │   │   ├── screens/
 │   │   │   ├── login_screen.dart
 │   │   │   ├── library_screen.dart
 │   │   │   ├── community_screen.dart
 │   │   │   ├── loans_screen.dart
 │   │   │   ├── stats_screen.dart
 │   │   │   └── settings_screen.dart
 │   │   ├── widgets/
 │   ├── utils/
 │   │   ├── export_utils.dart
 │   │   ├── date_utils.dart
 │   │   └── qr_utils.dart
 ├── assets/
 ├── test/
 ├── integration_test/
 ├── pubspec.yaml
 └── README.md
```

---

## 📱 Funcionalidades detalladas

### 1️⃣ Login local y seguridad
- **Login offline por PIN o biometría** (opcionalmente email/password con Supabase).
- Tokens y credenciales cifradas en `flutter_secure_storage`.
- Opción "mantener sesión iniciada".
- Bloqueo por PIN tras inactividad (configurable).

---

### 2️⃣ Biblioteca personal (local)
- Entidad `Book` con campos:
  ```
  id, title, author, isbn, barcode, cover_path, status, created_at, updated_at, notes
  ```
- Añadir libros:
  - Escaneo de código de barras/ISBN con cámara (mobile_scanner).
  - Búsqueda por ISBN/Título mediante Google Books API u OpenLibrary (opcional).
  - Alta manual.
- Optimizar almacenamiento de imágenes (compresión y thumbnails).
- Búsqueda local y filtrado avanzado.
- Exportar catálogo (CSV, JSON, PDF).

---

### 3️⃣ Grupos / Comunidades (opcional - Supabase)
- Tablas recomendadas en Supabase:
  - `groups(id, name, owner_id, created_at)`
  - `group_members(id, group_id, user_id, role)`
  - `shared_books(id, group_id, book_id, owner_id, visibility)`
  - `loans(id, book_id, from_user, to_user, status, start_date, due_date, created_at)`
- Roles básicos: owner, member.
- Visibilidad: los usuarios ven **los libros de los demás miembros**, no sus propios libros en la vista pública del grupo.
- Creación/entrada en grupos por invitación o código de grupo.

---

### 4️⃣ Flujo de préstamos
- **Estados de préstamo:** `pending`, `accepted`, `rejected`, `returned`, `expired`, `cancelled`.
- **Acciones:**
  - Solicitar préstamo (cliente crea `loans` con estado `pending`).
  - Propietario acepta/rechaza (cambia estado).
  - Al aceptar, el libro local del propietario pasa a `prestado` (local) y se sincroniza con Supabase.
  - Notificaciones a ambas partes.
  - Fecha de devolución opcional → recordatorios automáticos.
  - Cancelar solicitud si aún `pending`.

---

### 5️⃣ Notificaciones (locales + realtime)
- Eventos que generan notificación:
  - `loan_requested`
  - `loan_accepted`
  - `loan_rejected`
  - `loan_due_soon` (24h antes o configurable)
  - `loan_expired`
- **Implementación local:** `flutter_local_notifications` para notificaciones inmediatas y programadas.
- **Realtime / Push (opcional):** usar Supabase Realtime channels o FCM si se integra Supabase + Cloud Functions.
- **Background scheduling:** `workmanager` para programar checks y notificaciones aun cuando la app esté en background.

---

### 6️⃣ Exportaciones y backups
- Export formats: CSV, JSON, PDF.
- Funciones:
  - `export_books_csv()`
  - `export_loans_json()`
  - `export_books_pdf()`
  - `share_export(file_path)` (usar `share_plus`)
- **Backups:**
  - Exportar e importar backup local (archivo JSON en el dispositivo).
  - Backup opcional a Google Drive o Dropbox (usuario autoriza).
  - Restauración desde backup.

---

### 7️⃣ Estadísticas y UI
- Estadísticas básicas (número de préstamos, tiempo medio, libros más prestados).
- Pantallas:
  - Mis Libros (con filtros)
  - Grupo / Comunidad (si aplica)
  - Préstamos (entrantes, salientes, historial)
  - Estadísticas
  - Ajustes (notificaciones, backups, temas)
- Diseño: Material 3, navegación por pestañas o Drawer según preferencia.

---

### 8️⃣ Compartir libros sin servidor
- Generar **QR** con datos del libro (JSON reducido).
- Escaneo y añadir directamente al catálogo local del otro usuario.
- Útil para compartir en persona sin Supabase.

---

### 9️⃣ Monetización ética y no intrusiva
Opciones propuestas:
1. **Recomendaciones propias / contenidos culturales** en un bloque discreto (offline).  
2. **Botón de donación** (BuyMeACoffee / Ko-Fi) en ajustes.  
3. **Publicidad ligera (AdMob)** si y solo si se desea:
   - Banner discreto en pantalla de ajustes o estadísticas.
   - Intersticiales opcionales y raros (ej. al exportar o en onboarding).
   - Respetar GDPR / privacidad y pedir consentimiento.

---

## 🧪 Desarrollo y pruebas (modo local — sin compilar APK cada vez)

### Requisitos iniciales
- Instalar Flutter SDK (versión estable recomendada).
- Android Studio (para emuladores) o VS Code (opcional).
- Tener `adb` configurado para pruebas en dispositivo real.
- (Opcional) Configurar Supabase project para pruebas si usarás la parte remota.

### Ejecutar y probar rápidamente
- **Modo web** (ideal para UI y lógica no nativa):
  ```bash
  flutter run -d chrome
  ```
  Útil para probar navegación, estado, exportaciones (excepto cámara y notificaciones).

- **Desktop (Windows/Linux/macOS)**:
  ```bash
  flutter run -d windows
  ```
  Permite probar más casos sin móvil; cámara y sensores no estarán disponibles o serán emulados.

- **Emulador Android**:
  1. Abrir Android Studio → Virtual Device Manager → crear/empezar un emulador.
  2. Ejecutar:
     ```bash
     flutter devices
     flutter run
     ```
  Soporta cámara emulada, notificaciones y testing de integración.

- **Dispositivo real (USB)**:
  1. Activar depuración USB en el móvil.
  2. Conectar y ejecutar:
     ```bash
     flutter run -d <device_id>
     ```
  Esto instala la app en modo debug y permite hot reload (sin compilar APK final).

### Compilar APK (solo para distribución/QA final)
- Release APK:
  ```bash
  flutter build apk --release
  ```
  Resultado en: `build/app/outputs/flutter-apk/app-release.apk`

- Para Google Play, preferir `app bundle`:
  ```bash
  flutter build appbundle --release
  ```

### Hot reload vs hot restart
- **Hot reload**: aplica cambios de UI y lógica rápida (mantiene estado).
- **Hot restart**: reinicia la app preservando menos estado; usar cuando cambias providers o inicializaciones.

### Pruebas automatizadas
- Unit tests: `flutter test`
- Integration tests: `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart`

---

## 🧰 Supabase: esquema SQL básico (sugerencia)
Se sugiere ejecutar en SQL editor de Supabase:

```sql
-- Tabla groups
create table groups (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  owner_id uuid references auth.users(id),
  created_at timestamptz default now()
);

-- Tabla group_members
create table group_members (
  id uuid default uuid_generate_v4() primary key,
  group_id uuid references groups(id),
  user_id uuid references auth.users(id),
  role text default 'member',
  created_at timestamptz default now()
);

-- Tabla loans
create table loans (
  id uuid default uuid_generate_v4() primary key,
  book_id text not null,
  from_user uuid references auth.users(id),
  to_user uuid references auth.users(id),
  status text default 'pending',
  start_date date,
  due_date date,
  created_at timestamptz default now()
);
```

(Agregar índices y políticas RLS según necesidades de seguridad.)

---

## 💬 Prompt final para la IA (usar en Cursor/GPT Engineer)
> **Tarea:** Crea el proyecto Flutter "**Book Sharing App**" con la arquitectura y funcionalidades descritas en este documento.  
> Prioriza: modularidad, seguridad local (cifrado), experiencia offline-first y facilidad de prueba en local.  
> Entregables iniciales:
> - Proyecto Flutter con estructura básica y `pubspec.yaml` configurado.
> - Implementación de la base local (Drift/Hive) con modelos Book y Loan.
> - Pantallas de Login, Mis Libros, Préstamos y Ajustes con navegación funcional.
> - Implementación de escaneo de ISBN, exportación CSV/JSON/PDF, y notificaciones locales básicas.
> - Instrucciones para conectar Supabase (SQL inicial) y cómo probar en local.
> - Archivo README con pasos para ejecutar en desarrollo y compilar APK.
>
> Documenta el código con comentarios y crea ejemplos de datos para pruebas.

---

## 🚀 Próximos pasos recomendados
1. Ejecutar la IA (Cursor) con este MD para generar el esqueleto del proyecto.  
2. Probar la app en modo web y emulador.  
3. Implementar funcionalidades críticas en local (escaneo, catálogo, exportación).  
4. Añadir Supabase solo cuando el MVP local esté estable.  
5. Testear experiencias de usuario y pulir notificaciones y backups.

---

**Archivo generado por ChatGPT — listo para usar en Cursor o similar.**
