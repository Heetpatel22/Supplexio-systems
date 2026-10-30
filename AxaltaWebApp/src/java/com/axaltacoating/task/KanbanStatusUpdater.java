package com.axaltacoating.task;

import com.axaltacoating.model.Inventory;
import com.axaltacoating.util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class KanbanStatusUpdater implements Runnable {

    private static final Logger LOGGER = Logger.getLogger(KanbanStatusUpdater.class.getName());
    private static final long UPDATE_INTERVAL = 3600000; // 1 hour in milliseconds

    @Override
    public void run() {
        while (!Thread.currentThread().isInterrupted()) {
            try {
                updateKanbanStatuses();
                Thread.sleep(UPDATE_INTERVAL);
            } catch (InterruptedException e) {
                LOGGER.log(Level.INFO, "KanbanStatusUpdater interrupted", e);
                Thread.currentThread().interrupt();
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error in KanbanStatusUpdater", e);
            }
        }
    }

    private void updateKanbanStatuses() {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT id, quantity, min_threshold, max_threshold FROM inventory";
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();

            while (rs.next()) {
                int id = rs.getInt("id");
                int quantity = rs.getInt("quantity");
                int minThreshold = rs.getInt("min_threshold");
                int maxThreshold = rs.getInt("max_threshold");

                Inventory item = new Inventory(id, "", quantity, minThreshold, maxThreshold);
                String newStatus = item.getKanbanStatus();

                updateInventoryStatus(conn, id, newStatus);
            }

            LOGGER.info("Kanban statuses updated successfully");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating Kanban statuses", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }

    private void updateInventoryStatus(Connection conn, int id, String status) throws SQLException {
        String sql = "UPDATE inventory SET kanban_status = ? WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, id);
            stmt.executeUpdate();
        }
    }
}