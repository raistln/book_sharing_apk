<div align="center">
  <h1>📚 Book Sharing App</h1>
  <h3>Convierte tu biblioteca en una experiencia social elegante, organizada y siempre bajo control.</h3>
  <p>
    Gestiona tus libros, comparte préstamos con tu círculo y mantente al día con recordatorios inteligentes. <br/>
    ¡Descubre la forma más bonita de cuidar tu biblioteca personal!
  </p>
  <a href="#descarga">⬇️ Descarga y empieza en minutos</a>
  <br/>
  <a href="https://buymeacoffee.com/samumarfona">
    <img src="https://img.buymeacoffee.com/button-api/?text=Invítame%20a%20un%20café&emoji=☕&slug=samumarfona&button_colour=ff813f&font_colour=ffffff&font_family=Inter&outline_colour=000000&coffee_colour=ffffff" alt="Buy Me A Coffee" />
  </a>
</div>

---

## ✨ ¿Por qué te va a encantar?

- **Biblioteca impecable:** añade libros con datos precisos usando búsquedas en Open Library y Google Books.
- **Préstamos sin estrés:** controla estados, fechas límite y recibe notificaciones que te mantienen al día.
- **Estadísticas inspiradoras:** conoce tus hábitos de lectura y los títulos más prestados con visualizaciones claras.
- **Experiencia premium:** interfaz Material 3, modo oscuro/claro, navegación fluida y soporte offline.
- **Pensada para crecer:** integración opcional con Supabase, exportaciones CSV/JSON/PDF y un botón de apoyo con "Invítame a un café".

## 🎯 Ideal para ti si...

- Eres un amante de los libros que desea tener todo organizado en un solo lugar.
- Compartes libros con amigos o clubes de lectura y quieres evitar confusiones.
- Quieres estadísticas reales de tu biblioteca personal sin depender de hojas de cálculo.
- Buscas una app cuidada, en español y lista para personalizar con tu identidad.

## 🚀 Cómo empezar {#descarga}

```bash
flutter pub get
flutter run
```

- **Application ID:** `com.booksharing.app`
- **Versión actual:** `1.0.0+1`
- **Requisitos:** Flutter 3.22+, Dart 3.4+, Android 8.1 (API 27) en adelante.

## 🔐 Permisos que cuidarán de tu experiencia

| Permiso | Motivo | Momento |
|---------|--------|---------|
| `INTERNET` | Consultar catálogos externos y sincronización opcional. | Siempre disponible. |
| `CAMERA` | Escanear códigos de barras o capturar portadas. | Se pide justo antes de abrir la cámara/galería. |
| `READ/WRITE_EXTERNAL_STORAGE` (maxSdk 28) | Compatibilidad con importación/exportación en dispositivos antiguos. | Transparente al usuario. |
| `POST_NOTIFICATIONS` | Recordatorios de préstamos y avisos internos. | Se solicita al iniciar por primera vez en Android 13+. |
| `VIBRATE` | Mejor feedback háptico en alertas. | Automático. |

Los permisos se gestionan con [`permission_handler`](https://pub.dev/packages/permission_handler). Si el usuario rechaza uno crítico, se le guía para activarlo desde los ajustes del sistema.

## 🖼️ Portadas bonitas, siempre contigo

- Las portadas seleccionadas se comprimen a calidad 85 y máximo 1200px.
- Se guardan en `ApplicationDocumentsDirectory/covers` para mantener la app ligera.
- Las imágenes descargadas de catálogos se almacenan en caché para un acceso offline inmediato.

## ☕ Apóyame con un café (personaliza tu enlace)

1. Abre `lib/providers/settings_providers.dart` y reemplaza la URL por tu enlace real:

   ```dart
   final donationUrlProvider = Provider<String>((_) {
     return 'https://tu-enlace-de-donacion.com';
   });
   ```

2. En Ajustes verás el botón "Invítame a un café" apuntando al enlace que indiques.
3. Comparte la app con tu comunidad y recuérdales que pueden apoyarte desde ahí.

[![Invítame a un café](https://img.buymeacoffee.com/button-api/?text=Invítame%20a%20un%20café&emoji=☕&slug=samumarfona&button_colour=ff813f&font_colour=ffffff&font_family=Inter&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/samumarfona)

## 🛠️ ¿Quieres tu propio backend Supabase?

El proyecto oficial usa las credenciales integradas y no admite cambios desde la app. Si quieres alojar tu propia instancia (o personalizar Google Books):

1. Haz fork del repositorio.
2. Sigue la guía detallada en [`docs/self_host_supabase.md`](docs/self_host_supabase.md) para crear el proyecto Supabase, aplicar el esquema y actualizar tus claves en `lib/config/supabase_defaults.dart`.
3. Opcional: añade tu API key de Google Books desde Ajustes una vez compilada tu build.
4. Genera tus builds (`flutter build apk --release`) con las nuevas credenciales.

La guía también explica cómo mantener tu instancia y qué pasos seguir para distribuir tu propia versión.

## ✅ Calidad garantizada

1. **Pruebas automatizadas**
   ```bash
   flutter test
   flutter analyze
   ```
2. **Pruebas manuales**
   - Sigue la [lista de verificación](docs/manual_test_checklist.md) para validar importaciones, préstamos, notificaciones y sincronización.
   - Revisa los flujos críticos en modo claro y oscuro.

## 📦 Lista para lanzamiento

1. Ajusta `version` en `pubspec.yaml` y `versionCode/versionName` en `android/app/build.gradle.kts` si subes nueva release.
2. Ejecuta `flutter build apk --release` o `flutter build appbundle`.
3. Verifica que los diálogos de permisos aparezcan donde corresponde.
4. Recorre la checklist manual y captura evidencias para tu publicación.

## 🧾 Licencia

Este repositorio se distribuye bajo la licencia **Book Sharing App Non-Commercial License** incluida en `LICENSE`, que te permite usar y adaptar la app para fines personales, pero **prohíbe su monetización sin tu autorización explícita**.

## 🧍‍♀️ Completa tus datos



**book_sharing_app** 
**samumarfon@gmail.com**
**https://github.com/raistln**

---

¿Listo para mostrar tu biblioteca al mundo? Dale vida a tus libros, comparte historias con tus amigos y deja que Book Sharing App hable por ti. ¡Gracias por apoyar el proyecto! 🙌
