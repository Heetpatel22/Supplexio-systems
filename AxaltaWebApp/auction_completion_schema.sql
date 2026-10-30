-- Additional schema for auction completion and inventory management
-- Run this script to add the required tables and columns

USE axalta;

-- Add winning_supplier_id column to reverse_auctions table
ALTER TABLE reverse_auctions 
ADD COLUMN winning_supplier_id BIGINT NULL,
ADD FOREIGN KEY (winning_supplier_id) REFERENCES suppliers(id);

-- Create auction_deliveries table to track deliveries
CREATE TABLE IF NOT EXISTS auction_deliveries (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    auction_id BIGINT NOT NULL,
    supplier_id BIGINT NOT NULL,
    winning_amount DOUBLE NOT NULL,
    delivered_quantity INT DEFAULT 0,
    status ENUM('PENDING', 'DELIVERED', 'CANCELLED') DEFAULT 'PENDING',
    delivery_date TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (auction_id) REFERENCES reverse_auctions(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- Create auction_inventory_sync table to track which inventory items need auctions
CREATE TABLE IF NOT EXISTS auction_inventory_sync (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    inventory_id INT NOT NULL,
    product_id BIGINT NULL,
    auction_id BIGINT NULL,
    sync_status ENUM('PENDING', 'AUCTION_CREATED', 'COMPLETED') DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (inventory_id) REFERENCES inventory(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (auction_id) REFERENCES reverse_auctions(id)
);

-- Update products table to ensure all inventory items have corresponding products
-- First, let's create products for inventory items that don't have them
INSERT INTO products (name, description, category, base_price, unit, stock_quantity, inventory_id, created_at)
SELECT 
    i.item_name,
    CONCAT('Auto-generated product for inventory item: ', i.item_name),
    'General',
    0.00,
    'pcs',
    i.quantity,
    i.id,
    NOW()
FROM inventory i
LEFT JOIN products p ON p.inventory_id = i.id
WHERE p.id IS NULL;

-- Create a view to show auction-ready inventory items
CREATE OR REPLACE VIEW auction_ready_items AS
SELECT 
    i.id as inventory_id,
    i.item_name,
    i.quantity,
    i.min_threshold,
    i.max_threshold,
    i.kanban_status,
    i.needs_auction,
    i.auction_started,
    p.id as product_id,
    p.name as product_name,
    p.base_price,
    p.unit,
    CASE 
        WHEN ra.id IS NOT NULL AND ra.status = 'ACTIVE' THEN 'AUCTION_ACTIVE'
        WHEN ra.id IS NOT NULL AND ra.status = 'COMPLETED' THEN 'AUCTION_COMPLETED'
        WHEN i.needs_auction = TRUE AND i.auction_started = FALSE THEN 'NEEDS_AUCTION'
        ELSE 'NO_AUCTION_NEEDED'
    END as auction_status,
    ra.id as active_auction_id
FROM inventory i
LEFT JOIN products p ON p.inventory_id = i.id
LEFT JOIN reverse_auctions ra ON ra.product_id = p.id AND ra.status IN ('ACTIVE', 'SCHEDULED')
WHERE i.needs_auction = TRUE OR ra.id IS NOT NULL;

-- Create a stored procedure to automatically create auctions for low inventory items
DELIMITER //

CREATE PROCEDURE CreateAuctionForInventoryItem(
    IN inventory_item_id INT,
    IN start_price DOUBLE,
    IN auction_duration_hours INT
)
BEGIN
    DECLARE product_id_var BIGINT;
    DECLARE auction_id_var BIGINT;
    DECLARE item_name_var VARCHAR(255);
    DECLARE required_quantity_var INT;
    
    -- Get product details
    SELECT p.id, i.item_name, (i.max_threshold - i.quantity) 
    INTO product_id_var, item_name_var, required_quantity_var
    FROM inventory i
    LEFT JOIN products p ON p.inventory_id = i.id
    WHERE i.id = inventory_item_id;
    
    -- Create auction if product exists
    IF product_id_var IS NOT NULL THEN
        INSERT INTO reverse_auctions (
            product_id, 
            start_price, 
            current_price, 
            start_time, 
            end_time, 
            status
        ) VALUES (
            product_id_var,
            start_price,
            start_price,
            NOW(),
            DATE_ADD(NOW(), INTERVAL auction_duration_hours HOUR),
            'ACTIVE'
        );
        
        SET auction_id_var = LAST_INSERT_ID();
        
        -- Update inventory to mark auction as started
        UPDATE inventory 
        SET auction_started = TRUE 
        WHERE id = inventory_item_id;
        
        -- Create sync record
        INSERT INTO auction_inventory_sync (
            inventory_id, 
            product_id, 
            auction_id, 
            sync_status
        ) VALUES (
            inventory_item_id,
            product_id_var,
            auction_id_var,
            'AUCTION_CREATED'
        );
        
        SELECT auction_id_var as auction_id, 'SUCCESS' as status, 
               CONCAT('Auction created for ', item_name_var) as message;
    ELSE
        SELECT 0 as auction_id, 'ERROR' as status, 
               'No product found for inventory item' as message;
    END IF;
END //

DELIMITER ;

-- Create a function to calculate recommended auction quantity
DELIMITER //

CREATE FUNCTION GetRecommendedAuctionQuantity(inventory_item_id INT)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE current_qty INT;
    DECLARE max_threshold_qty INT;
    DECLARE recommended_qty INT;
    
    SELECT quantity, max_threshold 
    INTO current_qty, max_threshold_qty
    FROM inventory 
    WHERE id = inventory_item_id;
    
    -- Calculate quantity needed to reach max threshold plus 20% buffer
    SET recommended_qty = CEIL((max_threshold_qty - current_qty) * 1.2);
    
    -- Ensure minimum quantity of 1
    IF recommended_qty < 1 THEN
        SET recommended_qty = 1;
    END IF;
    
    RETURN recommended_qty;
END //

DELIMITER ;

-- Insert sample data for testing
INSERT IGNORE INTO auction_deliveries (auction_id, supplier_id, winning_amount, status) 
SELECT 
    ra.id,
    1, -- Assuming supplier ID 1 exists
    ra.current_price,
    'PENDING'
FROM reverse_auctions ra 
WHERE ra.status = 'COMPLETED' 
AND NOT EXISTS (
    SELECT 1 FROM auction_deliveries ad WHERE ad.auction_id = ra.id
);

COMMIT;

SELECT 'Auction completion schema setup completed successfully!' as Status;