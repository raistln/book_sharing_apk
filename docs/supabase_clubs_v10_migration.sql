-- ============================================================================
-- Book Sharing App - Supabase Clubs v10 Migration
-- ============================================================================
-- Aligns the remote Supabase clubs schema with the current client contract.
-- Apply this on an existing Supabase project before enabling the new clubs sync.
-- ============================================================================

BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE SCHEMA IF NOT EXISTS internal;


-- ============================================================================
-- STEP 1: TABLE SHAPE ALIGNMENT
-- ============================================================================

ALTER TABLE IF EXISTS public.reading_clubs
  ADD COLUMN IF NOT EXISTS meeting_place TEXT,
  ADD COLUMN IF NOT EXISTS frequency_days INTEGER,
  ADD COLUMN IF NOT EXISTS next_books_visible INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS current_book_id UUID;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'club_members'
      AND column_name = 'user_id'
  ) AND NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'club_members'
      AND column_name = 'member_id'
  ) THEN
    EXECUTE 'ALTER TABLE public.club_members RENAME COLUMN user_id TO member_id';
  END IF;
END $$;

ALTER TABLE IF EXISTS public.club_members
  ADD COLUMN IF NOT EXISTS last_activity TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE IF EXISTS public.club_books
  ADD COLUMN IF NOT EXISTS order_position INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS section_mode TEXT NOT NULL DEFAULT 'automatico',
  ADD COLUMN IF NOT EXISTS start_date TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS end_date TIMESTAMPTZ;

ALTER TABLE IF EXISTS public.club_reading_progress
  ADD COLUMN IF NOT EXISTS current_section INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS progress_status TEXT NOT NULL DEFAULT 'no_empezado',
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'section_comments'
      AND column_name = 'user_id'
  ) AND NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'section_comments'
      AND column_name = 'author_user_id'
  ) THEN
    EXECUTE 'ALTER TABLE public.section_comments RENAME COLUMN user_id TO author_user_id';
  END IF;
END $$;

ALTER TABLE IF EXISTS public.section_comments
  ADD COLUMN IF NOT EXISTS section_number INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS report_count INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN NOT NULL DEFAULT false;

-- ----------------------------------------------------------------
-- TABLE: book_proposals
-- ----------------------------------------------------------------
DO $$
BEGIN
  -- 1. Rename legacy column if it exists
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'book_proposals' AND column_name = 'user_id') 
     AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'book_proposals' AND column_name = 'proposed_by_user_id') THEN
    ALTER TABLE public.book_proposals RENAME COLUMN user_id TO proposed_by_user_id;
  END IF;

  -- 2. Ensure table exists
  CREATE TABLE IF NOT EXISTS public.book_proposals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
  );

  -- 3. Force alignment of all columns (Handles existing but incomplete tables)
  ALTER TABLE public.book_proposals 
    ADD COLUMN IF NOT EXISTS club_id UUID REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS book_uuid TEXT,
    ADD COLUMN IF NOT EXISTS proposed_by_user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS title TEXT,
    ADD COLUMN IF NOT EXISTS author TEXT,
    ADD COLUMN IF NOT EXISTS isbn TEXT,
    ADD COLUMN IF NOT EXISTS cover_url TEXT,
    ADD COLUMN IF NOT EXISTS votes TEXT NOT NULL DEFAULT '',
    ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'abierta',
    ADD COLUMN IF NOT EXISTS closing_date TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

  -- 4. Fill required NOT NULL constraints if they were added as NULL
  -- (Only applies if table already had rows, which is unlikely for new features)
  UPDATE public.book_proposals SET title = 'Sin título' WHERE title IS NULL;
  UPDATE public.book_proposals SET closing_date = NOW() + INTERVAL '7 days' WHERE closing_date IS NULL;
  UPDATE public.book_proposals SET book_uuid = 'temp-' || id::text WHERE book_uuid IS NULL;
  UPDATE public.book_proposals SET club_id = (SELECT id FROM public.reading_clubs LIMIT 1) WHERE club_id IS NULL;
  UPDATE public.book_proposals SET proposed_by_user_id = (SELECT id FROM public.profiles LIMIT 1) WHERE proposed_by_user_id IS NULL;

