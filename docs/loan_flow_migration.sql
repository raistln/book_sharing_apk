-- =====================================================================
-- LOAN FLOW IMPROVEMENTS - SQL MIGRATIONS FOR SUPABASE
-- =====================================================================
-- Este script añade soporte para:
-- 1. Préstamos manuales (personas sin la app)
-- 2. Estado 'expired' y limpieza automática
-- 3. Recordatorios 7 días antes del vencimiento
-- 4. Estado 'loaned' en el flujo de préstamos
--
-- INSTRUCCIONES:
-- Copia y pega este script completo en el SQL Editor de Supabase
-- =====================================================================

-- =====================================================================
-- 1) AÑADIR CAMPOS PARA PRÉSTAMOS MANUALES
-- =====================================================================

-- Hacer from_user nullable para permitir préstamos manuales
ALTER TABLE loans 
  ALTER COLUMN from_user DROP NOT NULL;

-- Añadir campos para información del prestatario externo
ALTER TABLE loans 
  ADD COLUMN IF NOT EXISTS external_borrower_name text,
  ADD COLUMN IF NOT EXISTS external_borrower_contact text;

-- Añadir comentarios para documentación
COMMENT ON COLUMN loans.external_borrower_name IS 'Nombre del prestatario para préstamos manuales (personas sin la app)';
COMMENT ON COLUMN loans.external_borrower_contact IS 'Información de contacto del prestatario externo (teléfono, email, etc.)';

-- =====================================================================
-- 2) ACTUALIZAR CHECK CONSTRAINT PARA INCLUIR 'loaned'
-- =====================================================================

-- Eliminar constraint antiguo si existe
ALTER TABLE loans DROP CONSTRAINT IF EXISTS loans_status_check;

-- Añadir nuevo constraint con todos los estados
ALTER TABLE loans 
  ADD CONSTRAINT loans_status_check 
  CHECK (status IN ('pending', 'accepted', 'rejected', 'returned', 'expired', 'cancelled', 'loaned'));

-- =====================================================================
-- 3) FUNCIÓN PARA LIMPIAR PRÉSTAMOS ANTIGUOS
-- =====================================================================

CREATE OR REPLACE FUNCTION cleanup_stale_loans()
RETURNS TABLE(loan_id uuid, borrower_id uuid, owner_id uuid, book_id uuid) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  cutoff_date timestamptz;
BEGIN
  cutoff_date := NOW() - INTERVAL '1 month';
  
  -- Actualizar préstamos antiguos a 'expired' y devolver información
  RETURN QUERY
  WITH updated_loans AS (
    UPDATE loans
    SET status = 'expired',
        updated_at = NOW()
    WHERE status IN ('pending', 'accepted')
      AND created_at < cutoff_date
    RETURNING id, from_user, to_user, shared_book_id
  ),
  updated_books AS (
    UPDATE shared_books
    SET is_available = true,
        updated_at = NOW()
    WHERE id IN (SELECT shared_book_id FROM updated_loans)
    RETURNING id
  )
  SELECT 
    ul.id as loan_id,
    ul.from_user as borrower_id,
    ul.to_user as owner_id,
    ul.shared_book_id as book_id
  FROM updated_loans ul;
END;
$$;

COMMENT ON FUNCTION cleanup_stale_loans() IS 'Marca préstamos en pending/accepted mayores a 1 mes como expired y libera los libros';

-- =====================================================================
-- 4) FUNCIÓN PARA ENVIAR RECORDATORIOS DE VENCIMIENTO
-- =====================================================================

CREATE OR REPLACE FUNCTION send_loan_reminders()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  reminder_date date;
  reminder_count integer := 0;
