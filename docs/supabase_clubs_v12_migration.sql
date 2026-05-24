-- ============================================================================
-- Book Sharing App - Supabase Clubs v12 Migration
-- ============================================================================
-- Adds next meeting details, updates club reading progress constraint, and
-- defines tables for club polls and chronicles.
-- ============================================================================

BEGIN;

-- 1. Add next meeting columns to reading_clubs
ALTER TABLE IF EXISTS public.reading_clubs
  ADD COLUMN IF NOT EXISTS next_meeting_date TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS next_meeting_place TEXT;

-- 2. Modify club_reading_progress unique constraint
-- Drift schema upgrade changed it to be unique on (club_id, book_id, user_id).
-- In supabase_schema_v9_COMPLETE.sql it was UNIQUE(club_id, book_id, user_id),
-- so it is already compatible! However, let's make sure it is exactly that.
-- Just in case, let's re-assert the unique constraint.
ALTER TABLE IF EXISTS public.club_reading_progress
  DROP CONSTRAINT IF EXISTS club_reading_progress_club_id_book_id_user_id_key;

ALTER TABLE IF EXISTS public.club_reading_progress
  ADD CONSTRAINT club_reading_progress_club_id_book_id_user_id_key UNIQUE (club_id, book_id, user_id);

-- 3. Define club_polls table
CREATE TABLE IF NOT EXISTS public.club_polls (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uuid TEXT NOT NULL UNIQUE,
  club_id UUID NOT NULL REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
  creator_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  options JSONB NOT NULL DEFAULT '[]'::jsonb, -- Array of strings/objects
  votes JSONB NOT NULL DEFAULT '{}'::jsonb, -- Map of user_id -> option_index
  is_closed BOOLEAN NOT NULL DEFAULT false,
  expires_at TIMESTAMPTZ,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Define club_chronicles table
CREATE TABLE IF NOT EXISTS public.club_chronicles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uuid TEXT NOT NULL UNIQUE,
  club_id UUID NOT NULL REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
  author_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  shared_book_uuid TEXT, -- Optional associated book reference
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Enable RLS on new tables
ALTER TABLE public.club_polls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.club_chronicles ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies for club_polls
DROP POLICY IF EXISTS "club_polls_select" ON public.club_polls;
DROP POLICY IF EXISTS "club_polls_insert" ON public.club_polls;
DROP POLICY IF EXISTS "club_polls_update" ON public.club_polls;
DROP POLICY IF EXISTS "club_polls_delete" ON public.club_polls;

CREATE POLICY "club_polls_select" ON public.club_polls
  FOR SELECT USING (internal.check_is_club_member(club_id, (select auth.uid())));

CREATE POLICY "club_polls_insert" ON public.club_polls
  FOR INSERT WITH CHECK (
    creator_user_id = (select auth.uid())
    AND internal.check_is_club_member(club_id, (select auth.uid()))
  );

CREATE POLICY "club_polls_update" ON public.club_polls
  FOR UPDATE USING (
    creator_user_id = (select auth.uid())
    OR internal.check_is_club_admin(club_id, (select auth.uid()))
  )
  WITH CHECK (
    creator_user_id = (select auth.uid())
    OR internal.check_is_club_admin(club_id, (select auth.uid()))
  );

CREATE POLICY "club_polls_delete" ON public.club_polls
  FOR DELETE USING (
    creator_user_id = (select auth.uid())
    OR internal.check_is_club_admin(club_id, (select auth.uid()))
  );

-- 7. RLS Policies for club_chronicles
DROP POLICY IF EXISTS "club_chronicles_select" ON public.club_chronicles;
DROP POLICY IF EXISTS "club_chronicles_insert" ON public.club_chronicles;
DROP POLICY IF EXISTS "club_chronicles_update" ON public.club_chronicles;
DROP POLICY IF EXISTS "club_chronicles_delete" ON public.club_chronicles;

CREATE POLICY "club_chronicles_select" ON public.club_chronicles
  FOR SELECT USING (internal.check_is_club_member(club_id, (select auth.uid())));

CREATE POLICY "club_chronicles_insert" ON public.club_chronicles
  FOR INSERT WITH CHECK (
    author_user_id = (select auth.uid())
    AND internal.check_is_club_member(club_id, (select auth.uid()))
  );

CREATE POLICY "club_chronicles_update" ON public.club_chronicles
  FOR UPDATE USING (
    author_user_id = (select auth.uid())
    OR internal.check_is_club_admin(club_id, (select auth.uid()))
  )
  WITH CHECK (
    author_user_id = (select auth.uid())
    OR internal.check_is_club_admin(club_id, (select auth.uid()))
  );

CREATE POLICY "club_chronicles_delete" ON public.club_chronicles
  FOR DELETE USING (
    author_user_id = (select auth.uid())
    OR internal.check_is_club_admin(club_id, (select auth.uid()))
  );

-- 8. Add triggers for updated_at
CREATE TRIGGER update_club_polls_at BEFORE UPDATE ON public.club_polls FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_club_chronicles_at BEFORE UPDATE ON public.club_chronicles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMIT;
