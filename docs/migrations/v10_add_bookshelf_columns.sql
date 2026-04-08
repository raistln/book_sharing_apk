-- Migration v10: Add bookshelf control columns to shared_books
-- Manual execution for Supabase SQL Editor

ALTER TABLE public.shared_books 
ADD COLUMN IF NOT EXISTS is_on_shelf BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS is_on_shelf_at TIMESTAMPTZ;

-- Optional: Initial data migration for personal backups (group_id is NULL)
-- This marks books already finished as 'on shelf' in Supabase to maintain consistency.
UPDATE public.shared_books 
SET is_on_shelf = true, 
    is_on_shelf_at = updated_at 
WHERE reading_status = 'finished' 
AND is_deleted = false;
