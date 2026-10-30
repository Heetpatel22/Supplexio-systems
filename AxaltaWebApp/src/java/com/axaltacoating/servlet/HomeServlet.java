package com.axaltacoating.servlet;

import com.axaltacoating.util.DatabaseStatusChecker;
import com.axaltacoating.util.DashboardCache;
import com.axaltacoating.util.DatabaseConnection;
import com.axaltacoating.model.Inventory;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet for handling home page statistics and data.
 */
public class HomeServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(HomeServlet.class.getName());
    private static final long DATABASE_TIMEOUT = 30000; // 30 seconds timeout
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is logged in
        if (request.getSession(false) == null || request.getSession().getAttribute("user") == null) {
            // Redirect to login page
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Check if database is ready
        if (!DatabaseStatusChecker.isDatabaseReady()) {
            try {
                DatabaseStatusChecker.waitForDatabase(DATABASE_TIMEOUT);
            } catch (InterruptedException e) {
                LOGGER.log(Level.SEVERE, "Timeout waiting for database initialization", e);
                response.sendRedirect(request.getContextPath() + "/please-wait.jsp");
                return;
            }
        }
        
        // Check for low stock items
        checkLowStockItems(request);
        
        // Get dashboard statistics from cache
        request.setAttribute("activeSuppliers", DashboardCache.get("activeSuppliers"));
        request.setAttribute("activeAuctions", DashboardCache.get("activeAuctions"));
        request.setAttribute("totalTransactions", DashboardCache.get("totalTransactions"));
        request.setAttribute("successRate", DashboardCache.get("successRate"));
        
        // Forward to index.jsp
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    private void checkLowStockItems(HttpServletRequest request) {
        try {
            List<Inventory> lowStockItems = getLowStockItemsFromDatabase();
            
            if (!lowStockItems.isEmpty()) {
                request.setAttribute("lowStockItems", lowStockItems);
                request.setAttribute("hasLowStockAlert", true);
                
                // Also set a simple message for backward compatibility
                StringBuilder itemNames = new StringBuilder();
                for (Inventory item : lowStockItems) {
                    itemNames.append(item.getItemName()).append(", ");
                }
                if (itemNames.length() > 0) {
                    String items = itemNames.substring(0, itemNames.length() - 2);
                    request.setAttribute("inventoryAlert", "Low stock for: " + items);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking low stock items", e);
        }
    }
    
    private List<Inventory> getLowStockItemsFromDatabase() throws SQLException {
        List<Inventory> lowStockItems = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement(
                "SELECT id, item_name, quantity, min_threshold, max_threshold, kanban_status, " +
                "needs_auction, auction_started FROM inventory " +
                "WHERE kanban_status = 'Low' OR needs_auction = true " +
                "ORDER BY quantity ASC"
            );
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Inventory item = new Inventory(
                    rs.getInt("id"),
                    rs.getString("item_name"),
                    rs.getInt("quantity"),
                    rs.getInt("min_threshold"),
                    rs.getInt("max_threshold")
                );
                item.setKanbanStatus(rs.getString("kanban_status"));
                item.setNeedsAuction(rs.getBoolean("needs_auction"));
                item.setAuctionStarted(rs.getBoolean("auction_started"));
                
                lowStockItems.add(item);
            }
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        
        return lowStockItems;
    }
}
