# PROMPT: Implementación de Clubes de Lectura

## CONTEXTO DE LA APLICACIÓN

La aplicación ya tiene implementado:
- Sistema de biblioteca personal de libros
- Grupos de préstamo entre usuarios
- Timeline de lectura por libro
- Sistema de reseñas y valoraciones
- Notificaciones in-app
- Sistema de invitaciones a grupos
- Gestión de copias locales de libros prestados

## OBJETIVO

Implementar una nueva funcionalidad: **Clubes de Lectura**, que se integrará dentro de la sección de Grupos existente.

---

## ARQUITECTURA Y UBICACIÓN

### Navegación
- La pestaña "Grupos" se divide en dos sub-pestañas:
  1. **Grupos de préstamo** (existente)
  2. **Clubes de lectura** (nueva)

- Mantener coherencia visual con el diseño actual de la app
- Reutilizar componentes existentes cuando sea posible

---

## MODELOS DE DATOS

### 1. Club de Lectura (`reading_club`)

```typescript
interface ReadingClub {
  id: string;
  nombre: string;
  descripcion: string;
  ciudad: string;
  lugar_reunion?: string; // Opcional
  frecuencia: 'semanal' | 'quincenal' | 'mensual' | 'personalizada';
  frecuencia_dias?: number; // Para frecuencia personalizada
  visibilidad: 'privado' | 'publico'; // Búsqueda pública solo en v2
  libros_siguientes_visibles: 1 | 2 | 3; // Solo configurable por dueño
  
  // Relaciones
  dueño_id: string;
  libro_actual_id?: string;
  
  // Timestamps
  creado_en: Date;
  actualizado_en: Date;
}
```

**Nota sobre visibilidad:** 
- Actualmente solo acceso por invitación
- La opción 'publico' está preparada para v2 (búsqueda pública de clubes)
- Por ahora todos los clubes son efectivamente 'privado'

### 2. Miembro de Club (`club_member`)

```typescript
interface ClubMember {
  id: string;
  club_id: string;
  usuario_id: string;
  rol: 'dueño' | 'admin' | 'miembro';
  estado: 'activo' | 'inactivo'; // Inactivo = se saltó un libro completo
  
  // Timestamps
  unido_en: Date;
  ultima_actividad: Date;
}
```

### 3. Libro del Club (`club_book`)

```typescript
interface ClubBook {
  id: string;
  club_id: string;
  libro_id: string; // Referencia a libro en biblioteca
  orden: number; // 0 = actual, 1 = siguiente, 2 = después...
  estado: 'propuesto' | 'votando' | 'proximo' | 'activo' | 'completado';
  
  // Configuración de tramos
  modo_tramos: 'automatico' | 'manual';
  total_capitulos: number;
  tramos: Tramo[]; // Array de tramos definidos
  
  // Fechas
  fecha_inicio?: Date; // Cuando se activa el libro
  fecha_fin?: Date; // Calculada según frecuencia y tramos
  
  // Timestamps
  creado_en: Date;
  actualizado_en: Date;
}
```

### 4. Tramo (`reading_section`)

```typescript
interface Tramo {
  numero: number; // 1, 2, 3...
  capitulo_inicio: number;
  capitulo_fin: number;
  fecha_apertura: Date;
  fecha_cierre: Date;
  abierto: boolean; // Calculado según fecha actual
}

// Ejemplo tramo:
// { numero: 1, capitulo_inicio: 1, capitulo_fin: 3, fecha_apertura: '2026-02-01', fecha_cierre: '2026-02-08', abierto: true }
// { numero: 2, capitulo_inicio: 4, capitulo_fin: 4, fecha_apertura: '2026-02-08', fecha_cierre: '2026-02-15', abierto: false }
```

### 5. Progreso Personal (`club_reading_progress`)

```typescript
interface ReadingProgress {
  id: string;
  club_id: string;
  libro_id: string;
  usuario_id: string;
  
  estado: 'no_empezado' | 'al_dia' | 'atrasado' | 'terminado';
  capitulo_actual: number;
  tramo_actual: number;
  
  actualizado_en: Date;
}
```

### 6. Comentario de Tramo (`section_comment`)

```typescript
interface SectionComment {
  id: string;
  club_id: string;
  libro_id: string;
  tramo_numero: number;
  usuario_id: string;
  
  contenido: string;
  reportes: number; // Contador de reportes
  oculto: boolean; // True si alcanza umbral de reportes
  
  // Timestamps
  creado_en: Date;
  eliminado_en?: Date; // Auto-eliminado 30 días después de terminar libro
}
```

### 7. Propuesta de Libro (`book_proposal`)

```typescript
interface BookProposal {
  id: string;
  club_id: string;
  libro_id: string;
  propuesto_por_id: string;
  total_capitulos: number; // Input manual obligatorio al proponer
  
  votos: string[]; // Array de usuario_id que votaron (máximo 2 votos por usuario)
  total_votos: number; // Calculado
  
  estado: 'abierta' | 'cerrada' | 'ganadora' | 'descartada';
  fecha_cierre?: Date; // Por defecto 7 días desde creación, o null si admin decide manual
  puede_retirarse: false; // Las propuestas NO pueden retirarse
  
  creado_en: Date;
}

// REGLA: Solo 1 propuesta activa por usuario y club
```

### 8. Reporte de Comentario (`comment_report`)

```typescript
interface CommentReport {
  id: string;
  comentario_id: string;
  reportado_por_id: string;
  razon?: string;
  
  creado_en: Date;
}
```

### 9. Log de Moderación (`moderation_log`)

