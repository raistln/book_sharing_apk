-- ============================================================================
-- Book Sharing App - Supabase SQL Schema v9 - COMPLETE DEPLOYMENT
-- ============================================================================
-- Including: Base Schema + Timeline Sync + Loan Hardening + Wishlist + Book Clubs
-- + Thematic Groups (allowed_genres, primary_color)
-- Optimized with: (select auth.uid()) and Linter-friendly RLS separation.
-- ============================================================================

-- Enable data destruction (UNCOMMENT TO ACTIVATE)
DO $$ BEGIN PERFORM set_config('app.enable_data_destruction', 'true', false); END $$;

-- ============================================================================
-- STEP 1: DANGER ZONE - DATA DESTRUCTION SECTION
-- ============================================================================
DO $$
BEGIN
  IF current_setting('app.enable_data_destruction', true) = 'true' THEN
    RAISE NOTICE '🔥 DATA DESTRUCTION ENABLED - Cleaning up everything...';
    
    -- Drop cron jobs
    BEGIN
      DECLARE job_record RECORD; BEGIN
        FOR job_record IN SELECT jobid, jobname FROM cron.job LOOP
          PERFORM cron.unschedule(job_record.jobid);
        END LOOP;
      END;
    EXCEPTION WHEN undefined_table THEN RAISE NOTICE 'pg_cron not installed'; END;

    -- Drop RLS policies
    DECLARE pol RECORD; BEGIN
      FOR pol IN SELECT schemaname, tablename, policyname FROM pg_policies WHERE schemaname = 'public' LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I CASCADE', pol.policyname, pol.schemaname, pol.tablename);
      END LOOP;
    END;

    -- Drop triggers
    DECLARE trig RECORD; BEGIN
      FOR trig IN SELECT event_object_table, trigger_name FROM information_schema.triggers WHERE trigger_schema = 'public' LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I CASCADE', trig.trigger_name, trig.event_object_table);
      END LOOP;
    END;

    -- Drop tables in reverse dependency order
    DROP TABLE IF EXISTS public.moderation_logs CASCADE;
    DROP TABLE IF EXISTS public.comment_reports CASCADE;
    DROP TABLE IF EXISTS public.section_comments CASCADE;
    DROP TABLE IF EXISTS public.book_proposals CASCADE;
    DROP TABLE IF EXISTS public.club_reading_progress CASCADE;
    DROP TABLE IF EXISTS public.club_members CASCADE;
    DROP TABLE IF EXISTS public.reading_clubs CASCADE;
    DROP TABLE IF EXISTS public.club_books CASCADE;
    DROP TABLE IF EXISTS public.wishlist_items CASCADE;
    DROP TABLE IF EXISTS public.reading_sessions CASCADE;
    DROP TABLE IF EXISTS public.reading_timeline_entries CASCADE;
    DROP TABLE IF EXISTS public.loan_notifications CASCADE;
    DROP TABLE IF EXISTS public.loans CASCADE;
    DROP TABLE IF EXISTS public.book_reviews CASCADE;
    DROP TABLE IF EXISTS public.shared_books CASCADE;
    DROP TABLE IF EXISTS public.group_invitations CASCADE;
    DROP TABLE IF EXISTS public.group_members CASCADE;
    DROP TABLE IF EXISTS public.groups CASCADE;
    DROP TABLE IF EXISTS public.profiles CASCADE;
    DROP TABLE IF EXISTS public.literary_bulletins CASCADE;
    DROP TABLE IF EXISTS public.system_logs CASCADE;
    DROP TABLE IF EXISTS public.system_metrics CASCADE;
    DROP TABLE IF EXISTS public.in_app_notifications CASCADE;
  END IF;
END $$;

-- Drop all functions
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS public.handle_loan_updates() CASCADE;
DROP FUNCTION IF EXISTS public.accept_loan(UUID, UUID) CASCADE;
DROP FUNCTION IF EXISTS public.check_is_group_member(UUID, UUID) CASCADE;
DROP FUNCTION IF EXISTS public.check_is_group_owner(UUID, UUID) CASCADE;
DROP FUNCTION IF EXISTS public.check_is_club_member(UUID, UUID) CASCADE;
DROP FUNCTION IF EXISTS public.check_is_club_admin(UUID, UUID) CASCADE;
DROP FUNCTION IF EXISTS public.expire_overdue_loans() CASCADE;
DROP FUNCTION IF EXISTS public.send_loan_reminders() CASCADE;
DROP FUNCTION IF EXISTS public.cleanup_old_notifications() CASCADE;
DROP FUNCTION IF EXISTS public.cleanup_deleted_records() CASCADE;

-- ============================================================================
-- STEP 2: EXTENSIONS & CORE TABLES
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_cron";

