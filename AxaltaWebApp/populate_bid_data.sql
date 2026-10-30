-- Script to populate bid_chart_data with sample data for testing

-- First, ensure the bid_chart_data table exists
CREATE TABLE IF NOT EXISTS bid_chart_data (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    auction_id INT NOT NULL,
    bid_time TIMESTAMP NOT NULL,
    bid_amount DOUBLE NOT NULL,
    supplier_id INT NOT NULL,
    supplier_name VARCHAR(255),
    bid_id INT,
    FOREIGN KEY (auction_id) REFERENCES reverse_auctions(id) ON DELETE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE,
    INDEX idx_auction_time (auction_id, bid_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Clear existing data for the auction (if any)
DELETE FROM bid_chart_data WHERE auction_id = 1;

-- Insert sample bid data with decreasing prices over time
INSERT INTO bid_chart_data (auction_id, bid_time, bid_amount, supplier_id, supplier_name, bid_id)
VALUES
(1, '2025-05-19 14:40:00', 9000.00, 1, 'Vaibhav Suthar', 1),
(1, '2025-05-19 14:41:00', 8500.00, 1, 'Vaibhav Suthar', 2),
(1, '2025-05-19 14:42:00', 8000.00, 1, 'Vaibhav Suthar', 3),
(1, '2025-05-19 14:43:00', 7500.00, 1, 'Vaibhav Suthar', 4),
(1, '2025-05-19 14:44:00', 7000.00, 1, 'Vaibhav Suthar', 5),
(1, '2025-05-19 14:45:00', 6500.00, 1, 'Vaibhav Suthar', 6),
(1, '2025-05-19 14:46:00', 6000.00, 1, 'Vaibhav Suthar', 7),
(1, '2025-05-19 14:47:00', 5500.00, 1, 'Vaibhav Suthar', 8),
(1, '2025-05-19 14:48:00', 5000.00, 1, 'Vaibhav Suthar', 9),
(1, '2025-05-19 14:49:00', 4500.00, 1, 'Vaibhav Suthar', 10),
(1, '2025-05-19 14:50:00', 4000.00, 1, 'Vaibhav Suthar', 11),
(1, '2025-05-19 14:51:00', 3500.00, 1, 'Vaibhav Suthar', 12),
(1, '2025-05-19 14:52:00', 3000.00, 1, 'Vaibhav Suthar', 13),
(1, '2025-05-19 14:53:00', 2500.00, 1, 'Vaibhav Suthar', 14),
(1, '2025-05-19 14:54:00', 2000.00, 1, 'Vaibhav Suthar', 15),
(1, '2025-05-19 14:55:00', 1500.00, 1, 'Vaibhav Suthar', 16),
(1, '2025-05-19 14:56:00', 1000.00, 1, 'Vaibhav Suthar', 17),
(1, '2025-05-19 14:57:00', 900.00, 1, 'Vaibhav Suthar', 18);

-- Also insert corresponding records into the bids table if they don't exist
INSERT IGNORE INTO bids (id, auction_id, user_id, bid_amount, bid_time)
VALUES
(1, 1, 1, 9000.00, '2025-05-19 14:40:00'),
(2, 1, 1, 8500.00, '2025-05-19 14:41:00'),
(3, 1, 1, 8000.00, '2025-05-19 14:42:00'),
(4, 1, 1, 7500.00, '2025-05-19 14:43:00'),
(5, 1, 1, 7000.00, '2025-05-19 14:44:00'),
(6, 1, 1, 6500.00, '2025-05-19 14:45:00'),
(7, 1, 1, 6000.00, '2025-05-19 14:46:00'),
(8, 1, 1, 5500.00, '2025-05-19 14:47:00'),
(9, 1, 1, 5000.00, '2025-05-19 14:48:00'),
(10, 1, 1, 4500.00, '2025-05-19 14:49:00'),
(11, 1, 1, 4000.00, '2025-05-19 14:50:00'),
(12, 1, 1, 3500.00, '2025-05-19 14:51:00'),
(13, 1, 1, 3000.00, '2025-05-19 14:52:00'),
(14, 1, 1, 2500.00, '2025-05-19 14:53:00'),
(15, 1, 1, 2000.00, '2025-05-19 14:54:00'),
(16, 1, 1, 1500.00, '2025-05-19 14:55:00'),
(17, 1, 1, 1000.00, '2025-05-19 14:56:00'),
(18, 1, 1, 900.00, '2025-05-19 14:57:00');