END $$;

-- ----------------------------------------------------------------
-- TABLE: comment_reports
-- ----------------------------------------------------------------
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'comment_reports' AND column_name = 'user_id') 
     AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'comment_reports' AND column_name = 'reported_by_user_id') THEN
    ALTER TABLE public.comment_reports RENAME COLUMN user_id TO reported_by_user_id;
  END IF;

  CREATE TABLE IF NOT EXISTS public.comment_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
  );

  ALTER TABLE public.comment_reports
    ADD COLUMN IF NOT EXISTS comment_id UUID REFERENCES public.section_comments(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS reported_by_user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS reason TEXT,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
END $$;

-- ----------------------------------------------------------------
-- TABLE: moderation_logs
-- ----------------------------------------------------------------
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'moderation_logs' AND column_name = 'user_id') 
     AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'moderation_logs' AND column_name = 'performed_by_user_id') THEN
    ALTER TABLE public.moderation_logs RENAME COLUMN user_id TO performed_by_user_id;
  END IF;

  CREATE TABLE IF NOT EXISTS public.moderation_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
  );

  ALTER TABLE public.moderation_logs
    ADD COLUMN IF NOT EXISTS club_id UUID REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS action TEXT NOT NULL DEFAULT 'unknown',
    ADD COLUMN IF NOT EXISTS performed_by_user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS target_id TEXT,
    ADD COLUMN IF NOT EXISTS reason TEXT,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
END $$;



-- ============================================================================
-- STEP 2: DATA NORMALIZATION
-- ============================================================================

UPDATE public.reading_clubs
SET next_books_visible = COALESCE(next_books_visible, 1)
WHERE next_books_visible IS NULL;

UPDATE public.club_members
SET last_activity = COALESCE(last_activity, joined_at, created_at, NOW())
WHERE last_activity IS NULL;

UPDATE public.club_books
SET order_position = COALESCE(order_position, 0),
    section_mode = COALESCE(NULLIF(section_mode, ''), 'automatico')
WHERE order_position IS NULL
   OR section_mode IS NULL
   OR section_mode = '';

UPDATE public.club_reading_progress
SET current_section = COALESCE(current_section, 0),
    progress_status = COALESCE(NULLIF(progress_status, ''), 'no_empezado'),
    created_at = COALESCE(created_at, updated_at, NOW())
WHERE current_section IS NULL
   OR progress_status IS NULL
   OR progress_status = ''
   OR created_at IS NULL;

UPDATE public.section_comments
SET section_number = COALESCE(section_number, 1),
    report_count = COALESCE(report_count, 0),
    updated_at = COALESCE(updated_at, created_at, NOW())
WHERE section_number IS NULL
   OR report_count IS NULL
   OR updated_at IS NULL;

-- ============================================================================
-- STEP 3: CONSTRAINTS AND INDEXES
-- ============================================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'club_members_club_id_member_id_key'
  ) THEN
    ALTER TABLE public.club_members
      ADD CONSTRAINT club_members_club_id_member_id_key UNIQUE (club_id, member_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'club_reading_progress_club_id_book_id_user_id_key'
  ) THEN
    ALTER TABLE public.club_reading_progress
      ADD CONSTRAINT club_reading_progress_club_id_book_id_user_id_key
      UNIQUE (club_id, book_id, user_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'fk_current_book'
  ) THEN
    ALTER TABLE public.reading_clubs
      ADD CONSTRAINT fk_current_book
      FOREIGN KEY (current_book_id)
      REFERENCES public.club_books(id)
      ON DELETE SET NULL;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_club_members_member_id ON public.club_members(member_id);