-- PROFILES
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

-- GROUPS & MEMBERS
CREATE TABLE public.groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  -- Thematic group: JSON array of BookGenre names, e.g. '["fantasy","horror"]
  -- NULL means no genre filter (all genres visible).
  allowed_genres JSONB DEFAULT NULL,
  -- Hex color of the primary (first) genre, e.g. '#7B5EA7'. NULL = no tint.
  primary_color TEXT DEFAULT NULL,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

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
  group_id UUID REFERENCES public.groups(id) ON DELETE CASCADE,
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  book_uuid TEXT,
  title TEXT NOT NULL,
  author TEXT,
  isbn TEXT,
  cover_url TEXT,
  genre TEXT,
  page_count INTEGER,
  publication_year INTEGER,
  is_read BOOLEAN NOT NULL DEFAULT false,
  reading_status TEXT DEFAULT 'pending', 
  description TEXT,
  barcode TEXT,
  read_at TIMESTAMPTZ,
  is_borrowed_external BOOLEAN NOT NULL DEFAULT false,
  external_lender_name TEXT,
  visibility TEXT NOT NULL DEFAULT 'group' CHECK (visibility IN ('private', 'group', 'public')),
  is_available BOOLEAN NOT NULL DEFAULT true,
  is_physical BOOLEAN NOT NULL DEFAULT true,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- BOOK REVIEWS
CREATE TABLE public.book_reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  book_uuid TEXT NOT NULL,
  author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 4),
  review TEXT,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- READING TIMELINE
CREATE TABLE public.reading_timeline_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  book_uuid TEXT NOT NULL,
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  current_page INTEGER,
  percentage_read INTEGER,
  event_type TEXT NOT NULL,
  note TEXT,
  event_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- LOANS & NOTIFICATIONS
CREATE TABLE public.loans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shared_book_id UUID REFERENCES public.shared_books(id) ON DELETE CASCADE,
  book_uuid TEXT,
  borrower_user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  lender_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'active', 'returned', 'cancelled', 'rejected', 'completed', 'expired')),
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  approved_at TIMESTAMPTZ,
  due_date TIMESTAMPTZ,
  borrower_returned_at TIMESTAMPTZ,
  lender_returned_at TIMESTAMPTZ,
  returned_at TIMESTAMPTZ,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT loan_type_check CHECK (
    (shared_book_id IS NOT NULL AND borrower_user_id IS NOT NULL) OR
    (shared_book_id IS NULL AND book_uuid IS NOT NULL AND borrower_user_id IS NULL)
  )
);

CREATE TABLE public.loan_notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  loan_id UUID REFERENCES public.loans(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'unread' CHECK (status IN ('unread', 'read', 'dismissed')),
  read_at TIMESTAMPTZ,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- WISHLIST
CREATE TABLE public.wishlist_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    uuid TEXT UNIQUE NOT NULL,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    author TEXT,
    isbn TEXT,
    notes TEXT,
    is_deleted BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- STEP 3: BOOK CLUBS MODULE
-- ============================================================================
CREATE TABLE public.reading_clubs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  city TEXT NOT NULL,
  frequency TEXT NOT NULL DEFAULT 'mensual',
  visibility TEXT NOT NULL DEFAULT 'privado',
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  current_book_id UUID, 
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.club_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  club_id UUID NOT NULL REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'miembro',
  status TEXT NOT NULL DEFAULT 'activo',
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(club_id, user_id)
);

