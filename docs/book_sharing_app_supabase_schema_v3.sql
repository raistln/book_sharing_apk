-- 📚 Book Sharing App – Supabase Schema (v3)
-- Este script crea un esquema completo con todas las mejoras del flujo de préstamos
-- Incluye: préstamos manuales, limpieza automática, recordatorios, y más.
-- Listo para usar en proyectos nuevos desde cero.

-- =====================================================================
-- 0) RESET OPCIONAL (EJECUTAR SOLO SI QUIERES BORRAR TODO)
-- =====================================================================
/*
-- BEGIN RESET ----------------------------------------------------------
DROP TABLE IF EXISTS in_app_notifications CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS loans CASCADE;
DROP TABLE IF EXISTS shared_books CASCADE;
DROP TABLE IF EXISTS group_invitations CASCADE;
DROP TABLE IF EXISTS group_members CASCADE;
DROP TABLE IF EXISTS groups CASCADE;
DROP TABLE IF EXISTS book_reviews CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS local_users CASCADE;

-- Eliminar cron jobs si existen
SELECT cron.unschedule('cleanup-stale-loans') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'cleanup-stale-loans'
);
SELECT cron.unschedule('send-loan-reminders') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'send-loan-reminders'
);
SELECT cron.unschedule('purge-in-app-notifications') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'purge-in-app-notifications'
);
-- END RESET ------------------------------------------------------------
*/

-- =====================================================================
-- 1) EXTENSIONES NECESARIAS
-- =====================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- =====================================================================
-- 2) TABLAS PRINCIPALES
-- =====================================================================