```typescript
interface ModerationLog {
  id: string;
  club_id: string;
  accion: 'borrar_comentario' | 'expulsar_miembro' | 'cerrar_votacion' | 'ocultar_comentario';
  realizado_por_id: string;
  objetivo_id: string; // ID del comentario, usuario, etc.
  razon?: string;
  
  creado_en: Date;
}
```

---

## LÓGICA DE NEGOCIO

### Creación de Club

**Endpoint:** `POST /api/clubs`

**Validaciones:**
- Nombre: obligatorio, 3-100 caracteres
- Descripción: obligatorio, 10-500 caracteres
- Ciudad: obligatorio
- Frecuencia: una de las opciones válidas
- Si frecuencia = 'personalizada', requiere `frecuencia_dias` (1-90)
- `libros_siguientes_visibles`: 1, 2 o 3

**Proceso:**
1. Crear registro en `reading_club`
2. Añadir al creador como miembro con rol 'dueño'
3. Retornar club creado

---

### Sistema de Invitaciones

**Reutilizar sistema existente de grupos de préstamo:**
- Solo miembros con rol 'dueño' o 'admin' pueden invitar
- Acceso inicial solo por invitación
- Al aceptar invitación, crear `club_member` con rol 'miembro'

---

### Añadir Libro al Club

**Endpoint:** `POST /api/clubs/:clubId/books`

**Permisos:** Solo 'dueño' o 'admin'

**Input:**
```typescript
{
  libro_id: string; // Obtenido de búsqueda existente o añadido manualmente
  total_capitulos: number; // SIEMPRE input manual del usuario
  modo_tramos: 'automatico' | 'manual';
  tramos?: Tramo[]; // Solo si modo_tramos = 'manual'
}
```

**IMPORTANTE:** 
- Reutilizar lógica existente de búsqueda de libros (Google Books + OpenLibrary)
- Si el libro no existe, usar flujo existente de añadir libro manualmente
- El número de capítulos SIEMPRE se solicita al usuario (input manual)
- No hay obtención automática de capítulos desde APIs

**Proceso:**

#### Si modo = 'automático':
1. Usar `total_capitulos` proporcionado por el usuario
2. Obtener `frecuencia` del club
3. Calcular número de tramos según frecuencia:
   - Semanal: 4 tramos (1 semana cada uno)
   - Quincenal: 2 tramos (15 días cada uno)
   - Mensual: 1 tramo (30 días)
   - Personalizada: calcular según `frecuencia_dias`
4. Dividir `total_capitulos` equitativamente entre tramos
5. Generar array de `Tramo[]` con fechas calculadas

**Ejemplo automático (libro 12 capítulos, club quincenal):**
```typescript
// Usuario ingresa: total_capitulos = 12
// Club frecuencia: quincenal (2 tramos de 15 días)
[
  { numero: 1, capitulo_inicio: 1, capitulo_fin: 6, fecha_apertura: '2026-02-01', fecha_cierre: '2026-02-15' },
  { numero: 2, capitulo_inicio: 7, capitulo_fin: 12, fecha_apertura: '2026-02-15', fecha_cierre: '2026-02-28' }
]
```

#### Si modo = 'manual':
1. Usuario ingresa tramos manualmente: "1-3, 4, 5-12"
2. Validar que cubra todos los capítulos (1 a `total_capitulos`) sin huecos
3. Calcular fechas de apertura/cierre según frecuencia del club
4. Guardar tramos

**Ejemplo manual:**
```typescript
Input del admin: 
- total_capitulos: 12
- tramos: "1-3, 4, 5-12"

Tramos generados:
[
  { numero: 1, capitulo_inicio: 1, capitulo_fin: 3, fecha_apertura: '2026-02-01', fecha_cierre: '2026-02-08' },
  { numero: 2, capitulo_inicio: 4, capitulo_fin: 4, fecha_apertura: '2026-02-08', fecha_cierre: '2026-02-15' },
  { numero: 3, capitulo_inicio: 5, capitulo_fin: 12, fecha_apertura: '2026-02-15', fecha_cierre: '2026-02-22' }
]
```

**Guardar:**
- Crear registro `club_book`
- Si no hay libro activo, marcar como activo (`orden = 0`)
- Si hay libro activo, añadir a cola (`orden = max(orden) + 1`)

---

### Cálculo de Progreso del Club

**Endpoint:** `GET /api/clubs/:clubId/progress`

**Retorna:**
```typescript
{
  // Opción A: Progreso por tramo
  tramo_actual: number;
  total_tramos: number;
  porcentaje_tramos: number; // tramo_actual / total_tramos * 100
  
  // Opción B: Porcentaje de miembros al día
  miembros_al_dia: number;
  miembros_total: number;
  porcentaje_miembros_al_dia: number; // miembros_al_dia / miembros_total * 100
  
  // Tiempo hasta siguiente tramo (fecha fija)
  proximo_tramo: {
    numero: number;
    fecha_apertura: Date;
    dias_restantes: number;
    mensaje: string; // "Quedan 5 días para el siguiente tramo"
  }
}
```

**Lógica:**
1. Obtener libro activo del club
2. Obtener tramo actual (primer tramo con `fecha_cierre > hoy`)
3. Contar miembros con `estado = 'al_dia'`
4. Contar total de miembros activos
5. Calcular porcentajes
6. Obtener próximo tramo y calcular días restantes

---

### Marcar Progreso Personal

**Endpoint:** `PUT /api/clubs/:clubId/books/:bookId/progress`

**Input:**
```typescript
{
  estado: 'no_empezado' | 'al_dia' | 'atrasado' | 'terminado';
  capitulo_actual?: number; // Opcional, para tracking fino
}
```

