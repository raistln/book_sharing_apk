# 📋 Plan de Mejora del Flujo de Préstamos
## Versión Final

---

## ✅ Decisiones Confirmadas

| Decisión | Respuesta |
|----------|-----------|
| **Estructura de tabs** | 📚 Biblioteca / 🔄 Préstamos / 👥 Grupos / ⚙️ Ajustes (4 tabs) |
| **Auto-confirmación** | Solo propietario, después de 7 días |
| **Recordatorio amable** | ✅ Implementar |
| **Historial** | Solo devueltos/expirados. Rechazados/cancelados se borran a los 30 días |
| **Préstamos manuales** | Integrar en tab Préstamos, eliminar grupo "Préstamos Personales" |
| **Stats actuales** | Guardar código para futuro perfil de usuario |

---

## 🎯 Cambio Arquitectural Principal

### ⚠️ SIMPLIFICACIÓN MAYOR

Los préstamos manuales ya no requieren un grupo especial. Se gestionan directamente desde la tab de Préstamos sin necesidad de `SharedBook`.

### 🔄 Comparación de Arquitectura

#### **Antes (Arquitectura Actual)**
```
Préstamo Manual → Requiere SharedBook → Requiere Grupo "Préstamos Personales"
                                      ↓
                        Se crea automáticamente en onboarding
```

#### **Después (Nueva Arquitectura)**
```
Préstamo Manual → Se crea directamente en tabla Loans
               → Referencia directa al Book (no SharedBook)
               → Se muestra en tab Préstamos
```

### 🎁 Beneficios

- ✨ Elimina complejidad de crear/mantener grupo automático
- 🧩 Simplifica el modelo de datos
- 👤 Mejor UX: usuario no ve grupo "fantasma" que no entiende
- 🔧 Reduce código y puntos de fallo

---

## 🗂️ Nueva Estructura de Navegación

```
┌──────────────────────────────────────────────────────────┐
│ 📚 Biblioteca │ 🔄 Préstamos │ 👥 Grupos │ ⚙️ Ajustes    │
└──────────────────────────────────────────────────────────┘
```

### 📱 Estructura de la Tab de Préstamos

```
📋 MIS PRÉSTAMOS
├── 📊 Resumen rápido
│   ├── Activos: X (digitales + manuales)
│   ├── Pendientes de aprobar: X  
│   └── Esperando confirmación: X
│
├── ➕ BOTÓN "Nuevo préstamo manual"
│
├── 🔔 SOLICITUDES ENTRANTES (préstamos digitales)
│   └── Cards: libro + solicitante + [Aceptar] [Rechazar]
│
├── ⏳ MIS PETICIONES (préstamos digitales que yo solicité)
│   └── Cards con opción de cancelar si pendiente
│
├── 📦 PRÉSTAMOS ACTIVOS (digitales + manuales)
│   ├── Sección: "Libros que presté" (soy lender)
│   │   └── Estado de confirmación + [Marcar devuelto]
│   └── Sección: "Libros que tengo prestados" (soy borrower)
│       └── Estado de confirmación + [Marcar devuelto]
│
└── 📜 HISTORIAL (solo devueltos/expirados)
    └── Filtrable por fecha/libro
```

---

## 📁 Archivos a Crear

### 🆕 `loans_tab.dart`
Tab principal de préstamos con todas las secciones.

### 🆕 `loans_providers.dart`
```dart
/// Providers específicos para la tab de préstamos

// Solicitudes entrantes (libros de otros que me piden)
final incomingLoanRequestsProvider = StreamProvider.autoDispose<List<LoanDetail>>

// Mis peticiones salientes
final outgoingLoanRequestsProvider = StreamProvider.autoDispose<List<LoanDetail>>

// Préstamos activos donde soy prestador (incluye manuales)
final activeLoansAsLenderProvider = StreamProvider.autoDispose<List<LoanDetail>>

// Préstamos activos donde soy prestatario
final activeLoansAsBorrowerProvider = StreamProvider.autoDispose<List<LoanDetail>>

// Historial (solo devueltos/expirados)
final loanHistoryProvider = StreamProvider.autoDispose<List<LoanDetail>>
```

### 🆕 `loan_confirmation_card.dart`
Widget para mostrar estado de doble confirmación con UI clara.

### 🆕 `manual_loan_sheet.dart`
Bottom sheet para crear préstamo manual (reemplaza dialog actual).

- 📚 Selector de libro de mi biblioteca
- 👤 Nombre del prestatario externo
- 📞 Contacto (opcional)
- 📅 Fecha de devolución o sin límite

