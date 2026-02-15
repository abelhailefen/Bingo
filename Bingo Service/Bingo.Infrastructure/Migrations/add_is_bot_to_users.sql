-- ============================================================
-- Bot Player System: Database Migration
-- ============================================================
-- This script adds the is_bot column to the users table
-- to support bot player functionality in the Bingo game.
-- ============================================================

-- Add is_bot column to users table
ALTER TABLE users 
ADD COLUMN is_bot BOOLEAN NOT NULL DEFAULT FALSE;

-- Create index for efficient bot queries
CREATE INDEX idx_users_is_bot ON users(is_bot) WHERE is_bot = true;

-- Optional: Create initial bot users (Bot_1 through Bot_250)
-- Uncomment the following section if you want to pre-populate bot users

/*
DO $$
DECLARE
    i INTEGER;
BEGIN
    FOR i IN 1..250 LOOP
        INSERT INTO users (user_id, username, phone_number, password_hash, balance, is_bot, created_at, updated_at)
        VALUES (
            1000000 + i,  -- Starting from user_id 1000001 to avoid conflicts
            'Bot_' || i,
            'BOT_' || i,
            'BOT_NO_PASSWORD',
            0,
            true,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        )
        ON CONFLICT (username) DO NOTHING;
    END LOOP;
END $$;
*/

-- Verify the migration
SELECT COUNT(*) as bot_count FROM users WHERE is_bot = true;
