package com.axaltacoating.task;

import com.axaltacoating.util.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.TimerTask;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AuctionClosingTask extends TimerTask {
    private static final Logger logger = Logger.getLogger(AuctionClosingTask.class.getName());

    @Override
    public void run() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            // Step 1: Update auction status to COMPLETED for ended auctions
            String updateAuctionsSql = 
                "UPDATE reverse_auctions " +
                "SET status = 'COMPLETED' " +
                "WHERE status = 'ACTIVE' AND end_time <= NOW()";
            
            int updatedCount = 0;
            try (PreparedStatement stmt = conn.prepareStatement(updateAuctionsSql)) {
                updatedCount = stmt.executeUpdate();
                if (updatedCount > 0) {
                    logger.info("Closed " + updatedCount + " auctions");
                }
            }

            // Step 2: Set winning suppliers for completed auctions that don't have winners yet
            String setWinnersSql = 
                "UPDATE reverse_auctions ra " +
                "INNER JOIN (" +
                "    SELECT b1.auction_id, b1.user_id, b1.bid_amount " +
                "    FROM bids b1 " +
                "    WHERE b1.bid_amount = (" +
                "        SELECT MIN(b2.bid_amount) " +
                "        FROM bids b2 " +
                "        WHERE b2.auction_id = b1.auction_id" +
                "    ) " +
                "    GROUP BY b1.auction_id " +
                ") winners ON ra.id = winners.auction_id " +
                "SET ra.winning_supplier_id = winners.user_id, " +
                "    ra.current_price = winners.bid_amount " +
                "WHERE ra.status = 'COMPLETED' AND ra.winning_supplier_id IS NULL";

            try (PreparedStatement stmt = conn.prepareStatement(setWinnersSql)) {
                int winnersSet = stmt.executeUpdate();
                if (winnersSet > 0) {
                    logger.info("Set winners for " + winnersSet + " completed auctions");
                }
            }

            // Step 3: Create delivery records for completed auctions that don't have them yet
            String createDeliveriesSql = 
                "INSERT INTO auction_deliveries (auction_id, supplier_id, winning_amount, status, created_at) " +
                "SELECT ra.id, ra.winning_supplier_id, ra.current_price, 'PENDING', NOW() " +
                "FROM reverse_auctions ra " +
                "LEFT JOIN auction_deliveries ad ON ra.id = ad.auction_id " +
                "WHERE ra.status = 'COMPLETED' " +
                "AND ra.winning_supplier_id IS NOT NULL " +
                "AND ad.id IS NULL";

            try (PreparedStatement stmt = conn.prepareStatement(createDeliveriesSql)) {
                int deliveriesCreated = stmt.executeUpdate();
                if (deliveriesCreated > 0) {
                    logger.info("Created " + deliveriesCreated + " delivery records");
                }
            }

            // Step 4: Auto-deliver auctions that have been completed for more than 24 hours
            // This simulates automatic delivery and inventory update
            String autoDeliverSql = 
                "SELECT ra.id, ra.product_id, p.name, p.inventory_id, " +
                "       GREATEST(1, COALESCE(i.max_threshold - i.quantity, 1)) as delivery_quantity " +
                "FROM reverse_auctions ra " +
                "JOIN products p ON ra.product_id = p.id " +
                "LEFT JOIN inventory i ON p.inventory_id = i.id " +
                "JOIN auction_deliveries ad ON ra.id = ad.auction_id " +
                "WHERE ra.status = 'COMPLETED' " +
                "AND ad.status = 'PENDING' " +
                "AND ra.end_time <= DATE_SUB(NOW(), INTERVAL 24 HOUR)";

            try (PreparedStatement selectStmt = conn.prepareStatement(autoDeliverSql)) {
                java.sql.ResultSet rs = selectStmt.executeQuery();
                
                while (rs.next()) {
                    long auctionId = rs.getLong("id");
                    long productId = rs.getLong("product_id");
                    String productName = rs.getString("name");
                    Long inventoryId = rs.getLong("inventory_id");
                    int deliveryQuantity = rs.getInt("delivery_quantity");
                    
                    // Update inventory if inventory_id exists
                    if (inventoryId != null && inventoryId > 0) {
                        String updateInventorySql = 
                            "UPDATE inventory " +
                            "SET quantity = quantity + ?, " +
                            "    kanban_status = CASE " +
                            "        WHEN (quantity + ?) <= min_threshold THEN 'Low' " +
                            "        WHEN (quantity + ?) >= max_threshold THEN 'High' " +
                            "        ELSE 'Medium' " +
                            "    END, " +
                            "    needs_auction = ((quantity + ?) <= min_threshold), " +
                            "    auction_started = FALSE, " +
                            "    updated_at = NOW() " +
                            "WHERE id = ?";
                        
                        try (PreparedStatement updateInventoryStmt = conn.prepareStatement(updateInventorySql)) {
                            updateInventoryStmt.setInt(1, deliveryQuantity);
                            updateInventoryStmt.setInt(2, deliveryQuantity);
                            updateInventoryStmt.setInt(3, deliveryQuantity);
                            updateInventoryStmt.setInt(4, deliveryQuantity);
                            updateInventoryStmt.setLong(5, inventoryId);
                            updateInventoryStmt.executeUpdate();
                        }
                    }
                    
                    // Update product stock quantity
                    String updateProductSql = 
                        "UPDATE products SET stock_quantity = COALESCE(stock_quantity, 0) + ? WHERE id = ?";
                    try (PreparedStatement updateProductStmt = conn.prepareStatement(updateProductSql)) {
                        updateProductStmt.setInt(1, deliveryQuantity);
                        updateProductStmt.setLong(2, productId);
                        updateProductStmt.executeUpdate();
                    }
                    
                    // Mark delivery as completed
                    String markDeliveredSql = 
                        "UPDATE auction_deliveries " +
                        "SET status = 'DELIVERED', delivered_quantity = ?, delivery_date = NOW() " +
                        "WHERE auction_id = ?";
                    try (PreparedStatement markDeliveredStmt = conn.prepareStatement(markDeliveredSql)) {
                        markDeliveredStmt.setInt(1, deliveryQuantity);
                        markDeliveredStmt.setLong(2, auctionId);
                        markDeliveredStmt.executeUpdate();
                    }
                    
                    logger.info("Auto-delivered " + deliveryQuantity + " units of " + productName + 
                               " for auction " + auctionId + " and updated inventory");
                }
                rs.close();
            }

            // Step 5: Create payment records for completed auctions that don't have payments yet
            String createPaymentsSql = 
                "INSERT INTO payments (auction_id, supplier_id, amount, status, payment_method, created_at) " +
                "SELECT ra.id, ra.winning_supplier_id, ra.current_price, 'PENDING', 'NOT_SELECTED', NOW() " +
                "FROM reverse_auctions ra " +
                "LEFT JOIN payments p ON ra.id = p.auction_id " +
                "WHERE ra.status = 'COMPLETED' " +
                "AND ra.winning_supplier_id IS NOT NULL " +
                "AND p.id IS NULL";

            try (PreparedStatement stmt = conn.prepareStatement(createPaymentsSql)) {
                int insertedCount = stmt.executeUpdate();
                if (insertedCount > 0) {
                    logger.info("Created " + insertedCount + " payment records");
                }
            }
            
            conn.commit();
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error in auction closing task", e);
        }
    }
}
