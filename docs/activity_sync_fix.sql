-- ============================================================================
-- SQL for Activity Sync (Reading Sessions & Wishlist)
-- Copy and run this in your Supabase SQL Editor
-- ============================================================================

-- 1. Create reading_sessions table
CREATE TABLE IF NOT EXISTS public.reading_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  book_uuid TEXT NOT NULL,
  start_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  end_time TIMESTAMPTZ,
  duration_seconds INTEGER,
  start_page INTEGER,
  end_page INTEGER,
  pages_read INTEGER,
  notes TEXT,
  mood TEXT,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Ensure wishlist_items table exists and is correctly configured
-- (If it already exists, this will ensure columns match our needs)
CREATE TABLE IF NOT EXISTS public.wishlist_items (
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

-- 3. Enable RLS
ALTER TABLE public.reading_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlist_items ENABLE ROW LEVEL SECURITY;

-- 4. Create RLS Policies
-- Sessions: Access only own data
DROP POLICY IF EXISTS "sessions_access" ON public.reading_sessions;
CREATE POLICY "sessions_access" ON public.reading_sessions 
    FOR ALL USING (owner_id = (select auth.uid()));

-- Wishlist: Access only own data
DROP POLICY IF EXISTS "wishlist_access" ON public.wishlist_items;
CREATE POLICY "wishlist_access" ON public.wishlist_items 
    FOR ALL USING (user_id = (select auth.uid()));

-- 5. Create triggers for updated_at
DROP TRIGGER IF EXISTS update_sessions_at ON public.reading_sessions;
CREATE TRIGGER update_sessions_at 
    BEFORE UPDATE ON public.reading_sessions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_wishlist_at ON public.wishlist_items;
CREATE TRIGGER update_wishlist_at 
    BEFORE UPDATE ON public.wishlist_items 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 6. Maintenance & Cleanup Jobs
-- These functions ensure the database doesn't accumulate unnecessary data.
-- They are scheduled to run automatically every night.

-- 6.1 Enhanced cleanup for soft-deleted records
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
  DELETE FROM public.reading_sessions WHERE is_deleted = true AND updated_at < NOW() - INTERVAL '30 days';
END; $$;

-- 6.2 Generalized notification cleanup
CREATE OR REPLACE FUNCTION public.cleanup_old_notifications()
RETURNS void SECURITY DEFINER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  DELETE FROM public.loan_notifications 
  WHERE (status IN ('read', 'dismissed') OR is_deleted = true) 
  AND created_at < NOW() - INTERVAL '7 days';
  
  -- Use dynamic SQL to safely check if in_app_notifications table exists before deleting
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'in_app_notifications' AND table_schema = 'public') THEN
    EXECUTE 'DELETE FROM public.in_app_notifications WHERE (status IN (''read'', ''dismissed'') OR is_deleted = true) AND created_at < NOW() - INTERVAL ''7 days''';
  END IF;
END; $$;

-- 6.3 Maintenance for system logs, metrics and expired invitations
CREATE OR REPLACE FUNCTION public.cleanup_system_data()
RETURNS void SECURITY DEFINER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  DELETE FROM public.system_logs WHERE created_at < NOW() - INTERVAL '14 days';
  DELETE FROM public.system_metrics WHERE recorded_at < NOW() - INTERVAL '60 days';
  DELETE FROM public.group_invitations WHERE status = 'expired' OR (status = 'pending' AND expires_at < NOW());
END; $$;

-- 6.4 Cleanup for old literary bulletins
CREATE OR REPLACE FUNCTION public.cleanup_expired_content()
RETURNS void SECURITY DEFINER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  DELETE FROM public.literary_bulletins 
  WHERE (year < (extract(year from NOW()) - 2))
     OR (year = (extract(year from NOW()) - 2) AND month < extract(month from NOW()));
END; $$;

-- 7. Register Cron Jobs
-- Note: Requires pg_cron extension to be enabled in Supabase.
SELECT cron.schedule('expire-overdue-loans', '0 * * * *', $$SELECT public.expire_overdue_loans()$$);
SELECT cron.schedule('send-loan-reminders', '0 9 * * *', $$SELECT public.send_loan_reminders()$$);
SELECT cron.schedule('cleanup-notifications', '0 0 * * *', $$SELECT public.cleanup_old_notifications()$$);
SELECT cron.schedule('cleanup-deleted', '0 1 * * *', $$SELECT public.cleanup_deleted_records()$$);
SELECT cron.schedule('cleanup-system', '0 2 * * *', $$SELECT public.cleanup_system_data()$$);
SELECT cron.schedule('cleanup-bulletins', '0 3 1 * *', $$SELECT public.cleanup_expired_content()$$);
