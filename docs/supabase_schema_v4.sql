-- ============================================================================
-- Book Sharing App - Supabase SQL Schema v4
-- ============================================================================
-- Features:
-- - Simplified loan states (requested, active, returned, expired)
-- - Double-confirmation for returns (both borrower and lender must confirm)
-- - Integrated notification system
-- - Support for manual loans (external borrowers)
-- - Automatic cleanup of rejected/cancelled loans
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- PROFILES (extends auth.users)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT NOT NULL UNIQUE,
  email TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS Policies for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all profiles"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- ============================================================================
-- GROUPS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS Policies for groups
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

-- ============================================================================
-- GROUP MEMBERS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.group_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(group_id, user_id)
);

-- RLS Policies for group_members
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

-- ============================================================================
-- GROUP INVITATIONS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.group_invitations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  inviter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  code TEXT NOT NULL UNIQUE,
  role TEXT NOT NULL DEFAULT 'member',
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),
  expires_at TIMESTAMPTZ NOT NULL,
  responded_at TIMESTAMPTZ,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS Policies for group_invitations
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

-- ============================================================================
-- SHARED BOOKS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.shared_books (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Book details (denormalized for sync)
  title TEXT NOT NULL,
  author TEXT,
  isbn TEXT,
  cover_url TEXT,
  
  visibility TEXT NOT NULL DEFAULT 'group' CHECK (visibility IN ('private', 'group', 'public')),
  is_available BOOLEAN NOT NULL DEFAULT true,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_shared_books_group ON public.shared_books(group_id) WHERE is_deleted = false;
CREATE INDEX IF NOT EXISTS idx_shared_books_owner ON public.shared_books(owner_id) WHERE is_deleted = false;

-- RLS Policies for shared_books
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

-- ============================================================================
-- LOANS (with double-confirmation for returns)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.loans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shared_book_id UUID NOT NULL REFERENCES public.shared_books(id) ON DELETE CASCADE,
  
  -- Users
  borrower_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- NULL for manual loans
  lender_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Manual loans (external borrowers without app)
  external_borrower_name TEXT,
  external_borrower_contact TEXT,
  
  -- Status: requested, active, returned, expired
  -- NOTE: rejected/cancelled are NOT stored (deleted immediately)
  status TEXT NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'active', 'returned', 'expired')),
  
  -- Dates
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  approved_at TIMESTAMPTZ, -- When lender approved (NULL for manual loans)
  due_date TIMESTAMPTZ,
  
  -- Double-confirmation for returns
  borrower_returned_at TIMESTAMPTZ, -- When borrower marked as returned
  lender_returned_at TIMESTAMPTZ,   -- When lender confirmed return
  returned_at TIMESTAMPTZ,           -- Final return timestamp (when BOTH confirmed)
  
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

-- Indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_loans_shared_book ON public.loans(shared_book_id) WHERE is_deleted = false;
CREATE INDEX IF NOT EXISTS idx_loans_borrower ON public.loans(borrower_user_id) WHERE is_deleted = false;
CREATE INDEX IF NOT EXISTS idx_loans_lender ON public.loans(lender_user_id) WHERE is_deleted = false;
CREATE INDEX IF NOT EXISTS idx_loans_status ON public.loans(status) WHERE is_deleted = false;

-- RLS Policies for loans
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

-- ============================================================================
-- LOAN NOTIFICATIONS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.loan_notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  loan_id UUID NOT NULL REFERENCES public.loans(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Notification type
  type TEXT NOT NULL CHECK (type IN (
    'loan_requested',
    'loan_approved',
    'loan_due_soon',
    'loan_overdue',
    'loan_borrower_returned',
    'loan_lender_confirmed',
    'loan_returned',
    'loan_expired'
  )),
  
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  
  -- Status
  status TEXT NOT NULL DEFAULT 'unread' CHECK (status IN ('unread', 'read', 'dismissed')),
  read_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_loan_notifications_user ON public.loan_notifications(user_id, status);
CREATE INDEX IF NOT EXISTS idx_loan_notifications_loan ON public.loan_notifications(loan_id);

-- RLS Policies for loan_notifications
ALTER TABLE public.loan_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications"
  ON public.loan_notifications FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can update their own notifications"
  ON public.loan_notifications FOR UPDATE
  USING (user_id = auth.uid());

-- ============================================================================
-- FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

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
$$ LANGUAGE plpgsql;

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
$$ LANGUAGE plpgsql;

-- ============================================================================
-- INITIAL DATA / CLEANUP
-- ============================================================================

-- Clean up any existing rejected/cancelled loans
DELETE FROM public.loans WHERE status IN ('rejected', 'cancelled');

-- ============================================================================
-- NOTES
-- ============================================================================
-- 
-- Double-confirmation return flow:
-- 1. Borrower marks as returned → borrower_returned_at = NOW()
-- 2. Lender confirms return → lender_returned_at = NOW()
-- 3. Trigger automatically sets returned_at and status='returned'
--
-- To mark as returned (borrower):
--   UPDATE loans SET borrower_returned_at = NOW() WHERE id = <loan_id>
--
-- To confirm return (lender):
--   UPDATE loans SET lender_returned_at = NOW() WHERE id = <loan_id>
--
-- To check if fully returned:
--   SELECT * FROM loans WHERE returned_at IS NOT NULL
--
-- To expire overdue loans (run periodically):
--   SELECT expire_overdue_loans();
--
-- ============================================================================
