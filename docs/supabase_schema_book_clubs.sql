-- ============================================================================
-- Book Clubs Feature - Supabase SQL Schema
-- ============================================================================
-- This script adds 8 new tables for the reading clubs feature.
-- Run this AFTER the main schema (supabase_schema_v7_clean deploy.sql)
-- ============================================================================

-- ============================================================================
-- STEP 1: CREATE TABLES
-- ============================================================================

-- READING CLUBS
CREATE TABLE public.reading_clubs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  city TEXT NOT NULL,
  meeting_place TEXT,
  
  -- Frequency configuration
  frequency TEXT NOT NULL CHECK (frequency IN ('semanal', 'quincenal', 'mensual', 'personalizada')),
  frequency_days INTEGER,
  
  -- Visibility (v1: only 'privado', v2: 'publico' for search)
  visibility TEXT NOT NULL DEFAULT 'privado' CHECK (visibility IN ('privado', 'publico')),
  
  -- UI configuration (only owner can change)
  next_books_visible INTEGER NOT NULL DEFAULT 1 CHECK (next_books_visible BETWEEN 1 AND 3),
  
  -- Relationships
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  current_book_id UUID, -- Will be added as FK after club_books table is created
  
  -- Soft delete
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- CLUB MEMBERS
CREATE TABLE public.club_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  club_id UUID NOT NULL REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  -- Role: dueño (owner), admin, miembro (member)
  role TEXT NOT NULL DEFAULT 'miembro' CHECK (role IN ('dueño', 'admin', 'miembro')),
  
  -- Status: activo (active), inactivo (skipped a complete book)
  status TEXT NOT NULL DEFAULT 'activo' CHECK (status IN ('activo', 'inactivo')),
  
  -- Activity tracking
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_activity TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Soft delete
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraints
  UNIQUE(club_id, user_id)
);

-- CLUB BOOKS
CREATE TABLE public.club_books (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  club_id UUID NOT NULL REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
  
  -- Book reference (UUID from local Books table)
  book_uuid TEXT NOT NULL,
  
  -- Order in queue (0 = current, 1 = next, 2 = after that, etc.)
  order_position INTEGER NOT NULL DEFAULT 0,
  
  -- Status: propuesto, votando, proximo, activo, completado
  status TEXT NOT NULL DEFAULT 'propuesto' CHECK (status IN ('propuesto', 'votando', 'proximo', 'activo', 'completado')),
  
  -- Section configuration
  section_mode TEXT NOT NULL DEFAULT 'automatico' CHECK (section_mode IN ('automatico', 'manual')),
  total_chapters INTEGER NOT NULL,
  
  -- Sections (tramos) stored as JSONB array
  -- Format: [{"numero": 1, "capitulo_inicio": 1, "capitulo_fin": 3, "fecha_apertura": "2026-02-01", "fecha_cierre": "2026-02-08", "abierto": true}, ...]
  sections JSONB NOT NULL DEFAULT '[]'::jsonb,
  
  -- Dates
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  
  -- Soft delete
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Now add the FK constraint for current_book_id
ALTER TABLE public.reading_clubs
  ADD CONSTRAINT fk_current_book
  FOREIGN KEY (current_book_id)
  REFERENCES public.club_books(id)
  ON DELETE SET NULL;

-- CLUB READING PROGRESS
CREATE TABLE public.club_reading_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  club_id UUID NOT NULL REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
  book_id UUID NOT NULL REFERENCES public.club_books(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  -- Progress status: no_empezado, al_dia, atrasado, terminado
  status TEXT NOT NULL DEFAULT 'no_empezado' CHECK (status IN ('no_empezado', 'al_dia', 'atrasado', 'terminado')),
  
  -- Fine-grained tracking (optional)
  current_chapter INTEGER NOT NULL DEFAULT 0,
  current_section INTEGER NOT NULL DEFAULT 0,
  
  -- Timestamp
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraint: one progress per user per book per club
  UNIQUE(club_id, book_id, user_id)
);

-- BOOK PROPOSALS
CREATE TABLE public.book_proposals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  club_id UUID NOT NULL REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
  
  -- Book reference
  book_uuid TEXT NOT NULL,
  
  -- Proposer
  proposed_by_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  -- Chapter count (ALWAYS manual input)
  total_chapters INTEGER NOT NULL,
  
  -- Voting
  votes UUID[] NOT NULL DEFAULT '{}', -- Array of user_id who voted
  vote_count INTEGER NOT NULL DEFAULT 0,
  
  -- Status: abierta, cerrada, ganadora, descartada
  status TEXT NOT NULL DEFAULT 'abierta' CHECK (status IN ('abierta', 'cerrada', 'ganadora', 'descartada')),
  
  -- Close date (default 7 days from creation, or null for manual close)
  close_date TIMESTAMPTZ,
  
  -- Soft delete
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- SECTION COMMENTS
CREATE TABLE public.section_comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  club_id UUID NOT NULL REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
  book_id UUID NOT NULL REFERENCES public.club_books(id) ON DELETE CASCADE,
  section_number INTEGER NOT NULL,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  -- Comment content
  content TEXT NOT NULL,
  
  -- Moderation
  reports_count INTEGER NOT NULL DEFAULT 0,
  is_hidden BOOLEAN NOT NULL DEFAULT false,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ -- Soft delete via timestamp
);

