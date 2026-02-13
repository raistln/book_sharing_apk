-- ============================================================================
-- Supabase Manual Alterations Script (v8) - FINAL RLS OVERLAP FIX
-- ============================================================================
-- Use this script to update an EXISTING database to match the latest schema.
-- Fixes "Multiple Permissive Policies" for profiles table SELECT action.
-- ============================================================================

-- STEP 1: Update shared_books metadata
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='shared_books' AND column_name='page_count') THEN
        ALTER TABLE public.shared_books ADD COLUMN page_count INTEGER;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='shared_books' AND column_name='publication_year') THEN
        ALTER TABLE public.shared_books ADD COLUMN publication_year INTEGER;
    END IF;
END $$;

-- STEP 2: Create wishlist_items table
CREATE TABLE IF NOT EXISTS public.wishlist_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    uuid TEXT UNIQUE NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    author TEXT,
    isbn TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wishlist_user_id ON public.wishlist_items(user_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_uuid ON public.wishlist_items(uuid);

-- STEP 3: RESOLVE RLS OVERLAPS
-- The linter complains if we have "ALL" and "SELECT" on the same table.

-- Table: public.profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "profiles_select_all" ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update" ON public.profiles;
DROP POLICY IF EXISTS "profiles_select" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "profiles_manage" ON public.profiles;
DROP POLICY IF EXISTS "profiles_manage_own" ON public.profiles;

-- Fixed: separate SELECT from the "ALL" variants to avoid redundancy
CREATE POLICY "profiles_select" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE USING (id = (select auth.uid())) WITH CHECK (id = (select auth.uid()));
CREATE POLICY "profiles_insert_own" ON public.profiles FOR INSERT WITH CHECK (id = (select auth.uid()));

-- Table: public.loans
ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "loans_select" ON public.loans;
DROP POLICY IF EXISTS "loans_insert" ON public.loans;
DROP POLICY IF EXISTS "loans_update" ON public.loans;
DROP POLICY IF EXISTS "Users can view their own loans" ON public.loans;
DROP POLICY IF EXISTS "Users can update their own loans" ON public.loans;
DROP POLICY IF EXISTS "loans_access" ON public.loans;
CREATE POLICY "loans_access" ON public.loans FOR ALL 
USING (lender_user_id = (select auth.uid()) OR borrower_user_id = (select auth.uid()));

-- Table: public.shared_books
ALTER TABLE public.shared_books ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "shared_books_select" ON public.shared_books;
DROP POLICY IF EXISTS "shared_books_insert" ON public.shared_books;
DROP POLICY IF EXISTS "shared_books_update" ON public.shared_books;
DROP POLICY IF EXISTS "shared_books_delete" ON public.shared_books;
DROP POLICY IF EXISTS "Users can manage their own shared books" ON public.shared_books;
DROP POLICY IF EXISTS "books_access" ON public.shared_books;
CREATE POLICY "books_access" ON public.shared_books FOR ALL 
USING (owner_id = (select auth.uid()) OR check_is_group_member(group_id, (select auth.uid())));

-- Table: public.reading_timeline_entries
ALTER TABLE public.reading_timeline_entries ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "timeline_select_own" ON public.reading_timeline_entries;
DROP POLICY IF EXISTS "timeline_insert_own" ON public.reading_timeline_entries;
DROP POLICY IF EXISTS "timeline_update_own" ON public.reading_timeline_entries;
DROP POLICY IF EXISTS "timeline_delete_own" ON public.reading_timeline_entries;
DROP POLICY IF EXISTS "Users can manage their own timeline" ON public.reading_timeline_entries;
DROP POLICY IF EXISTS "timeline_access" ON public.reading_timeline_entries;
CREATE POLICY "timeline_access" ON public.reading_timeline_entries FOR ALL 
USING (owner_id = (select auth.uid()));

-- Table: public.wishlist_items
ALTER TABLE public.wishlist_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage their own wishlist items" ON public.wishlist_items;
DROP POLICY IF EXISTS "wishlist_access" ON public.wishlist_items;
CREATE POLICY "wishlist_access" ON public.wishlist_items FOR ALL 
USING (user_id = (select auth.uid())) WITH CHECK (user_id = (select auth.uid()));

-- STEP 4: Ensure Hardening & Triggers are applied
CREATE OR REPLACE FUNCTION public.handle_loan_updates()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.lender_returned_at IS NOT NULL AND NEW.borrower_returned_at IS NOT NULL THEN
    IF NEW.status != 'completed' THEN
      NEW.status := 'completed';
      NEW.returned_at := GREATEST(NEW.lender_returned_at, NEW.borrower_returned_at);
    END IF;
  END IF;
  IF OLD.status IN ('cancelled', 'rejected') AND NEW.status = 'active' THEN NEW.status := OLD.status; END IF;
  IF OLD.status = 'active' AND NEW.status IN ('cancelled', 'rejected') THEN NEW.status := OLD.status; END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS loan_updates_handler ON public.loans;
CREATE TRIGGER loan_updates_handler BEFORE UPDATE ON public.loans
  FOR EACH ROW EXECUTE FUNCTION handle_loan_updates();

DROP TRIGGER IF EXISTS update_wishlist_updated_at ON public.wishlist_items;
CREATE TRIGGER update_wishlist_updated_at BEFORE UPDATE ON public.wishlist_items
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- ALL INCREMENTAL CHANGES APPLIED - RLS CONFLICTS RESOLVED
-- ============================================================================
