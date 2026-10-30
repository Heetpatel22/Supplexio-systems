-- Create missing tables for auction functionality
-- Run this script to fix the SQLSyntaxErrorException

USE axalta;

-- Create auction_deliveries table if it doesn't exist
CREATE TABLE IF NOT EXISTS auction_deliveries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    auction_id INT NOT NULL,
    supplier_id INT NOT NULL,
    winning_amount DOUBLE NOT NULL,
    delivered_quantity INT DEFAULT 0,
    status ENUM('PENDING', 'DELIVERED', 'CANCELLED') DEFAULT 'PENDING',
    delivery_date TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (auction_id) REFERENCES reverse_auctions(id) ON DELETE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE
);

-- Add winning_supplier_id column to reverse_auctions table if it doesn't exist
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE table_name = 'reverse_auctions' 
     AND column_name = 'winning_supplier_id' 
     AND table_schema = 'axalta') > 0,
    'SELECT "Column winning_supplier_id already exists" as message',
    'ALTER TABLE reverse_auctions ADD COLUMN winning_supplier_id INT NULL, ADD FOREIGN KEY (winning_supplier_id) REFERENCES suppliers(id)'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Ensure products have inventory_id column
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE table_name = 'products' 
     AND column_name = 'inventory_id' 
     AND table_schema = 'axalta') > 0,
    'SELECT "Column inventory_id already exists in products" as message',
    'ALTER TABLE products ADD COLUMN inventory_id INT NULL, ADD FOREIGN KEY (inventory_id) REFERENCES inventory(id)'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Create products for inventory items that don't have them
INSERT IGNORE INTO products (name, description, category, base_price, unit, stock_quantity, inventory_id, created_at)
SELECT 
    i.item_name,
    CONCAT('Auto-generated product for inventory item: ', i.item_name),
    'General',
    100.00, -- Default base price
    'pcs',   -- Default unit
    i.quantity,
    i.id,
    NOW()
FROM inventory i
LEFT JOIN products p ON p.inventory_id = i.id
WHERE p.id IS NULL;

-- Create some sample auction deliveries for testing
INSERT IGNORE INTO auction_deliveries (auction_id, supplier_id, winning_amount, status) 
SELECT 
    ra.id,
    COALESCE(ra.winning_supplier_id, 1), -- Use winning supplier or default to supplier 1
    ra.current_price,
    'PENDING'
FROM reverse_auctions ra 
WHERE ra.status = 'COMPLETED' 
AND NOT EXISTS (
    SELECT 1 FROM auction_deliveries ad WHERE ad.auction_id = ra.id
)
LIMIT 5; -- Limit to avoid too many records

COMMIT;

SELECT 'Missing tables created successfully!' as Status;
SELECT 'auction_deliveries table is now available' as Message;