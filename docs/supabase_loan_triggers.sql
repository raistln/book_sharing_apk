-- =====================================================
-- Supabase Loan State Validation Triggers
-- =====================================================
-- Purpose: Prevent invalid loan state transitions that can occur
--          due to synchronization conflicts between clients.
--
-- Problem: When a loan is cancelled but a client accepts it while
--          offline, the loan can end up in an invalid state (active
--          but with no borrower, or accepted after cancellation).
--
-- Solution: Database-level validation ensures state transitions
--           follow business rules regardless of sync timing.
-- =====================================================

-- Drop existing trigger and function if they exist
DROP TRIGGER IF EXISTS loan_state_validation ON loans;
DROP FUNCTION IF EXISTS validate_loan_state_transition();

-- Create function to validate loan state transitions
CREATE OR REPLACE FUNCTION validate_loan_state_transition()
RETURNS TRIGGER AS $$
BEGIN
  -- Prevent accepting a cancelled loan
  IF OLD.status = 'cancelled' AND NEW.status = 'active' THEN
    RAISE EXCEPTION 'Cannot accept a cancelled loan (loan_id: %)', NEW.id
      USING HINT = 'The loan was cancelled before it could be accepted';
  END IF;
  
  -- Prevent accepting a rejected loan
  IF OLD.status = 'rejected' AND NEW.status = 'active' THEN
    RAISE EXCEPTION 'Cannot accept a rejected loan (loan_id: %)', NEW.id
      USING HINT = 'The loan was already rejected';
  END IF;
  
  -- Prevent cancelling an already active loan
  -- (should use return flow instead)
  IF OLD.status = 'active' AND NEW.status = 'cancelled' THEN
    RAISE EXCEPTION 'Cannot cancel an active loan (loan_id: %). Use return flow instead', NEW.id
      USING HINT = 'Active loans must be returned, not cancelled';
  END IF;
  
  -- Prevent rejecting an already active loan
  IF OLD.status = 'active' AND NEW.status = 'rejected' THEN
    RAISE EXCEPTION 'Cannot reject an active loan (loan_id: %). Use return flow instead', NEW.id
      USING HINT = 'Active loans must be returned, not rejected';
  END IF;
  
  -- Prevent reactivating a completed/returned loan
  IF OLD.status IN ('returned', 'completed') AND NEW.status = 'active' THEN
    RAISE EXCEPTION 'Cannot reactivate a completed loan (loan_id: %)', NEW.id
      USING HINT = 'Completed loans cannot be reactivated';
  END IF;
  
  -- All other transitions are allowed
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Create trigger that runs before any update to loans table
CREATE TRIGGER loan_state_validation
  BEFORE UPDATE ON loans
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION validate_loan_state_transition();

-- =====================================================
-- Valid State Transitions (for reference)
-- =====================================================
-- pending -> active    (loan accepted)
-- pending -> rejected  (loan rejected by owner)
-- pending -> cancelled (loan cancelled by borrower)
-- active -> returned   (borrower marks as returned)
-- active -> completed  (both parties confirm return)
-- returned -> completed (owner confirms return)
--
-- Invalid transitions (prevented by trigger):
-- cancelled -> active
-- rejected -> active
-- active -> cancelled
-- active -> rejected
-- returned -> active
-- completed -> active
-- =====================================================

COMMENT ON FUNCTION validate_loan_state_transition() IS 
'Validates loan state transitions to prevent sync conflicts. 
Ensures loans cannot be accepted after being cancelled or rejected, 
and prevents invalid state changes on active or completed loans.';
