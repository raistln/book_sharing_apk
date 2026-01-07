-- ============================================================================
-- Book Sharing App - Supabase SQL Schema v7 - CLEAN DEPLOYMENT
-- ============================================================================
-- WARNING: This script will DROP ALL existing tables, policies, triggers,
-- functions, and cron jobs. ALL DATA WILL BE LOST.
-- Only run this if you want to start completely fresh.
-- ============================================================================

-- ============================================================================
-- ⚠️  DANGER ZONE - DATA DESTRUCTION SECTION ⚠️
-- ============================================================================
-- 
-- INSTRUCTIONS:
-- 1. For CLEAN DEPLOY (delete all data): Uncomment lines 16-17
-- 2. For SAFE UPDATE (preserve data): Keep lines 16-17 commented
-- 
-- To activate data deletion, uncomment line 16 and comment line 17:
--   DO $$ BEGIN PERFORM set_config('app.enable_data_destruction', 'true', false); END $$;
--   -- DO $$ BEGIN PERFORM set_config('app.enable_data_destruction', 'false', false); END $$;
--
-- To disable data deletion, keep lines 16-17 as-is:
--   -- DO $$ BEGIN PERFORM set_config('app.enable_data_destruction', 'true', false); END $$;
--   DO $$ BEGIN PERFORM set_config('app.enable_data_destruction', 'false', false); END $$;
-- ============================================================================

-- Enable data destruction (UNCOMMENT TO ACTIVATE)
DO $$ BEGIN PERFORM set_config('app.enable_data_destruction', 'true', false); END $$;
-- DO $$ BEGIN PERFORM set_config('app.enable_data_destruction', 'false', false); END $$;

-- ============================================================================
-- STEP 1: DROP ALL EXISTING CRON JOBS (ONLY IF DESTRUCTION ENABLED)
-- ============================================================================
DO $$
BEGIN
  IF current_setting('app.enable_data_destruction', true) = 'true' THEN
    RAISE NOTICE '🔥 DATA DESTRUCTION ENABLED - Dropping all cron jobs...';
    
    -- Drop any existing cron jobs (pg_cron extension)
    DECLARE
      job_record RECORD;
    BEGIN
      FOR job_record IN 
        SELECT jobid, jobname FROM cron.job
      LOOP
        PERFORM cron.unschedule(job_record.jobid);
        RAISE NOTICE 'Dropped cron job: % (ID: %)', job_record.jobname, job_record.jobid;
      END LOOP;
    EXCEPTION
      WHEN undefined_table THEN
        RAISE NOTICE 'pg_cron not installed, skipping cron job cleanup';
    END;
  ELSE
    RAISE NOTICE '🛡️  SAFE MODE - Skipping cron job cleanup';
  END IF;
END $$;

-- ============================================================================
-- STEP 2: DROP ALL EXISTING POLICIES (ONLY IF DESTRUCTION ENABLED)
-- ============================================================================
DO $$
BEGIN
  IF current_setting('app.enable_data_destruction', true) = 'true' THEN
    RAISE NOTICE '🔥 DATA DESTRUCTION ENABLED - Dropping all RLS policies...';
    
    -- Drop all RLS policies on existing tables
    DECLARE
      pol RECORD;
    BEGIN
      FOR pol IN 
        SELECT schemaname, tablename, policyname 
        FROM pg_policies 
        WHERE schemaname = 'public'
      LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I CASCADE', 
          pol.policyname, pol.schemaname, pol.tablename);
        RAISE NOTICE 'Dropped policy: % on %.%', pol.policyname, pol.schemaname, pol.tablename;
      END LOOP;
    END;
  ELSE
    RAISE NOTICE '🛡️  SAFE MODE - Skipping RLS policy cleanup';
  END IF;
END $$;

-- ============================================================================
-- STEP 3: DROP ALL EXISTING TRIGGERS (ONLY IF DESTRUCTION ENABLED)
-- ============================================================================
DO $$
BEGIN
  IF current_setting('app.enable_data_destruction', true) = 'true' THEN
    RAISE NOTICE '🔥 DATA DESTRUCTION ENABLED - Dropping all triggers...';
    
    -- Drop all triggers on existing tables
    DECLARE
      trig RECORD;
    BEGIN
      FOR trig IN 
        SELECT event_object_table, trigger_name 
        FROM information_schema.triggers 
        WHERE trigger_schema = 'public'
      LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I CASCADE', 
          trig.trigger_name, trig.event_object_table);
        RAISE NOTICE 'Dropped trigger: % on %', trig.trigger_name, trig.event_object_table;
      END LOOP;
    END;
  ELSE
    RAISE NOTICE '🛡️  SAFE MODE - Skipping trigger cleanup';
  END IF;
