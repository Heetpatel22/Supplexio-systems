-- Purchase Orders Table
CREATE TABLE IF NOT EXISTS purchase_orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    auction_id BIGINT NOT NULL,
    supplier_id BIGINT NOT NULL,
    company_name VARCHAR(255),
    material VARCHAR(255),
    amount DOUBLE NOT NULL,
    status ENUM('PENDING', 'SENT', 'DELIVERED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (auction_id) REFERENCES reverse_auctions(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);
