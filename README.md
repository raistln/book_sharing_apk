<div align="center">

# 📚 PassTheBook

### *Comparte tu pasión por la lectura*

Una aplicación móvil moderna y completa construida con **Flutter** para gestionar bibliotecas personales, compartir libros en comunidades locales y realizar un seguimiento inteligente de préstamos.

[![Flutter](https://img.shields.io/badge/Flutter-3.4+-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-Non--Commercial-red)](LICENSE)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)](https://supabase.com/)

[Características](#-características-principales) • [Instalación](#-instalación) • [Tecnologías](#️-stack-tecnológico) • [Licencia](#-licencia)

</div>

---

## 🌟 Descripción

**PassTheBook** es una solución integral para los amantes de los libros que desean:
- 📖 Catalogar y organizar su biblioteca personal de forma inteligente
- 👥 Compartir libros con amigos, familia o clubes de lectura
- 🔄 Gestionar préstamos de manera profesional con seguimiento completo
- 📊 Obtener estadísticas y métricas sobre sus hábitos de lectura
- 🔒 Mantener su colección segura y privada

La aplicación combina la potencia de Flutter con un backend robusto en Supabase, ofreciendo sincronización en tiempo real, notificaciones push y una experiencia de usuario fluida y moderna.

---

## ✨ Características Principales

### 📖 Gestión Avanzada de Biblioteca
- **Escáner Inteligente de ISBN:** Añade libros instantáneamente escaneando el código de barras con la cámara
- **Búsqueda Multifuente:** Integración con **Google Books API** y **Open Library** para obtener metadatos precisos automáticamente
- **Colecciones Personalizadas:** Organiza tus libros por estado de lectura, autores, géneros o valoraciones personales
- **Portadas Dinámicas:** Sistema automático de gestión de portadas con caché inteligente
- **Reseñas y Valoraciones:** Añade tus propias reseñas y calificaciones con sistema de estrellas
- **Filtros Avanzados:** Busca y filtra por título, autor, ISBN, estado de disponibilidad y más

### 👥 Comunidad y Grupos
- **Grupos Privados:** Crea comunidades de lectura cerradas (familia, amigos, clubes de lectura)
- **Invitaciones QR:** Comparte el acceso a tus grupos mediante códigos QR o enlaces únicos
- **Descubrimiento Inteligente:** Explora libros compartidos por otros miembros sin comprometer tu privacidad
- **Gestión de Miembros:** Administra roles, permisos y membresías de tus grupos
- **Grupo Personal Automático:** Sistema de préstamos manuales para personas fuera de la plataforma

### 🔄 Sistema Profesional de Préstamos
- **Flujo Digital Completo:** Solicita, aprueba y gestiona préstamos directamente desde la app
- **Notificaciones en Tiempo Real:** Recibe alertas instantáneas sobre solicitudes, aprobaciones y devoluciones
- **Gestión de Estados:** Control total sobre préstamos pendientes, activos, devueltos o rechazados
- **Préstamos Manuales:** Registra préstamos a personas fuera de la plataforma
- **Historial Completo:** Mantén un registro detallado de todos los movimientos de tus libros
- **Confirmación Dual:** Sistema de doble confirmación para devoluciones (solicitante y propietario)
- **Fechas de Vencimiento:** Establece y rastrea fechas límite para devoluciones

### 🔒 Seguridad y Privacidad
- **Autenticación Biométrica:** Protege tu biblioteca con huella dactilar o Face ID
- **Bloqueo por PIN:** Código de seguridad adicional para acceso a la aplicación
- **Control de Inactividad:** Cierre de sesión automático tras periodos configurables de inactividad
- **Visibilidad Granular:** Controla qué libros son visibles en cada grupo (disponible, privado, archivado)
- **Datos Locales:** Base de datos SQLite local con sincronización opcional a la nube

### 📊 Estadísticas e Insights
- **Dashboard Visual:** Gráficos interactivos sobre tu progreso de lectura y estado de la colección
- **Métricas de Préstamo:** Descubre qué libros son los más solicitados en tus grupos
- **Calendario de Lectura:** Visualiza tu actividad de lectura a lo largo del tiempo
- **Estadísticas de Grupo:** Analiza la actividad y popularidad de libros en cada comunidad

### 💾 Herramientas y Exportación
- **Backups Automáticos:** Copias de seguridad programadas de tu base de datos local
- **Importación CSV:** Compatible con exportaciones de Goodreads y otros servicios
- **Exportación JSON:** Exporta tu biblioteca completa en formato estructurado
- **Reportes PDF:** Genera listas profesionales de tus libros o préstamos activos
- **Compartir Listas:** Comparte tu colección mediante enlaces o archivos

---

## 🛠️ Stack Tecnológico

### Frontend
- **[Flutter](https://flutter.dev/)** - Framework multiplataforma con Material Design 3
- **[Dart](https://dart.dev/)** - Lenguaje de programación moderno y eficiente
- **[Riverpod](https://riverpod.dev/)** - Gestión de estado reactiva y type-safe

### Base de Datos y Backend
- **[Drift](https://drift.simonbinder.eu/)** - ORM reactivo sobre SQLite para persistencia local
- **[Supabase](https://supabase.com/)** - Backend as a Service con PostgreSQL, autenticación y storage
- **SQLite** - Base de datos embebida para funcionamiento offline

### Integraciones y APIs
- **[Google Books API](https://developers.google.com/books)** - Metadatos de libros
- **[Open Library API](https://openlibrary.org/developers/api)** - Fuente alternativa de información bibliográfica
- **[Mobile Scanner](https://pub.dev/packages/mobile_scanner)** - Escáner de códigos de barras optimizado

### Funcionalidades Adicionales
- **[Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)** - Notificaciones locales y push
- **[Workmanager](https://pub.dev/packages/workmanager)** - Tareas en segundo plano (sincronización, backups)
- **[Local Auth](https://pub.dev/packages/local_auth)** - Autenticación biométrica
- **[QR Flutter](https://pub.dev/packages/qr_flutter)** - Generación de códigos QR
- **[PDF](https://pub.dev/packages/pdf)** - Generación de documentos PDF
- **[Image Picker](https://pub.dev/packages/image_picker)** - Selección de imágenes

---

## 🚀 Instalación

### Requisitos Previos
- **Flutter SDK** >= 3.4.0 ([Guía de instalación](https://docs.flutter.dev/get-started/install))
- **Dart SDK** >= 3.4.0 (incluido con Flutter)
- **Cuenta de Supabase** ([Crear cuenta gratuita](https://supabase.com/))
- **Android Studio** o **Xcode** (para desarrollo móvil)

### Pasos de Instalación

1. **Clonar el Repositorio**
   ```bash
   git clone https://github.com/raistln/book_sharing_apk.git
   cd book_sharing_apk
   ```

2. **Instalar Dependencias**
   ```bash
   flutter pub get
   ```

3. **Generar Código (Drift, Riverpod)**
   
   Este paso es **esencial** para generar los archivos de base de datos y providers:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Configurar Variables de Entorno**
   
   Crea un archivo `.env` en la raíz del proyecto con tus credenciales de Supabase:
   ```env
   SUPABASE_URL=https://tu-proyecto.supabase.co
   SUPABASE_ANON_KEY=tu-clave-anonima-de-supabase
   ```
   
   > **Nota:** Puedes obtener estas credenciales desde el dashboard de tu proyecto en Supabase (Settings > API)

5. **Configurar Google Books API (Opcional)**
   
   Para habilitar la búsqueda de libros, obtén una API key gratuita:
   - Visita [Google Cloud Console](https://console.cloud.google.com/)
   - Crea un proyecto y habilita la Books API
   - Genera una API key
   - Configúrala desde la app en Ajustes > Integraciones

6. **Ejecutar la Aplicación**
   ```bash
   # En modo debug
   flutter run

   # En modo release (Android)
   flutter build apk --release
   flutter install
   ```

### Configuración de Supabase

La aplicación requiere las siguientes tablas y funciones en Supabase. Puedes encontrar el esquema completo en:
- `docs/supabase_schema_v7_clean deploy.sql` - Esquema completo de base de datos
- `docs/supabase_loan_hardening_COMPLETE.sql` - Funciones y triggers para préstamos

Ejecuta estos scripts en el SQL Editor de tu proyecto Supabase.

---

## 🧪 Calidad de Código

El proyecto mantiene altos estándares de calidad mediante:

### Análisis Estático
```bash
# Ejecutar análisis de código
flutter analyze

# Verificar formato
dart format --set-exit-if-changed .
```

### Testing
```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test/
```

### Checklist de Testing Manual
Consulta `docs/manual_test_checklist.md` para una lista exhaustiva de casos de prueba manuales antes de cada release.

---

## 📱 Capturas de Pantalla

> **Nota:** Añadir capturas de pantalla de la aplicación en las siguientes secciones:
> - Biblioteca personal con filtros
> - Vista de detalles de libro
> - Gestión de grupos y comunidades
> - Flujo de préstamos
> - Dashboard de estadísticas

---

## 📋 Roadmap y Futuras Mejoras

Consulta `docs/future_iterations.md` para ver las características planificadas, incluyendo:
- 🌐 Soporte multiidioma completo
- 📚 Integración con más APIs de libros
- 🎯 Recomendaciones personalizadas basadas en IA
- 📖 Clubes de lectura con discusiones
- 🏆 Sistema de logros y gamificación

---

## 📄 Licencia

Este proyecto está bajo la **Book Sharing App Non-Commercial & Source Available License (Version 1.1)**.

- ✅ **Para Usted:** Uso personal, educativo, investigación y evaluación.
- ✅ **Para Usted:** Modificación para uso interno y distribución gratuita de derivados (siempre que sigan siendo de código abierto y bajo esta misma licencia).
- 👤 **Autor:** Samuel Martín Fonseca se reserva el derecho **EXCLUSIVO** de monetización y explotación comercial del software en cualquier plataforma.
- ❌ **Prohibido:** Cualquier tipo de Uso Comercial por parte de terceros sin autorización expresa.
- ❌ **Prohibido:** Cobrar por el acceso o distribución de este software o sus derivados.

> [!IMPORTANT]
> Si crea una versión modificada, debe mantener la misma licencia, dar crédito al autor original y compartir el código fuente de sus modificaciones.

Ver el archivo [LICENSE](LICENSE) para el texto legal completo.

---

## 👨‍💻 Autor

<div align="center">

### Samuel Martín

**Desarrollador Full Stack | Especialista en Flutter**

[![GitHub](https://img.shields.io/badge/GitHub-raistln-181717?logo=github)](https://github.com/raistln)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Samuel_Martín-0A66C2?logo=linkedin)](https://www.linkedin.com/in/samuel-mart%C3%ADn-fonseca-74014b17/)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy_Me_A_Coffee-Support-FFDD00?logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/raistln)

</div>

### 💬 Contacto

- **Email:** samumarfon@gmail.com
- **GitHub Issues:** Para reportar bugs o solicitar características
- **LinkedIn:** Para consultas profesionales

---

## 🤝 Contribuciones

Aunque este es un proyecto personal, las sugerencias y reportes de bugs son bienvenidos:

1. 🐛 **Reportar Bugs:** Abre un issue describiendo el problema
2. 💡 **Sugerir Características:** Comparte tus ideas en las discusiones
3. 📖 **Mejorar Documentación:** Los PRs para documentación son bienvenidos

---

## 🙏 Agradecimientos

- **Flutter Team** - Por el increíble framework
- **Supabase** - Por el backend robusto y fácil de usar
- **Comunidad Open Source** - Por las increíbles librerías y herramientas

---

## ⭐ Soporte

Si este proyecto te ha sido útil, considera:

- ⭐ Darle una estrella al repositorio
- ☕ [Invitarme a un café](https://buymeacoffee.com/raistln)
- 🔗 Compartirlo con otros amantes de la lectura

---

<div align="center">

**Desarrollado con ❤️ y 📚 para la comunidad de lectores**

*PassTheBook - Porque los libros están hechos para compartirse*

</div>