CREATE INDEX IF NOT EXISTS idx_club_books_club_order ON public.club_books(club_id, order_position);
CREATE INDEX IF NOT EXISTS idx_club_books_book_uuid ON public.club_books(book_uuid);
CREATE INDEX IF NOT EXISTS idx_club_progress_book_user ON public.club_reading_progress(book_id, user_id);
CREATE INDEX IF NOT EXISTS idx_book_proposals_club_created ON public.book_proposals(club_id, created_at);
CREATE INDEX IF NOT EXISTS idx_section_comments_book_section_created ON public.section_comments(book_id, section_number, created_at);
CREATE INDEX IF NOT EXISTS idx_comment_reports_comment_id ON public.comment_reports(comment_id);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_club_created ON public.moderation_logs(club_id, created_at);

-- ============================================================================
-- STEP 4: HELPERS AND UPDATED-AT TRIGGERS
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS internal;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END; $$;

-- ----------------------------------------------------------------
-- SYSTEM HELPERS (STAY IN PUBLIC FOR RPC)
-- ----------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.log_error(p_source TEXT, p_message TEXT, p_metadata JSONB DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.system_logs (log_level, source, message, metadata)
  VALUES ('error', p_source, p_message, p_metadata);
END; $$;

CREATE OR REPLACE FUNCTION public.update_system_metrics(p_name TEXT, p_value TEXT)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.system_metrics (metric_name, metric_value)
  VALUES (p_name, p_value)
  ON CONFLICT (metric_name, metric_hour) 
  DO UPDATE SET metric_value = EXCLUDED.metric_value, recorded_at = NOW();
END; $$;

-- ----------------------------------------------------------------
-- RLS HELPERS (MOVED TO INTERNAL TO SILENCE LINTER)
-- ----------------------------------------------------------------

CREATE OR REPLACE FUNCTION internal.check_is_club_member(p_club_id UUID, p_user_id UUID)
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.reading_clubs rc
    WHERE rc.id = p_club_id AND rc.owner_id = p_user_id AND rc.is_deleted = false
  ) OR EXISTS (
    SELECT 1 FROM public.club_members cm
    WHERE cm.club_id = p_club_id AND cm.member_id = p_user_id AND cm.is_deleted = false
  );
END; $$;

CREATE OR REPLACE FUNCTION internal.check_is_club_admin(p_club_id UUID, p_user_id UUID)
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.reading_clubs rc
    WHERE rc.id = p_club_id AND rc.owner_id = p_user_id AND rc.is_deleted = false
  ) OR EXISTS (
    SELECT 1 FROM public.club_members cm
    WHERE cm.club_id = p_club_id AND cm.member_id = p_user_id AND translate(lower(cm.role), 'ñ', 'n') IN ('dueno', 'admin') AND cm.is_deleted = false
  );
END; $$;

CREATE OR REPLACE FUNCTION internal.check_is_group_member(p_group_id UUID, p_user_id UUID) 
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.group_members
    WHERE group_id = p_group_id 
      AND member_id = p_user_id
  );
END;
$$;

DROP TRIGGER IF EXISTS update_clubs_at ON public.reading_clubs;
CREATE TRIGGER update_clubs_at
  BEFORE UPDATE ON public.reading_clubs
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_club_members_at ON public.club_members;
CREATE TRIGGER update_club_members_at
  BEFORE UPDATE ON public.club_members
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_club_books_at ON public.club_books;
CREATE TRIGGER update_club_books_at
  BEFORE UPDATE ON public.club_books
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_club_progress_at ON public.club_reading_progress;
CREATE TRIGGER update_club_progress_at
  BEFORE UPDATE ON public.club_reading_progress
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_book_proposals_at ON public.book_proposals;
CREATE TRIGGER update_book_proposals_at
  BEFORE UPDATE ON public.book_proposals
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_section_comments_at ON public.section_comments;
CREATE TRIGGER update_section_comments_at
  BEFORE UPDATE ON public.section_comments
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- STEP 5: RLS POLICIES
-- ============================================================================