-- Usuarios locales (uno por auth.users)
CREATE TABLE IF NOT EXISTS local_users (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_user_id uuid UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  username text NOT NULL,
  display_name text,
  avatar_url text,
  google_books_api_key text,
  pin_hash text,
  pin_salt text,
  pin_updated_at timestamptz,
  is_deleted boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Biblioteca personal
CREATE TABLE IF NOT EXISTS books (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id uuid NOT NULL REFERENCES local_users(id) ON DELETE CASCADE,
  title text NOT NULL,
  author text,
  isbn text,
  barcode text,
  cover_url text,
  status text NOT NULL DEFAULT 'available' CHECK (
    status IN ('available', 'loaned', 'reserved', 'archived')
  ),
  notes text,
  is_deleted boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Reseñas (una por usuario/libro)
CREATE TABLE IF NOT EXISTS book_reviews (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  book_id uuid NOT NULL REFERENCES books(id) ON DELETE CASCADE,
  author_id uuid NOT NULL REFERENCES local_users(id) ON DELETE CASCADE,
  rating integer NOT NULL CHECK (rating BETWEEN 1 AND 5),
  review text,
  is_deleted boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT book_reviews_unique_per_user UNIQUE (book_id, author_id, is_deleted)
);

-- Grupos de lectura
CREATE TABLE IF NOT EXISTS groups (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  description text,
  owner_id uuid REFERENCES local_users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Miembros del grupo
CREATE TABLE IF NOT EXISTS group_members (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id uuid NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES local_users(id) ON DELETE CASCADE,
  role text NOT NULL DEFAULT 'member',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT group_members_unique UNIQUE (group_id, user_id)
);

-- Invitaciones a grupos
CREATE TABLE IF NOT EXISTS group_invitations (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id uuid NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  inviter_id uuid NOT NULL REFERENCES local_users(id) ON DELETE CASCADE,
  accepted_user_id uuid REFERENCES local_users(id) ON DELETE SET NULL,
  role text NOT NULL DEFAULT 'member' CHECK (role IN ('member', 'admin')),
  code uuid NOT NULL DEFAULT uuid_generate_v4() UNIQUE,
  status text NOT NULL DEFAULT 'pending' CHECK (
    status IN ('pending', 'accepted', 'rejected', 'cancelled', 'expired')
  ),
  expires_at timestamptz NOT NULL,
  responded_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Libros compartidos dentro del grupo
CREATE TABLE IF NOT EXISTS shared_books (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id uuid NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  owner_id uuid NOT NULL REFERENCES local_users(id) ON DELETE CASCADE,
  book_uuid text NOT NULL,
  visibility text NOT NULL DEFAULT 'group' CHECK (
    visibility IN ('group', 'private', 'public')
  ),
  is_available boolean NOT NULL DEFAULT true,
  is_deleted boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT shared_books_unique_book UNIQUE (group_id, book_uuid)
);

-- Préstamos (con soporte para préstamos manuales)
CREATE TABLE IF NOT EXISTS loans (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  shared_book_id uuid NOT NULL REFERENCES shared_books(id) ON DELETE CASCADE,
  
  -- from_user es nullable para préstamos manuales (personas sin la app)
  from_user uuid REFERENCES local_users(id) ON DELETE CASCADE,
  to_user uuid NOT NULL REFERENCES local_users(id) ON DELETE CASCADE,
  
  -- Información del prestatario externo (para préstamos manuales)
  external_borrower_name text,
  external_borrower_contact text,
  
  -- Estados: pending, accepted, loaned, rejected, returned, expired, cancelled
  status text NOT NULL DEFAULT 'pending' CHECK (
    status IN ('pending', 'accepted', 'loaned', 'rejected', 'returned', 'expired', 'cancelled')
  ),
  
  start_date timestamptz NOT NULL DEFAULT now(),
  due_date timestamptz,
  returned_at timestamptz,
  cancelled_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Notificaciones de eventos relevantes (legacy, mantener por compatibilidad)
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES local_users(id) ON DELETE CASCADE,
  type text NOT NULL,
  message text,
  related_loan uuid REFERENCES loans(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  read boolean NOT NULL DEFAULT false
);

-- Notificaciones in-app (sistema principal)
CREATE TABLE IF NOT EXISTS in_app_notifications (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  type text NOT NULL CHECK (char_length(type) <= 64),

  -- Relación con préstamos y libros compartidos
  loan_id uuid REFERENCES loans(id) ON DELETE SET NULL,
  shared_book_id uuid REFERENCES shared_books(id) ON DELETE SET NULL,

  -- Actor/target
  actor_user_id uuid REFERENCES local_users(id) ON DELETE SET NULL,
  target_user_id uuid NOT NULL REFERENCES local_users(id) ON DELETE CASCADE,

  title text,
  message text,

  status text NOT NULL DEFAULT 'unread' CHECK (char_length(status) <= 32),

  is_deleted boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- =====================================================================
-- 3) ÍNDICES
-- =====================================================================

CREATE UNIQUE INDEX IF NOT EXISTS local_users_username_unique
  ON local_users (lower(username));

CREATE INDEX IF NOT EXISTS in_app_notifications_target_idx
  ON in_app_notifications (target_user_id, is_deleted, status);

CREATE INDEX IF NOT EXISTS in_app_notifications_loan_idx
  ON in_app_notifications (loan_id);

CREATE INDEX IF NOT EXISTS in_app_notifications_shared_book_idx
  ON in_app_notifications (shared_book_id);

-- =====================================================================
-- 4) FUNCIONES Y TRIGGERS
-- =====================================================================

-- Función para notificar cambios de estado en préstamos
CREATE OR REPLACE FUNCTION public.notify_loan_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    -- Solo notificar si no es un préstamo manual
    IF NEW.from_user IS NOT NULL THEN
      INSERT INTO notifications (user_id, type, message, related_loan)
      VALUES (NEW.to_user, 'loan_requested', 'Te han solicitado un préstamo.', NEW.id);
    END IF;
  ELSIF (TG_OP = 'UPDATE') THEN
    IF (NEW.status <> OLD.status) THEN
      IF (NEW.status = 'accepted') THEN
        IF NEW.from_user IS NOT NULL THEN
          INSERT INTO notifications (user_id, type, message, related_loan)
          VALUES (NEW.from_user, 'loan_accepted', 'Tu préstamo ha sido aceptado.', NEW.id);
        END IF;
      ELSIF (NEW.status = 'rejected') THEN
        IF NEW.from_user IS NOT NULL THEN
          INSERT INTO notifications (user_id, type, message, related_loan)
          VALUES (NEW.from_user, 'loan_rejected', 'Tu préstamo ha sido rechazado.', NEW.id);
        END IF;
      ELSIF (NEW.status = 'returned') THEN
        INSERT INTO notifications (user_id, type, message, related_loan)
        VALUES (NEW.to_user, 'loan_returned', 'Se ha marcado el préstamo como devuelto.', NEW.id);
      ELSIF (NEW.status = 'expired') THEN
        IF NEW.from_user IS NOT NULL THEN
          INSERT INTO notifications (user_id, type, message, related_loan)
          VALUES (NEW.from_user, 'loan_expired', 'Un préstamo ha expirado.', NEW.id);
        END IF;
      ELSIF (NEW.status = 'cancelled') THEN
        INSERT INTO notifications (user_id, type, message, related_loan)
        VALUES (NEW.to_user, 'loan_cancelled', 'La solicitud de préstamo fue cancelada.', NEW.id);
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_loan_change ON loans;
CREATE TRIGGER on_loan_change
AFTER INSERT OR UPDATE ON loans
FOR EACH ROW
EXECUTE FUNCTION public.notify_loan_status_change();

-- Función para limpiar préstamos antiguos (>1 mes en pending/accepted)
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

-- Función para enviar recordatorios 7 días antes del vencimiento
CREATE OR REPLACE FUNCTION send_loan_reminders()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  reminder_date date;
  reminder_count integer := 0;
  owner_count integer := 0;
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
    AND l.from_user IS NOT NULL
    AND NOT EXISTS (
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
  
  GET DIAGNOSTICS owner_count = ROW_COUNT;
  
  RAISE NOTICE 'Enviados % recordatorios para préstamos que vencen el %', (reminder_count + owner_count), reminder_date;
END;
$$;

COMMENT ON FUNCTION send_loan_reminders() IS 'Envía recordatorios 7 días antes del vencimiento de préstamos activos';

-- Función para limpiar notificaciones antiguas
CREATE OR REPLACE FUNCTION public.purge_in_app_notifications()
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  DELETE FROM public.in_app_notifications
  WHERE (
      status IN ('read', 'dismissed')
      AND updated_at < now() - interval '15 days'
    )
    OR (
      status NOT IN ('read', 'dismissed')
      AND updated_at < now() - interval '30 days'
    );
$$;

COMMENT ON FUNCTION public.purge_in_app_notifications() IS 'Elimina notificaciones leídas >15 días y no leídas >30 días';

-- =====================================================================
-- 5) CRON JOBS
-- =====================================================================

-- Eliminar jobs existentes si existen (para evitar duplicados)
SELECT cron.unschedule('cleanup-stale-loans') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'cleanup-stale-loans'
);

SELECT cron.unschedule('send-loan-reminders') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'send-loan-reminders'
);

SELECT cron.unschedule('purge-in-app-notifications') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'purge-in-app-notifications'
);

-- Programar limpieza de préstamos antiguos (diario a las 2 AM)
SELECT cron.schedule(
  'cleanup-stale-loans',
  '0 2 * * *',
  $cron$
  DO $block$
  DECLARE
    expired_loan RECORD;
  BEGIN
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
  END $block$;
  $cron$
);

-- Programar envío de recordatorios (diario a las 9 AM)
SELECT cron.schedule(
  'send-loan-reminders',
  '0 9 * * *',
  'SELECT send_loan_reminders();'
);

-- Programar limpieza de notificaciones (diario a las 3 AM)
SELECT cron.schedule(
  'purge-in-app-notifications',
  '0 3 * * *',
  'SELECT public.purge_in_app_notifications();'
);

-- =====================================================================
-- 6) ROW LEVEL SECURITY (RLS)
-- =====================================================================