CREATE TABLE public.club_books (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  club_id UUID NOT NULL REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
  book_uuid TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'propuesto',
  total_chapters INTEGER NOT NULL,
  sections JSONB NOT NULL DEFAULT '[]'::jsonb,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.reading_clubs ADD CONSTRAINT fk_current_book FOREIGN KEY (current_book_id) REFERENCES public.club_books(id) ON DELETE SET NULL;

CREATE TABLE public.club_reading_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  club_id UUID NOT NULL REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
  book_id UUID NOT NULL REFERENCES public.club_books(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  current_chapter INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(club_id, book_id, user_id)
);

CREATE TABLE public.section_comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  club_id UUID NOT NULL REFERENCES public.reading_clubs(id) ON DELETE CASCADE,
  book_id UUID NOT NULL REFERENCES public.club_books(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_hidden BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- STEP 4: SYSTEM & METADATA TABLES
-- ============================================================================
CREATE TABLE public.literary_bulletins (
    id BIGSERIAL PRIMARY KEY,
    province TEXT NOT NULL,
    period TEXT NOT NULL, 
    month INTEGER NOT NULL,
    year INTEGER NOT NULL,
    narrative TEXT NOT NULL,
    events JSONB NOT NULL DEFAULT '[]'::jsonb,
    generated_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(province, month, year)
);

CREATE TABLE public.system_logs (
  id BIGSERIAL PRIMARY KEY,
  log_level TEXT NOT NULL,
  source TEXT NOT NULL,
  message TEXT NOT NULL,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.system_metrics (
  id BIGSERIAL PRIMARY KEY,
  metric_name TEXT NOT NULL,
  metric_value TEXT NOT NULL,
  source TEXT,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  metric_hour TIMESTAMPTZ NOT NULL DEFAULT date_trunc('hour', NOW()),
  UNIQUE (metric_name, metric_hour)
);

-- ============================================================================
-- STEP 5: FUNCTIONS
-- ============================================================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$;

CREATE OR REPLACE FUNCTION public.accept_loan(p_loan_id UUID, p_lender_user_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_loan RECORD; v_shared_book_id UUID; BEGIN
  SELECT * INTO v_loan FROM public.loans WHERE id = p_loan_id FOR UPDATE;
  IF v_loan IS NULL OR v_loan.status != 'requested' THEN RAISE EXCEPTION 'Invalid state'; END IF;
  v_shared_book_id := v_loan.shared_book_id;
  IF EXISTS (SELECT 1 FROM public.loans WHERE shared_book_id = v_shared_book_id AND status = 'active' AND id != p_loan_id) THEN
    RAISE EXCEPTION 'Already on loan';
  END IF;
  UPDATE public.loans SET status = 'active', approved_at = NOW(), updated_at = NOW() WHERE id = p_loan_id;
  UPDATE public.loans SET status = 'rejected', updated_at = NOW() WHERE shared_book_id = v_shared_book_id AND status = 'requested' AND id != p_loan_id;
  RETURN jsonb_build_object('uuid', p_loan_id, 'status', 'active');
END; $$;

CREATE OR REPLACE FUNCTION public.expire_overdue_loans()
RETURNS void LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  UPDATE public.loans SET status = 'expired'
  WHERE status = 'active' AND due_date < NOW() AND is_deleted = false;
END; $$;

CREATE OR REPLACE FUNCTION public.send_loan_reminders()
RETURNS void LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  INSERT INTO public.loan_notifications (id, loan_id, user_id, type, title, message)
  SELECT uuid_generate_v4(), l.id, l.borrower_user_id, 'loan_due_soon', 'Vencimiento', 'Tu préstamo vence pronto.'
  FROM public.loans l WHERE l.status = 'active' AND DATE(l.due_date) = CURRENT_DATE + INTERVAL '7 days' AND l.is_deleted = false;
END; $$;

CREATE OR REPLACE FUNCTION public.cleanup_old_notifications()
RETURNS void SECURITY DEFINER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  DELETE FROM public.loan_notifications 
  WHERE (status IN ('read', 'dismissed') OR is_deleted = true) 
  AND created_at < NOW() - INTERVAL '7 days';
  
  -- Maintenance for in_app_notifications if they exist
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'in_app_notifications' AND table_schema = 'public') THEN
    EXECUTE 'DELETE FROM public.in_app_notifications WHERE (status IN (''read'', ''dismissed'') OR is_deleted = true) AND created_at < NOW() - INTERVAL ''7 days''';
  END IF;
END; $$;

CREATE OR REPLACE FUNCTION public.cleanup_deleted_records()
RETURNS void SECURITY DEFINER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  DELETE FROM public.profiles WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
  DELETE FROM public.groups WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
  DELETE FROM public.group_members WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
  DELETE FROM public.group_invitations WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
  DELETE FROM public.shared_books WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
  DELETE FROM public.reading_timeline_entries WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
  DELETE FROM public.loans WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
  DELETE FROM public.loan_notifications WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
  DELETE FROM public.wishlist_items WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
  DELETE FROM public.reading_clubs WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
  DELETE FROM public.club_members WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
  DELETE FROM public.club_books WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
  -- reading_sessions added in v9 cleanup
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'reading_sessions' AND table_schema = 'public') THEN
    DELETE FROM public.reading_sessions WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
  END IF;
END; $$;

CREATE OR REPLACE FUNCTION public.cleanup_system_data()
RETURNS void SECURITY DEFINER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  DELETE FROM public.system_logs WHERE created_at < NOW() - INTERVAL '14 days';
  DELETE FROM public.system_metrics WHERE recorded_at < NOW() - INTERVAL '60 days';
  DELETE FROM public.group_invitations WHERE status = 'expired' OR (status = 'pending' AND expires_at < NOW());
END; $$;

CREATE OR REPLACE FUNCTION public.cleanup_expired_content()
RETURNS void SECURITY DEFINER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  DELETE FROM public.literary_bulletins 
  WHERE (year < (extract(year from NOW()) - 2))
     OR (year = (extract(year from NOW()) - 2) AND month < extract(month from NOW()));
END; $$;

CREATE OR REPLACE FUNCTION public.handle_loan_updates()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF NEW.lender_returned_at IS NOT NULL AND NEW.borrower_returned_at IS NOT NULL THEN
    IF NEW.status != 'completed' THEN NEW.status := 'completed'; NEW.returned_at := GREATEST(NEW.lender_returned_at, NEW.borrower_returned_at); END IF;
  END IF;
  IF OLD.status IN ('cancelled', 'rejected') AND NEW.status = 'active' THEN NEW.status := OLD.status; END IF;
  IF OLD.status = 'active' AND NEW.status IN ('cancelled', 'rejected') THEN NEW.status := OLD.status; END IF;
  RETURN NEW;
END; $$;

-- ============================================================================
-- STEP 6: RLS POLICIES (OPTIMIZED & LINTER-FRIENDLY)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.check_is_group_member(p_group_id UUID, p_user_id UUID) 
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN RETURN EXISTS (SELECT 1 FROM public.group_members WHERE group_id = p_group_id AND user_id = p_user_id AND is_deleted = false); END; $$;

CREATE OR REPLACE FUNCTION public.check_is_club_member(p_club_id UUID, p_user_id UUID) 
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN RETURN EXISTS (SELECT 1 FROM public.club_members WHERE club_id = p_club_id AND user_id = p_user_id AND is_deleted = false); END; $$;

-- PROFILES: Fixed SELECT conflict by splitting actions
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "profiles_select" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE USING (id = (select auth.uid())) WITH CHECK (id = (select auth.uid()));
CREATE POLICY "profiles_insert_own" ON public.profiles FOR INSERT WITH CHECK (id = (select auth.uid()));

ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
CREATE POLICY "groups_access" ON public.groups FOR ALL USING (owner_id = (select auth.uid()) OR check_is_group_member(id, (select auth.uid())));

ALTER TABLE public.shared_books ENABLE ROW LEVEL SECURITY;
CREATE POLICY "books_access" ON public.shared_books FOR ALL USING (owner_id = (select auth.uid()) OR check_is_group_member(group_id, (select auth.uid())));

ALTER TABLE public.reading_timeline_entries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "timeline_access" ON public.reading_timeline_entries FOR ALL USING (owner_id = (select auth.uid()));

ALTER TABLE public.reading_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sessions_access" ON public.reading_sessions FOR ALL USING (owner_id = (select auth.uid()));

ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "loans_access" ON public.loans FOR ALL USING (lender_user_id = (select auth.uid()) OR borrower_user_id = (select auth.uid()));

ALTER TABLE public.wishlist_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "wishlist_access" ON public.wishlist_items FOR ALL USING (user_id = (select auth.uid()));

ALTER TABLE public.reading_clubs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "clubs_access" ON public.reading_clubs FOR ALL USING (owner_id = (select auth.uid()) OR check_is_club_member(id, (select auth.uid())));

ALTER TABLE public.literary_bulletins ENABLE ROW LEVEL SECURITY;
CREATE POLICY "bulletins_public_read" ON public.literary_bulletins FOR SELECT USING (true);

-- ============================================================================
-- STEP 7: TRIGGERS & CRON
-- ============================================================================

CREATE TRIGGER update_profiles_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_groups_at BEFORE UPDATE ON public.groups FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_shared_books_at BEFORE UPDATE ON public.shared_books FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_loans_at BEFORE UPDATE ON public.loans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_timeline_at BEFORE UPDATE ON public.reading_timeline_entries FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sessions_at BEFORE UPDATE ON public.reading_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_wishlist_at BEFORE UPDATE ON public.wishlist_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER loan_updates_handler BEFORE UPDATE ON public.loans FOR EACH ROW EXECUTE FUNCTION handle_loan_updates();

SELECT cron.schedule('expire-overdue-loans', '0 * * * *', $$SELECT public.expire_overdue_loans()$$);
SELECT cron.schedule('send-loan-reminders', '0 9 * * *', $$SELECT public.send_loan_reminders()$$);
SELECT cron.schedule('cleanup-notifications', '0 0 * * *', $$SELECT public.cleanup_old_notifications()$$);
SELECT cron.schedule('cleanup-deleted', '0 1 * * *', $$SELECT public.cleanup_deleted_records()$$);
SELECT cron.schedule('cleanup-system', '0 2 * * *', $$SELECT public.cleanup_system_data()$$);
SELECT cron.schedule('cleanup-bulletins', '0 3 1 * *', $$SELECT public.cleanup_expired_content()$$);

-- ============================================================================
-- DEPLOYMENT COMPLETE (v8 - FULL - LINTER CLEAN)
-- ============================================================================
