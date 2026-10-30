-- Add unit column to products table if it doesn't exist
USE axalta;

-- Check if column exists before adding it
SET @columnExists = 0;
SELECT COUNT(*) INTO @columnExists FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'axalta' AND TABLE_NAME = 'products' AND COLUMN_NAME = 'unit';

-- Add the column if it doesn't exist
SET @sql = IF(@columnExists = 0, 
    'ALTER TABLE products ADD COLUMN unit VARCHAR(50) DEFAULT "unit" AFTER base_price', 
    'SELECT "Column already exists"');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Update existing products to have a default unit value
UPDATE products SET unit = 'unit' WHERE unit IS NULL;

-- Show the updated table structure
DESCRIBE products;
