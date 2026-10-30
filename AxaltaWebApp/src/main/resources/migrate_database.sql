-- Migration script to rename database from axalta to supplexio
-- Make sure to backup your database before running this script

-- Create new database if it doesn't exist
CREATE DATABASE IF NOT EXISTS supplexio;

-- Transfer all tables and data from axalta to supplexio
-- This needs to be run as root or a user with sufficient privileges

-- Get list of tables from axalta database
SET @tables = NULL;
SELECT GROUP_CONCAT(table_name)
    INTO @tables
    FROM information_schema.tables
    WHERE table_schema = 'axalta';

-- Prepare move statement
SET @tables = CONCAT('Tables_in_axalta: ', @tables);

-- Move tables to new database
SET @stmt = CONCAT('RENAME TABLE ',
    REPLACE(
        REPLACE(
            @tables,
            'Tables_in_axalta: ',
            ''
        ),
        ',',
        '.`axalta` TO supplexio.`'
    ),
    '.`axalta` TO supplexio.`');

-- Execute the move
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop old database after successful migration
DROP DATABASE axalta;

-- Grant permissions to application user (adjust as needed)
GRANT ALL PRIVILEGES ON supplexio.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
