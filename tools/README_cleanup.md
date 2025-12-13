# Herramientas de Limpieza de Supabase

## Problemas Resueltos

### 1. Duplicados en shared_books
**Problema**: Los mismos libros aparecían múltiples veces con el mismo `book_uuid` pero diferentes `group_id`.

**Síntomas**:
- Libros duplicados en la interfaz
- Sincronización incorrecta entre grupos
- Confusión en el estado de disponibilidad

**Soluciones Implementadas**:

#### A. Prevención de Duplicados (Código)
- **book_repository.dart**: Verificación antes de insertar libros compartidos
- **supabase_group_repository.dart**: Detección de duplicados durante sincronización
- Nueva función `shareBookWithAllUserGroups()` para compartir automáticamente

#### B. Limpieza de Datos Existentes
Ejecutar el script SQL `cleanup_supabase_duplicates.sql` en la consola de Supabase:

```sql
-- El script elimina duplicados manteniendo el registro más reciente
-- para cada combinación (book_uuid, group_id)
```

## Pasos para la Limpieza

### 1. Backup de Datos
```sql
CREATE TABLE shared_books_backup AS 
SELECT * FROM shared_books;
```

### 2. Ejecutar Script de Limpieza
```sql
-- Copiar y pegar el contenido de cleanup_supabase_duplicates.sql
-- en la consola SQL de Supabase
```

### 3. Verificar Resultados
```sql
-- Verificar que no queden duplicados
SELECT book_uuid, group_id, COUNT(*) 
FROM shared_books 
WHERE is_deleted = false 
GROUP BY book_uuid, group_id 
HAVING COUNT(*) > 1;
```

## Comportamiento Esperado Después de la Limpieza

1. **Sin duplicados**: Cada libro aparece una vez por grupo
2. **Visibilidad correcta**: Los libros disponibles se muestran en todos los grupos del usuario
3. **Sincronización automática**: Los libros nuevos se comparten automáticamente con todos los grupos
4. **Filtro de privacidad**: Los libros privados/archivados se ocultan correctamente

## Monitoreo

Después de la limpieza, monitorear:
- Logs del aplicación para errores de sincronización
- Consistencia de datos entre grupos
- Performance de consultas

## Notas Importantes

- El script mantiene el registro más reciente (basado en `updated_at`)
- Los registros marcados como `is_deleted = true` son ignorados
- Es recomendable ejecutar durante un período de bajo uso
- Hacer backup siempre antes de operaciones de limpieza masiva
