-- Script para limpiar duplicados en la tabla shared_books de Supabase
-- 
-- PROBLEMA: Los mismos libros (book_uuid) aparecen múltiples veces con diferentes group_id
-- SOLUCIÓN: Mantener solo el registro más reciente para cada combinación (book_uuid, group_id)

-- Paso 1: Identificar los duplicados
WITH duplicates AS (
  SELECT 
    book_uuid,
    group_id,
    COUNT(*) as duplicate_count,
    MIN(id) as keep_id,
    MAX(updated_at) as latest_update,
    ARRAY_AGG(id ORDER BY updated_at DESC) as all_ids
  FROM shared_books
  WHERE is_deleted = false
  GROUP BY book_uuid, group_id
  HAVING COUNT(*) > 1
),

-- Paso 2: Obtener los IDs a eliminar
records_to_delete AS (
  SELECT 
    unnest(all_ids) as id_to_delete
  FROM duplicates
  WHERE unnest(all_ids) != keep_id
)

-- Paso 3: Eliminar los duplicados (manteniendo el más reciente)
DELETE FROM shared_books
WHERE id IN (SELECT id_to_delete FROM records_to_delete);

-- Paso 4: Verificar el resultado
SELECT 
  book_uuid,
  group_id,
  COUNT(*) as final_count
FROM shared_books
WHERE is_deleted = false
GROUP BY book_uuid, group_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Paso 5: Mostrar estadísticas de limpieza
SELECT 
  'Limpieza completada' as status,
  (SELECT COUNT(*) FROM records_to_delete) as duplicates_removed,
  (SELECT COUNT(*) FROM shared_books WHERE is_deleted = false) as remaining_records;