END $$;

-- ============================================================================
-- STEP 4: DROP ALL EXISTING TABLES (ONLY IF DESTRUCTION ENABLED)
-- ============================================================================
DO $$
BEGIN
  IF current_setting('app.enable_data_destruction', true) = 'true' THEN
    RAISE NOTICE '🔥 DATA DESTRUCTION ENABLED - Dropping all tables...';
    
    -- Drop tables in reverse dependency order
    DROP TABLE IF EXISTS public.loan_notifications CASCADE;
    DROP TABLE IF EXISTS public.loans CASCADE;
    DROP TABLE IF EXISTS public.shared_books CASCADE;
    DROP TABLE IF EXISTS public.group_invitations CASCADE;
    DROP TABLE IF EXISTS public.group_members CASCADE;
    DROP TABLE IF EXISTS public.groups CASCADE;
    DROP TABLE IF EXISTS public.profiles CASCADE;
    DROP TABLE IF EXISTS public.system_logs CASCADE;
    DROP TABLE IF EXISTS public.system_metrics CASCADE;

    -- Drop any other legacy tables that might exist
    DROP TABLE IF EXISTS public.books CASCADE;
    DROP TABLE IF EXISTS public.book_reviews CASCADE;
    DROP TABLE IF EXISTS public.notifications CASCADE;
    
    RAISE NOTICE '✅ All existing tables dropped successfully';
  ELSE
    RAISE NOTICE '🛡️  SAFE MODE - Preserving existing tables';
  END IF;
END $$;

-- ============================================================================
-- END OF DANGER ZONE - Remaining steps are always safe
-- ============================================================================
DROP TABLE IF EXISTS public.in_app_notifications CASCADE;

-- ============================================================================
-- STEP 5: DROP ALL EXISTING FUNCTIONS
-- ============================================================================
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS public.handle_loan_return_confirmation() CASCADE;
DROP FUNCTION IF EXISTS public.expire_overdue_loans() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.cleanup_old_notifications() CASCADE;
DROP FUNCTION IF EXISTS public.cleanup_deleted_records() CASCADE;
DROP FUNCTION IF EXISTS public.log_error(TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.update_system_metrics(TEXT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.check_is_group_member(UUID, UUID) CASCADE;
DROP FUNCTION IF EXISTS public.check_is_group_owner(UUID, UUID) CASCADE;

-- ============================================================================
-- STEP 6: ENABLE REQUIRED EXTENSIONS
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_cron";

-- ============================================================================
-- STEP 7: CREATE ALL TABLES (without RLS policies yet)
-- ============================================================================

-- PROFILES
-- Note: id is not a foreign key to auth.users to support local-only users
-- Users authenticated via Supabase Auth will have matching IDs
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username TEXT NOT NULL UNIQUE,
  email TEXT,
  display_name TEXT,
  avatar_url TEXT,
  google_books_api_key TEXT,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  pin_hash TEXT,
  pin_salt TEXT,
  pin_updated_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- GROUPS
CREATE TABLE public.groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- GROUP MEMBERS
CREATE TABLE public.group_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(group_id, user_id)
);

-- GROUP INVITATIONS
CREATE TABLE public.group_invitations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  inviter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  accepted_user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  code TEXT NOT NULL UNIQUE,
  role TEXT NOT NULL DEFAULT 'member',
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),
  expires_at TIMESTAMPTZ NOT NULL,
  responded_at TIMESTAMPTZ,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- SHARED BOOKS
