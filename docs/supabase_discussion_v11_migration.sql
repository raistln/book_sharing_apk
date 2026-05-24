-- ============================================================================
-- Book Sharing App - Supabase Discussion v11 Migration
-- ============================================================================
-- Adds support for general club chat, threaded replies, and spoiler flags.
-- ============================================================================

BEGIN;

-- 1. Add new columns to section_comments
ALTER TABLE IF EXISTS public.section_comments
  ADD COLUMN IF NOT EXISTS club_id UUID REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS parent_id UUID REFERENCES public.section_comments(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS is_spoiler BOOLEAN NOT NULL DEFAULT false;

-- 2. Populate club_id for existing comments based on book_id
UPDATE public.section_comments sc
SET club_id = cb.club_id
FROM public.club_books cb
WHERE sc.book_id = cb.id AND sc.club_id IS NULL;

-- 3. Make club_id NOT NULL
ALTER TABLE IF EXISTS public.section_comments
  ALTER COLUMN club_id SET NOT NULL;

-- 4. Make book_id nullable to allow general club chat
ALTER TABLE IF EXISTS public.section_comments
  ALTER COLUMN book_id DROP NOT NULL;

-- 5. Update section_comments RLS policies to use club_id directly
DROP POLICY IF EXISTS "section_comments_select" ON public.section_comments;
DROP POLICY IF EXISTS "section_comments_insert" ON public.section_comments;
DROP POLICY IF EXISTS "section_comments_update" ON public.section_comments;
DROP POLICY IF EXISTS "section_comments_delete" ON public.section_comments;

CREATE POLICY "section_comments_select" ON public.section_comments
  FOR SELECT USING (internal.check_is_club_member(club_id, (select auth.uid())));

CREATE POLICY "section_comments_insert" ON public.section_comments
  FOR INSERT WITH CHECK (
    author_user_id = (select auth.uid())
    AND internal.check_is_club_member(club_id, (select auth.uid()))
  );

CREATE POLICY "section_comments_update" ON public.section_comments
  FOR UPDATE USING (
    author_user_id = (select auth.uid())
    OR internal.check_is_club_admin(club_id, (select auth.uid()))
  )
  WITH CHECK (
    author_user_id = (select auth.uid())
    OR internal.check_is_club_admin(club_id, (select auth.uid()))
  );

CREATE POLICY "section_comments_delete" ON public.section_comments
  FOR DELETE USING (
    author_user_id = (select auth.uid())
    OR internal.check_is_club_admin(club_id, (select auth.uid()))
  );

-- 6. Update comment_reports RLS policies to use club_id via section_comments instead of club_books
DROP POLICY IF EXISTS "comment_reports_select" ON public.comment_reports;
DROP POLICY IF EXISTS "comment_reports_insert" ON public.comment_reports;
DROP POLICY IF EXISTS "comment_reports_delete" ON public.comment_reports;

CREATE POLICY "comment_reports_select" ON public.comment_reports
  FOR SELECT USING (
    EXISTS (
      SELECT 1
      FROM public.section_comments sc
      WHERE sc.id = comment_reports.comment_id
        AND internal.check_is_club_member(sc.club_id, (select auth.uid()))
    )
  );

CREATE POLICY "comment_reports_insert" ON public.comment_reports
  FOR INSERT WITH CHECK (
    reported_by_user_id = (select auth.uid())
    AND EXISTS (
      SELECT 1
      FROM public.section_comments sc
      WHERE sc.id = comment_id
        AND internal.check_is_club_member(sc.club_id, (select auth.uid()))
    )
  );

CREATE POLICY "comment_reports_delete" ON public.comment_reports
  FOR DELETE USING (
    reported_by_user_id = (select auth.uid())
    OR EXISTS (
      SELECT 1
      FROM public.section_comments sc
      WHERE sc.id = comment_reports.comment_id
        AND internal.check_is_club_admin(sc.club_id, (select auth.uid()))
    )
  );

COMMIT;