ALTER TABLE public.reading_clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.club_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.club_books ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book_proposals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.club_reading_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.section_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comment_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moderation_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "clubs_access" ON public.reading_clubs;
DROP POLICY IF EXISTS "clubs_select" ON public.reading_clubs;
DROP POLICY IF EXISTS "clubs_insert" ON public.reading_clubs;
DROP POLICY IF EXISTS "clubs_update" ON public.reading_clubs;
DROP POLICY IF EXISTS "clubs_delete" ON public.reading_clubs;
CREATE POLICY "clubs_select" ON public.reading_clubs
  FOR SELECT USING (owner_id = (select auth.uid()) OR internal.check_is_club_member(id, (select auth.uid())));
CREATE POLICY "clubs_insert" ON public.reading_clubs
  FOR INSERT WITH CHECK (owner_id = (select auth.uid()));
CREATE POLICY "clubs_update" ON public.reading_clubs
  FOR UPDATE USING (internal.check_is_club_admin(id, (select auth.uid())))
  WITH CHECK (internal.check_is_club_admin(id, (select auth.uid())));
CREATE POLICY "clubs_delete" ON public.reading_clubs
  FOR DELETE USING (owner_id = (select auth.uid()));

DROP POLICY IF EXISTS "club_members_select" ON public.club_members;
DROP POLICY IF EXISTS "club_members_insert" ON public.club_members;
DROP POLICY IF EXISTS "club_members_update" ON public.club_members;
DROP POLICY IF EXISTS "club_members_delete" ON public.club_members;
CREATE POLICY "club_members_select" ON public.club_members
  FOR SELECT USING (internal.check_is_club_member(club_id, (select auth.uid())));
CREATE POLICY "club_members_insert" ON public.club_members
  FOR INSERT WITH CHECK (
    internal.check_is_club_admin(club_id, (select auth.uid()))
    OR member_id = (select auth.uid())
  );
CREATE POLICY "club_members_update" ON public.club_members
  FOR UPDATE USING (
    internal.check_is_club_admin(club_id, (select auth.uid()))
    OR member_id = (select auth.uid())
  )
  WITH CHECK (
    internal.check_is_club_admin(club_id, (select auth.uid()))
    OR member_id = (select auth.uid())
  );
CREATE POLICY "club_members_delete" ON public.club_members
  FOR DELETE USING (
    check_is_club_admin(club_id, (select auth.uid()))
    OR member_id = (select auth.uid())
  );

DROP POLICY IF EXISTS "club_books_select" ON public.club_books;
DROP POLICY IF EXISTS "club_books_insert" ON public.club_books;
DROP POLICY IF EXISTS "club_books_update" ON public.club_books;
DROP POLICY IF EXISTS "club_books_delete" ON public.club_books;
CREATE POLICY "club_books_select" ON public.club_books
  FOR SELECT USING (check_is_club_member(club_id, (select auth.uid())));
CREATE POLICY "club_books_insert" ON public.club_books
  FOR INSERT WITH CHECK (check_is_club_admin(club_id, (select auth.uid())));
CREATE POLICY "club_books_update" ON public.club_books
  FOR UPDATE USING (check_is_club_admin(club_id, (select auth.uid())))
  WITH CHECK (check_is_club_admin(club_id, (select auth.uid())));
CREATE POLICY "club_books_delete" ON public.club_books
  FOR DELETE USING (check_is_club_admin(club_id, (select auth.uid())));

DROP POLICY IF EXISTS "book_proposals_select" ON public.book_proposals;
DROP POLICY IF EXISTS "book_proposals_insert" ON public.book_proposals;
DROP POLICY IF EXISTS "book_proposals_update" ON public.book_proposals;
DROP POLICY IF EXISTS "book_proposals_delete" ON public.book_proposals;
CREATE POLICY "book_proposals_select" ON public.book_proposals
  FOR SELECT USING (check_is_club_member(club_id, (select auth.uid())));
