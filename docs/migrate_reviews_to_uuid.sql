-- MIGRATION SCRIPT: Decouple book_reviews from shared_books.id

-- 1. Add book_uuid column to book_reviews
ALTER TABLE public.book_reviews 
ADD COLUMN IF NOT EXISTS book_uuid TEXT;

-- 2. Backfill the book_uuid by joining with shared_books using the old book_id
UPDATE public.book_reviews br
SET book_uuid = sb.book_uuid
FROM public.shared_books sb
WHERE br.book_id::text = sb.id::text;

-- Note: if there are any reviews with NO matching shared_books (orphans), 
-- they will have a NULL book_uuid. We should delete them or handle them carefully.
DELETE FROM public.book_reviews WHERE book_uuid IS NULL;

-- 3. Make book_uuid REQUIRED
ALTER TABLE public.book_reviews
ALTER COLUMN book_uuid SET NOT NULL;

-- 4. Drop the old book_id column
ALTER TABLE public.book_reviews 
DROP COLUMN book_id;

-- 5. Optional: Add an index for faster lookups based on book_uuid
CREATE INDEX IF NOT EXISTS idx_book_reviews_uuid ON public.book_reviews(book_uuid);
