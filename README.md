# 📚 PassTheBook

Una aplicación móvil moderna y completa construida con **Flutter** para gestionar bibliotecas personales, compartir libros en comunidades locales y realizar un seguimiento inteligente de préstamos en grupos de confianza.

![PassTheBook Banner](https://raw.githubusercontent.com/raistln/book_sharing_apk/main/assets/readme_banner.png) *(Nota: Sustituir por imagen real si está disponible)*

## ✨ Características Principales

### 📖 Gestión Avanzada de Biblioteca
- **Escáner Inteligente:** Añade libros instantáneamente escaneando el código de barras (ISBN) con la cámara.
- **Búsqueda Multifuente:** Integración con **Google Books API** y **Open Library** para obtener metadatos precisos.
- **Colecciones Personalizadas:** Organiza tus libros por estado de lectura, autores, categorías o valoraciones.
- **Portadas Dinámicas:** Gestión automática de portadas con sistema de caché y refresco.

### 👥 Comunidad y Grupos
- **Grupos Privados:** Crea o únete a comunidades de lectura (familia, amigos, clubes de lectura).
- **Invitaciones QR:** Comparte el acceso a tus grupos de forma sencilla mediante códigos QR generados dinámicamente.
- **Descubrimiento:** Explora libros compartidos por otros miembros de tus grupos sin perder la privacidad de tu colección personal.

### 🔄 Sistema Pro de Préstamos
- **Flujo Digital:** Solicita libros directamente desde la app con notificaciones en tiempo real para el propietario.
- **Gestión de Estados:** Control total sobre préstamos pendientes, aprobados, devueltos o rechazados.
- **Préstamos Externos:** Registra préstamos de forma manual para personas fuera de la plataforma.
- **Historial Completo:** Mantén un registro histórico de todos los movimientos de tus libros.

### 🔒 Seguridad y Privacidad
- **Acceso Biométrico:** Protege tu biblioteca con Huella Dactilar o FaceID.
- **Bloqueo por PIN:** Configura un código de seguridad para el acceso a la aplicación.
- **Control de Inactividad:** Cierre de sesión automático tras periodos de inactividad configurables.

### 📊 Estadísticas e Insights
- **Dashboard Visual:** Gráficos detallados sobre tu progreso de lectura y estado de la colección.
- **Métricas de Préstamo:** Descubre qué libros son los más populares en tus grupos.

### 💾 Herramientas y Datos
- **Backups Automáticos:** Copias de seguridad automáticas de tu base de datos local para nunca perder tus datos.
- **Importación/Exportación:** Soporte completo para formatos **CSV** (compatible con Goodreads) y **JSON**.
- **Reportes en PDF:** Genera listas de tus libros o préstamos en formato PDF profesional.

## 🛠️ Stack Tecnológico

- **Framework:** [Flutter](https://flutter.dev/) (Material Design 3)
- **Lenguaje:** [Dart](https://dart.dev/)
- **Gestión de Estado:** [Riverpod](https://riverpod.dev/)
- **Base de Datos Local:** [Drift](https://drift.simonbinder.eu/) (SQLite reactivo)
- **Backend & Sync:** [Supabase](https://supabase.com/)
- **Notificaciones:** [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- **Tareas en Segundo Plano:** [Workmanager](https://pub.dev/packages/workmanager)

## 🚀 Configuración del Proyecto

### Requisitos Previos
- Flutter SDK (Última versión estable)
- Cuenta de Supabase configurada

### Instalación

1.  **Clonar y Acceder:**
    ```bash
    git clone https://github.com/raistln/book_sharing_apk.git
    cd book_sharing_apk
    ```

2.  **Instalar Dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Generación de Archivos:**
    Esencial para el funcionamiento de Drift y Riverpod:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Configuración de Entorno:**
    Crea un archivo `.env` en la raíz con tus credenciales de Supabase:
    ```env
    SUPABASE_URL=YOUR_SUPABASE_URL
    SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
    ```

5.  **Ejecutar:**
    ```bash
    flutter run
    ```

## 🧪 Calidad de Código
El proyecto utiliza un sistema estricto de análisis de código para mantener la mantenibilidad:
```bash
flutter analyze
```

---
Desarrollado con ❤️ para amantes de la lectura.