BEGIN
  reminder_date := CURRENT_DATE + INTERVAL '7 days';
  
  -- Insertar notificaciones para prestatarios (si tienen cuenta)
  INSERT INTO in_app_notifications (
    id, type, target_user_id, actor_user_id, loan_id, shared_book_id, 
    title, message, status, created_at, updated_at
  )
  SELECT 
    uuid_generate_v4(),
    'loan_due_soon',
    l.from_user,
    l.to_user,
    l.id,
    l.shared_book_id,
    'Préstamo próximo a vencer',
    'Tu préstamo vence en 7 días.',
    'unread',
    NOW(),
    NOW()
  FROM loans l
  WHERE l.status = 'loaned'
    AND DATE(l.due_date) = reminder_date
    AND l.from_user IS NOT NULL  -- Solo si tiene cuenta
    AND NOT EXISTS (
      -- Evitar duplicados
      SELECT 1 FROM in_app_notifications n
      WHERE n.loan_id = l.id
        AND n.type = 'loan_due_soon'
        AND n.target_user_id = l.from_user
        AND DATE(n.created_at) = CURRENT_DATE
    );
  
  GET DIAGNOSTICS reminder_count = ROW_COUNT;
  
  -- Insertar notificaciones para propietarios
  INSERT INTO in_app_notifications (
    id, type, target_user_id, actor_user_id, loan_id, shared_book_id, 
    title, message, status, created_at, updated_at
  )
  SELECT 
    uuid_generate_v4(),
    'loan_due_soon',
    l.to_user,
    l.from_user,
    l.id,
    l.shared_book_id,
    'Préstamo próximo a vencer',
    CASE 
      WHEN l.from_user IS NOT NULL THEN 'Un préstamo vence en 7 días.'
      ELSE 'El préstamo a ' || COALESCE(l.external_borrower_name, 'alguien') || ' vence en 7 días.'
    END,
    'unread',
    NOW(),
    NOW()
  FROM loans l
  WHERE l.status = 'loaned'
    AND DATE(l.due_date) = reminder_date
    AND NOT EXISTS (
      SELECT 1 FROM in_app_notifications n
      WHERE n.loan_id = l.id
        AND n.type = 'loan_due_soon'
        AND n.target_user_id = l.to_user
        AND DATE(n.created_at) = CURRENT_DATE
    );
  
  GET DIAGNOSTICS reminder_count = reminder_count + ROW_COUNT;
  
  RAISE NOTICE 'Enviados % recordatorios para préstamos que vencen el %', reminder_count, reminder_date;
END;
$$;

COMMENT ON FUNCTION send_loan_reminders() IS 'Envía recordatorios 7 días antes del vencimiento de préstamos activos';

-- =====================================================================
-- 5) PROGRAMAR CRON JOBS
-- =====================================================================

-- Asegurar que pg_cron está habilitado
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Eliminar jobs existentes si existen (para evitar duplicados)
SELECT cron.unschedule('cleanup-stale-loans') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'cleanup-stale-loans'
);

SELECT cron.unschedule('send-loan-reminders') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'send-loan-reminders'
);

-- Programar limpieza de préstamos antiguos (diario a las 2 AM)
SELECT cron.schedule(
  'cleanup-stale-loans',
  '0 2 * * *',  -- Cron expression: minuto hora día mes día_semana
  $$
  DO $$
  DECLARE
    expired_loan RECORD;
  BEGIN
    -- Limpiar préstamos antiguos y crear notificaciones
    FOR expired_loan IN 
      SELECT * FROM cleanup_stale_loans()
    LOOP
      -- Notificar al prestatario (si tiene cuenta)
      IF expired_loan.borrower_id IS NOT NULL THEN
        INSERT INTO in_app_notifications (
          id, type, target_user_id, loan_id, title, message, status, created_at, updated_at
        ) VALUES (
          uuid_generate_v4(),
          'loan_expired',
          expired_loan.borrower_id,
          expired_loan.loan_id,
          'Préstamo expirado',
          'Tu préstamo ha expirado por inactividad.',
          'unread',
          NOW(),
          NOW()
        );
      END IF;
      
      -- Notificar al propietario
      INSERT INTO in_app_notifications (
        id, type, target_user_id, loan_id, title, message, status, created_at, updated_at
      ) VALUES (
        uuid_generate_v4(),
        'loan_expired',
        expired_loan.owner_id,
        expired_loan.loan_id,
        'Préstamo expirado',
        'Un préstamo pendiente ha expirado por inactividad.',
        'unread',
        NOW(),
        NOW()
      );
    END LOOP;
  END $$;
  $$
);

