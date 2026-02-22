-- ============================================================================
-- Thematic Groups Migration
-- Run this in the Supabase SQL Editor BEFORE releasing app v26
-- ============================================================================

-- Add genre filter and color tint columns to groups table
ALTER TABLE public.groups ADD COLUMN IF NOT EXISTS allowed_genres JSONB DEFAULT NULL;
ALTER TABLE public.groups ADD COLUMN IF NOT EXISTS primary_color TEXT DEFAULT NULL;

-- Verify
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name   = 'groups'
  AND column_name  IN ('allowed_genres', 'primary_color');