---

## 🔧 Archivos a Modificar

### 🔄 `home_shell.dart`

```dart
// Cambiar de 5 a 4 tabs:
children: [
  LibraryTab(onOpenForm: ...),
  LoansTab(),                    // NUEVO (reemplaza StatsTab)
  GroupsTab(),                   // Renombrado de CommunityTab
  SettingsTab(),
],

destinations: [
  NavigationDestination(
    icon: Icon(Icons.menu_book_outlined),
    label: 'Biblioteca',
  ),
  NavigationDestination(
    icon: Icon(Icons.swap_horiz_outlined),  // NUEVO icono
    selectedIcon: Icon(Icons.swap_horiz),
    label: 'Préstamos',                     // NUEVO
  ),
  NavigationDestination(
    icon: Icon(Icons.groups_outlined),
    label: 'Grupos',                        // Renombrado
  ),
  NavigationDestination(
    icon: Icon(Icons.settings_outlined),
    label: 'Ajustes',
  ),
],

// Actualizar _handleNotificationIntent para nuevos índices
```

### 🔄 `community_tab.dart` → `groups_tab.dart`

Renombrar archivo y:

- 🔗 Integrar funcionalidad de "Descubrir libros" dentro de cada grupo
- ❌ Eliminar sección de préstamos (mover a LoansTab)
- ✅ Mantener gestión de grupos + estadísticas grupales

### 🔄 `loan_repository.dart`

**Nuevos métodos:**

```dart
/// Crear préstamo manual SIN necesidad de SharedBook
Future<Loan> createManualLoanDirect({
  required Book book,
  required LocalUser owner,
  required String borrowerName,
  DateTime? dueDate,
  String? borrowerContact,
})

/// Auto-confirmación por propietario después de 7 días
Future<Loan> ownerForceConfirmReturn({
  required Loan loan,
  required LocalUser owner,
}) {
  // Validar que pasaron >= 7 días desde lenderReturnedAt
  // Marcar ambos campos y completar devolución
}

/// Limpieza de préstamos rechazados/cancelados > 30 días
Future<int> cleanupOldRejectedLoans()
```

### 🔄 `loan_controller.dart`

**Nuevos métodos:**

```dart
/// Enviar recordatorio amable
Future<void> sendReturnReminder({
  required Loan loan,
  required LocalUser actor,
})

/// Auto-confirmación por propietario
Future<Loan> ownerForceConfirmReturn({
  required Loan loan,
  required LocalUser owner,
})

/// Mejorar markReturned para indicar estado de confirmación
// Mensaje: "Tu confirmación registrada. Esperando a [nombre]."
// o: "¡Devolución completada!"
```

### 🔄 `database.dart`

Modificar tabla Loans:

```dart
class Loans extends Table {
  // ... campos existentes ...
  
  // NUEVO: Referencia directa a Book para préstamos manuales
  // (alternativa a sharedBookId cuando no hay grupo)
  IntColumn get bookId => integer().nullable().references(Books, #id)();
}
```

> ⚠️ **ADVERTENCIA**: Esto requiere migración de base de datos. Crear migration v6.

### 🗑️ Código de grupo personal a eliminar/archivar

#### 🔄 `book_repository.dart`

Eliminar o deprecar:

- `getOrCreatePersonalGroup()`
- `ensureBookIsShared()` (para manuales)
- `shareBookToPersonalGroup()`

Añadir comentario TODO:

```dart
// TODO: Estos métodos quedan para compatibilidad con préstamos existentes
// En futuras versiones, migrar datos y eliminar completamente
```

#### 🔄 `onboarding_wizard_screen.dart`

Eliminar la creación de grupo personal en:

- `_completeWizard()`
- `_skipWizard()`

#### 🔄 `manual_loan_dialog.dart`

Reemplazar por `manual_loan_sheet.dart` o modificar para usar `createManualLoanDirect()` sin SharedBook.

#### 📦 `group_utils.dart`

Marcar como deprecated:

```dart
@Deprecated('Personal loans group is no longer used. Use direct loans instead.')
const String kPersonalLoansGroupName = 'Préstamos Personales';
```

#### 🔄 `group_dao.dart`

Eliminar ordenamiento especial para "Préstamos Personales".

#### 🔄 `group_card.dart`

Eliminar lógica especial para ocultar menú/propietario en grupo personal.

### 🔄 `in_app_notification_type.dart`

Añadir:

