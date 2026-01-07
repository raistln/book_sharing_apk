-- =====================================================
-- LOAN SYSTEM HARDENING SCRIPT (COMPLETE & SYNC-FRIENDLY)
-- =====================================================
-- Version: 1.1
-- Fixes:
-- 1. Merged completion & validation logic into one function.
-- 2. "Sync-Friendly" validation: Regressions (e.g., completed -> active) 
--    are now silently ignored (vetoed) instead of raising exceptions.
--    This prevents sync "hanging" or "getting stuck".
-- 3. Explicitly drops legacy schema triggers to avoid conflicts.
-- 4. Hardened security: search_path restricted for functions.
-- 5. Hardened RLS: restricted loan_notifications INSERT policy.
-- =====================================================

-- 0. CLEANUP LEGACY FUNCTIONS (Fixes Search Path Mutable Lints)
DROP FUNCTION IF EXISTS public.check_loan_completion CASCADE;
DROP FUNCTION IF EXISTS public.validate_loan_state_transition CASCADE;

-- -----------------------------------------------------
-- 1. RPC FUNCTION: accept_loan (Atomic Acceptance)
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION accept_loan(
  p_loan_id UUID,
  p_lender_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_loan RECORD;
  v_shared_book_id UUID;
  v_updated_loan JSONB;
BEGIN
  -- 1. Lock the loan row
  SELECT * INTO v_loan
  FROM loans
  WHERE id = p_loan_id
  FOR UPDATE;

  -- 2. Validations
  IF v_loan IS NULL THEN
    RAISE EXCEPTION 'Loan not found';
  END IF;

  IF v_loan.status != 'requested' THEN
    RAISE EXCEPTION 'Loan is not in requested state (current: %)', v_loan.status;
  END IF;

  v_shared_book_id := v_loan.shared_book_id;

  -- 3. Check for double booking (other ACTIVE loans)
  IF EXISTS (
    SELECT 1 FROM loans 
    WHERE shared_book_id = v_shared_book_id 
      AND status = 'active'
      AND id != p_loan_id
  ) THEN
    RAISE EXCEPTION 'This book is already currently on loan';
  END IF;

  -- 4. Update the target loan to ACTIVE
  UPDATE loans
  SET 
    status = 'active',
    approved_at = NOW(),
    updated_at = NOW()
  WHERE id = p_loan_id
  RETURNING * INTO v_loan;

  -- 5. Auto-reject other REQUESTED loans for the same book
  UPDATE loans
  SET 
    status = 'rejected',
    updated_at = NOW()
  WHERE shared_book_id = v_shared_book_id
    AND status = 'requested'
    AND id != p_loan_id;

  -- 6. Return the updated loan record (mapped for app)
  v_updated_loan := jsonb_build_object(
    'uuid', v_loan.id,
    'shared_book_id', v_loan.shared_book_id,
    'book_uuid', v_loan.book_uuid,
    'borrower_user_id', v_loan.borrower_user_id,
    'lender_user_id', v_loan.lender_user_id,
    'status', v_loan.status,
    'approved_at', v_loan.approved_at,
    'updated_at', v_loan.updated_at
  );

  RETURN v_updated_loan;
END;
$$;

-- -----------------------------------------------------
-- 2. UNIFIED TRIGGER: handle_loan_updates
-- -----------------------------------------------------
-- This function handles BOTH auto-completion and state validation.
-- By combining them, we ensure completion runs before validation
-- and we can avoid sync-breaking exceptions.

CREATE OR REPLACE FUNCTION handle_loan_updates()
RETURNS TRIGGER AS $$
BEGIN
  -- A. AUTO-COMPLETION LOGIC
  -- If both parties confirmed return, force status to 'completed'
  IF NEW.lender_returned_at IS NOT NULL AND NEW.borrower_returned_at IS NOT NULL THEN
    IF NEW.status != 'completed' THEN
      NEW.status := 'completed';
      
      -- Ensure returned_at is set to the latest of the two
      IF NEW.lender_returned_at > NEW.borrower_returned_at THEN
        NEW.returned_at := NEW.lender_returned_at;
      ELSE
        NEW.returned_at := NEW.borrower_returned_at;
      END IF;
    END IF;
  END IF;

  -- B. SYNC-FRIENDLY VALIDATION LOGIC
  -- Instead of raising exceptions (which breaks sync), we simply
  -- "veto" the change by forcing the NEW.status back to OLD.status
  -- if the transition is a forbidden regression.

  -- 1. Prevent "un-cancelling" or "un-rejecting" a loan (Must stay cancelled/rejected)
  IF OLD.status IN ('cancelled', 'rejected') AND NEW.status = 'active' THEN
    -- If we RAISE EXCEPTION here, sync fails. 
    -- So we just ignore the attempt to make it active again.
    NEW.status := OLD.status;
  END IF;

  -- 2. Prevent cancelling/rejecting an ALREADY Active loan 
  -- (Clients might try this if they are offline and don't know it was accepted)
  IF OLD.status = 'active' AND NEW.status IN ('cancelled', 'rejected') THEN
    NEW.status := OLD.status;
  END IF;

  -- 3. Prevent reactivating a COMPLETED loan
  -- (If Client B is slow and thinks it's still 'active', we don't let it revert)
  IF OLD.status = 'completed' AND NEW.status != 'completed' THEN
    NEW.status := OLD.status;
  END IF;

  -- IMPORTANT: We allow other fields (timestamps, metadata) to be updated
  -- but we protect the integrity of the 'status' lifecycle.
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- -----------------------------------------------------
-- 3. SETUP TRIGGERS (Cleanup & Install)
-- -----------------------------------------------------

-- 1. Drop old triggers from hardening script
DROP TRIGGER IF EXISTS trigger_auto_complete_loan ON loans;
DROP TRIGGER IF EXISTS loan_state_validation ON loans;

-- 2. Drop legacy schema triggers to avoid double logic/conflicts
DROP TRIGGER IF EXISTS loan_return_confirmation ON loans;

-- 3. Create the new unified trigger
CREATE TRIGGER loan_unified_handler
  BEFORE UPDATE ON loans
  FOR EACH ROW
  EXECUTE FUNCTION handle_loan_updates();

-- -----------------------------------------------------
-- 4. RLS HARDENING: loan_notifications
-- -----------------------------------------------------

DROP POLICY IF EXISTS "System can create notifications" ON public.loan_notifications;

-- Only allow users to create notifications if they are a participant in the loan.
CREATE POLICY "System can create notifications"
  ON public.loan_notifications FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.loans l
      WHERE l.id = loan_id
        AND (
          l.borrower_user_id = (SELECT auth.uid()) 
          OR l.lender_user_id = (SELECT auth.uid())
          -- Support for anonymous/service-role inserts if needed (auth.uid() is null)
          OR (SELECT auth.uid()) IS NULL
        )
    )
  );

-- -----------------------------------------------------
-- FINISHED
-- -----------------------------------------------------
