-- ============================================================
-- Bot Player System: Database Migration with Realistic Names
-- ============================================================
-- This script creates 250 bot users with realistic names
-- ============================================================

-- Add is_bot column to users table (if not already exists)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS is_bot BOOLEAN NOT NULL DEFAULT FALSE;

-- Create index for efficient bot queries
CREATE INDEX IF NOT EXISTS idx_users_is_bot ON users(is_bot) WHERE is_bot = true;

-- Create bot users with realistic names
DO $$
DECLARE
    bot_names TEXT[] := ARRAY[
        'Abebe', 'Almaz', 'Aster', 'Ayana', 'Bekele', 'Biruk', 'Chaltu', 'Daniel', 'Dawit', 'Eden',
        'Elias', 'Emanuel', 'Eyob', 'Fikir', 'Gemechu', 'Getachew', 'Girma', 'Hana', 'Helen', 'Henok',
        'Hiwot', 'Ibrahim', 'Israel', 'Kalkidan', 'Kaleb', 'Kidist', 'Lensa', 'Mahlet', 'Mekdes', 'Meron',
        'Meseret', 'Mesfin', 'Meskerem', 'Miki', 'Mulugeta', 'Naod', 'Nebiyat', 'Netsanet', 'Rahel', 'Rebecca',
        'Robel', 'Ruth', 'Salem', 'Samuel', 'Sara', 'Selam', 'Semhar', 'Senait', 'Seyoum', 'Shewit',
        'Sirak', 'Sofia', 'Solomon', 'Tadesse', 'Tefera', 'Tekle', 'Temesgen', 'Tesfa', 'Tigist', 'Tinsae',
        'Tsegaye', 'Winta', 'Yared', 'Yeshi', 'Yohannes', 'Yonatan', 'Zelalem', 'Zerihun', 'Zewdu', 'Amanuel',
        'Bereket', 'Bethlehem', 'Biniyam', 'Dagmawi', 'Derartu', 'Elsa', 'Fasika', 'Firehiwot', 'Genet', 'Habtamu',
        'Haben', 'Hermela', 'Lidya', 'Makda', 'Melat', 'Michael', 'Million', 'Mussie', 'Nathaniel', 'Nebiat',
        'Nebyou', 'Netsanet', 'Nigusu', 'Selamawit', 'Semira', 'Saron', 'Seble', 'Senay', 'Senayt',
        'Sintayehu', 'Sosina', 'Tadelech', 'Tewodros', 'Tiruwork', 'Yabsira', 'Yodit', 'Yonathan', 'Zewditu',
        'Ahmed', 'Ali', 'Amir', 'Fatima', 'Hassan', 'Jamal', 'Leyla', 'Mohammed', 'Mustafa', 'Omar',
        'Rashid', 'Salah', 'Yasmin', 'Abdullah', 'Adam', 'Aisha', 'Amina', 'Bilal', 'Farah', 'Halima',
        'Hamza', 'Ismail', 'Khadija', 'Malik', 'Mariam', 'Noor', 'Rayan', 'Safiya', 'Yusuf',
        'Zakaria', 'Zainab', 'Tariq', 'Layla', 'Karim', 'Nasir', 'Habib', 'Samira', 'Latif', 'Nabila',
        'James', 'John', 'Robert', 'David', 'William', 'Joseph', 'Charles', 'Thomas', 'Matthew',
        'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen',
        'Nancy', 'Lisa', 'Betty', 'Margaret', 'Sandra', 'Ashley', 'Kimberly', 'Emily', 'Donna', 'Michelle',
        'Carol', 'Amanda', 'Dorothy', 'Melissa', 'Deborah', 'Stephanie', 'Sharon', 'Laura', 'Cynthia',
        'Kathleen', 'Amy', 'Angela', 'Shirley', 'Anna', 'Brenda', 'Pamela', 'Emma', 'Nicole',
        'Samantha', 'Katherine', 'Christine', 'Debra', 'Rachel', 'Carolyn', 'Janet', 'Catherine', 'Maria', 'Heather',
        'Diane', 'Julie', 'Olivia', 'Joyce', 'Virginia', 'Victoria', 'Kelly', 'Lauren', 'Christina',
        'Joan', 'Evelyn', 'Judith', 'Megan', 'Andrea', 'Cheryl', 'Hannah', 'Jacqueline', 'Martha', 'Gloria',
        'Teresa', 'Ann', 'Madison', 'Frances', 'Kathryn', 'Janice', 'Jean', 'Abigail', 'Sophia',
        'Brittany', 'Isabella', 'Charlotte', 'Natalie', 'Grace', 'Alice', 'Denise', 'Amber', 'Danielle', 'Rose'
    ];
    i INTEGER;
    name_index INTEGER;
    bot_username TEXT;
BEGIN
    FOR i IN 1..250 LOOP
        -- Cycle through names, adding numbers if we run out
        name_index := ((i - 1) % array_length(bot_names, 1)) + 1;
        
        IF i <= array_length(bot_names, 1) THEN
            bot_username := bot_names[name_index];
        ELSE
            -- Add numbers for duplicates (e.g., "Abebe2", "Almaz2")
            bot_username := bot_names[name_index] || ((i / array_length(bot_names, 1)) + 1)::TEXT;
        END IF;
        
        INSERT INTO users (user_id, username, phone_number, password_hash, balance, is_bot, created_at, updated_at)
        VALUES (
            1000000 + i,  -- Starting from user_id 1000001 to avoid conflicts
            bot_username,
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

-- Verify the migration
SELECT COUNT(*) as bot_count FROM users WHERE is_bot = true;