ALTER TABLE local_users        ENABLE ROW LEVEL SECURITY;
ALTER TABLE books              ENABLE ROW LEVEL SECURITY;
ALTER TABLE book_reviews       ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups             ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members      ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_invitations  ENABLE ROW LEVEL SECURITY;
ALTER TABLE shared_books       ENABLE ROW LEVEL SECURITY;
ALTER TABLE loans              ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications      ENABLE ROW LEVEL SECURITY;
ALTER TABLE in_app_notifications ENABLE ROW LEVEL SECURITY;

-- local_users ---------------------------------------------------------
DROP POLICY IF EXISTS local_users_select_self ON local_users;
CREATE POLICY local_users_select_self
  ON local_users FOR SELECT
  USING (auth.uid() IS NULL OR auth.uid() = auth_user_id);

DROP POLICY IF EXISTS local_users_manage_self ON local_users;
CREATE POLICY local_users_manage_self
  ON local_users FOR ALL
  USING (auth.uid() IS NULL OR auth.uid() = auth_user_id)
  WITH CHECK (auth.uid() IS NULL OR auth.uid() = auth_user_id);

-- books ---------------------------------------------------------------
DROP POLICY IF EXISTS books_select_owner ON books;
CREATE POLICY books_select_owner
  ON books FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = owner_id AND u.auth_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS books_manage_owner ON books;