**Lógica automática:**
1. Si `capitulo_actual` está en tramo activo → `estado = 'al_dia'`
2. Si `capitulo_actual` está en tramo anterior → `estado = 'atrasado'`
3. Si `capitulo_actual` >= último capítulo → `estado = 'terminado'`

**Proceso:**
1. Actualizar `reading_progress`
2. Actualizar `ultima_actividad` del `club_member`
3. Generar notificación si termina tramo: "¡Has completado el tramo X!"

---

### Sistema de Propuestas y Votaciones

#### Proponer Libro

**Endpoint:** `POST /api/clubs/:clubId/proposals`

**Validaciones:**
- Usuario debe ser miembro activo
- **Límite: 1 propuesta activa por usuario y club** (no puede proponer más hasta que se cierre la actual)
- El libro no debe estar ya en el club (activo, próximo o completado)
- `total_capitulos` es obligatorio (input manual)

**Proceso:**
1. Verificar que usuario no tenga propuesta activa en este club:
   ```typescript
   const propuestaActiva = await BookProposal.findOne({
     club_id: clubId,
     propuesto_por_id: usuarioId,
     estado: 'abierta'
   });
   
   if (propuestaActiva) {
     throw new Error('Ya tienes una propuesta activa en este club');
   }
   ```
2. Crear `book_proposal` con `estado = 'abierta'`
3. Guardar `total_capitulos` proporcionado por el usuario
4. `fecha_cierre = hoy + 7 días` (por defecto)
5. Generar notificación: "Nuevo libro propuesto por X"

**Nota:** Las propuestas NO pueden retirarse una vez creadas.

#### Votar Propuesta

**Endpoint:** `POST /api/clubs/:clubId/proposals/:proposalId/vote`

**Validaciones:**
- Usuario no puede votar su propia propuesta
- Usuario puede dar máximo 2 votos en total (entre todas las propuestas abiertas)
- Propuesta debe estar en estado 'abierta'

**Proceso:**
1. Verificar que usuario tiene votos disponibles
2. Añadir `usuario_id` al array `votos`
3. Incrementar `total_votos`
4. Si usuario ya votó esta propuesta → quitar voto (toggle)

#### Cerrar Votación

**Endpoint:** `POST /api/clubs/:clubId/proposals/close`

**Permisos:** Solo 'dueño' o 'admin'

**Proceso automático (al llegar a `fecha_cierre`):**
1. Obtener todas las propuestas abiertas
2. Ordenar por `total_votos` descendente
3. Si hay empate en primer lugar:
   - Generar notificación al dueño: "Hay un empate, debes decidir"
   - Esperar decisión manual
4. Si no hay empate:
   - Marcar ganadora como `estado = 'ganadora'`
   - Resto marcar como `estado = 'descartada'`
   - Añadir libro ganador al club como próximo libro

**Proceso manual (dueño/admin cierra antes):**
- Mismo proceso pero ejecutado manualmente

---

### Discusión por Tramos

#### Crear Comentario

**Endpoint:** `POST /api/clubs/:clubId/books/:bookId/sections/:sectionNum/comments`

**Validaciones:**
- Usuario debe ser miembro activo
- El tramo debe estar abierto (`fecha_apertura <= hoy <= fecha_cierre`)

**Proceso:**
1. Crear `section_comment`
2. Generar notificación a miembros suscritos al tramo

#### Reportar Comentario

**Endpoint:** `POST /api/comments/:commentId/report`

**Proceso:**
1. Crear `comment_report`
2. Incrementar contador `reportes` en `section_comment`
3. Si `reportes >= 3` (umbral):
   - Marcar `oculto = true`
   - Generar notificación a admins/dueño
   - Crear entrada en `moderation_log`

#### Borrar Comentario

**Endpoint:** `DELETE /api/comments/:commentId`

**Permisos:**
- Autor del comentario
- Dueño o admin del club

**Proceso:**
1. Marcar `eliminado_en = ahora`
2. Crear entrada en `moderation_log` (si fue admin/dueño quien borró)

#### Limpieza Automática (Cron Job)

**Ejecutar diariamente:**
```typescript
// Buscar libros completados hace más de 30 días
const librosViejos = await ClubBook.find({
  estado: 'completado',
  fecha_fin: { $lte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) }
});

// Eliminar comentarios asociados
for (const libro of librosViejos) {
  await SectionComment.deleteMany({
    libro_id: libro.id,
    eliminado_en: null // No borrar los ya eliminados manualmente
  });
}
```

**NOTA:** Las reseñas finales del libro NO se eliminan.

---

### Gestión de Miembros

#### Expulsar Miembro

**Endpoint:** `DELETE /api/clubs/:clubId/members/:memberId`

**Permisos:** Solo 'dueño' o 'admin'

**Proceso:**
1. Eliminar `club_member`
2. Eliminar `reading_progress` del usuario en el club
3. Los `section_comment` se mantienen (excepto los borrados)
4. Crear entrada en `moderation_log`
5. Generar notificación al usuario expulsado

#### Salir del Club

**Endpoint:** `DELETE /api/clubs/:clubId/leave`

**Proceso:**
1. Eliminar `club_member`
2. Eliminar `reading_progress` del usuario
3. Los `section_comment` se mantienen
4. Generar notificación a dueño/admins: "X ha salido del club"

#### Marcar Inactividad Automática (Cron Job)