-- COMMENT REPORTS
CREATE TABLE public.comment_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  comment_id UUID NOT NULL REFERENCES public.section_comments(id) ON DELETE CASCADE,
  reported_by_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reason TEXT,
  
  -- Timestamp
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraint: one report per user per comment
  UNIQUE(comment_id, reported_by_id)
);

-- MODERATION LOGS
CREATE TABLE public.moderation_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  club_id UUID NOT NULL REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
  
  -- Action type
  action TEXT NOT NULL CHECK (action IN ('borrar_comentario', 'expulsar_miembro', 'cerrar_votacion', 'ocultar_comentario')),
  
  -- Who performed the action
  performed_by_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  -- Target (comment_id, member_id, etc.)
  target_id UUID NOT NULL,
  
  -- Optional reason
  reason TEXT,
  
  -- Timestamp
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- STEP 2: CREATE INDEXES
-- ============================================================================

-- Reading clubs
CREATE INDEX idx_reading_clubs_owner ON public.reading_clubs(owner_id) WHERE is_deleted = false;

-- Club members
CREATE INDEX idx_club_members_club ON public.club_members(club_id) WHERE is_deleted = false;
CREATE INDEX idx_club_members_user ON public.club_members(user_id) WHERE is_deleted = false;

-- Club books
CREATE INDEX idx_club_books_club_status ON public.club_books(club_id, status) WHERE is_deleted = false;
CREATE INDEX idx_club_books_order ON public.club_books(club_id, order_position) WHERE is_deleted = false;

-- Reading progress
CREATE INDEX idx_reading_progress_user ON public.club_reading_progress(user_id, club_id);
CREATE INDEX idx_reading_progress_book ON public.club_reading_progress(book_id, status);

-- Book proposals
CREATE INDEX idx_book_proposals_club_status ON public.book_proposals(club_id, status) WHERE is_deleted = false;
CREATE INDEX idx_book_proposals_proposer ON public.book_proposals(proposed_by_id) WHERE is_deleted = false;