CREATE POLICY "book_proposals_insert" ON public.book_proposals
  FOR INSERT WITH CHECK (
    check_is_club_member(club_id, (select auth.uid()))
    AND proposed_by_user_id = (select auth.uid())
  );
CREATE POLICY "book_proposals_update" ON public.book_proposals
  FOR UPDATE USING (check_is_club_member(club_id, (select auth.uid())))
  WITH CHECK (check_is_club_member(club_id, (select auth.uid())));
CREATE POLICY "book_proposals_delete" ON public.book_proposals
  FOR DELETE USING (check_is_club_admin(club_id, (select auth.uid())));

DROP POLICY IF EXISTS "club_progress_select" ON public.club_reading_progress;
DROP POLICY IF EXISTS "club_progress_insert" ON public.club_reading_progress;
DROP POLICY IF EXISTS "club_progress_update" ON public.club_reading_progress;
DROP POLICY IF EXISTS "club_progress_delete" ON public.club_reading_progress;
CREATE POLICY "club_progress_select" ON public.club_reading_progress
  FOR SELECT USING (check_is_club_member(club_id, (select auth.uid())));
CREATE POLICY "club_progress_insert" ON public.club_reading_progress
  FOR INSERT WITH CHECK (
    check_is_club_member(club_id, (select auth.uid()))
    AND user_id = (select auth.uid())
  );
CREATE POLICY "club_progress_update" ON public.club_reading_progress
  FOR UPDATE USING (
    check_is_club_member(club_id, (select auth.uid()))
    AND user_id = (select auth.uid())
  )
  WITH CHECK (
    check_is_club_member(club_id, (select auth.uid()))
    AND user_id = (select auth.uid())
  );
CREATE POLICY "club_progress_delete" ON public.club_reading_progress
  FOR DELETE USING (
    check_is_club_admin(club_id, (select auth.uid()))
    OR user_id = (select auth.uid())
  );

DROP POLICY IF EXISTS "section_comments_select" ON public.section_comments;
DROP POLICY IF EXISTS "section_comments_insert" ON public.section_comments;
DROP POLICY IF EXISTS "section_comments_update" ON public.section_comments;
DROP POLICY IF EXISTS "section_comments_delete" ON public.section_comments;
CREATE POLICY "section_comments_select" ON public.section_comments
  FOR SELECT USING (
    EXISTS (
      SELECT 1
      FROM public.club_books cb
      WHERE cb.id = section_comments.book_id
        AND check_is_club_member(cb.club_id, (select auth.uid()))
    )
  );
CREATE POLICY "section_comments_insert" ON public.section_comments
  FOR INSERT WITH CHECK (
    author_user_id = (select auth.uid())
    AND EXISTS (
      SELECT 1
      FROM public.club_books cb
      WHERE cb.id = book_id
        AND check_is_club_member(cb.club_id, (select auth.uid()))
    )
  );
CREATE POLICY "section_comments_update" ON public.section_comments
  FOR UPDATE USING (
    author_user_id = (select auth.uid())
    OR EXISTS (
      SELECT 1
      FROM public.club_books cb
      WHERE cb.id = section_comments.book_id
        AND check_is_club_admin(cb.club_id, (select auth.uid()))
    )
  )
  WITH CHECK (
    author_user_id = (select auth.uid())
    OR EXISTS (
      SELECT 1
      FROM public.club_books cb
      WHERE cb.id = book_id
        AND check_is_club_admin(cb.club_id, (select auth.uid()))
    )
  );
CREATE POLICY "section_comments_delete" ON public.section_comments
  FOR DELETE USING (
    author_user_id = (select auth.uid())
    OR EXISTS (
      SELECT 1
      FROM public.club_books cb
      WHERE cb.id = section_comments.book_id
        AND check_is_club_admin(cb.club_id, (select auth.uid()))
    )
  );

