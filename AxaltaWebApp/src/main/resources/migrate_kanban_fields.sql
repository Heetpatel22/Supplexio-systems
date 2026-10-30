-- Migration script to add Kanban-related fields to the inventory table
-- Make sure to backup your database before running this script

USE supplexio;

-- Add new columns to the inventory table if they don't exist
ALTER TABLE inventory
ADD COLUMN IF NOT EXISTS min_threshold INT NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS max_threshold INT NOT NULL DEFAULT 100,
ADD COLUMN IF NOT EXISTS kanban_status VARCHAR(10) NOT NULL DEFAULT 'Medium',
ADD COLUMN IF NOT EXISTS auction_started BOOLEAN NOT NULL DEFAULT FALSE;

-- Update existing rows with default Kanban status based on current quantity
UPDATE inventory
SET kanban_status = CASE
    WHEN quantity <= min_threshold THEN 'Low'
    WHEN quantity >= max_threshold THEN 'High'
    ELSE 'Medium'
END;

-- Create an index on kanban_status for improved query performance
CREATE INDEX IF NOT EXISTS idx_inventory_kanban_status ON inventory (kanban_status);

-- Optionally, you can add a trigger to automatically update kanban_status when quantity changes
DELIMITER //
CREATE TRIGGER IF NOT EXISTS update_kanban_status
BEFORE UPDATE ON inventory
FOR EACH ROW
BEGIN
    IF NEW.quantity <= NEW.min_threshold THEN
        SET NEW.kanban_status = 'Low';
    ELSEIF NEW.quantity >= NEW.max_threshold THEN
        SET NEW.kanban_status = 'High';
    ELSE
        SET NEW.kanban_status = 'Medium';
    END IF;
END;
//
DELIMITER ;

-- Log the migration
INSERT INTO migration_log (script_name, executed_at) VALUES ('migrate_kanban_fields.sql', NOW());