-- Section comments
CREATE INDEX idx_section_comments_section ON public.section_comments(book_id, section_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_section_comments_club ON public.section_comments(club_id) WHERE deleted_at IS NULL;

-- Comment reports
CREATE INDEX idx_comment_reports_comment ON public.comment_reports(comment_id);

-- Moderation logs
CREATE INDEX idx_moderation_logs_club ON public.moderation_logs(club_id);

-- ============================================================================
-- STEP 3: ENABLE RLS AND CREATE POLICIES
-- ============================================================================

-- Helper function to check if user is a club member
CREATE OR REPLACE FUNCTION public.check_is_club_member(p_club_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.club_members
    WHERE club_id = p_club_id 
      AND user_id = p_user_id 
      AND is_deleted = false
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Helper function to check if user is a club owner
CREATE OR REPLACE FUNCTION public.check_is_club_owner(p_club_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.reading_clubs
    WHERE id = p_club_id 
      AND owner_id = p_user_id 
      AND is_deleted = false
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Helper function to check if user is a club admin or owner
CREATE OR REPLACE FUNCTION public.check_is_club_admin(p_club_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.club_members
    WHERE club_id = p_club_id 
      AND user_id = p_user_id 
      AND role IN ('dueño', 'admin')
      AND is_deleted = false
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- READING CLUBS
ALTER TABLE public.reading_clubs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "reading_clubs_select"
  ON public.reading_clubs FOR SELECT
  USING (
    (select auth.uid()) IS NULL
    OR owner_id = (select auth.uid())
    OR check_is_club_member(id, (select auth.uid()))
  );

CREATE POLICY "reading_clubs_insert"
  ON public.reading_clubs FOR INSERT
  WITH CHECK ((select auth.uid()) IS NULL OR (select auth.uid()) = owner_id);

CREATE POLICY "reading_clubs_update"
  ON public.reading_clubs FOR UPDATE
  USING ((select auth.uid()) IS NULL OR owner_id = (select auth.uid()));

-- CLUB MEMBERS
ALTER TABLE public.club_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "club_members_select"
  ON public.club_members FOR SELECT
  USING (
    (select auth.uid()) IS NULL
    OR user_id = (select auth.uid())
    OR check_is_club_member(club_id, (select auth.uid()))
  );

CREATE POLICY "club_members_insert"
  ON public.club_members FOR INSERT
  WITH CHECK ((select auth.uid()) IS NULL OR check_is_club_admin(club_id, (select auth.uid())));

CREATE POLICY "club_members_update"
  ON public.club_members FOR UPDATE
  USING ((select auth.uid()) IS NULL OR check_is_club_admin(club_id, (select auth.uid())));

CREATE POLICY "club_members_delete"
  ON public.club_members FOR DELETE
  USING (
    (select auth.uid()) IS NULL 
    OR check_is_club_admin(club_id, (select auth.uid()))
    OR user_id = (select auth.uid()) -- Can leave on their own
  );

-- CLUB BOOKS
ALTER TABLE public.club_books ENABLE ROW LEVEL SECURITY;

CREATE POLICY "club_books_select"
  ON public.club_books FOR SELECT
  USING (
    (select auth.uid()) IS NULL
    OR check_is_club_member(club_id, (select auth.uid()))
  );

CREATE POLICY "club_books_insert"
  ON public.club_books FOR INSERT
  WITH CHECK ((select auth.uid()) IS NULL OR check_is_club_admin(club_id, (select auth.uid())));

CREATE POLICY "club_books_update"
  ON public.club_books FOR UPDATE
  USING ((select auth.uid()) IS NULL OR check_is_club_admin(club_id, (select auth.uid())));

-- CLUB READING PROGRESS
ALTER TABLE public.club_reading_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "club_reading_progress_select"
  ON public.club_reading_progress FOR SELECT
  USING (
    (select auth.uid()) IS NULL
    OR user_id = (select auth.uid())
    OR check_is_club_member(club_id, (select auth.uid()))
  );

CREATE POLICY "club_reading_progress_insert"
  ON public.club_reading_progress FOR INSERT
  WITH CHECK ((select auth.uid()) IS NULL OR user_id = (select auth.uid()));

CREATE POLICY "club_reading_progress_update"
  ON public.club_reading_progress FOR UPDATE
  USING ((select auth.uid()) IS NULL OR user_id = (select auth.uid()));

-- BOOK PROPOSALS
ALTER TABLE public.book_proposals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "book_proposals_select"
  ON public.book_proposals FOR SELECT
  USING (
    (select auth.uid()) IS NULL
    OR check_is_club_member(club_id, (select auth.uid()))
  );

CREATE POLICY "book_proposals_insert"
  ON public.book_proposals FOR INSERT
  WITH CHECK (
    (select auth.uid()) IS NULL 
    OR (
      proposed_by_id = (select auth.uid())
      AND check_is_club_member(club_id, (select auth.uid()))
    )
  );

CREATE POLICY "book_proposals_update"
  ON public.book_proposals FOR UPDATE
  USING (
    (select auth.uid()) IS NULL
    OR check_is_club_member(club_id, (select auth.uid()))
  );

-- SECTION COMMENTS
ALTER TABLE public.section_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "section_comments_select"
  ON public.section_comments FOR SELECT
  USING (
    (select auth.uid()) IS NULL
    OR check_is_club_member(club_id, (select auth.uid()))
  );

CREATE POLICY "section_comments_insert"
  ON public.section_comments FOR INSERT
  WITH CHECK (
    (select auth.uid()) IS NULL
    OR (
      user_id = (select auth.uid())
      AND check_is_club_member(club_id, (select auth.uid()))
    )
  );

CREATE POLICY "section_comments_update"
  ON public.section_comments FOR UPDATE
  USING (
    (select auth.uid()) IS NULL
    OR user_id = (select auth.uid())
    OR check_is_club_admin(club_id, (select auth.uid()))
  );

CREATE POLICY "section_comments_delete"
  ON public.section_comments FOR DELETE
  USING (
    (select auth.uid()) IS NULL
    OR user_id = (select auth.uid())
    OR check_is_club_admin(club_id, (select auth.uid()))
  );

-- COMMENT REPORTS
ALTER TABLE public.comment_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "comment_reports_select"
  ON public.comment_reports FOR SELECT
  USING (
    (select auth.uid()) IS NULL
    OR EXISTS (
      SELECT 1 FROM public.section_comments sc
      WHERE sc.id = comment_id
        AND check_is_club_admin(sc.club_id, (select auth.uid()))
    )
  );

CREATE POLICY "comment_reports_insert"
  ON public.comment_reports FOR INSERT
  WITH CHECK (
    (select auth.uid()) IS NULL
    OR reported_by_id = (select auth.uid())
  );

-- MODERATION LOGS
ALTER TABLE public.moderation_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "moderation_logs_select"
  ON public.moderation_logs FOR SELECT
  USING (
    (select auth.uid()) IS NULL
    OR check_is_club_admin(club_id, (select auth.uid()))
  );

CREATE POLICY "moderation_logs_insert"
  ON public.moderation_logs FOR INSERT
  WITH CHECK ((select auth.uid()) IS NULL OR check_is_club_admin(club_id, (select auth.uid())));

-- ============================================================================
-- STEP 4: CREATE TRIGGERS
-- ============================================================================

-- Apply updated_at trigger to all new tables
CREATE TRIGGER update_reading_clubs_updated_at 
  BEFORE UPDATE ON public.reading_clubs
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_club_members_updated_at 
  BEFORE UPDATE ON public.club_members
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_club_books_updated_at 
  BEFORE UPDATE ON public.club_books
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_book_proposals_updated_at 
  BEFORE UPDATE ON public.book_proposals
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger to auto-hide comments when report threshold is reached
CREATE OR REPLACE FUNCTION public.auto_hide_reported_comments()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_report_count INTEGER;
  v_club_id UUID;
BEGIN
  -- Count reports for this comment
  SELECT COUNT(*), sc.club_id
  INTO v_report_count, v_club_id
  FROM public.comment_reports cr
  JOIN public.section_comments sc ON sc.id = cr.comment_id
  WHERE cr.comment_id = NEW.comment_id
  GROUP BY sc.club_id;

  -- If threshold reached (3 reports), hide the comment
  IF v_report_count >= 3 THEN
    UPDATE public.section_comments
    SET is_hidden = true,
        reports_count = v_report_count
    WHERE id = NEW.comment_id;

    -- Log the auto-hide action
    INSERT INTO public.moderation_logs (
      club_id,
      action,
      performed_by_id,
      target_id,
      reason
    ) VALUES (
      v_club_id,
      'ocultar_comentario',
      NEW.reported_by_id, -- Last reporter
      NEW.comment_id,
      'Auto-hidden after reaching 3 reports'
    );
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_auto_hide_reported_comments
  AFTER INSERT ON public.comment_reports
  FOR EACH ROW EXECUTE FUNCTION public.auto_hide_reported_comments();

-- ============================================================================
-- STEP 5: ADD COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE public.reading_clubs IS 'Book reading clubs with scheduled reading sections';
COMMENT ON TABLE public.club_members IS 'Members of reading clubs with roles and activity tracking';
COMMENT ON TABLE public.club_books IS 'Books being read by clubs, with sections (tramos) configuration';
COMMENT ON TABLE public.club_reading_progress IS 'Personal reading progress for each user in each club book';
COMMENT ON TABLE public.book_proposals IS 'Book proposals submitted by members for voting';
COMMENT ON TABLE public.section_comments IS 'Discussion comments for specific reading sections';
COMMENT ON TABLE public.comment_reports IS 'Reports of inappropriate comments';
COMMENT ON TABLE public.moderation_logs IS 'Audit log of moderation actions';

COMMENT ON COLUMN public.club_books.sections IS 'JSONB array of section objects with: numero, capitulo_inicio, capitulo_fin, fecha_apertura, fecha_cierre, abierto';
COMMENT ON COLUMN public.book_proposals.votes IS 'Array of user_id UUIDs who voted for this proposal';

-- ============================================================================
-- DEPLOYMENT COMPLETE
-- ============================================================================
-- To verify deployment, run:
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE '%club%';
-- ============================================================================