CREATE POLICY books_manage_owner
  ON books FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = owner_id AND u.auth_user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = owner_id AND u.auth_user_id = auth.uid()
    )
  );

-- book_reviews --------------------------------------------------------
DROP POLICY IF EXISTS book_reviews_select ON book_reviews;
CREATE POLICY book_reviews_select
  ON book_reviews FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = author_id AND u.auth_user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1
      FROM books b
      JOIN local_users u ON u.id = b.owner_id
      WHERE b.id = book_id AND u.auth_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS book_reviews_manage_author ON book_reviews;
CREATE POLICY book_reviews_manage_author
  ON book_reviews FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = author_id AND u.auth_user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = author_id AND u.auth_user_id = auth.uid()
    )
  );

-- groups --------------------------------------------------------------
DROP POLICY IF EXISTS groups_select_member ON groups;
CREATE POLICY groups_select_member
  ON groups FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM group_members gm
      JOIN local_users u ON u.id = gm.user_id
      WHERE gm.group_id = groups.id AND u.auth_user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = owner_id AND u.auth_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS groups_manage_owner ON groups;
CREATE POLICY groups_manage_owner
  ON groups FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = owner_id AND u.auth_user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = owner_id AND u.auth_user_id = auth.uid()
    )
  );

-- group_members -------------------------------------------------------
DROP POLICY IF EXISTS group_members_select ON group_members;
CREATE POLICY group_members_select
  ON group_members FOR SELECT
  USING (true);

DROP POLICY IF EXISTS group_members_manage_owner ON group_members;
CREATE POLICY group_members_manage_owner
  ON group_members FOR ALL
  USING (true)
  WITH CHECK (true);

-- group_invitations ---------------------------------------------------
DROP POLICY IF EXISTS group_invitations_select ON group_invitations;
CREATE POLICY group_invitations_select
  ON group_invitations FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM groups g
      JOIN local_users u ON u.id = g.owner_id
      WHERE g.id = group_invitations.group_id AND u.auth_user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = inviter_id AND u.auth_user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = accepted_user_id AND u.auth_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS group_invitations_manage_owner ON group_invitations;
CREATE POLICY group_invitations_manage_owner
  ON group_invitations FOR ALL
  USING (
    EXISTS (
      SELECT 1
      FROM groups g
      JOIN local_users u ON u.id = g.owner_id
      WHERE g.id = group_id AND u.auth_user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM groups g
      JOIN local_users u ON u.id = g.owner_id
      WHERE g.id = group_id AND u.auth_user_id = auth.uid()
    )
  );

-- shared_books --------------------------------------------------------
DROP POLICY IF EXISTS shared_books_select_group_members ON shared_books;
CREATE POLICY shared_books_select_group_members
  ON shared_books FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM group_members gm
      JOIN local_users u ON u.id = gm.user_id
      WHERE gm.group_id = shared_books.group_id AND u.auth_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS shared_books_manage_owner ON shared_books;
CREATE POLICY shared_books_manage_owner
  ON shared_books FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = owner_id AND u.auth_user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = owner_id AND u.auth_user_id = auth.uid()
    )
  );

-- loans (con soporte para préstamos manuales) ------------------------
DROP POLICY IF EXISTS loans_select_participants ON loans;
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

DROP POLICY IF EXISTS loans_manage_participants ON loans;
CREATE POLICY loans_manage_participants
  ON loans FOR ALL
  USING (
    (from_user IS NOT NULL AND EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = from_user AND u.auth_user_id = auth.uid()
    ))
    OR
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = to_user AND u.auth_user_id = auth.uid()
    )
  )
  WITH CHECK (
    (from_user IS NOT NULL AND EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = from_user AND u.auth_user_id = auth.uid()
    ))
    OR
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = to_user AND u.auth_user_id = auth.uid()
    )
  );