**Ejecutar al terminar cada libro:**
```typescript
// Obtener miembros que NO leyeron el libro recién completado
const miembrosInactivos = await ClubMember.find({
  club_id: clubId,
  usuario_id: { 
    $nin: await ReadingProgress.find({ 
      club_id: clubId, 
      libro_id: libroCompletadoId,
      estado: { $in: ['al_dia', 'terminado'] }
    }).distinct('usuario_id')
  }
});

// Marcar como inactivos
for (const miembro of miembrosInactivos) {
  miembro.estado = 'inactivo';
  await miembro.save();
}

// Notificar al dueño
await Notification.create({
  tipo: 'miembros_inactivos',
  club_id: clubId,
  mensaje: `${miembrosInactivos.length} miembros no leyeron el último libro`
});
```

---

### Integración con Biblioteca Personal

**Cuando un libro del club termina:**

**Endpoint automático (ejecutado al cambiar estado a 'completado'):**

```typescript
async function onLibroClubCompletado(clubId: string, libroId: string) {
  const miembros = await ClubMember.find({ club_id: clubId, estado: 'activo' });
  
  for (const miembro of miembros) {
    // Verificar si el usuario tiene el libro en su biblioteca
    const tieneLibro = await BibliotecaPersonal.exists({ 
      usuario_id: miembro.usuario_id, 
      libro_id: libroId 
    });
    
    if (!tieneLibro) {
      // Añadir como "libro prestado" al historial
      await BibliotecaPersonal.create({
        usuario_id: miembro.usuario_id,
        libro_id: libroId,
        tipo: 'prestado', // Reutilizar sistema existente
        fuente: `Club: ${club.nombre}`,
        fecha_inicio: libro.fecha_inicio,
        fecha_fin: libro.fecha_fin,
        estado: 'leido'
      });
    }
  }
}
```

---

### Reseñas Compartidas

**Endpoint:** `POST /api/clubs/:clubId/books/:bookId/review`

**Input:**
```typescript
{
  valoracion: 1-5; // Estrellas
  texto?: string; // Opcional
  spoiler: boolean;
}
```

**Proceso:**
1. Guardar reseña en tabla `reseñas_libros` (sistema existente)
2. Marcar que fue creada desde el club:
   ```typescript
   {
     usuario_id,
     libro_id,
     valoracion,
     texto,
     spoiler,
     contexto: 'club',
     club_id: clubId, // Nuevo campo
     creado_en: Date
   }
   ```
3. La reseña aparece:
   - En el historial del club
   - En la ficha del libro en la biblioteca personal del usuario
   - En la vista pública del libro (si no es spoiler)

---

### Timeline Personal

**Reutilizar sistema existente de timeline:**
- Cada usuario mantiene su timeline del libro independientemente del club
- El timeline se guarda en tabla `timeline_lectura` (existente)
- Visible desde:
  - Vista de libro en biblioteca personal
  - Vista de progreso personal en club

**No duplicar datos**, solo referenciar.

---

## NOTIFICACIONES

### Sistema In-App (Existente)

**Tipos de notificaciones:**

```typescript
type NotificacionClub =
  | { tipo: 'nuevo_tramo'; club_id; libro_id; tramo_numero }
  | { tipo: 'nuevo_libro'; club_id; libro_id }
  | { tipo: 'votacion_abierta'; club_id; proposal_id }
  | { tipo: 'votacion_cerrada'; club_id; libro_ganador_id }
  | { tipo: 'comentario_nuevo'; club_id; libro_id; tramo_numero; comentario_id }
  | { tipo: 'miembro_completo_tramo'; club_id; usuario_id; tramo_numero }
  | { tipo: 'recordatorio_atrasado'; club_id; libro_id }
  | { tipo: 'expulsion'; club_id }
  | { tipo: 'nuevo_miembro'; club_id; usuario_id };
```

**Generar notificación cuando:**
- ✅ Se abre un nuevo tramo → `nuevo_tramo`
- ✅ Se añade un libro al club → `nuevo_libro`
- ✅ Se abre una votación → `votacion_abierta`
- ✅ Se cierra una votación → `votacion_cerrada`
- ✅ Hay un nuevo comentario en un tramo que estás siguiendo → `comentario_nuevo`
- ✅ Alguien completa un tramo → `miembro_completo_tramo`
- ✅ Vas atrasado respecto al club → `recordatorio_atrasado` (semanal)

### Notificaciones Fuera de App (Push/Email)

**Configuración por usuario:**

```typescript
interface PreferenciasNotificaciones {
  usuario_id: string;
  club_id: string;
  
  nuevo_tramo: {
    in_app: boolean;
    push: boolean;
    email: boolean;
  };
  nuevo_libro: {
    in_app: boolean;
    push: boolean;
    email: boolean;
  };
  votacion_abierta: {
    in_app: boolean;
    push: boolean;
  };
  resumen_semanal: {
    email: boolean;
  };
}
```

**Valores por defecto:**
- `nuevo_tramo`: in-app + push
- `nuevo_libro`: in-app + push + email
- `votacion_abierta`: in-app
- `resumen_semanal`: email desactivado

**Implementación:**
1. Al generar notificación, consultar preferencias del usuario
2. Enviar según canales activos
3. Para push/email, usar servicios existentes (Firebase, SendGrid, etc.)

---

## INTERFAZ DE USUARIO

### Pantalla Principal del Club

**Componentes en orden visual (de arriba a abajo):**

#### 1. Cabecera
```typescript
<ClubHeader>
  <h1>{club.nombre}</h1>
  <Metadata>
    <Icon>📍</Icon> {club.ciudad}
    <Icon>📅</Icon> {frecuenciaLegible(club.frecuencia)}
    <Icon>👥</Icon> {miembros.length} miembros
  </Metadata>
  {isAdmin && <ButtonEditClub />}
</ClubHeader>
```

