-- Database setup script for Axalta Web Application
-- Run this script to create the database and all required tables

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS axalta;
USE axalta;

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) DEFAULT 'General',
    base_price DECIMAL(10,2) DEFAULT 0.00,
    unit VARCHAR(50) DEFAULT 'pcs',
    stock_quantity INT DEFAULT 0,
    inventory_id BIGINT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create suppliers table
CREATE TABLE IF NOT EXISTS suppliers (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    password VARCHAR(255) NOT NULL,
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create reverse auctions table
CREATE TABLE IF NOT EXISTS reverse_auctions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    start_price DOUBLE NOT NULL,
    current_price DOUBLE NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    status ENUM('PENDING', 'ACTIVE', 'COMPLETED', 'CANCELLED', 'SCHEDULED') DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Create bids table
CREATE TABLE IF NOT EXISTS bids (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    auction_id BIGINT NOT NULL,
    supplier_id BIGINT NOT NULL,
    user_id BIGINT,
    amount DOUBLE NOT NULL,
    bid_amount DOUBLE,
    bid_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (auction_id) REFERENCES reverse_auctions(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- Update bids table to ensure consistency
UPDATE bids SET user_id = supplier_id WHERE user_id IS NULL;
UPDATE bids SET bid_amount = amount WHERE bid_amount IS NULL;

-- Create inventory table
CREATE TABLE IF NOT EXISTS inventory (
    id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    min_threshold INT NOT NULL,
    max_threshold INT NOT NULL,
    kanban_status ENUM('Low', 'Medium', 'High') DEFAULT 'Medium',
    needs_auction BOOLEAN DEFAULT FALSE,
    auction_started BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create auction invitations table
CREATE TABLE IF NOT EXISTS auction_invitations (
    auction_id BIGINT NOT NULL,
    supplier_id BIGINT NOT NULL,
    status ENUM('PENDING', 'ACCEPTED', 'DECLINED') DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (auction_id, supplier_id),
    FOREIGN KEY (auction_id) REFERENCES reverse_auctions(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- Create payments table
CREATE TABLE IF NOT EXISTS payments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    auction_id BIGINT NOT NULL,
    supplier_id BIGINT NOT NULL,
    amount DOUBLE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    payment_method VARCHAR(20),
    transaction_id VARCHAR(100),
    payment_date TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remarks TEXT,
    FOREIGN KEY (auction_id) REFERENCES reverse_auctions(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- Insert sample inventory data
INSERT IGNORE INTO inventory (id, item_name, quantity, min_threshold, max_threshold, kanban_status, needs_auction, auction_started) VALUES
(1, 'Steel Rods', 50, 20, 100, 'Medium', FALSE, FALSE),
(2, 'Copper Sheets', 30, 10, 80, 'High', FALSE, FALSE),
(3, 'Aluminum Plates', 80, 40, 120, 'Medium', FALSE, FALSE),
(4, 'Plastic Granules', 120, 60, 200, 'Medium', FALSE, FALSE),
(5, 'Paint Buckets', 15, 25, 100, 'Low', TRUE, FALSE);

-- Update kanban status and needs_auction based on current quantities
UPDATE inventory 
SET kanban_status = CASE 
    WHEN quantity <= min_threshold THEN 'Low'
    WHEN quantity >= max_threshold THEN 'High'
    ELSE 'Medium'
END,
needs_auction = (quantity <= min_threshold);

COMMIT;

SELECT 'Database setup completed successfully!' as Status;