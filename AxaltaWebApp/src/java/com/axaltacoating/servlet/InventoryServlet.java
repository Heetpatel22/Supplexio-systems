package com.axaltacoating.servlet;

import com.axaltacoating.model.Inventory;
import com.axaltacoating.util.DatabaseConnection;
import com.google.gson.Gson;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "InventoryServlet", urlPatterns = {"/inventory"})
public class InventoryServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(InventoryServlet.class.getName());
    private static final int ITEMS_PER_PAGE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "edit":
                showEditForm(request, response);
                break;
            case "list":
                listInventory(request, response);
                break;
            case "ajaxList":
                ajaxListInventory(request, response);
                break;
            default:
                listInventory(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        switch (action) {
            case "update":
                updateInventory(request, response);
                break;
            case "startAuction":
                startAuction(request, response);
                break;
            case "getProductId":
                getProductId(request, response);
                break;
            default:
                listInventory(request, response);
                break;
        }
    }

    private void listInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int totalItems = getTotalInventoryCount();
            int totalPages = (int) Math.ceil((double) totalItems / ITEMS_PER_PAGE);
            
            // Get initial inventory data for the first page
            List<Inventory> inventoryList = getInventoryPage(1, ITEMS_PER_PAGE);

            request.setAttribute("totalItems", totalItems);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("inventory", inventoryList);
            request.getRequestDispatcher("/WEB-INF/views/inventory/list.jsp").forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Error retrieving inventory count", e);
        }
    }

    private void ajaxListInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            page = Integer.parseInt(pageStr);
        }

        String searchTerm = request.getParameter("search");
        String kanbanFilter = request.getParameter("filter");
        String auctionFilter = request.getParameter("auctionFilter");

        try {
            List<Inventory> inventoryList = getFilteredInventoryPage(page, ITEMS_PER_PAGE, searchTerm, kanbanFilter, auctionFilter);
            int totalItems = getFilteredInventoryCount(searchTerm, kanbanFilter, auctionFilter);
            int totalPages = (int) Math.ceil((double) totalItems / ITEMS_PER_PAGE);

            // Calculate summary counts from all inventory (not just current page)
            Map<String, Integer> summaryCounts = getInventorySummaryCounts();

            Map<String, Object> responseData = new HashMap<>();
            responseData.put("inventory", inventoryList);
            responseData.put("currentPage", page);
            responseData.put("totalPages", totalPages);
            responseData.put("totalItems", totalItems);
            responseData.put("lowCount", summaryCounts.get("lowCount"));
            responseData.put("mediumCount", summaryCounts.get("mediumCount"));
            responseData.put("highCount", summaryCounts.get("highCount"));
            responseData.put("auctionNeededCount", summaryCounts.get("auctionNeededCount"));

            Gson gson = new Gson();
            String jsonResponse = gson.toJson(responseData);

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(jsonResponse);

        } catch (SQLException e) {
            throw new ServletException("Error retrieving inventory", e);
        }
    }

    private int getTotalInventoryCount() throws SQLException {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM inventory");
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    private List<Inventory> getInventoryPage(int page, int itemsPerPage) throws SQLException {
        List<Inventory> inventoryList = new ArrayList<>();
        int offset = (page - 1) * itemsPerPage;

        String sql = "SELECT id, item_name, quantity, min_threshold, max_threshold, kanban_status, auction_started, needs_auction " +
                     "FROM inventory ORDER BY item_name LIMIT ? OFFSET ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, itemsPerPage);
            stmt.setInt(2, offset);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Inventory item = new Inventory(
                        rs.getInt("id"),
                        rs.getString("item_name"),
                        rs.getInt("quantity"),
                        rs.getInt("min_threshold"),
                        rs.getInt("max_threshold")
                    );
                    item.setKanbanStatus(rs.getString("kanban_status"));
                    item.setAuctionStarted(rs.getBoolean("auction_started"));
                    item.setNeedsAuction(rs.getBoolean("needs_auction"));
                    inventoryList.add(item);
                }
            }
        }

        return inventoryList;
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/inventory");
            return;
        }

        int id = Integer.parseInt(idParam);
        Inventory item = null;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement("SELECT * FROM inventory WHERE id = ?");
            stmt.setInt(1, id);
            rs = stmt.executeQuery();

            if (rs.next()) {
                item = new Inventory(
                    rs.getInt("id"),
                    rs.getString("item_name"),
                    rs.getInt("quantity"),
                    rs.getInt("min_threshold"),
                    rs.getInt("max_threshold")
                );
                item.setKanbanStatus(rs.getString("kanban_status"));
                item.setAuctionStarted(rs.getBoolean("auction_started"));
            }

            if (item != null) {
                request.setAttribute("item", item);
                request.getRequestDispatcher("/WEB-INF/views/inventory/edit.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/inventory");
            }

        } catch (SQLException e) {
            throw new ServletException("Error retrieving inventory item for edit", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }

    private void updateInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        String quantityParam = request.getParameter("quantity");
        String minThresholdParam = request.getParameter("minThreshold");
        String maxThresholdParam = request.getParameter("maxThreshold");

        if (idParam == null || idParam.isEmpty() || quantityParam == null || quantityParam.isEmpty() ||
            minThresholdParam == null || minThresholdParam.isEmpty() || maxThresholdParam == null || maxThresholdParam.isEmpty()) {
            request.setAttribute("error", "All fields are required");
            listInventory(request, response);
            return;
        }

        int id = Integer.parseInt(idParam);
        int quantity = Integer.parseInt(quantityParam);
        int minThreshold = Integer.parseInt(minThresholdParam);
        int maxThreshold = Integer.parseInt(maxThresholdParam);

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();
            Inventory updatedItem = new Inventory(id, "", quantity, minThreshold, maxThreshold);
            updatedItem.setQuantity(quantity); // This will trigger the Kanban status update

            stmt = conn.prepareStatement("UPDATE inventory SET quantity = ?, min_threshold = ?, max_threshold = ?, kanban_status = ? WHERE id = ?");
            stmt.setInt(1, quantity);
            stmt.setInt(2, minThreshold);
            stmt.setInt(3, maxThreshold);
            stmt.setString(4, updatedItem.getKanbanStatus());
            stmt.setInt(5, id);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                LOGGER.log(Level.INFO, "Inventory item updated: ID = {0}, New Quantity = {1}, New Kanban Status = {2}", 
                    new Object[]{id, quantity, updatedItem.getKanbanStatus()});
                
                if (checkIfAuctionNeeded(updatedItem)) {
                    request.setAttribute("auctionNeeded", true);
                    request.setAttribute("itemId", id);
                    LOGGER.log(Level.WARNING, "Auction needed for item: ID = {0}", id);
                    triggerAutomaticAuction(id);
                }

                request.setAttribute("success", "Inventory updated successfully");
            } else {
                LOGGER.log(Level.WARNING, "Failed to update inventory item: ID = {0}", id);
                request.setAttribute("error", "Failed to update inventory");
            }

            listInventory(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating inventory", e);
            throw new ServletException("Error updating inventory", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }

    private boolean checkIfAuctionNeeded(Inventory item) {
        return "Low".equals(item.getKanbanStatus()) && !item.isAuctionStarted();
    }

    private void triggerAutomaticAuction(int itemId) {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement("UPDATE inventory SET auction_started = TRUE WHERE id = ?");
            stmt.setInt(1, itemId);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                LOGGER.log(Level.INFO, "Automatic auction triggered for item: ID = {0}", itemId);
            } else {
                LOGGER.log(Level.WARNING, "Failed to trigger automatic auction for item: ID = {0}", itemId);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error triggering automatic auction", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }

    private void startAuction(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String itemIdParam = request.getParameter("itemId");
        if (itemIdParam == null || itemIdParam.isEmpty()) {
            sendJsonResponse(response, false, "Item ID is required");
            return;
        }

        int itemId = Integer.parseInt(itemIdParam);
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement("UPDATE inventory SET auction_started = TRUE WHERE id = ?");
            stmt.setInt(1, itemId);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                sendJsonResponse(response, true, "Auction started successfully");
            } else {
                sendJsonResponse(response, false, "Failed to start auction");
            }

        } catch (SQLException e) {
            sendJsonResponse(response, false, "Error starting auction: " + e.getMessage());
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }

    /**
     * Gets the product ID associated with an inventory item.
     */
    private void getProductId(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String itemIdParam = request.getParameter("itemId");
        
        if (itemIdParam == null || itemIdParam.isEmpty()) {
            sendJsonResponse(response, false, "Item ID is required");
            return;
        }
        
        int itemId = Integer.parseInt(itemIdParam);
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement(
                "SELECT p.id as product_id FROM products p " +
                "WHERE p.inventory_id = ?"
            );
            stmt.setInt(1, itemId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                long productId = rs.getLong("product_id");
                
                response.setContentType("application/json");
                response.getWriter().write(String.format(
                    "{\"success\": true, \"productId\": %d}",
                    productId
                ));
            } else {
                sendJsonResponse(response, false, "No product found for this inventory item");
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting product ID", e);
            sendJsonResponse(response, false, "Error getting product ID: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing database resources", e);
            }
        }
    }

    private List<Inventory> getFilteredInventoryPage(int page, int itemsPerPage, String searchTerm, String kanbanFilter, String auctionFilter) throws SQLException {
        List<Inventory> inventoryList = new ArrayList<>();
        int offset = (page - 1) * itemsPerPage;

        StringBuilder sql = new StringBuilder("SELECT id, item_name, quantity, min_threshold, max_threshold, kanban_status, auction_started, needs_auction FROM inventory WHERE 1=1");
        List<Object> parameters = new ArrayList<>();

        // Add search filter
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND LOWER(item_name) LIKE ?");
            parameters.add("%" + searchTerm.toLowerCase() + "%");
        }

        // Add kanban status filter
        if (kanbanFilter != null && !kanbanFilter.trim().isEmpty()) {
            sql.append(" AND kanban_status = ?");
            parameters.add(kanbanFilter);
        }

        // Add auction filter
        if (auctionFilter != null && !auctionFilter.trim().isEmpty()) {
            switch (auctionFilter) {
                case "needed":
                    sql.append(" AND needs_auction = TRUE");
                    break;
                case "started":
                    sql.append(" AND auction_started = TRUE");
                    break;
                case "none":
                    sql.append(" AND needs_auction = FALSE AND auction_started = FALSE");
                    break;
            }
        }

        sql.append(" ORDER BY item_name LIMIT ? OFFSET ?");
        parameters.add(itemsPerPage);
        parameters.add(offset);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < parameters.size(); i++) {
                stmt.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Inventory item = new Inventory(
                        rs.getInt("id"),
                        rs.getString("item_name"),
                        rs.getInt("quantity"),
                        rs.getInt("min_threshold"),
                        rs.getInt("max_threshold")
                    );
                    item.setKanbanStatus(rs.getString("kanban_status"));
                    item.setAuctionStarted(rs.getBoolean("auction_started"));
                    item.setNeedsAuction(rs.getBoolean("needs_auction"));
                    inventoryList.add(item);
                }
            }
        }

        return inventoryList;
    }

    private int getFilteredInventoryCount(String searchTerm, String kanbanFilter, String auctionFilter) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM inventory WHERE 1=1");
        List<Object> parameters = new ArrayList<>();

        // Add search filter
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND LOWER(item_name) LIKE ?");
            parameters.add("%" + searchTerm.toLowerCase() + "%");
        }

        // Add kanban status filter
        if (kanbanFilter != null && !kanbanFilter.trim().isEmpty()) {
            sql.append(" AND kanban_status = ?");
            parameters.add(kanbanFilter);
        }

        // Add auction filter
        if (auctionFilter != null && !auctionFilter.trim().isEmpty()) {
            switch (auctionFilter) {
                case "needed":
                    sql.append(" AND needs_auction = TRUE");
                    break;
                case "started":
                    sql.append(" AND auction_started = TRUE");
                    break;
                case "none":
                    sql.append(" AND needs_auction = FALSE AND auction_started = FALSE");
                    break;
            }
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < parameters.size(); i++) {
                stmt.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    private Map<String, Integer> getInventorySummaryCounts() throws SQLException {
        Map<String, Integer> counts = new HashMap<>();
        counts.put("lowCount", 0);
        counts.put("mediumCount", 0);
        counts.put("highCount", 0);
        counts.put("auctionNeededCount", 0);

        String sql = "SELECT kanban_status, needs_auction, COUNT(*) as count FROM inventory GROUP BY kanban_status, needs_auction";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                String status = rs.getString("kanban_status");
                boolean needsAuction = rs.getBoolean("needs_auction");
                int count = rs.getInt("count");

                switch (status) {
                    case "Low":
                        counts.put("lowCount", counts.get("lowCount") + count);
                        break;
                    case "Medium":
                        counts.put("mediumCount", counts.get("mediumCount") + count);
                        break;
                    case "High":
                        counts.put("highCount", counts.get("highCount") + count);
                        break;
                }

                if (needsAuction) {
                    counts.put("auctionNeededCount", counts.get("auctionNeededCount") + count);
                }
            }
        }

        return counts;
    }

    private void sendJsonResponse(HttpServletResponse response, boolean success, String message) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String jsonResponse = String.format("{\"success\": %b, \"message\": \"%s\"}", success, message);
        response.getWriter().write(jsonResponse);
    }

}