#### 2. Libro Actual (Bloque destacado - más grande)
```typescript
<LibroActual>
  <Portada size="large" src={libro.portada} />
  
  <Info>
    <h2>{libro.titulo}</h2>
    <p>{libro.autor}</p>
    
    {/* Opción A: Progreso por tramo */}
    <ProgresoBar>
      <span>Tramo {tramo_actual} de {total_tramos}</span>
      <ProgressBar value={porcentaje_tramos} />
    </ProgresoBar>
    
    {/* Opción B: Progreso de miembros */}
    <MiembrosProgreso>
      <span>{miembros_al_dia} de {miembros_total} miembros al día</span>
      <ProgressBar value={porcentaje_miembros_al_dia} />
    </MiembrosProgreso>
    
    {/* Tiempo hasta próximo tramo */}
    <ProximoTramo>
      <Icon>⏰</Icon>
      <span>{proximo_tramo.mensaje}</span>
    </ProximoTramo>
  </Info>
  
  <Actions>
    <Button onClick={irADiscusion}>💬 Ir a discusión del tramo {tramo_actual}</Button>
    <Button onClick={marcarProgreso}>✓ Marcar mi progreso</Button>
  </Actions>
</LibroActual>
```

#### 3. Indicador Personal
```typescript
<EstadoPersonal>
  {estado === 'al_dia' && (
    <Badge color="green">
      ✓ Estás al día con el club
    </Badge>
  )}
  {estado === 'atrasado' && (
    <Badge color="orange">
      ⚠ Vas 1 tramo por detrás
    </Badge>
  )}
  {estado === 'terminado' && (
    <Badge color="blue">
      🎉 Has terminado este libro
    </Badge>
  )}
</EstadoPersonal>
```

#### 4. Actividad Reciente
```typescript
<ActividadReciente>
  <h3>Actividad reciente</h3>
  <Timeline limit={5}>
    {/* Ejemplos: */}
    <Item>
      <Avatar user={usuario} />
      <Text>{usuario.nombre} comentó en el tramo 3</Text>
      <Time>Hace 2 horas</Time>
    </Item>
    <Item>
      <Icon>✓</Icon>
      <Text>María terminó el tramo 2</Text>
      <Time>Hace 5 horas</Time>
    </Item>
    <Item>
      <Icon>📚</Icon>
      <Text>Se abrió el tramo 3</Text>
      <Time>Hace 1 día</Time>
    </Item>
  </Timeline>
</ActividadReciente>
```

#### 5. Próximos Libros
```typescript
<ProximosLibros>
  <h3>Próximos libros</h3>
  {/* Mostrar solo la cantidad configurada por el dueño */}
  {proximosLibros.slice(0, club.libros_siguientes_visibles).map(libro => (
    <LibroCompacto key={libro.id}>
      <Portada size="small" src={libro.portada} />
      <Info>
        <Title>{libro.titulo}</Title>
        <Author>{libro.autor}</Author>
      </Info>
    </LibroCompacto>
  ))}
  
  {isOwner && (
    <ConfigButton onClick={abrirConfiguracion}>
      ⚙️ Configurar cuántos mostrar (1-3)
    </ConfigButton>
  )}
</ProximosLibros>
```

**Nota:** Solo el dueño puede cambiar `libros_siguientes_visibles`. Todos los miembros ven la misma cantidad.

#### 6. Propuestas y Votaciones
```typescript
<PropuestasVotaciones>
  <Header>
    <h3>Propuestas de libros</h3>
    <Button onClick={proponerLibro}>+ Proponer libro</Button>
  </Header>
  
  {propuestasAbiertas.map(propuesta => (
    <PropuestaCard key={propuesta.id}>
      <Portada src={propuesta.libro.portada} />
      <Info>
        <Title>{propuesta.libro.titulo}</Title>
        <Author>{propuesta.libro.autor}</Author>
        <Propuesto>Propuesto por {propuesta.propuesto_por.nombre}</Propuesto>
      </Info>
      <Votacion>
        <VotosCount>{propuesta.total_votos} votos</VotosCount>
        {!propuesta.votos.includes(userId) && votosDisponibles > 0 && (
          <Button onClick={votar}>👍 Votar</Button>
        )}
        {propuesta.votos.includes(userId) && (
          <Button onClick={quitarVoto} variant="secondary">✓ Votado</Button>
        )}
      </Votacion>
      {propuesta.fecha_cierre && (
        <Countdown>Cierra en {diasRestantes(propuesta.fecha_cierre)} días</Countdown>
      )}
    </PropuestaCard>
  ))}
</PropuestasVotaciones>
```

#### 7. Historial del Club
```typescript
<HistorialClub>
  <h3>Libros leídos ({librosCompletados.length})</h3>
  <Grid>
    {librosCompletados.map(libro => (
      <LibroHistorial key={libro.id}>
        <Portada src={libro.portada} />
        <Info>
          <Title>{libro.titulo}</Title>
          <Fecha>Leído en {formatearFecha(libro.fecha_fin)}</Fecha>
          <Rating value={libro.valoracion_promedio} />
        </Info>
        <Button onClick={() => verReseñas(libro.id)}>Ver reseñas</Button>
      </LibroHistorial>
    ))}
  </Grid>
</HistorialClub>
```

---

### Pantalla de Discusión de Tramo

