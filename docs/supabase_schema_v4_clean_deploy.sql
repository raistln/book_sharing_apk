-- ============================================================================
-- Book Sharing App - Supabase SQL Schema v5 - CLEAN DEPLOYMENT
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
  shared_book_id UUID NOT NULL REFERENCES public.shared_books(id) ON DELETE CASCADE,
  
  -- Users
  borrower_user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  lender_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  -- Manual loans (external borrowers without app)
  external_borrower_name TEXT,
  external_borrower_contact TEXT,
  
  -- Status: requested, active, returned, expired
  status TEXT NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'active', 'returned', 'expired')),
  
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
  
  -- Constraint: must be either normal loan OR manual loan, not both
  CONSTRAINT loan_type_check CHECK (
    (borrower_user_id IS NOT NULL AND external_borrower_name IS NULL)
    OR
    (borrower_user_id IS NULL AND external_borrower_name IS NOT NULL)
  )
);

-- LOAN NOTIFICATIONS
CREATE TABLE public.loan_notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  loan_id UUID NOT NULL REFERENCES public.loans(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  -- Notification type
  type TEXT NOT NULL CHECK (type IN (
    'loan_requested',
    'loan_approved',
    'loan_rejected',
    'loan_cancelled',
    'loan_due_soon',
    'loan_overdue',
    'borrower_returned',
    'lender_returned',
    'return_completed',
    'loan_expired'
  )),
  
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  
  -- Status
  status TEXT NOT NULL DEFAULT 'unread' CHECK (status IN ('unread', 'read', 'dismissed')),
  read_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
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

CREATE INDEX idx_loan_notifications_user ON public.loan_notifications(user_id, status);
CREATE INDEX idx_loan_notifications_loan ON public.loan_notifications(loan_id);

-- ============================================================================
-- STEP 9: ENABLE RLS AND CREATE POLICIES
-- ============================================================================

-- PROFILES
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all profiles"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- GROUPS
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view groups they are members of"
  ON public.groups FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.group_members
      WHERE group_members.group_id = groups.id
        AND group_members.user_id = auth.uid()
        AND group_members.is_deleted = false
    )
  );

CREATE POLICY "Group owners can update their groups"
  ON public.groups FOR UPDATE
  USING (owner_id = auth.uid());

CREATE POLICY "Authenticated users can create groups"
  ON public.groups FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- GROUP MEMBERS
ALTER TABLE public.group_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view members of their groups"
  ON public.group_members FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.group_members gm
      WHERE gm.group_id = group_members.group_id
        AND gm.user_id = auth.uid()
        AND gm.is_deleted = false
    )
  );

CREATE POLICY "Group owners can manage members"
  ON public.group_members FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.groups
      WHERE groups.id = group_members.group_id
        AND groups.owner_id = auth.uid()
    )
  );

-- GROUP INVITATIONS
ALTER TABLE public.group_invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view invitations for their groups"
  ON public.group_invitations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.group_members
      WHERE group_members.group_id = group_invitations.group_id
        AND group_members.user_id = auth.uid()
        AND group_members.is_deleted = false
    )
  );

CREATE POLICY "Group members can create invitations"
  ON public.group_invitations FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.group_members
      WHERE group_members.group_id = group_invitations.group_id
        AND group_members.user_id = auth.uid()
        AND group_members.is_deleted = false
    )
  );

-- SHARED BOOKS
ALTER TABLE public.shared_books ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view shared books in their groups"
  ON public.shared_books FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.group_members
      WHERE group_members.group_id = shared_books.group_id
        AND group_members.user_id = auth.uid()
        AND group_members.is_deleted = false
    )
  );

CREATE POLICY "Users can manage their own shared books"
  ON public.shared_books FOR ALL
  USING (owner_id = auth.uid());

-- LOANS
ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view loans they are involved in"
  ON public.loans FOR SELECT
  USING (
    borrower_user_id = auth.uid() 
    OR lender_user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.group_members gm
      JOIN public.shared_books sb ON sb.group_id = gm.group_id
      WHERE sb.id = loans.shared_book_id
        AND gm.user_id = auth.uid()
        AND gm.is_deleted = false
    )
  );

CREATE POLICY "Users can create loans for books in their groups"
  ON public.loans FOR INSERT
  WITH CHECK (
    borrower_user_id = auth.uid()
    OR lender_user_id = auth.uid()
  );

CREATE POLICY "Users can update their own loans"
  ON public.loans FOR UPDATE
  USING (
    borrower_user_id = auth.uid()
    OR lender_user_id = auth.uid()
  );

-- LOAN NOTIFICATIONS
ALTER TABLE public.loan_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications"
  ON public.loan_notifications FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can update their own notifications"
  ON public.loan_notifications FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "System can create notifications"
  ON public.loan_notifications FOR INSERT
  WITH CHECK (true);

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

-- ============================================================================
-- DEPLOYMENT COMPLETE
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '============================================================================';
  RAISE NOTICE 'Schema v5 deployment complete!';
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
