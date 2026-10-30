-- Fix suppliers table by adding missing user_id column
-- Run this script to fix the SQLSyntaxErrorException

USE axalta;

-- Add user_id column to suppliers table if it doesn't exist
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE table_name = 'suppliers' 
     AND column_name = 'user_id' 
     AND table_schema = 'axalta') > 0,
    'SELECT "Column user_id already exists in suppliers" as message',
    'ALTER TABLE suppliers ADD COLUMN user_id INT NULL, ADD FOREIGN KEY (user_id) REFERENCES users(id)'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Also add company_name and contact_person as real columns if they are virtual
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE table_name = 'suppliers' 
     AND column_name = 'company_name' 
     AND extra NOT LIKE '%VIRTUAL%'
     AND table_schema = 'axalta') > 0,
    'SELECT "Column company_name already exists as real column" as message',
    'ALTER TABLE suppliers DROP COLUMN company_name, ADD COLUMN company_name VARCHAR(255) NULL'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE table_name = 'suppliers' 
     AND column_name = 'contact_person' 
     AND extra NOT LIKE '%VIRTUAL%'
     AND table_schema = 'axalta') > 0,
    'SELECT "Column contact_person already exists as real column" as message',
    'ALTER TABLE suppliers DROP COLUMN contact_person, ADD COLUMN contact_person VARCHAR(255) NULL'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Update existing suppliers to have some default values
UPDATE suppliers SET 
    company_name = CONCAT(name, ' Company'),
    contact_person = email
WHERE company_name IS NULL OR contact_person IS NULL;

COMMIT;

SELECT 'Suppliers table fixed successfully!' as Status;
SELECT 'user_id, company_name, and contact_person columns are now available' as Message;