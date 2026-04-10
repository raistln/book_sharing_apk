-- Migration to allow 5 recommendation levels (adds 'finishedButTough')

BEGIN;

ALTER TABLE public.book_reviews DROP CONSTRAINT IF EXISTS book_reviews_rating_check;
ALTER TABLE public.book_reviews ADD CONSTRAINT book_reviews_rating_check CHECK (rating BETWEEN 1 AND 5);

COMMIT;