DROP POLICY IF EXISTS "comment_reports_select" ON public.comment_reports;
DROP POLICY IF EXISTS "comment_reports_insert" ON public.comment_reports;
DROP POLICY IF EXISTS "comment_reports_delete" ON public.comment_reports;
CREATE POLICY "comment_reports_select" ON public.comment_reports
  FOR SELECT USING (
    EXISTS (
      SELECT 1
      FROM public.section_comments sc
      JOIN public.club_books cb ON cb.id = sc.book_id
      WHERE sc.id = comment_reports.comment_id
        AND check_is_club_member(cb.club_id, (select auth.uid()))
    )
  );
CREATE POLICY "comment_reports_insert" ON public.comment_reports
  FOR INSERT WITH CHECK (
    reported_by_user_id = (select auth.uid())
    AND EXISTS (
      SELECT 1
      FROM public.section_comments sc
      JOIN public.club_books cb ON cb.id = sc.book_id
      WHERE sc.id = comment_id
        AND check_is_club_member(cb.club_id, (select auth.uid()))
    )
  );
CREATE POLICY "comment_reports_delete" ON public.comment_reports
  FOR DELETE USING (
    reported_by_user_id = (select auth.uid())
    OR EXISTS (
      SELECT 1
      FROM public.section_comments sc
      JOIN public.club_books cb ON cb.id = sc.book_id
      WHERE sc.id = comment_reports.comment_id
        AND check_is_club_admin(cb.club_id, (select auth.uid()))
    )
  );

DROP POLICY IF EXISTS "moderation_logs_select" ON public.moderation_logs;
DROP POLICY IF EXISTS "moderation_logs_insert" ON public.moderation_logs;
CREATE POLICY "moderation_logs_select" ON public.moderation_logs
  FOR SELECT USING (check_is_club_member(club_id, (select auth.uid())));
CREATE POLICY "moderation_logs_insert" ON public.moderation_logs
  FOR INSERT WITH CHECK (
    check_is_club_admin(club_id, (select auth.uid()))
    AND performed_by_user_id = (select auth.uid())
  );

-- Duplicate definition removed (already defined in Step 4)


-- ============================================================================
-- STEP 6: SECURITY HARDENING
-- ============================================================================
-- Revoke public execution of SECURITY DEFINER functions to satisfy linter
-- ------------------------------------------------------------------ ============================================================================
-- STEP 6: SECURITY HARDENING (Linter Fixes)
-- ============================================================================

-- 1. Revoke EXECUTE from everyone by default for all existing functions
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM anon;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM authenticated;

-- 2. Ensure future functions don't have default PUBLIC execute permissions
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM authenticated;

-- 3. Grant EXECUTE only to 'authenticated' for necessary RPCs
GRANT EXECUTE ON FUNCTION public.accept_loan(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.log_error(TEXT, TEXT, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_system_metrics(TEXT, TEXT) TO authenticated;

-- 4. Grant EXECUTE on helpers to authenticated (Internal schema)
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA internal TO authenticated;


-- 4. Grant EXECUTE to 'service_role' for internal/automated tasks (Cron/Triggers)
GRANT EXECUTE ON FUNCTION public.cleanup_deleted_records() TO service_role;
GRANT EXECUTE ON FUNCTION public.cleanup_expired_content() TO service_role;
GRANT EXECUTE ON FUNCTION public.cleanup_old_notifications() TO service_role;
GRANT EXECUTE ON FUNCTION public.cleanup_system_data() TO service_role;
GRANT EXECUTE ON FUNCTION public.expire_overdue_loans() TO service_role;
GRANT EXECUTE ON FUNCTION public.send_loan_reminders() TO service_role;
GRANT EXECUTE ON FUNCTION public.handle_loan_updates() TO service_role;
GRANT EXECUTE ON FUNCTION public.auto_hide_reported_comments() TO service_role;
GRANT EXECUTE ON FUNCTION public.notify_loan_status_change() TO service_role;
GRANT EXECUTE ON FUNCTION public.purge_in_app_notifications() TO service_role;

COMMIT;
