-- Add kanban-related fields to existing tables if they don't exist

-- For products table - add additional fields if needed
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS category VARCHAR(100) DEFAULT 'General',
ADD COLUMN IF NOT EXISTS base_price DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN IF NOT EXISTS unit VARCHAR(50) DEFAULT 'pcs',
ADD COLUMN IF NOT EXISTS stock_quantity INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS inventory_id BIGINT NULL;

-- For suppliers table - add status field if needed
ALTER TABLE suppliers 
ADD COLUMN IF NOT EXISTS status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE';

-- For reverse_auctions table - ensure proper status values
ALTER TABLE reverse_auctions 
MODIFY COLUMN status ENUM('PENDING', 'ACTIVE', 'COMPLETED', 'CANCELLED', 'SCHEDULED') DEFAULT 'PENDING';

-- For bids table - ensure proper column names
ALTER TABLE bids 
ADD COLUMN IF NOT EXISTS user_id BIGINT,
ADD COLUMN IF NOT EXISTS bid_amount DOUBLE,
ADD COLUMN IF NOT EXISTS bid_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Update bids table to use consistent column names
UPDATE bids SET user_id = supplier_id WHERE user_id IS NULL;
UPDATE bids SET bid_amount = amount WHERE bid_amount IS NULL;

-- For auction_invitations table - add status field
ALTER TABLE auction_invitations 
ADD COLUMN IF NOT EXISTS status ENUM('PENDING', 'ACCEPTED', 'DECLINED') DEFAULT 'PENDING';