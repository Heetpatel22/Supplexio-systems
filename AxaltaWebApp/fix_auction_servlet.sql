-- Quick fix to add missing columns and tables
USE axalta;

-- Add winning_supplier_id column to reverse_auctions table
ALTER TABLE reverse_auctions ADD COLUMN winning_supplier_id BIGINT NULL;

-- Create auction_deliveries table
CREATE TABLE auction_deliveries (
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

-- Create auction_inventory_sync table
CREATE TABLE auction_inventory_sync (
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

-- Create products for inventory items that don't have them
INSERT IGNORE INTO products (name, description, category, base_price, unit, stock_quantity, inventory_id, created_at)
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

SELECT 'Tables created successfully!' as Status;