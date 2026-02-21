-- 1. Add new columns to the cards table
ALTER TABLE cards ADD COLUMN state INTEGER DEFAULT 2 NOT NULL;
ALTER TABLE cards ADD COLUMN reservation_expires_at TIMESTAMP WITHOUT TIME ZONE NULL;

-- 2. Add xmin for optimistic concurrency (Entity Framework Core RowVersion equivalent in PostgreSQL)
-- Note: PostgreSQL has a built-in system column 'xmin' that EF Core uses for concurrency.
-- We map it by adding an explicit column or configuring EF Core to use the system one.
-- Alternatively, if you mapped it as a byte array, you need to add a standard trigger or column.
-- Assuming EF Core maps 'byte[] RowVersion' to 'bytea' or 'xmin', usually PostgreSQL provider handles it.
-- Let's add the column explicitly if it's meant to be managed by application logic:
ALTER TABLE cards ADD COLUMN row_version xid NOT NULL DEFAULT '0';

-- Alternatively, the standard Npgsql way to handle concurrency is using the system column xmin.
-- If you mapped `IsRowVersion()`, Npgsql translates this to the hidden `xmin` column.
-- So explicitly adding `row_version` might not be necessary, but just in case:
-- ALTER TABLE cards ADD COLUMN row_version bytea;
