-- 📚 Book Sharing App – Supabase Schema (v2)
-- Este script crea un esquema coherente con el cliente Flutter y
-- proporciona un bloque opcional para limpiar todas las tablas antes
-- de recrearlas.

-- =====================================================================
-- 0) RESET OPCIONAL (EJECUTAR SOLO SI QUIERES BORRAR TODO)
-- =====================================================================
/*
-- BEGIN RESET ----------------------------------------------------------
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS loans CASCADE;
DROP TABLE IF EXISTS shared_books CASCADE;
DROP TABLE IF EXISTS group_invitations CASCADE;
DROP TABLE IF EXISTS group_members CASCADE;
DROP TABLE IF EXISTS groups CASCADE;
DROP TABLE IF EXISTS book_reviews CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS local_users CASCADE;
-- END RESET ------------------------------------------------------------
*/

-- =====================================================================
-- 1) EXTENSIONES NECESARIAS
-- =====================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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

-- Préstamos
CREATE TABLE IF NOT EXISTS loans (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  shared_book_id uuid NOT NULL REFERENCES shared_books(id) ON DELETE CASCADE,
  from_user uuid NOT NULL REFERENCES local_users(id) ON DELETE CASCADE,
  to_user uuid NOT NULL REFERENCES local_users(id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'pending' CHECK (
    status IN ('pending', 'accepted', 'rejected', 'returned', 'expired', 'cancelled')
  ),
  start_date timestamptz NOT NULL DEFAULT now(),
  due_date timestamptz,
  returned_at timestamptz,
  cancelled_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Notificaciones de eventos relevantes
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES local_users(id) ON DELETE CASCADE,
  type text NOT NULL,
  message text,
  related_loan uuid REFERENCES loans(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  read boolean NOT NULL DEFAULT false
);

-- Índices auxiliares ---------------------------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS local_users_username_unique
  ON local_users (lower(username));

-- =====================================================================
-- 3) TRIGGERS
-- =====================================================================

CREATE OR REPLACE FUNCTION public.notify_loan_status_change()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO notifications (user_id, type, message, related_loan)
    VALUES (NEW.to_user, 'loan_requested', 'Te han solicitado un préstamo.', NEW.id);
  ELSIF (TG_OP = 'UPDATE') THEN
    IF (NEW.status <> OLD.status) THEN
      IF (NEW.status = 'accepted') THEN
        INSERT INTO notifications (user_id, type, message, related_loan)
        VALUES (NEW.from_user, 'loan_accepted', 'Tu préstamo ha sido aceptado.', NEW.id);
      ELSIF (NEW.status = 'rejected') THEN
        INSERT INTO notifications (user_id, type, message, related_loan)
        VALUES (NEW.from_user, 'loan_rejected', 'Tu préstamo ha sido rechazado.', NEW.id);
      ELSIF (NEW.status = 'returned') THEN
        INSERT INTO notifications (user_id, type, message, related_loan)
        VALUES (NEW.to_user, 'loan_returned', 'Se ha marcado el préstamo como devuelto.', NEW.id);
      ELSIF (NEW.status = 'expired') THEN
        INSERT INTO notifications (user_id, type, message, related_loan)
        VALUES (NEW.from_user, 'loan_expired', 'Un préstamo ha expirado.', NEW.id);
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

-- =====================================================================
-- 4) ROW LEVEL SECURITY (RLS)
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

-- Políticas sobre books
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

-- Políticas sobre book_reviews
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

-- Políticas sobre groups
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

-- Políticas sobre group_members
DROP POLICY IF EXISTS group_members_select ON group_members;
CREATE POLICY group_members_select
  ON group_members FOR SELECT
  USING (true);

DROP POLICY IF EXISTS group_members_manage_owner ON group_members;
CREATE POLICY group_members_manage_owner
  ON group_members FOR ALL
  USING (true)
  WITH CHECK (true);

-- Políticas sobre group_invitations
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

-- Políticas sobre shared_books
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

-- Políticas sobre loans
DROP POLICY IF EXISTS loans_select_participants ON loans;
CREATE POLICY loans_select_participants
  ON loans FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = from_user AND u.auth_user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = to_user AND u.auth_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS loans_manage_participants ON loans;
CREATE POLICY loans_manage_participants
  ON loans FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = from_user AND u.auth_user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = to_user AND u.auth_user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = from_user AND u.auth_user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM local_users u
      WHERE u.id = to_user AND u.auth_user_id = auth.uid()
    )
  );

-- Políticas sobre notifications
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
  
create table public.in_app_notifications (
  id uuid primary key default extensions.uuid_generate_v4(),
  type text not null check (char_length(type) <= 64),

  -- Relación con préstamos compartidos
  loan_id uuid references loans(id) on delete set null,
  shared_book_id uuid references shared_books(id) on delete set null,

  -- Actor/target
  actor_user_id uuid references local_users(id) on delete set null,
  target_user_id uuid not null references local_users(id) on delete cascade,

  title text,
  message text,

  status text not null default 'unread' check (char_length(status) <= 32),

  is_deleted boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index in_app_notifications_target_idx
  on public.in_app_notifications (target_user_id, is_deleted, status);

create index in_app_notifications_loan_idx
  on public.in_app_notifications (loan_id);

create index in_app_notifications_shared_book_idx
  on public.in_app_notifications (shared_book_id);

alter table public.in_app_notifications
  enable row level security;

-- 1) Asegurar la extensión pg_cron
create extension if not exists pg_cron;

-- 2) (Opcional) crear/actualizar la función de limpieza
create or replace function public.purge_in_app_notifications()
returns void
language sql
security definer
set search_path = public
as $$
  delete from public.in_app_notifications
  where (
      status in ('read', 'dismissed')
      and updated_at < now() - interval '15 days'
    )
    or (
      status not in ('read', 'dismissed')
      and updated_at < now() - interval '30 days'
    );
$$;

-- 3) Programar el job diario (03:00 AM)
select cron.schedule(
  'purge-in-app-notifications',
  '0 3 * * *',
  'select public.purge_in_app_notifications();'
);