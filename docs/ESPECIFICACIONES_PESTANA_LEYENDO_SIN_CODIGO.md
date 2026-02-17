# 📖 Especificaciones: Pestaña "Leyendo" + Modo Sesión de Lectura

## Contexto del Proyecto

PassTheBook es una app Flutter para gestionar bibliotecas personales y préstamos de libros. La filosofía de la app es **tranquila, contemplativa, sin gamificación estresante ni presión para el usuario**.

**Stack técnico:**
- Flutter 3.4+ con Dart 3.4+
- Drift (SQLite) para base de datos local
- Riverpod para gestión de estado
- Material Design 3

**Importante:** Ya existe un sistema de timeline integrado en cada libro. La nueva funcionalidad debe insertar entradas en ese timeline existente de forma más rápida y orgánica.

---

## 1. Restructuración de Navegación

### Bottom Navigation Bar

**Estado actual:**
- 4 pestañas: Biblioteca | Préstamos | Grupos | Ajustes

**Estado deseado:**
- 4 pestañas: **Leyendo** | Biblioteca | Préstamos | Grupos

**Cambios:**
- Añadir nueva pestaña "Leyendo" en primera posición
- Mover "Ajustes" del bottom navigation al FAB menu

**Razón del cambio:**
- La pestaña "Leyendo" muestra lo que el usuario está haciendo AHORA (contexto presente)
- Tiene más prioridad visual que "Ajustes" que se usa ocasionalmente
- Ajustes en el FAB libera espacio valioso en la navegación principal

### FAB Menu (Floating Action Button)

**Estado actual:**
- Boletín Local
- Mi Estantería
- Notificaciones
- Mi Perfil

**Estado deseado:**
- Boletín Local
- Mi Estantería
- Notificaciones
- Mi Perfil
- **Ajustes** (nuevo, movido desde bottom nav)

**Implementación del FAB:**
- Usar el package `flutter_speed_dial` (o crear menú custom si lo prefieres)
- Iconos claros para cada opción
- Color principal: #8B7355 (marrón característico de la app)
- Mantener estilo Georgia para textos

---

## 2. Base de Datos: Nueva Tabla

### Tabla: reading_sessions

**Propósito:**
Almacenar información de cada sesión de lectura para luego insertarla en el timeline existente del libro.

**Campos necesarios:**
- **id**: Identificador único
- **userId**: Usuario que realizó la sesión
- **bookId**: Libro que se leyó
- **sessionDate**: Fecha y hora de la sesión
- **durationMinutes**: Duración de la sesión en minutos
- **pagesRead**: Cantidad de páginas leídas (opcional, puede ser null)
- **startPage**: Página en la que empezó (opcional)
- **endPage**: Página en la que terminó (opcional)
- **note**: Nota personal para el timeline (máximo 280 caracteres, opcional)
- **markedAsCompleted**: Boolean indicando si el usuario marcó el libro como terminado
- **sessionType**: Tipo de sesión ('timed' | 'unlimited' | 'manual')
- **createdAt**: Timestamp de creación

**Relaciones:**
- Esta tabla alimenta el timeline existente
- Cuando se guarda una sesión, debe insertarse una entrada correspondiente en el timeline del libro

---

## 3. Pestaña "Leyendo" - Pantalla Principal

### Vista General

**Nombre:** ReadingScreen

**Propósito:**
Mostrar todos los libros que el usuario está leyendo actualmente (status = 'reading') con opciones para iniciar sesiones de lectura o actualizar progreso.

### Estructura Visual

**Header:**
- Título: "📖 Leyendo"
- Subtítulo: "Tus libros en curso"
- Contador: "X libros" (donde X es la cantidad)

**Lista de Libros:**
- Cada libro se muestra en una card individual
- Organización vertical (scroll infinito)
- Sin límite de libros simultáneos (puede tener 1, 3, 10 libros en lectura)

**Estado Vacío:**
- Icono grande de libro (opaco)
- Mensaje: "No tienes libros en lectura"
- Descripción: "Ve a tu biblioteca y marca un libro como 'En lectura' para empezar"
- Botón: "Ir a Biblioteca" (navega a la pestaña Biblioteca)