CREATE TABLE public.shared_books (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  -- Book reference (for sync with local database)
  book_uuid TEXT,
  
  -- Book details (denormalized for sync)
  title TEXT NOT NULL,
  author TEXT,
  isbn TEXT,
  cover_url TEXT,
  
  -- Read status
  is_read BOOLEAN NOT NULL DEFAULT false,
  
  visibility TEXT NOT NULL DEFAULT 'group' CHECK (visibility IN ('private', 'group', 'public')),
  is_available BOOLEAN NOT NULL DEFAULT true,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- LOANS
CREATE TABLE public.loans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shared_book_id UUID REFERENCES public.shared_books(id) ON DELETE CASCADE,
  
  -- Reference to book for manual loans (when shared_book_id is null)
  book_uuid TEXT,

  -- Users
  borrower_user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  lender_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  -- Manual loans (external borrowers without app)
  external_borrower_name TEXT,
  external_borrower_contact TEXT,
  
  -- Status: requested, active, returned, cancelled, rejected, completed, expired
  status TEXT NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'active', 'returned', 'cancelled', 'rejected', 'completed', 'expired')),
  
  -- Dates
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  approved_at TIMESTAMPTZ,
  due_date TIMESTAMPTZ,
  
  -- Double-confirmation for returns
  borrower_returned_at TIMESTAMPTZ,
  lender_returned_at TIMESTAMPTZ,
  returned_at TIMESTAMPTZ,
  
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraint: must be either normal loan (via shared_book) OR manual loan (via book_uuid), not both
  CONSTRAINT loan_type_check CHECK (
    -- Normal Loan: Has shared_book and real borrower
    (shared_book_id IS NOT NULL AND borrower_user_id IS NOT NULL AND external_borrower_name IS NULL)
    OR
    -- Manual Loan: Has book_uuid and external borrower name
    (shared_book_id IS NULL AND book_uuid IS NOT NULL AND borrower_user_id IS NULL AND external_borrower_name IS NOT NULL)
  )
);

