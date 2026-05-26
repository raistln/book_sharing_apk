-- ============================================================================
-- Book Sharing App - Supabase Sync Hardening v13
-- ============================================================================
-- Objetivo:
-- 1) Endurecer y unificar RLS de discusión de clubes (chat/comentarios/reportes).
-- 2) Añadir limpieza automática para evitar basura en nube.
-- 3) Evitar cronjobs duplicados (reprogramar jobs con nombres estables).
-- ============================================================================

BEGIN;

CREATE EXTENSION IF NOT EXISTS "pg_cron";

-- ---------------------------------------------------------------------------
-- 1) Alineación de estructura para discusión (idempotente)
-- ---------------------------------------------------------------------------

ALTER TABLE IF EXISTS public.section_comments
  ADD COLUMN IF NOT EXISTS club_id UUID REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS parent_id UUID REFERENCES public.section_comments(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS is_spoiler BOOLEAN NOT NULL DEFAULT false;

UPDATE public.section_comments sc
SET club_id = cb.club_id
FROM public.club_books cb
WHERE sc.book_id = cb.id
  AND sc.club_id IS NULL;

-- Si aún no se puede poner NOT NULL (datos legacy incompletos), este bloque no rompe migración.
DO $$
BEGIN
  BEGIN
    ALTER TABLE public.section_comments
      ALTER COLUMN club_id SET NOT NULL;
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'club_id remains nullable due to legacy rows; fix data then enforce NOT NULL.';
  END;
END $$;

ALTER TABLE IF EXISTS public.section_comments
  ALTER COLUMN book_id DROP NOT NULL;

-- ---------------------------------------------------------------------------
-- 2) RLS consistente para discusión de clubes
-- ---------------------------------------------------------------------------

ALTER TABLE IF EXISTS public.section_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.comment_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.moderation_logs ENABLE ROW LEVEL SECURITY;

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

DROP POLICY IF EXISTS "moderation_logs_select" ON public.moderation_logs;
DROP POLICY IF EXISTS "moderation_logs_insert" ON public.moderation_logs;

CREATE POLICY "moderation_logs_select" ON public.moderation_logs
  FOR SELECT USING (internal.check_is_club_member(club_id, (select auth.uid())));

CREATE POLICY "moderation_logs_insert" ON public.moderation_logs
  FOR INSERT WITH CHECK (
    performed_by_user_id = (select auth.uid())
    AND internal.check_is_club_admin(club_id, (select auth.uid()))
  );

-- ---------------------------------------------------------------------------
-- 3) Retención y limpieza (nube)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.cleanup_job_runs (
  id BIGSERIAL PRIMARY KEY,
  job_name TEXT NOT NULL,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at TIMESTAMPTZ,
  rows_deleted BIGINT NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'running',
  error TEXT
);

CREATE INDEX IF NOT EXISTS idx_cleanup_job_runs_job_started
  ON public.cleanup_job_runs(job_name, started_at DESC);

CREATE INDEX IF NOT EXISTS idx_section_comments_deleted_updated
  ON public.section_comments(is_deleted, updated_at);

CREATE INDEX IF NOT EXISTS idx_book_proposals_deleted_status_updated
  ON public.book_proposals(is_deleted, status, updated_at);

CREATE INDEX IF NOT EXISTS idx_comment_reports_created_at
  ON public.comment_reports(created_at);

CREATE INDEX IF NOT EXISTS idx_moderation_logs_created_at
  ON public.moderation_logs(created_at);

-- Soft deletes globales: conservar 90 días
CREATE OR REPLACE FUNCTION public.cleanup_deleted_records_v13()
RETURNS void
SECURITY DEFINER
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  v_run_id BIGINT;
  v_rows BIGINT := 0;
  v_deleted INTEGER := 0;
