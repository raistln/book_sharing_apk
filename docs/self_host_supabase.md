# Guía para autogestionar tu instancia de Supabase

Esta guía te ayuda a crear tu propio backend Supabase y conectar tu fork de **Book Sharing App**. Sigue los pasos cuidadosamente para evitar errores de sincronización.

---

## 1. Crear proyecto en Supabase

1. Accede a [https://supabase.com/](https://supabase.com/) y crea una cuenta.
2. Pulsa **New project** y elige región + plan (el gratuito es suficiente para pruebas).
3. Define una contraseña fuerte para la base de datos.
4. Espera a que finalice el aprovisionamiento (unos minutos).

## 2. Habilitar extensiones

En la consola SQL del proyecto ejecuta:

```sql
create extension if not exists "uuid-ossp";
```

## 3. Crear tablas y triggers necesarios

1. Ejecuta el script `docs/book_sharing_app_supabase_schema.sql` completo en la sección **SQL Editor**.
2. Verifica que las tablas aparecen dentro del esquema `public`.

## 4. Configurar políticas (RLS)

Revisa la sección de comentarios dentro del script y ajusta las **Row Level Security Policies** según tus necesidades. El ejemplo mínimo para uso personal:

```sql
alter table local_users enable row level security;
create policy "own data" on local_users
  for all
  using (auth.uid() = auth_user_id)
  with check (auth.uid() = auth_user_id);
```

Repite según el nivel de protección que desees para `books`, `groups`, etc.

## 5. Obtener credenciales

1. En la consola Supabase ve a **Project Settings → API**.
2. Apunta los valores:
   - `Project URL`
   - `anon` key
   - (Opcional) `service_role` key para administración avanzada.

## 6. Configurar tu fork

1. Haz fork del repositorio y clónalo localmente.
2. Crea un archivo `.env` en la raíz con tus credenciales (puedes copiar `.env` de ejemplo):

   ```env
   SUPABASE_URL=https://TU-PROYECTO.supabase.co
   SUPABASE_ANON_KEY=tu_anon_key
   GOOGLE_BOOKS_API_KEY=
   ```

   - El campo `GOOGLE_BOOKS_API_KEY` puede dejarse vacío para introducirlo manualmente desde Ajustes.
   - No publiques este archivo si contienen tus claves reales.

3. Si necesitas una clave `service_role`, guárdala a salvo (no la incluyas en la app) y úsala solo desde servidores seguros.

## 7. Opcional: configurar Google Books

1. Ve a [Google Cloud Console](https://console.cloud.google.com/), crea un proyecto y habilita **Books API**.
2. Genera una API key y consérvala.
3. En la app, abre **Ajustes → Integraciones externas → Google Books API** y pega tu clave.
4. El valor se almacena de forma local en el dispositivo.

## 8. Reconstruir y distribuir

1. Actualiza el identificador de la app si lo necesitas (`applicationId` en `android/app/build.gradle.kts`).
2. Ejecuta:

   ```bash
   flutter pub get
   flutter build apk --release
   ```

3. Firma y distribuye la APK según tu flujo habitual.

## 9. Mantener la instancia

- Supabase aplica cuotas en el plan gratuito. Monitoriza el panel de uso.
- Configura backups automáticos desde **Database → Backups** si lo deseas.
- Revisa periódicamente las políticas y permisos para evitar exposiciones involuntarias.

---

¡Listo! Tu fork ya apunta a una instancia Supabase propia y aislada del proyecto oficial.