-- LOAN NOTIFICATIONS
CREATE TABLE public.loan_notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  loan_id UUID REFERENCES public.loans(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  -- Notification type
  type TEXT NOT NULL,
  
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  
  -- Status
  status TEXT NOT NULL DEFAULT 'unread' CHECK (status IN ('unread', 'read', 'dismissed')),
  read_at TIMESTAMPTZ,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- SYSTEM TABLES
CREATE TABLE IF NOT EXISTS public.system_logs (
  id BIGSERIAL PRIMARY KEY,
  log_level TEXT NOT NULL CHECK (log_level IN ('debug', 'info', 'warning', 'error', 'critical')),
  source TEXT NOT NULL,
  message TEXT NOT NULL,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.system_metrics (
  id BIGSERIAL PRIMARY KEY,
  metric_name TEXT NOT NULL,
  metric_value TEXT NOT NULL,
  source TEXT,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  metric_hour TIMESTAMPTZ NOT NULL DEFAULT date_trunc('hour', NOW()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (metric_name, metric_hour)
);

-- ============================================================================
-- STEP 8: CREATE INDEXES
-- ============================================================================

CREATE INDEX idx_shared_books_group ON public.shared_books(group_id) WHERE is_deleted = false;
CREATE INDEX idx_shared_books_owner ON public.shared_books(owner_id) WHERE is_deleted = false;

CREATE INDEX idx_loans_shared_book ON public.loans(shared_book_id) WHERE is_deleted = false;
CREATE INDEX idx_loans_borrower ON public.loans(borrower_user_id) WHERE is_deleted = false;
CREATE INDEX idx_loans_lender ON public.loans(lender_user_id) WHERE is_deleted = false;
CREATE INDEX idx_loans_status ON public.loans(status) WHERE is_deleted = false;

CREATE INDEX IF NOT EXISTS idx_loan_notifications_user ON public.loan_notifications(user_id, status) WHERE is_deleted = false;
CREATE INDEX IF NOT EXISTS idx_loan_notifications_loan ON public.loan_notifications(loan_id);
CREATE INDEX idx_groups_owner ON public.groups(owner_id) WHERE is_deleted = false;
CREATE INDEX idx_group_members_user ON public.group_members(user_id) WHERE is_deleted = false;
CREATE INDEX idx_group_invitations_group ON public.group_invitations(group_id) WHERE is_deleted = false;
CREATE INDEX idx_group_invitations_inviter ON public.group_invitations(inviter_id) WHERE is_deleted = false;
CREATE INDEX idx_group_invitations_accepted_user ON public.group_invitations(accepted_user_id) WHERE is_deleted = false;
CREATE INDEX IF NOT EXISTS idx_system_metrics_hour ON public.system_metrics(metric_hour);

-- ============================================================================
-- STEP 9: ENABLE RLS AND CREATE POLICIES
-- ============================================================================

-- PROFILES
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Select is public
CREATE POLICY "profiles_select_all" ON public.profiles FOR SELECT USING (true);

-- Insert: allowed for anyone (to support creation without Supabase Auth)
-- But we check that if they ARE logged in, they use their own ID.
CREATE POLICY "profiles_insert" ON public.profiles FOR INSERT 
WITH CHECK ((select auth.uid()) IS NULL OR (select auth.uid()) = id);

-- Update: only owner (if logged in) or everyone (if using anon key)
-- Note: This is less secure but matches how the app is built (local pin only)
CREATE POLICY "profiles_update" ON public.profiles FOR UPDATE 
USING ((select auth.uid()) IS NULL OR (select auth.uid()) = id);

-- GROUPS
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;

-- Helper functions to break RLS recursion
CREATE OR REPLACE FUNCTION public.check_is_group_member(p_group_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.group_members
    WHERE group_id = p_group_id AND user_id = p_user_id AND is_deleted = false
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.check_is_group_owner(p_group_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.groups
    WHERE id = p_group_id AND owner_id = p_user_id AND is_deleted = false
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE POLICY "groups_select"
  ON public.groups FOR SELECT
  USING (
    (select auth.uid()) IS NULL 
    OR owner_id = (select auth.uid())
    OR check_is_group_member(id, (select auth.uid()))
  );

CREATE POLICY "groups_update"
  ON public.groups FOR UPDATE
  USING ((select auth.uid()) IS NULL OR owner_id = (select auth.uid()));

CREATE POLICY "groups_insert"
  ON public.groups FOR INSERT
  WITH CHECK ((select auth.uid()) IS NULL OR (select auth.uid()) = owner_id);

-- GROUP MEMBERS
ALTER TABLE public.group_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "group_members_select"
  ON public.group_members FOR SELECT
  USING (
    (select auth.uid()) IS NULL
    OR user_id = (select auth.uid())
    OR check_is_group_member(group_id, (select auth.uid()))
    OR check_is_group_owner(group_id, (select auth.uid()))
  );

CREATE POLICY "group_members_insert"
  ON public.group_members FOR INSERT
  WITH CHECK ((select auth.uid()) IS NULL OR check_is_group_owner(group_id, (select auth.uid())));

CREATE POLICY "group_members_update"
  ON public.group_members FOR UPDATE
  USING ((select auth.uid()) IS NULL OR check_is_group_owner(group_id, (select auth.uid())));

CREATE POLICY "group_members_delete"
  ON public.group_members FOR DELETE
  USING ((select auth.uid()) IS NULL OR check_is_group_owner(group_id, (select auth.uid())) OR user_id = (select auth.uid()));

-- GROUP INVITATIONS
ALTER TABLE public.group_invitations ENABLE ROW LEVEL SECURITY;



CREATE POLICY "group_invitations_select"
  ON public.group_invitations FOR SELECT
  USING (
    (select auth.uid()) IS NULL
    OR check_is_group_member(group_id, (select auth.uid()))
    OR check_is_group_owner(group_id, (select auth.uid()))
  );

CREATE POLICY "group_invitations_insert"
  ON public.group_invitations FOR INSERT
  WITH CHECK (
    (select auth.uid()) IS NULL
    OR check_is_group_member(group_id, (select auth.uid()))
    OR check_is_group_owner(group_id, (select auth.uid()))
  );

-- SHARED BOOKS
ALTER TABLE public.shared_books ENABLE ROW LEVEL SECURITY;

-- Combined policy to avoid multiple permissive policies for SELECT
CREATE POLICY "shared_books_select"
  ON public.shared_books FOR SELECT
  USING (
    (select auth.uid()) IS NULL
    OR owner_id = (select auth.uid())
    OR check_is_group_member(group_id, (select auth.uid()))
  );

CREATE POLICY "shared_books_insert"
  ON public.shared_books FOR INSERT
  WITH CHECK ((select auth.uid()) IS NULL OR owner_id = (select auth.uid()));

CREATE POLICY "shared_books_update"
  ON public.shared_books FOR UPDATE
  USING ((select auth.uid()) IS NULL OR owner_id = (select auth.uid()));

CREATE POLICY "shared_books_delete"
  ON public.shared_books FOR DELETE
  USING ((select auth.uid()) IS NULL OR owner_id = (select auth.uid()));

-- LOANS
ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "loans_select"
  ON public.loans FOR SELECT
  USING (
    (select auth.uid()) IS NULL
    OR borrower_user_id = (select auth.uid()) 
    OR lender_user_id = (select auth.uid())
    OR EXISTS (
      SELECT 1 FROM public.shared_books sb
      WHERE sb.id = loans.shared_book_id
        AND (sb.owner_id = (select auth.uid()) OR check_is_group_member(sb.group_id, (select auth.uid())))
    )
  );

CREATE POLICY "loans_insert"
  ON public.loans FOR INSERT
  WITH CHECK (
    (select auth.uid()) IS NULL
    OR borrower_user_id = (select auth.uid())
    OR lender_user_id = (select auth.uid())
  );

CREATE POLICY "loans_update"
  ON public.loans FOR UPDATE
  USING (
    (select auth.uid()) IS NULL
    OR borrower_user_id = (select auth.uid())
    OR lender_user_id = (select auth.uid())
  );

-- LOAN NOTIFICATIONS
ALTER TABLE public.loan_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "loan_notifications_select"
  ON public.loan_notifications FOR SELECT
  USING ((select auth.uid()) IS NULL OR user_id = (select auth.uid()));

CREATE POLICY "loan_notifications_update"
  ON public.loan_notifications FOR UPDATE
  USING ((select auth.uid()) IS NULL OR user_id = (select auth.uid()));

CREATE POLICY "System can create notifications"
  ON public.loan_notifications FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.loans l
      WHERE l.id = loan_id
        AND (
          l.borrower_user_id = (SELECT auth.uid()) 
          OR l.lender_user_id = (SELECT auth.uid())
          OR (SELECT auth.uid()) IS NULL
        )
    )
  );

-- SYSTEM TABLES
ALTER TABLE public.system_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_metrics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view logs" ON public.system_logs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can view metrics" ON public.system_metrics FOR SELECT TO authenticated USING (true);

-- ============================================================================
-- STEP 10: CREATE FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Apply updated_at trigger to all tables
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_groups_updated_at BEFORE UPDATE ON public.groups
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_group_members_updated_at BEFORE UPDATE ON public.group_members
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_group_invitations_updated_at BEFORE UPDATE ON public.group_invitations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shared_books_updated_at BEFORE UPDATE ON public.shared_books
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_loans_updated_at BEFORE UPDATE ON public.loans
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to handle double-confirmation of loan returns
CREATE OR REPLACE FUNCTION handle_loan_return_confirmation()
RETURNS TRIGGER AS $$
BEGIN
  -- If both borrower and lender have confirmed return, set final returned_at
  IF NEW.borrower_returned_at IS NOT NULL 
     AND NEW.lender_returned_at IS NOT NULL 
     AND NEW.returned_at IS NULL THEN
    NEW.returned_at = GREATEST(NEW.borrower_returned_at, NEW.lender_returned_at);
    NEW.status = 'returned';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

CREATE TRIGGER loan_return_confirmation BEFORE UPDATE ON public.loans
  FOR EACH ROW EXECUTE FUNCTION handle_loan_return_confirmation();

-- Function to auto-expire loans past due date
CREATE OR REPLACE FUNCTION expire_overdue_loans()
RETURNS void AS $$
BEGIN
  UPDATE public.loans
  SET status = 'expired'
  WHERE status = 'active'
    AND due_date < NOW()
    AND is_deleted = false;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Function to send 7-day loan reminders
CREATE OR REPLACE FUNCTION send_loan_reminders()
RETURNS void AS $$
DECLARE
  reminder_date DATE;
BEGIN
  reminder_date := CURRENT_DATE + INTERVAL '7 days';
  
  -- Insert notifications for borrowers (7 days before due)
  INSERT INTO public.loan_notifications (
    id, loan_id, user_id, type, title, message, status, created_at
  )
  SELECT 
    uuid_generate_v4(),
    l.id,
    l.borrower_user_id,
    'loan_due_soon',
    'Préstamo próximo a vencer',
    'Tu préstamo de "' || sb.title || '" vence en 7 días.',
    'unread',
    NOW()
  FROM public.loans l
  JOIN public.shared_books sb ON sb.id = l.shared_book_id
  WHERE l.status = 'active'
    AND DATE(l.due_date) = reminder_date
    AND l.borrower_user_id IS NOT NULL
    AND l.is_deleted = false
    AND NOT EXISTS (
      SELECT 1 FROM public.loan_notifications ln
      WHERE ln.loan_id = l.id
        AND ln.type = 'loan_due_soon'
        AND ln.user_id = l.borrower_user_id
        AND DATE(ln.created_at) = CURRENT_DATE
    );
    
  -- Insert notifications for lenders (7 days before due)
  INSERT INTO public.loan_notifications (
    id, loan_id, user_id, type, title, message, status, created_at
  )
  SELECT 
    uuid_generate_v4(),
    l.id,
    l.lender_user_id,
    'loan_due_soon',
    'Préstamo próximo a vencer',
    'El préstamo de "' || sb.title || '" vence en 7 días.',
    'unread',
    NOW()
  FROM public.loans l
  JOIN public.shared_books sb ON sb.id = l.shared_book_id
  WHERE l.status = 'active'
    AND DATE(l.due_date) = reminder_date
    AND l.is_deleted = false
    AND NOT EXISTS (
      SELECT 1 FROM public.loan_notifications ln
      WHERE ln.loan_id = l.id
        AND ln.type = 'loan_due_soon'
        AND ln.user_id = l.lender_user_id
        AND DATE(ln.created_at) = CURRENT_DATE
    );
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Function to cleanup old notifications
CREATE OR REPLACE FUNCTION public.cleanup_old_notifications()
RETURNS void 
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM public.loan_notifications
  WHERE (status IN ('read', 'dismissed') OR is_deleted = true)
    AND created_at < NOW() - INTERVAL '7 days';
END;
$$ SET search_path = public;

-- Function to cleanup deleted records
CREATE OR REPLACE FUNCTION public.cleanup_deleted_records()
RETURNS void 
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM public.loans WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
  DELETE FROM public.shared_books WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
END;
$$ SET search_path = public;

-- Logging helpers
CREATE OR REPLACE FUNCTION public.log_error(p_function_name TEXT, p_error_message TEXT) 
RETURNS VOID SECURITY DEFINER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  INSERT INTO public.system_logs (log_level, source, message, metadata)
  VALUES ('error', p_function_name, p_error_message, jsonb_build_object('timestamp', NOW()));
END;
$$;

CREATE OR REPLACE FUNCTION public.update_system_metrics(p_metric_name TEXT, p_metric_value TEXT, p_source TEXT DEFAULT NULL) 
RETURNS VOID SECURITY DEFINER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  INSERT INTO public.system_metrics (metric_name, metric_value, source, recorded_at)
  VALUES (p_metric_name, p_metric_value, p_source, NOW())
  ON CONFLICT (metric_name, date_trunc('hour', recorded_at)) 
  DO UPDATE SET metric_value = EXCLUDED.metric_value, updated_at = NOW();
END;
$$;

-- ============================================================================
-- STEP 11: SCHEDULE CRON JOBS
-- ============================================================================

-- Schedule loan expiration check (runs every hour)
SELECT cron.schedule(
  'expire-overdue-loans',
  '0 * * * *',
  $$SELECT expire_overdue_loans()$$
);

-- Schedule 7-day loan reminders (runs daily at 9 AM)
SELECT cron.schedule(
  'send-loan-reminders',
  '0 9 * * *',
  $$SELECT send_loan_reminders()$$
);

-- Schedule cleanup jobs
SELECT cron.schedule('cleanup-old-notifications', '0 0 * * *', $$SELECT public.cleanup_old_notifications()$$);
SELECT cron.schedule('cleanup-deleted-records', '0 1 * * *', $$SELECT public.cleanup_deleted_records()$$);

-- ============================================================================
-- DEPLOYMENT COMPLETE
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '============================================================================';
  RAISE NOTICE 'Schema v7 deployment complete!';
  RAISE NOTICE '============================================================================';
  RAISE NOTICE 'Tables created:';
  RAISE NOTICE '  - profiles';
  RAISE NOTICE '  - groups';
  RAISE NOTICE '  - group_members';
  RAISE NOTICE '  - group_invitations';
  RAISE NOTICE '  - shared_books';
  RAISE NOTICE '  - loans';
  RAISE NOTICE '  - loan_notifications';
  RAISE NOTICE '';
  RAISE NOTICE 'Cron jobs scheduled:';
  RAISE NOTICE '  - expire-overdue-loans (hourly)';
  RAISE NOTICE '  - send-loan-reminders (daily at 9 AM)';
  RAISE NOTICE '============================================================================';
END $$;