```typescript
<DiscusionTramo>
  <Header>
    <BackButton />
    <Title>Discusión - Tramo {tramo.numero}</Title>
    <Info>Capítulos {tramo.capitulo_inicio} - {tramo.capitulo_fin}</Info>
  </Header>
  
  {!tramo.abierto && (
    <Alert type="warning">
      Este tramo aún no está disponible. Se abrirá el {formatearFecha(tramo.fecha_apertura)}
    </Alert>
  )}
  
  {tramo.abierto && (
    <>
      <Comentarios>
        {comentarios.map(comentario => (
          <ComentarioCard key={comentario.id}>
            <Avatar user={comentario.usuario} />
            <Contenido>
              <Autor>{comentario.usuario.nombre}</Autor>
              <Texto>{comentario.contenido}</Texto>
              <Acciones>
                <Time>{formatearFecha(comentario.creado_en)}</Time>
                <Button onClick={() => reportar(comentario.id)}>🚩 Reportar</Button>
                {(isAdmin || comentario.usuario_id === userId) && (
                  <Button onClick={() => borrar(comentario.id)}>🗑 Borrar</Button>
                )}
              </Acciones>
            </Contenido>
          </ComentarioCard>
        ))}
      </Comentarios>
      
      <NuevoComentario>
        <Textarea 
          placeholder="Comparte tus pensamientos sobre este tramo..."
          value={nuevoComentario}
          onChange={setNuevoComentario}
        />
        <Button onClick={publicarComentario}>Publicar</Button>
      </NuevoComentario>
    </>
  )}
</DiscusionTramo>
```

---

### Modal: Marcar Progreso Personal

```typescript
<ModalProgreso>
  <Header>
    <Title>Mi progreso en {libro.titulo}</Title>
  </Header>
  
  <EstadoSelector>
    <RadioGroup value={estado} onChange={setEstado}>
      <Radio value="no_empezado">
        No he empezado
      </Radio>
      <Radio value="al_dia">
        Voy al día (terminé el tramo {tramo_actual})
      </Radio>
      <Radio value="atrasado">
        Voy atrasado (no terminé el tramo {tramo_actual})
      </Radio>
      <Radio value="terminado">
        He terminado el libro
      </Radio>
    </RadioGroup>
  </EstadoSelector>
  
  {estado === 'terminado' && (
    <ReseñaPrompt>
      <p>¿Quieres dejar una reseña?</p>
      <Button onClick={abrirReseña}>✍️ Escribir reseña</Button>
    </ReseñaPrompt>
  )}
  
  <Actions>
    <Button onClick={guardarProgreso} variant="primary">Guardar</Button>
    <Button onClick={cerrar} variant="secondary">Cancelar</Button>
  </Actions>
</ModalProgreso>
```

---

### Modal: Proponer Libro

**IMPORTANTE:** Reutilizar la lógica existente de búsqueda de libros (Google Books + OpenLibrary).

```typescript
<ModalProponerLibro>
  <Header>
    <Title>Proponer libro al club</Title>
  </Header>
  
  {/* REUTILIZAR componente existente de búsqueda de libros */}
  <BuscadorLibroExistente
    onLibroSeleccionado={setLibroSeleccionado}
    placeholder="Buscar libro por título o ISBN..."
  />
  
  {/* Si el libro no está en la BD, usar lógica existente de añadir manualmente */}
  {!libroEncontrado && (
    <BotonAñadirManual onClick={abrirFormularioManual}>
      + Añadir libro manualmente
    </BotonAñadirManual>
  )}
  
  {libroSeleccionado && (
    <LibroSeleccionado>
      <Portada src={libroSeleccionado.portada} />
      <Info>
        <Title>{libroSeleccionado.titulo}</Title>
        <Author>{libroSeleccionado.autor}</Author>
      </Info>
      
      {/* Input manual de capítulos */}
      <InputCapitulos>
        <Label>Número de capítulos:</Label>
        <Input 
          type="number"
          min={1}
          placeholder="Ej: 12"
          value={totalCapitulos}
          onChange={setTotalCapitulos}
          required
        />
        <Help>Este dato es necesario para dividir el libro en tramos</Help>
      </InputCapitulos>
    </LibroSeleccionado>
  )}
  
  <Actions>
    <Button 
      onClick={enviarPropuesta} 
      variant="primary"
      disabled={!libroSeleccionado || !totalCapitulos}
    >
      Proponer libro
    </Button>
    <Button onClick={cerrar} variant="secondary">Cancelar</Button>
  </Actions>
</ModalProponerLibro>
```

---

## CASOS EDGE Y VALIDACIONES

### Nuevo Miembro se une a Mitad de Libro

**Proceso:**
1. Al aceptar invitación, verificar si hay libro activo
2. Si hay libro activo:
   - Crear `reading_progress` con `estado = 'atrasado'`
   - Mostrar todos los tramos anteriores (puede leerlos y comentar)
   - Mensaje: "Te has unido mientras el club lee {libro.titulo}. Ponte al día para el siguiente libro"

### Usuario Inactivo

**Detección:**
- Cron job ejecuta al completar cada libro
- Si usuario no tiene progreso en libro completado → marcar `estado = 'inactivo'`

**Vista para dueño/admin:**
```typescript
<MiembrosInactivos>
  <Alert type="warning">
    {miembrosInactivos.length} miembros no participaron en el último libro
  </Alert>
  <Lista>
    {miembrosInactivos.map(miembro => (
      <MiembroItem>
        <Avatar user={miembro.usuario} />
        <Nombre>{miembro.usuario.nombre}</Nombre>
        <Acciones>
          <Button onClick={() => contactar(miembro.usuario_id)}>✉️ Contactar</Button>
          <Button onClick={() => expulsar(miembro.id)} variant="danger">❌ Expulsar</Button>
        </Acciones>
      </MiembroItem>
    ))}
  </Lista>
</MiembrosInactivos>
```

### Empate en Votación

