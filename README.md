# 📚 Book Sharing App

Una aplicación móvil moderna construida con Flutter para gestionar bibliotecas personales, compartir libros con amigos y realizar un seguimiento de préstamos en grupos de confianza.

## ✨ Características Principales

### 📖 Gestión de Biblioteca
- **Escáner de Código de Barras:** Añade libros rápidamente escaneando su ISBN con la cámara.
- **Búsqueda Integrada:** Busca libros por título o autor utilizando la API de Google Books.
- **Organización:** Filtra tu colección por estado de lectura, autor o título.

### 🤝 Comunidad y Grupos
- **Grupos Privados:** Crea comunidades para compartir libros (ej. "Club de Lectura", "Familia").
- **Invitaciones Fáciles:** Invita miembros mediante códigos QR o enlaces compartibles.
- **Roles:** Gestiona administradores y miembros dentro de cada grupo.

### 🔄 Sistema de Préstamos
- **Préstamos Digitales:** Solicita libros disponibles en tu grupo.
- **Flujo de Aprobación:** Los propietarios pueden aceptar o rechazar solicitudes.
- **Préstamos Manuales:** Registra préstamos a personas que no usan la app (ej. "Prestado a Juan").
- **Fechas Flexibles:** Define fechas de devolución o marca préstamos como indefinidos.

### ⭐ Reseñas y Valoraciones
- **Opiniones:** Califica libros y deja reseñas para que otros miembros del grupo las vean.
- **Promedios:** Visualiza la calificación media de cada libro basada en la comunidad.

## 🛠️ Stack Tecnológico

- **Framework:** [Flutter](https://flutter.dev/)
- **Lenguaje:** [Dart](https://dart.dev/)
- **Gestión de Estado:** [Riverpod](https://riverpod.dev/) (Architecture-agnostic testing and state management)
- **Base de Datos Local:** [Drift](https://drift.simonbinder.eu/) (Reactive persistence for Flutter)
- **Backend / Sincronización:** [Supabase](https://supabase.com/) (Open Source Firebase alternative)
- **UI Components:** Material Design 3

## 🚀 Configuración del Proyecto

### Requisitos Previos
- Flutter SDK (Latest Stable)
- Dart SDK
- Cuenta de Supabase (para funcionalidad online)

### Instalación

1.  **Clonar el repositorio:**
    ```bash
    git clone https://github.com/tu-usuario/book-sharing-app.git
    cd book-sharing-app
    ```

2.  **Instalar dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Generación de código:**
    Este proyecto utiliza `build_runner` para Drift y Riverpod.
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Configuración de Supabase:**
    Crea un archivo `.env` en la raíz (o configura las variables de entorno) con tus credenciales:
    ```
    SUPABASE_URL=tu_url_de_supabase
    SUPABASE_ANON_KEY=tu_clave_anonima
    ```

5.  **Ejecutar la App:**
    ```bash
    flutter run
    ```

## 🧪 Análisis y Calidad
El proyecto mantiene un estándar alto de calidad de código.
Para verificar el estado actual:
```bash
flutter analyze
```
*(Actualmente pasando con 0 problemas)*

## 📄 Licencia
Este proyecto está bajo la licencia MIT.