```dart
returnReminderSent('return_reminder'),      // Recordatorio enviado
returnPendingConfirmation('return_pending'), // Pendiente tu confirmación
```

### 🔄 `loans_section.dart`

**Corregir bug:**

```dart
// Línea 252: Cambiar 'pending' por 'requested'
if (isBorrower && status == 'requested') {  // Era 'pending'
```

---

## 🧹 Limpieza Automática de Préstamos

### Implementar en background

```dart
/// Llamar periódicamente (ej: al iniciar app o cada sync)
Future<void> performLoanCleanup() async {
  final cutoffDate = DateTime.now().subtract(Duration(days: 30));
  
  // Marcar como deleted (soft delete) préstamos rechazados/cancelados
  // con updatedAt < cutoffDate
  await db.loans.update()
    .where((l) => l.status.isIn(['rejected', 'cancelled']))
    .where((l) => l.updatedAt.isSmallerThan(cutoffDate))
    .write(LoansCompanion(isDeleted: Value(true)));
}
```

---

## 🚀 Orden de Implementación

### 📦 Fase 1: Infraestructura (sin breaking changes)

- [ ] Añadir campo `bookId` nullable a tabla Loans (migration v6)
- [ ] Crear `loans_providers.dart`
- [ ] Crear `loan_confirmation_card.dart`
- [ ] Añadir métodos nuevos a `loan_repository.dart` y `loan_controller.dart`
- [ ] Corregir bug 'pending' → 'requested'

### 🎨 Fase 2: Nueva Tab

- [ ] Crear `loans_tab.dart` con secciones
- [ ] Crear `manual_loan_sheet.dart`
- [ ] Modificar `home_shell.dart` (4 tabs, nuevos índices)
- [ ] Renombrar `community_tab.dart` → `groups_tab.dart`

### 🔄 Fase 3: Migración de préstamos manuales

- [ ] Modificar `createManualLoan` para no requerir SharedBook
- [ ] Eliminar código de grupo personal en onboarding
- [ ] Deprecar funciones en `group_utils.dart`

### ✨ Fase 4: Limpieza

- [ ] Implementar cleanup de préstamos viejos
- [ ] Añadir TODOs para migrar stats a perfil
- [ ] Eliminar `discovery_tab.dart` (integrar en grupos)
- [ ] Tests y verificación

---

## ✅ Plan de Verificación

### 🤖 Tests Automatizados

- Analizar archivos con MCP
- Ejecutar suite de tests

### 👁️ Verificación Manual

1. **Navegación**: 4 tabs funcionan correctamente
2. **Préstamo manual nuevo**:
   - Crear desde tab Préstamos
   - Verificar que NO crea grupo personal
   - Aparece en lista de activos
3. **Solicitudes entrantes**: Ver y aceptar/rechazar
4. **Doble confirmación**:
   - Marcar devuelto → Ver "Esperando a X"
   - Otra parte marca → Ver "Completado"
5. **Auto-confirmación 7 días**: Propietario puede forzar después de 7 días
6. **Recordatorio**: Enviar y verificar notificación
7. **Limpieza**: Crear préstamo rechazado, cambiar fecha, verificar cleanup

---

## 📝 Notas de Migración

> ⚠️ **PRECAUCIÓN**: Préstamos manuales existentes
> 
> Los que ya existen con SharedBook seguirán funcionando. El nuevo código debe soportar ambos casos:
> 
> - `sharedBookId != null` → préstamo tradicional
> - `bookId != null && sharedBookId == null` → préstamo manual directo
> 
> La migración completa de datos existentes se puede hacer en una fase posterior.

---

## 📊 Resumen de Tareas

### ✅ Análisis
- [x] Revisar código existente de préstamos
- [x] Identificar arquitectura de grupo personal
- [x] Confirmar doble confirmación en backend

### ✅ Planificación
- [x] Crear plan inicial
- [x] Recibir feedback y actualizar
- [ ] Aprobación final del usuario

### 🔨 Implementación
- [ ] **Fase 1**: Infraestructura (5 tareas)
- [ ] **Fase 2**: Nueva Tab (4 tareas)
- [ ] **Fase 3**: Eliminar Grupo Personal (4 tareas)
- [ ] **Fase 4**: Limpieza Final (4 tareas)

---

## 🎯 Objetivo Final

Reestructurar navegación, crear tab de préstamos dedicada, integrar préstamos manuales sin grupos, y eliminar el grupo personal automático para simplificar la arquitectura y mejorar la experiencia de usuario.