**Proceso automático:**
1. Al llegar a `fecha_cierre`, detectar empate
2. Generar notificación al dueño:
   ```typescript
   {
     tipo: 'empate_votacion',
     club_id,
     propuestas_empatadas: [propuesta1, propuesta2],
     mensaje: 'Hay un empate en la votación. Debes elegir el ganador'
   }
   ```
3. Vista especial para dueño:
   ```typescript
   <DecidirEmpate>
     <Titulo>Hay un empate. Elige el libro ganador:</Titulo>
     {propuestasEmpatadas.map(propuesta => (
       <PropuestaCard>
         <LibroInfo />
         <Button onClick={() => elegirGanador(propuesta.id)}>
           Elegir este libro
         </Button>
       </PropuestaCard>
     ))}
   </DecidirEmpate>
   ```

### Eliminar Club

**Endpoint:** `DELETE /api/clubs/:clubId`

**Permisos:** Solo dueño

**Proceso:**
1. Mostrar confirmación:
   ```
   "¿Estás seguro? Esto eliminará:
   - Todos los miembros
   - Todas las propuestas
   - Todos los comentarios
   - El historial de libros leídos
   
   Las reseñas individuales se mantendrán en las bibliotecas personales."
   ```
2. Si confirma:
   - Eliminar `club_members`
   - Eliminar `book_proposals`
   - Eliminar `section_comments`
   - Eliminar `reading_progress`
   - Eliminar `club_books`
   - Eliminar `reading_club`
3. Generar notificación a todos los miembros

---

## RENDIMIENTO Y OPTIMIZACIÓN

### Paginación

**Comentarios:**
- Cargar 20 comentarios iniciales por tramo
- Botón "Cargar más" para siguientes 20

**Historial:**
- Cargar 12 libros iniciales
- Scroll infinito o paginación

**Actividad reciente:**
- Máximo 5 eventos visibles
- No paginación (solo los más recientes)

### Índices de Base de Datos

```typescript
// Índices críticos
club_books: ['club_id', 'estado', 'orden']
club_members: ['club_id', 'usuario_id', 'estado']
reading_progress: ['club_id', 'libro_id', 'usuario_id']
section_comments: ['club_id', 'libro_id', 'tramo_numero', 'creado_en']
book_proposals: ['club_id', 'estado', 'total_votos']
```

### Caché

**Datos a cachear (Redis):**
```typescript
// Progreso del club (TTL: 1 hora)
`club:${clubId}:progress` → { tramo_actual, miembros_al_dia, ... }

// Libro actual (TTL: hasta que cambie libro)
`club:${clubId}:current_book` → { libro, tramos, ... }

// Contadores (TTL: 5 minutos)
`club:${clubId}:members_count` → numero
`club:${clubId}:comments_count:${tramoId}` → numero
```

### Lazy Loading

**No cargar inicialmente:**
- Historial completo (solo 12 primeros)
- Comentarios de tramos no activos
- Detalles de miembros (solo nombres y avatares)

---

## TESTING

### Tests Unitarios Críticos

```typescript
// Cálculo de tramos automático
test('divide libro en tramos según frecuencia', () => {
  const libro = { total_capitulos: 12 };
  const club = { frecuencia: 'quincenal' };
  const tramos = calcularTramos(libro, club);
  
  expect(tramos).toHaveLength(2);
  expect(tramos[0]).toMatchObject({
    capitulo_inicio: 1,
    capitulo_fin: 6
  });
});

// Validación de votos
test('usuario no puede votar más de 2 veces', async () => {
  await votarPropuesta(propuesta1, userId);
  await votarPropuesta(propuesta2, userId);
  
  await expect(
    votarPropuesta(propuesta3, userId)
  ).rejects.toThrow('Ya has usado tus 2 votos');
});

// Detección de inactividad
test('marca inactivos a miembros que no leyeron libro', async () => {
  await completarLibro(clubId, libroId);
  await marcarInactivos(clubId, libroId);
  
  const inactivos = await ClubMember.find({ 
    club_id: clubId, 
    estado: 'inactivo' 
  });
  
  expect(inactivos).toHaveLength(3);
});
```

### Tests de Integración

```typescript
// Flujo completo: crear club → añadir libro → leer → votar siguiente
test('flujo completo de club de lectura', async () => {
  // 1. Crear club
  const club = await crearClub({
    nombre: 'Test Club',
    frecuencia: 'semanal'
  });
  
  // 2. Añadir libro
  const libro = await añadirLibro(club.id, {
    libro_id: 'libro123',
    modo_tramos: 'automatico',
    total_capitulos: 8
  });
  
  expect(libro.tramos).toHaveLength(4); // 4 semanas
  
  // 3. Marcar progreso
  await marcarProgreso(club.id, libro.id, userId, { estado: 'al_dia' });
  
  const progreso = await getProgreso(club.id);
  expect(progreso.miembros_al_dia).toBe(1);
  
  // 4. Proponer siguiente libro
  const propuesta = await proponerLibro(club.id, 'libro456', userId);
  
  // 5. Votar
  await votarPropuesta(propuesta.id, otroUserId);
  
  expect(propuesta.total_votos).toBe(1);
});
```

---

## MIGRACIÓN Y DESPLIEGUE

### Plan de Migración

**Fase 1: Crear tablas**
```sql
CREATE TABLE reading_clubs (...);
CREATE TABLE club_members (...);
CREATE TABLE club_books (...);
CREATE TABLE reading_progress (...);
CREATE TABLE section_comments (...);
CREATE TABLE book_proposals (...);
CREATE TABLE comment_reports (...);
CREATE TABLE moderation_logs (...);
```