-- Programar envío de recordatorios (diario a las 9 AM)
SELECT cron.schedule(
  'send-loan-reminders',
  '0 9 * * *',
  'SELECT send_loan_reminders();'
);

-- =====================================================================
-- 6) ACTUALIZAR POLÍTICAS RLS PARA PRÉSTAMOS MANUALES
-- =====================================================================

-- Eliminar políticas antiguas
DROP POLICY IF EXISTS loans_select_participants ON loans;
DROP POLICY IF EXISTS loans_manage_participants ON loans;

-- Nueva política de SELECT: permite ver préstamos donde eres participante O propietario
CREATE POLICY loans_select_participants
  ON loans FOR SELECT
  USING (
    -- Eres el prestatario (si tiene cuenta)
    (from_user IS NOT NULL AND EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = from_user AND u.auth_user_id = auth.uid()
    ))
    OR
    -- Eres el propietario
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = to_user AND u.auth_user_id = auth.uid()
    )
  );

-- Nueva política de gestión: permite gestionar préstamos donde eres participante O propietario
CREATE POLICY loans_manage_participants
  ON loans FOR ALL
  USING (
    -- Eres el prestatario (si tiene cuenta)
    (from_user IS NOT NULL AND EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = from_user AND u.auth_user_id = auth.uid()
    ))
    OR
    -- Eres el propietario
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = to_user AND u.auth_user_id = auth.uid()
    )
  )
  WITH CHECK (
    -- Eres el prestatario (si tiene cuenta)
    (from_user IS NOT NULL AND EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = from_user AND u.auth_user_id = auth.uid()
    ))
    OR
    -- Eres el propietario
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = to_user AND u.auth_user_id = auth.uid()
    )
  );

-- =====================================================================
-- 7) VERIFICACIÓN Y RESUMEN
-- =====================================================================

-- Verificar que los cron jobs están programados
SELECT 
  jobname,
  schedule,
  command,
  active
FROM cron.job
WHERE jobname IN ('cleanup-stale-loans', 'send-loan-reminders', 'purge-in-app-notifications')
ORDER BY jobname;

-- Mostrar resumen de cambios
DO $$
BEGIN
  RAISE NOTICE '✅ Migración completada exitosamente!';
  RAISE NOTICE '';
  RAISE NOTICE 'Cambios aplicados:';
  RAISE NOTICE '1. ✓ Campo from_user ahora es nullable';
  RAISE NOTICE '2. ✓ Añadidos campos external_borrower_name y external_borrower_contact';
  RAISE NOTICE '3. ✓ Actualizado constraint de status para incluir "loaned"';
  RAISE NOTICE '4. ✓ Creada función cleanup_stale_loans()';
  RAISE NOTICE '5. ✓ Creada función send_loan_reminders()';
  RAISE NOTICE '6. ✓ Programado cron job para limpieza (diario 2 AM)';
  RAISE NOTICE '7. ✓ Programado cron job para recordatorios (diario 9 AM)';
  RAISE NOTICE '8. ✓ Actualizadas políticas RLS para préstamos manuales';
  RAISE NOTICE '';
  RAISE NOTICE 'Próximos pasos:';
  RAISE NOTICE '- Ejecutar "dart run build_runner build" en Flutter para regenerar código Drift';
  RAISE NOTICE '- Probar creación de préstamos manuales';
  RAISE NOTICE '- Verificar que los cron jobs se ejecutan correctamente';
END $$;