BEGIN
  INSERT INTO public.cleanup_job_runs (job_name)
  VALUES ('cleanup_deleted_records_v13')
  RETURNING id INTO v_run_id;

  DELETE FROM public.section_comments
  WHERE is_deleted = true
    AND updated_at < NOW() - INTERVAL '90 days';
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  v_rows := v_rows + v_deleted;

  DELETE FROM public.book_proposals
  WHERE is_deleted = true
    AND updated_at < NOW() - INTERVAL '90 days';
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  v_rows := v_rows + v_deleted;

  DELETE FROM public.club_reading_progress
  WHERE is_deleted = true
    AND updated_at < NOW() - INTERVAL '90 days';
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  v_rows := v_rows + v_deleted;

  DELETE FROM public.club_books
  WHERE is_deleted = true
    AND updated_at < NOW() - INTERVAL '90 days';
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  v_rows := v_rows + v_deleted;

  DELETE FROM public.club_members
  WHERE is_deleted = true
    AND updated_at < NOW() - INTERVAL '90 days';
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  v_rows := v_rows + v_deleted;

  DELETE FROM public.reading_clubs
  WHERE is_deleted = true
    AND updated_at < NOW() - INTERVAL '90 days';
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  v_rows := v_rows + v_deleted;

  UPDATE public.cleanup_job_runs
  SET finished_at = NOW(),
      rows_deleted = v_rows,
      status = 'success'
  WHERE id = v_run_id;
EXCEPTION WHEN OTHERS THEN
  UPDATE public.cleanup_job_runs
  SET finished_at = NOW(),
      rows_deleted = v_rows,
      status = 'error',
      error = SQLERRM
  WHERE id = v_run_id;
  RAISE;
END;
$$;

-- Datos efímeros de discusión
CREATE OR REPLACE FUNCTION public.cleanup_club_discussion_data_v13()
RETURNS void
SECURITY DEFINER
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  v_run_id BIGINT;
  v_rows BIGINT := 0;
  v_deleted INTEGER := 0;
BEGIN
  INSERT INTO public.cleanup_job_runs (job_name)
  VALUES ('cleanup_club_discussion_data_v13')
  RETURNING id INTO v_run_id;

  -- Reportes antiguos (incidencias moderación ya resueltas): 180 días
  DELETE FROM public.comment_reports
  WHERE created_at < NOW() - INTERVAL '180 days';
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  v_rows := v_rows + v_deleted;

  -- Logs moderación antiguos: 365 días
  DELETE FROM public.moderation_logs
  WHERE created_at < NOW() - INTERVAL '365 days';
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  v_rows := v_rows + v_deleted;

  -- Propuestas cerradas/descartadas/ganadoras antiguas no borradas: 180 días
  DELETE FROM public.book_proposals
  WHERE is_deleted = false
    AND status IN ('cerrada', 'descartada', 'ganadora')
    AND updated_at < NOW() - INTERVAL '180 days';
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  v_rows := v_rows + v_deleted;

  UPDATE public.cleanup_job_runs
  SET finished_at = NOW(),
      rows_deleted = v_rows,
      status = 'success'
  WHERE id = v_run_id;
EXCEPTION WHEN OTHERS THEN
  UPDATE public.cleanup_job_runs
  SET finished_at = NOW(),
      rows_deleted = v_rows,
      status = 'error',
      error = SQLERRM
  WHERE id = v_run_id;
  RAISE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.cleanup_deleted_records_v13() TO service_role;
GRANT EXECUTE ON FUNCTION public.cleanup_club_discussion_data_v13() TO service_role;

-- ---------------------------------------------------------------------------
-- 4) Cronjobs estables (evitar duplicados)
-- ---------------------------------------------------------------------------

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'cleanup-deleted-v13') THEN
    PERFORM cron.unschedule((SELECT jobid FROM cron.job WHERE jobname = 'cleanup-deleted-v13' LIMIT 1));
  END IF;

  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'cleanup-club-discussion-v13') THEN
    PERFORM cron.unschedule((SELECT jobid FROM cron.job WHERE jobname = 'cleanup-club-discussion-v13' LIMIT 1));
  END IF;
END $$;

SELECT cron.schedule(
  'cleanup-deleted-v13',
  '0 1 * * *',
  $$SELECT public.cleanup_deleted_records_v13()$$
);

SELECT cron.schedule(
  'cleanup-club-discussion-v13',
  '15 1 * * *',
  $$SELECT public.cleanup_club_discussion_data_v13()$$
);

COMMIT;