**Fase 2: Índices**
```sql
CREATE INDEX idx_club_books_club_id ON club_books(club_id);
CREATE INDEX idx_club_members_club_usuario ON club_members(club_id, usuario_id);
-- etc...
```

**Fase 3: Deploy backend**
- Endpoints de clubes
- Lógica de tramos
- Sistema de votaciones
- Notificaciones

**Fase 4: Deploy frontend**
- Pestaña "Clubes de lectura"
- Pantallas principales
- Modales

**Fase 5: Cron jobs**
- Limpieza de comentarios (30 días)
- Cierre automático de votaciones
- Detección de inactividad

### Rollback Plan

Si hay problemas:
1. Ocultar pestaña "Clubes de lectura" en frontend
2. Desactivar cron jobs
3. Mantener datos en DB (no eliminar)
4. Investigar y corregir
5. Re-deploy cuando esté listo

---

## CONSIDERACIONES DE SEGURIDAD

### Permisos

**Matriz de permisos:**

| Acción | Dueño | Admin | Miembro |
|--------|-------|-------|---------|
| Editar club | ✅ | ❌ | ❌ |
| Invitar miembros | ✅ | ✅ | ❌ |
| Expulsar miembros | ✅ | ✅ | ❌ |
| Añadir libro | ✅ | ✅ | ❌ |
| Definir tramos | ✅ | ✅ | ❌ |
| Cerrar votación | ✅ | ✅ | ❌ |
| Borrar comentarios | ✅ | ✅ | Solo propios |
| Proponer libros | ✅ | ✅ | ✅ |
| Votar propuestas | ✅ | ✅ | ✅ |
| Comentar | ✅ | ✅ | ✅ |
| Reportar | ✅ | ✅ | ✅ |
| Salir del club | ❌ | ✅ | ✅ |

### Validaciones de Seguridad

```typescript
// Verificar permisos antes de cada acción
async function verificarPermiso(
  clubId: string, 
  usuarioId: string, 
  accion: string
): Promise<boolean> {
  const miembro = await ClubMember.findOne({ club_id: clubId, usuario_id: usuarioId });
  
  if (!miembro) return false;
  
  const permisos = MATRIZ_PERMISOS[miembro.rol];
  return permisos.includes(accion);
}

// Rate limiting
// Máximo 10 comentarios por hora por usuario
// Máximo 1 propuesta activa por usuario y club (sin límite temporal)
// Máximo 20 reportes por día por usuario
```

### Sanitización

```typescript
// Sanitizar comentarios para prevenir XSS
import sanitizeHtml from 'sanitize-html';

function sanitizarComentario(texto: string): string {
  return sanitizeHtml(texto, {
    allowedTags: [], // Sin HTML
    allowedAttributes: {}
  });
}
```

---

## MÉTRICAS Y ANALYTICS

### Métricas a Trackear

```typescript
// Club
- Número total de clubes activos
- Número promedio de miembros por club
- Tasa de retención de miembros (% que permanecen 3+ meses)

// Libros
- Libros completados por club (promedio)
- Tiempo promedio para completar un libro
- Tasa de finalización (% usuarios que terminan vs. abandonan)

// Engagement
- Comentarios por tramo (promedio)
- Usuarios activos vs. inactivos (ratio)
- Propuestas por mes
- Participación en votaciones (%)

// Notificaciones
- Tasa de apertura de notificaciones
- Acciones realizadas desde notificaciones
```

### Dashboard para Dueños

```typescript
<DashboardAdmin>
  <Estadisticas>
    <Card>
      <Titulo>Miembros activos</Titulo>
      <Numero>{miembrosActivos} / {totalMiembros}</Numero>
      <Porcentaje>{(miembrosActivos/totalMiembros*100).toFixed(0)}%</Porcentaje>
    </Card>
    
    <Card>
      <Titulo>Libros completados</Titulo>
      <Numero>{librosCompletados}</Numero>
    </Card>
    
    <Card>
      <Titulo>Promedio de comentarios</Titulo>
      <Numero>{promedioComentarios.toFixed(1)} por tramo</Numero>
    </Card>
  </Estadisticas>
  
  <GraficaActividad>
    {/* Gráfica de actividad del club en los últimos 6 meses */}
  </GraficaActividad>
</DashboardAdmin>
```

---

## DECISIONES FINALES CONFIRMADAS

### ✅ Resuelto:
1. **Búsqueda de libros:** Reutilizar lógica existente (Google Books + OpenLibrary)
2. **Número de capítulos:** Siempre input manual del usuario
3. **Visibilidad pública:** Solo en versión 2 (por ahora solo invitación)
4. **Límite de propuestas:** 1 propuesta activa por usuario y club
5. **Retirar propuestas:** No permitido
6. **Libros siguientes visibles:** Configurable 1-3, solo por dueño
7. **Audiolibros:** No diferenciación, usar capítulos igual que libros físicos

### ⏳ Pendiente para versiones futuras:
- **v2:** Búsqueda pública de clubes
- **v2:** Posible monetización (clubes premium, límites por usuario)
- **v3:** Potencial integración con plataformas de audiolibros (tiempo en vez de capítulos)

---

## CONCLUSIÓN

Este prompt cubre:
- ✅ Modelos de datos completos
- ✅ Lógica de negocio detallada
- ✅ Interfaz de usuario especificada
- ✅ Casos edge contemplados
- ✅ Optimizaciones de rendimiento
- ✅ Plan de testing
- ✅ Seguridad y permisos
- ✅ Migración y despliegue

**Listo para implementación** con cualquier stack (React/Vue + Node/Django/Rails).