**Sección Inferior (Opcional):**
- Card de estadísticas con:
  - Tiempo de lectura semanal
  - Páginas leídas esta semana
  - Libros completados recientemente

### Card de Libro en Lectura

**Contenido de cada card:**

**Izquierda:**
- Portada del libro (80x120px aproximadamente)
- Usar cached_network_image para performance
- Placeholder mientras carga
- Error widget si falla (icono de libro genérico)

**Derecha:**
- **Título del libro** (tipografía Georgia, bold, 2 líneas máximo)
- **Autor** (tipografía Georgia, color secundario)
- **Barra de progreso:**
  - Texto: "Página X de Y"
  - Porcentaje: "Z%"
  - ProgressBar visual (color #8B7355)
  - Fondo de la barra: #E5DCC8

**Botones de acción:**
- **Botón principal (ancho):** "Comenzar Sesión" 
  - Icon: play_circle_outline
  - Color: #8B7355 (marrón principal)
  - Acción: Abre pantalla de configuración de sesión
  
- **Botón secundario (estrecho):** "Actualizar"
  - Sin icono
  - Outlined button
  - Acción: Abre diálogo rápido para actualizar página actual

**Diseño:**
- Card con elevación sutil
- Border radius de 12px
- Padding interno de 16px
- Margin inferior de 16px entre cards

---

## 4. Flujo: Iniciar Sesión de Lectura

### Paso 1: Configuración de Sesión

**Pantalla:** ReadingSessionSetupScreen

**Propósito:**
Permitir al usuario elegir cuánto tiempo va a dedicar a leer.

**Elementos visuales:**

**Superior:**
- Portada del libro (tamaño mediano, 100x150px)
- Título del libro centrado debajo de la portada

**Pregunta principal:**
- Texto grande: "⏱️ ¿Cuánto tiempo vas a leer?"

**Opciones rápidas (chips):**
- 15 minutos
- 30 minutos
- 45 minutos
- 1 hora
- 1 hora 30 minutos
- 2 horas

**Botón secundario:**
- "Tiempo personalizado" (abre un input numérico)
- Permite ingresar cualquier cantidad de minutos

**Opción inferior (discreta):**
- Link de texto pequeño: "Sin límite de tiempo"
- Para lecturas largas sin timer específico

**Comportamiento:**
- Al seleccionar una opción, navega inmediatamente a la pantalla de sesión
- No hay confirmación adicional (flujo rápido)

### Paso 2: Sesión de Lectura Activa

**Pantalla:** ReadingSessionScreen

**Propósito:**
Crear un ambiente de lectura sin distracciones con pantalla en blanco y negro, timer visible y modo No Molestar activo.

**Características técnicas:**

**Efecto Visual:**
- Aplicar filtro de escala de grises a toda la pantalla (ColorFilter.matrix)
- Fondo negro con opacidad 95%
- Toda la interfaz en tonos grises

**Elementos en pantalla:**

**Centro superior:**
- Portada del libro muy opaca (opacity 0.3)
- Tamaño reducido (120x180px)

**Centro de pantalla:**

Si tiene timer:
- Círculo de progreso (CircularProgressIndicator)
- Timer en el centro con formato MM:SS
- Tipografía grande (48px), peso ligero
- Color blanco muy transparente (white38)

Si es sin límite:
- Icono de infinito (Icons.all_inclusive)
- Texto: "Lectura sin límite"

**Inferior:**
- Botón de texto discreto: "Terminar ahora"
- Color blanco muy transparente
- No debe ser prominente (el objetivo es no distraer)

**Funcionalidad del sistema:**

**Modo No Molestar:**
- Activar automáticamente al entrar
- En Android: usar NotificationManager.INTERRUPTION_FILTER_NONE
- En iOS: no es posible activarlo programáticamente (explicar esto al usuario si es necesario)

**Pantalla encendida:**
- Mantener pantalla activa durante toda la sesión
- Usar SystemChrome.setEnabledSystemUIMode para modo inmersivo

**Timer:**
- Actualización cada segundo
- Cuando llega a 0, proceder automáticamente al paso siguiente

**Al finalizar:**
- Vibración suave (HapticFeedback.mediumImpact)
- Desactivar modo No Molestar
- Mostrar diálogo de sesión completada

### Paso 3: Diálogo de Sesión Completada

**Widget:** SessionCompleteDialog

**Propósito:**
Recopilar información sobre la sesión que acaba de terminar y actualizar el timeline del libro.

**Título:**
- "✨ Sesión completada" (centrado, tipografía Georgia, bold)

**Subtítulo:**
- "Has dedicado X minutos/horas a leer" (donde X es la duración real de la sesión)

**Campos de entrada:**

**1. Páginas leídas (opcional):**
- TextField numérico
- Label: "¿Cuántas páginas leíste? (opcional)"
- Icono: book
- Permite dejar vacío
- Si el usuario ingresa un número, se usa para actualizar currentPage en la base de datos

**2. Nota personal (opcional):**
- TextField multilinea (3 líneas)
- Límite: 280 caracteres (mostrar contador)
- Label: "💭 ¿Algo que quieras recordar? (opcional)"
- Hint: "Ej: 'El capítulo 5 me hizo llorar'"
- Esta nota se inserta en el timeline del libro
- Es privada por defecto

**3. Checkbox: ¿Terminaste el libro?**
- CheckboxListTile
- Texto: "¿Terminaste este libro?"
- Si está marcado:
  - Mostrar subtexto: "Se marcará como completado"
  - Al guardar, cambiar status del libro a 'completed'
  - Actualizar finishedDate a la fecha actual

**Botones de acción:**

**Botón 1: "Solo guardar"**
- Outlined button (borde marrón)
- Acción:
  - Guarda la sesión en reading_sessions
  - Inserta entrada en el timeline del libro
  - Actualiza currentPage si se ingresó
  - Cambia status a completed si se marcó el checkbox
  - Cierra el diálogo
  - Vuelve a la pestaña "Leyendo"

**Botón 2: "Guardar y ver libro"**
- Elevated button (fondo marrón)
- Acción:
  - Hace lo mismo que "Solo guardar"
  - Además navega al detalle del libro
  - Útil para ver el timeline actualizado o la estantería si completó el libro

**Layout:**
- Botones en fila (igual ancho)
- Espacio de 12px entre botones
- Padding generoso (24px)

---

## 5. Actualización Rápida de Progreso

### Diálogo: QuickProgressUpdateDialog

**Propósito:**
Permitir actualizar la página actual sin iniciar una sesión completa de lectura.

**Cuándo se usa:**
- Usuario pulsa botón "Actualizar" en la card del libro
- Para actualizaciones rápidas sin cronómetro

**Contenido:**
- Título: "Actualizar progreso"
- Nombre del libro (bold, centrado)
- TextField numérico para página actual
- Sufijo: "de X" (donde X es el total de páginas)
- Autofocus en el campo

**Botones:**
- "Cancelar" (text button)
- "Guardar" (elevated button, marrón)

**Acción al guardar:**
- Actualizar user_books.currentPage
- Calcular y actualizar user_books.progress (porcentaje)
- Mostrar snackbar de confirmación
- Cerrar diálogo
- NO inserta entrada en timeline (solo actualiza progreso)

---

## 6. Integración con Timeline Existente

### Conceptos Clave

Ya existe un sistema de timeline en cada libro. La sesión de lectura debe **insertar entradas en ese timeline existente**, no crear uno nuevo.

### Tipos de Entradas a Insertar

**Entrada tipo "session" (sesión normal):**
- Fecha de la sesión
- Duración en minutos
- Páginas leídas (si se ingresó)
- Nota personal (si se ingresó)
- No cambia el status del libro

**Entrada tipo "completed" (libro terminado):**
- Fecha de finalización
- Duración de la última sesión
- Nota personal (si se ingresó)
- Cambia el status del libro a "completed"
- Actualiza finishedDate

### Lógica de Guardado

**Si el usuario marcó "Terminé el libro":**
1. Insertar entrada en timeline tipo "completed"
2. Actualizar user_books:
   - status = 'completed'
   - finishedDate = fecha actual
   - currentPage = total de páginas del libro
   - progress = 100%

**Si solo leyó sin terminar:**
1. Insertar entrada en timeline tipo "session"
2. Si ingresó páginas leídas:
   - Actualizar currentPage (sumar las páginas leídas al currentPage actual)
   - Recalcular progress (porcentaje)
3. El status permanece como "reading"

---

## 7. Provider de Riverpod

### readingBooksProvider

**Tipo:** FutureProvider<List<BookWithDetails>>

**Propósito:**
Obtener todos los libros con status = 'reading' del usuario actual.

**Query:**
- JOIN entre user_books y books
- WHERE: status = 'reading' AND userId = currentUserId
- Ordenar por última modificación (opcional)

**Estructura de datos:**
- Devuelve una lista de BookWithDetails
- BookWithDetails debe contener:
  - Book (datos del libro: id, title, author, coverUrl, pageCount)
  - UserBook (datos del usuario: id, currentPage, progress, status)

**Uso:**
- La pantalla ReadingScreen escucha este provider
- Se refresca automáticamente cuando hay cambios
- Maneja estados: loading, data, error

---

## 8. Estados de la UI

### Estado: Loading (Cargando)

**Cuándo:** Al abrir la pestaña por primera vez o al refrescar

**Mostrar:**
- CircularProgressIndicator centrado
- Color del spinner: #8B7355

### Estado: Error

**Cuándo:** Falla la query a la base de datos

**Mostrar:**
- Icono de error (error_outline)
- Mensaje: "Error al cargar libros"
- Botón: "Reintentar" que refresca el provider

### Estado: Empty (Vacío)

**Cuándo:** El usuario no tiene libros con status = 'reading'

**Mostrar:**
- Icono grande de libro (menu_book_outlined, opacidad 30%)
- Título: "No tienes libros en lectura"
- Descripción: "Ve a tu biblioteca y marca un libro como 'En lectura' para empezar"
- Botón: "Ir a Biblioteca" que cambia de pestaña

### Estado: Data (Con libros)

**Cuándo:** El usuario tiene uno o más libros en lectura

**Mostrar:**
- Lista de cards de libros
- Stats card al final (opcional)

---

## 9. Colores y Tipografía

### Paleta de Colores

**Principal:**
- Marrón principal: #8B7355
- Marrón claro: #6B5D4F
- Papel envejecido: #F5F1E8
- Texto oscuro: #2C2416
- Texto secundario: #8B7355

**Barras y fondos:**
- Fondo de progress bar: #E5DCC8
- Relleno de progress bar: #8B7355

**En modo B&N:**
- Todos los colores se convierten a escala de grises
- Blanco transparente para textos (white38, white24)
- Negro opaco para fondo (black con opacity 0.95)

### Tipografía

**Fuente principal:** Georgia
- Títulos: bold, 18-22px
- Subtítulos: regular, 14-16px
- Texto de body: regular, 14px
- Labels: 12-14px

**Timer en sesión:**
- Tamaño: 48px
- Peso: light (w300)
- Familia: Georgia

---

## 10. Animaciones y Transiciones

### Navegación Entre Pantallas

- Usar MaterialPageRoute con transición por defecto
- No agregar animaciones custom (mantener simplicidad)

### Diálogos

- showDialog con barrierDismissible según contexto:
  - SessionCompleteDialog: false (debe completar el flujo)
  - QuickProgressUpdateDialog: true (puede cancelar)

### Progress Bar

- LinearProgressIndicator con borderRadius
- Animación smooth al actualizar valor

### Vibración

- HapticFeedback.mediumImpact al terminar sesión
- No usar en otros lugares (mantener sutileza)

---

## 11. Modo No Molestar (Platform-Specific)

### Android

**Implementación:**
- Usar platform channels
- Método: NotificationManager.setInterruptionFilter
- Valor: INTERRUPTION_FILTER_NONE
- Requiere permisos: NotificationManager.POLICY_ACCESS_NOTIFICATION
- Al salir: restaurar a INTERRUPTION_FILTER_ALL

**Permisos necesarios:**
- En AndroidManifest.xml declarar permiso de modificar configuración
- Solicitar permiso en runtime la primera vez

### iOS

**Limitación:**
- iOS no permite activar Do Not Disturb programáticamente
- Es una restricción del sistema operativo

**Alternativa:**
- Mostrar mensaje al usuario la primera vez
- Explicar que puede activar Do Not Disturb manualmente
- No bloquear la funcionalidad por esto

---

## 12. Performance y Optimización

### Caché de Imágenes

- Usar cached_network_image para todas las portadas
- Configurar cache manager si es necesario
- Placeholder mientras carga
- Error widget si falla

### Timer

- Usar Timer.periodic con duración de 1 segundo
- Cancelar el timer en dispose()
- No causa problemas de performance (es muy ligero)

### Queries a Base de Datos

- Las queries son simples (JOIN de dos tablas con WHERE)
- No requiere optimización especial
- Drift maneja el caché automáticamente

### Pantalla en Modo Sesión

- ColorFilter no impacta performance significativamente
- Es un shader GPU, muy eficiente
- No usar imágenes pesadas en esta pantalla

---

## 13. Casos de Uso y Flujos

### Caso 1: Usuario Lee 30 Minutos y Actualiza Páginas

**Flujo:**
1. Usuario abre pestaña "Leyendo"
2. Ve su libro "Rayuela" al 67% (página 234/350)
3. Pulsa "Comenzar Sesión"
4. Elige "30 min"
5. Lee durante 30 minutos (pantalla B&N)
6. Timer termina, vibra
7. Diálogo: ingresa "30" páginas leídas
8. Añade nota: "El capítulo con Maga me emocionó"
9. NO marca como terminado
10. Pulsa "Solo guardar"
11. Vuelve a pestaña "Leyendo"
12. Ve "Rayuela" ahora al 75% (página 264/350)

**Resultado en BD:**
- reading_sessions: nueva entrada con 30min, 30 páginas, nota
- timeline del libro: nueva entrada tipo "session"
- user_books: currentPage = 264, progress = 75%

### Caso 2: Usuario Termina un Libro

**Flujo:**
1. Usuario está en página 320 de 328 de "1984"
2. Comienza sesión de 45min
3. Al terminar, ingresa "8" páginas (llegó al final)
4. Añade nota: "Final impactante, no lo esperaba"
5. MARCA checkbox "Terminé este libro"
6. Pulsa "Guardar y ver libro"
7. Navega al detalle de "1984"
8. Ve en timeline la entrada de completado con su nota

**Resultado en BD:**
- reading_sessions: entrada con markedAsCompleted = true
- timeline: entrada tipo "completed" con nota
- user_books: status = 'completed', finishedDate = hoy, currentPage = 328
- El libro desaparece de la pestaña "Leyendo"
- El libro aparece en la estantería virtual (si está implementada)

### Caso 3: Usuario Actualiza Progreso Sin Sesión

**Flujo:**
1. Usuario leyó físicamente sin la app
2. Abre pestaña "Leyendo"
3. Pulsa "Actualizar" en "El Principito"
4. Ingresa página actual: "45"
5. Pulsa "Guardar"
6. Ve snackbar: "Progreso actualizado"
7. Progress bar se actualiza

**Resultado en BD:**
- user_books: currentPage = 45, progress actualizado
- NO se crea entrada en timeline (solo actualización manual)
- NO se crea reading_session

### Caso 4: Usuario Lee Sin Límite de Tiempo

**Flujo:**
1. Comienza sesión
2. Elige "Sin límite de tiempo"
3. Pantalla B&N muestra símbolo de infinito
4. No hay timer visible
5. Usuario lee 2 horas
6. Pulsa "Terminar ahora"
7. Diálogo muestra "Has dedicado 2h 15min a leer"
8. Resto del flujo igual

**Resultado:**
- durationMinutes = 135 (2h 15min)
- sessionType = 'unlimited'

---

## 14. Mensajes y Textos de la UI

### Mensajes Positivos (Sin Presión)

**En lugar de:**
- ❌ "¡Solo quedan 5 días para tu meta!"
- ❌ "¡Llevas 3 días sin leer!"
- ❌ "¡Lee 20 minutos más!"

**Usar:**
- ✅ "Has dedicado X horas tranquilas este mes"
- ✅ "Cada libro que termines aparecerá aquí"
- ✅ "Lee cuando quieras, a tu ritmo"

### Tono de Voz

- Cálido y acogedor
- Sin exclamaciones excesivas
- Sin lenguaje de urgencia
- Usar tipografía Georgia para reforzar ambiente literario

---

## 15. Testing y Validación

### Escenarios a Testear

**Funcionalidad básica:**
- [ ] Ver libros en lectura
- [ ] Iniciar sesión con timer
- [ ] Iniciar sesión sin límite
- [ ] Timer cuenta correctamente
- [ ] Vibración al terminar
- [ ] Guardar páginas leídas
- [ ] Guardar nota en timeline
- [ ] Marcar libro como completado
- [ ] Actualización rápida de progreso

**Estados especiales:**
- [ ] Usuario sin libros en lectura
- [ ] Usuario con 1 libro en lectura
- [ ] Usuario con múltiples libros (3-5)
- [ ] Error de conexión a BD
- [ ] Portadas que fallan al cargar

**Integración:**
- [ ] Timeline se actualiza correctamente
- [ ] Status de libro cambia a completed
- [ ] FinishedDate se establece
- [ ] Libro desaparece de "Leyendo" al completarse
- [ ] Progreso se calcula correctamente

**Performance:**
- [ ] No hay lag al abrir pestaña
- [ ] Timer es preciso
- [ ] Pantalla B&N se renderiza suavemente
- [ ] Transiciones son fluidas

---

## 16. Dependencias Necesarias

### Packages de Flutter

**Obligatorios:**
- flutter_riverpod: gestión de estado
- drift: base de datos SQLite
- cached_network_image: caché de imágenes

**Opcionales:**
- flutter_speed_dial: para FAB con menú (o hacer custom)
- uuid: generar IDs únicos

**Nativas:**
- Platform channels para modo No Molestar (Android)

---

## 17. Priorización de Desarrollo

### Fase 1: MVP (Crítico)
1. Restructurar navegación (bottom nav + FAB)
2. Crear tabla reading_sessions
3. Implementar ReadingScreen básica
4. Implementar cards de libros
5. Implementar configuración de sesión
6. Implementar sesión con timer
7. Implementar diálogo de cierre
8. Integrar con timeline existente

### Fase 2: Mejoras (Importante)
9. Actualización rápida de progreso
10. Modo No Molestar (Android)
11. Estados de error y vacío
12. Animaciones y pulido visual

### Fase 3: Extras (Opcional)
13. Stats card de actividad
14. Sesiones sin límite de tiempo
15. Vibración al terminar
16. Export de timeline

---

## 18. Decisiones de Diseño Clave

### ¿Por Qué Sesión Antes que Estadísticas?

- La acción (leer) es más importante que la medición (stats)
- Stats son consecuencia natural de usar sesiones
- Usuario viene a leer, no a ver gráficos

### ¿Por Qué Notas en el Diálogo de Cierre?

- Es el momento perfecto: acabas de leer, ideas frescas
- Reduce fricción: no hay que navegar a otra pantalla
- Construcción orgánica de memoria literaria

### ¿Por Qué Blanco y Negro?

- Reduce fatiga visual
- Menos distracción de colores
- Crea ambiente de "modo enfocado"
- No es estrictamente necesario para funcionalidad, pero mejora experiencia

### ¿Por Qué Checkbox de Completado?

- Momento natural: acabas de terminar
- Ahorra pasos: no hay que ir a otra pantalla
- Cierre emocional: marca un logro

---

## 19. Notas Finales

### Filosofía de la Feature

Esta feature debe sentirse como un **ritual de lectura**, no como un tracker fitness.

**Principios:**
- Facilita la lectura, no la mide obsesivamente
- Celebra el tiempo dedicado, no presiona por más
- Construye memoria emocional, no solo estadísticas
- Respeta la privacidad: todo es personal por defecto
- Sin notificaciones molestas ni recordatorios

### Coherencia con el Resto de la App

- Usa la misma paleta de colores
- Mantiene tipografía Georgia
- Respeta el diseño Material 3
- No introduce elementos gamificados (puntos, niveles, rachas)

### Extensibilidad Futura

Esta base permite añadir después:
- Gráficos de actividad de lectura
- Comparación de hábitos (privada, personal)
- Export de timeline como PDF
- Compartir logros (opcional, no invasivo)
- Integración con clubes de lectura (sesiones grupales)

Pero todo eso es OPCIONAL y puede esperar. El MVP debe ser funcional y simple.

---

**Fin del documento de especificaciones.**