-- notifications (legacy) ----------------------------------------------
DROP POLICY IF EXISTS notifications_select_owner ON notifications;
CREATE POLICY notifications_select_owner
  ON notifications FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = user_id AND u.auth_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS notifications_insert_self ON notifications;
CREATE POLICY notifications_insert_self
  ON notifications FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = user_id AND u.auth_user_id = auth.uid()
    )
  );

-- in_app_notifications ------------------------------------------------
DROP POLICY IF EXISTS in_app_notifications_select_target ON in_app_notifications;
CREATE POLICY in_app_notifications_select_target
  ON in_app_notifications FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = target_user_id AND u.auth_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS in_app_notifications_manage_target ON in_app_notifications;
CREATE POLICY in_app_notifications_manage_target
  ON in_app_notifications FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = target_user_id AND u.auth_user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = target_user_id AND u.auth_user_id = auth.uid()
    )
  );

-- =====================================================================
-- 7) COMENTARIOS Y DOCUMENTACIÓN
-- =====================================================================

COMMENT ON TABLE loans IS 'Préstamos de libros. Soporta préstamos normales (entre usuarios) y manuales (a personas sin la app)';
COMMENT ON COLUMN loans.from_user IS 'Usuario que solicita el préstamo. NULL para préstamos manuales';
COMMENT ON COLUMN loans.to_user IS 'Usuario propietario del libro';
COMMENT ON COLUMN loans.external_borrower_name IS 'Nombre del prestatario para préstamos manuales';
COMMENT ON COLUMN loans.external_borrower_contact IS 'Contacto del prestatario externo (teléfono, email, etc.)';
COMMENT ON COLUMN loans.status IS 'Estado: pending, accepted, loaned, rejected, returned, expired, cancelled';

-- =====================================================================
-- 8) VERIFICACIÓN Y RESUMEN
-- =====================================================================

-- Verificar que los cron jobs están programados
DO $$
DECLARE
  job_count integer;
BEGIN
  SELECT COUNT(*) INTO job_count
  FROM cron.job
  WHERE jobname IN ('cleanup-stale-loans', 'send-loan-reminders', 'purge-in-app-notifications');
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ Schema v3 creado exitosamente!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Tablas creadas:';
  RAISE NOTICE '  ✓ local_users';
  RAISE NOTICE '  ✓ books';
  RAISE NOTICE '  ✓ book_reviews';
  RAISE NOTICE '  ✓ groups';
  RAISE NOTICE '  ✓ group_members';
  RAISE NOTICE '  ✓ group_invitations';
  RAISE NOTICE '  ✓ shared_books';
  RAISE NOTICE '  ✓ loans (con soporte para préstamos manuales)';
  RAISE NOTICE '  ✓ notifications (legacy)';
  RAISE NOTICE '  ✓ in_app_notifications';
  RAISE NOTICE '';
  RAISE NOTICE 'Funciones creadas:';
  RAISE NOTICE '  ✓ notify_loan_status_change()';
  RAISE NOTICE '  ✓ cleanup_stale_loans()';
  RAISE NOTICE '  ✓ send_loan_reminders()';
  RAISE NOTICE '  ✓ purge_in_app_notifications()';
  RAISE NOTICE '';
  RAISE NOTICE 'Cron jobs programados: %', job_count;
  RAISE NOTICE '  ✓ cleanup-stale-loans (diario 2 AM)';
  RAISE NOTICE '  ✓ send-loan-reminders (diario 9 AM)';
  RAISE NOTICE '  ✓ purge-in-app-notifications (diario 3 AM)';
  RAISE NOTICE '';
  RAISE NOTICE 'Políticas RLS: ✓ Habilitadas en todas las tablas';
  RAISE NOTICE '';
  RAISE NOTICE 'Próximos pasos:';
  RAISE NOTICE '1. Ejecutar "dart run build_runner build" en Flutter';
  RAISE NOTICE '2. Probar el flujo de préstamos completo';
  RAISE NOTICE '3. Verificar que los cron jobs funcionan correctamente';
  RAISE NOTICE '';
END $$;
