-- Alter inventory table to update structure
ALTER TABLE inventory
    MODIFY COLUMN kanban_status ENUM('Low', 'Medium', 'High') DEFAULT 'Medium',
    ADD COLUMN IF NOT EXISTS needs_auction BOOLEAN DEFAULT FALSE AFTER kanban_status;

-- Update existing rows to set needs_auction based on kanban_status
UPDATE inventory
SET needs_auction = (kanban_status = 'Low');