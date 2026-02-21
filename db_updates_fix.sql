-- 1. Add new columns to the cards table if they don't exist yet
-- ALTER TABLE cards ADD COLUMN state INTEGER DEFAULT 2 NOT NULL;
-- ALTER TABLE cards ADD COLUMN reservation_expires_at TIMESTAMP WITHOUT TIME ZONE NULL;

-- FIX: We initially added row_version mapped to xid, but Entity Framework 
-- cannot cast 'byte[]' to 'xid' easily. Instead, Npgsql supports the built-in system 
-- column 'xmin' via `.UseXminAsConcurrencyToken()`.
-- Therefore, you must DROP the column you added earlier to fix the 500 IS Error:
ALTER TABLE cards DROP COLUMN IF EXISTS row_version;
