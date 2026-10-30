package com.axaltacoating.servlet;

import com.axaltacoating.model.Bid;
import com.axaltacoating.model.ReverseAuction;
import com.axaltacoating.model.Supplier;
import com.axaltacoating.util.DatabaseConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet for handling supplier bidding operations.
 */
@WebServlet(name = "BiddingServlet", urlPatterns = {"/bidding"})
public class BiddingServlet extends HttpServlet {

    /**
     * Handles the HTTP GET method.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "login":
                showLoginForm(request, response);
                break;
            case "logout":
                logout(request, response);
                break;
            case "view":
                viewAuction(request, response);
                break;
            default:
                listAuctions(request, response);
                break;
        }
    }

    /**
     * Handles the HTTP POST method.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        switch (action) {
            case "login":
                login(request, response);
                break;
            case "bid":
                placeBid(request, response);
                break;
            default:
                listAuctions(request, response);
                break;
        }
    }

    /**
     * Shows the login form.
     */
    private void showLoginForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/bidding/login.jsp").forward(request, response);
    }

    /**
     * Processes the login.
     */
    private void login(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String name = request.getParameter("name");
        
        if (email == null || email.trim().isEmpty() || name == null || name.trim().isEmpty()) {
            request.setAttribute("error", "Email and name are required");
            showLoginForm(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement(
                "SELECT * FROM suppliers WHERE email = ? AND name = ? AND status = 'ACTIVE'"
            );
            stmt.setString(1, email);
            stmt.setString(2, name);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                Supplier supplier = new Supplier();
                supplier.setId(rs.getLong("id"));
                supplier.setName(rs.getString("name"));
                supplier.setEmail(rs.getString("email"));
                supplier.setPhone(rs.getString("phone"));
                supplier.setAddress(rs.getString("address"));
                supplier.setStatus(rs.getString("status"));
                
                HttpSession session = request.getSession();
                session.setAttribute("supplier", supplier);
                
                response.sendRedirect(request.getContextPath() + "/bidding");
            } else {
                request.setAttribute("error", "Invalid email or name, or your account is not active");
                showLoginForm(request, response);
            }
            
        } catch (SQLException e) {
            throw new ServletException("Error during login", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }

    /**
     * Logs out the supplier.
     */
    private void logout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        response.sendRedirect(request.getContextPath() + "/bidding?action=login");
    }

    /**
     * Lists auctions available for bidding.
     */
    private void listAuctions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("supplier") == null) {
            response.sendRedirect(request.getContextPath() + "/bidding?action=login");
            return;
        }
        
        Supplier supplier = (Supplier) session.getAttribute("supplier");
        List<ReverseAuction> auctions = getActiveAuctions(supplier.getId());
        request.setAttribute("auctions", auctions);
        // WITH THIS — actually load the supplier's POs:
        request.setAttribute("purchaseOrders", getSupplierPurchaseOrders(supplier.getId())); // Empty list for now, POs shown on dedicated page
        request.getRequestDispatcher("/WEB-INF/views/bidding/list.jsp").forward(request, response);
    }

    /**
     * Views a specific auction for bidding.
     */
    private void viewAuction(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("supplier") == null) {
            response.sendRedirect(request.getContextPath() + "/bidding?action=login");
            return;
        }
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/bidding");
            return;
        }
        
        long id = Long.parseLong(idParam);
        Supplier supplier = (Supplier) session.getAttribute("supplier");
        
        // Check if supplier is invited to this auction
        if (!isSupplierInvited(supplier.getId(), id)) {
            request.setAttribute("error", "You are not invited to this auction");
            listAuctions(request, response);
            return;
        }
        
        ReverseAuction auction = getAuctionById(id);
        if (auction == null) {
            response.sendRedirect(request.getContextPath() + "/bidding");
            return;
        }
        
        // Get supplier's previous bids for this auction
        List<Bid> supplierBids = getSupplierBids(supplier.getId(), id);
        request.setAttribute("supplierBids", supplierBids);
        
        // Get all bids for this auction (anonymized)
        List<Object[]> allBids = getAllBids(id);
        request.setAttribute("allBids", allBids);
        
        request.setAttribute("auction", auction);
        request.setAttribute("currentTimeMillis", System.currentTimeMillis());
        request.setAttribute("isAuctionActive", "ACTIVE".equals(auction.getStatus()) && 
            System.currentTimeMillis() >= auction.getStartTime().getTime() && 
            System.currentTimeMillis() <= auction.getEndTime().getTime());
        request.getRequestDispatcher("/WEB-INF/views/bidding/view.jsp").forward(request, response);
    }

    /**
     * Places a bid on an auction.
     */
    private void placeBid(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("supplier") == null) {
            response.sendRedirect(request.getContextPath() + "/bidding?action=login");
            return;
        }
        
        String auctionIdParam = request.getParameter("auctionId");
        String bidAmountParam = request.getParameter("amount");
        
        if (auctionIdParam == null || auctionIdParam.isEmpty() || 
            bidAmountParam == null || bidAmountParam.isEmpty()) {
            
            request.setAttribute("error", "Auction ID and bid amount are required");
            listAuctions(request, response);
            return;
        }
        
        try {
            long auctionId = Long.parseLong(auctionIdParam);
            double bidAmount = Double.parseDouble(bidAmountParam);
            Supplier supplier = (Supplier) session.getAttribute("supplier");
            
            // Check if supplier is invited to this auction
            if (!isSupplierInvited(supplier.getId(), auctionId)) {
                request.setAttribute("error", "You are not invited to this auction");
                listAuctions(request, response);
                return;
            }
            
            // Get auction details
            ReverseAuction auction = getAuctionById(auctionId);
            if (auction == null) {
                request.setAttribute("error", "Auction not found");
                listAuctions(request, response);
                return;
            }
            
            // Check if auction is active
            if (!"ACTIVE".equals(auction.getStatus())) {
                request.setAttribute("error", "This auction is no longer active");
                viewAuction(request, response);
                return;
            }
            
            // Check if auction has started
            Date now = new Date();
            if (now.before(auction.getStartTime())) {
                request.setAttribute("error", "This auction has not started yet");
                viewAuction(request, response);
                return;
            }
            
            // Check if auction has ended
            if (now.after(auction.getEndTime())) {
                request.setAttribute("error", "This auction has already ended");
                viewAuction(request, response);
                return;
            }
            
            // Check if bid amount is lower than current price
            if (bidAmount >= auction.getCurrentPrice()) {
                request.setAttribute("error", "Your bid must be lower than the current price");
                viewAuction(request, response);
                return;
            }
            
            Connection conn = null;
            PreparedStatement stmt = null;
            
            try {
                conn = DatabaseConnection.getConnection();
                conn.setAutoCommit(false);
                
                // Insert the bid
                stmt = conn.prepareStatement(
                    "INSERT INTO bids (auction_id, supplier_id, amount, bid_time) VALUES (?, ?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS
                );
                stmt.setLong(1, auctionId);
                stmt.setLong(2, supplier.getId());
                stmt.setDouble(3, bidAmount);
                stmt.setTimestamp(4, new Timestamp(now.getTime()));
                
                int affectedRows = stmt.executeUpdate();
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                long bidId = -1;
                if (generatedKeys.next()) {
                    bidId = generatedKeys.getLong(1);
                }
                generatedKeys.close();
                stmt.close();
                
                if (affectedRows > 0) {
                    // Update the auction's current price
                    stmt = conn.prepareStatement(
                        "UPDATE reverse_auctions SET current_price = ? WHERE id = ?"
                    );
                    stmt.setDouble(1, bidAmount);
                    stmt.setLong(2, auctionId);
                    stmt.executeUpdate();
                    
                    // Insert data into bid_chart_data table for charting
                    // Using the bidId to reference the original bid
                    stmt = conn.prepareStatement(
                        "INSERT INTO bid_chart_data (auction_id, bid_time, amount, supplier_id, supplier_name, bid_id) " +
                        "VALUES (?, ?, ?, ?, ?, ?)"
                    );
                    stmt.setLong(1, auctionId);
                    stmt.setTimestamp(2, new Timestamp(now.getTime()));
                    stmt.setDouble(3, bidAmount);
                    stmt.setLong(4, supplier.getId());
                    stmt.setString(5, supplier.getName());
                    stmt.setLong(6, bidId);
                    stmt.executeUpdate();
                    
                    conn.commit();
                    request.setAttribute("success", "Your bid has been placed successfully");
                } else {
                    conn.rollback();
                    request.setAttribute("error", "Failed to place bid");
                }
                
            } catch (SQLException e) {
                try {
                    if (conn != null) {
                        conn.rollback();
                    }
                } catch (SQLException ex) {
                    // Ignore
                }
                throw new ServletException("Error placing bid", e);
            } finally {
                try {
                    if (conn != null) {
                        conn.setAutoCommit(true);
                    }
                } catch (SQLException e) {
                    // Ignore
                }
                DatabaseConnection.closeQuietly(null, stmt, conn);
            }
            
            viewAuction(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid bid amount");
            viewAuction(request, response);
        }
    }

    /**
     * Checks if a supplier is invited to an auction.
     */
    private boolean isSupplierInvited(long supplierId, long auctionId) throws ServletException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM auction_invitations WHERE supplier_id = ? AND auction_id = ?"
            );
            stmt.setLong(1, supplierId);
            stmt.setLong(2, auctionId);
            rs = stmt.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                return true;
            }
            
        } catch (SQLException e) {
            throw new ServletException("Error checking invitation", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        
        return false;
    }

    /**
     * Gets an auction by ID.
     */
    private ReverseAuction getAuctionById(long id) throws ServletException {
        ReverseAuction auction = null;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement(
                "SELECT a.*, p.name as product_name, p.unit " +
                "FROM reverse_auctions a " +
                "JOIN products p ON a.product_id = p.id " +
                "WHERE a.id = ?"
            );
            stmt.setLong(1, id);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                auction = new ReverseAuction();
                auction.setId(rs.getLong("id"));
                auction.setProductId(rs.getLong("product_id"));
                auction.setProductName(rs.getString("product_name"));
                auction.setRequiredQuantity(rs.getInt("required_quantity"));
                auction.setUnit(rs.getString("unit"));
                auction.setStartingPrice(rs.getDouble("start_price"));
                auction.setCurrentPrice(rs.getDouble("current_price"));
                auction.setStartTime(rs.getTimestamp("start_time"));
                auction.setEndTime(rs.getTimestamp("end_time"));
                auction.setStatus(rs.getString("status"));
            }
            
        } catch (SQLException e) {
            throw new ServletException("Error retrieving auction", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        
        return auction;
    }

    /**
     * Gets a supplier's bids for an auction.
     */
    private List<Bid> getSupplierBids(long supplierId, long auctionId) throws ServletException {
        List<Bid> bids = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement(
                "SELECT * FROM bids WHERE supplier_id = ? AND auction_id = ? ORDER BY bid_time DESC"
            );
            stmt.setLong(1, supplierId);
            stmt.setLong(2, auctionId);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Bid bid = new Bid();
                bid.setId(rs.getLong("id"));
                bid.setAuctionId(rs.getLong("auction_id"));
                bid.setSupplierId(rs.getLong("supplier_id"));
                bid.setAmount(rs.getDouble("amount"));
                bid.setBidTime(rs.getTimestamp("bid_time"));
                bids.add(bid);
            }
            
        } catch (SQLException e) {
            throw new ServletException("Error retrieving supplier bids", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
        
        return bids;
    }

    /**
     * Gets all bids for an auction (anonymized).
     */
    private List<Object[]> getAllBids(long auctionId) throws ServletException {
    List<Object[]> bids = new ArrayList<>();
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        conn = DatabaseConnection.getConnection();
        stmt = conn.prepareStatement(
            "SELECT b.id, b.auction_id, b.supplier_id, b.amount, b.bid_time, s.name AS supplier_name " +
            "FROM bids b " +
            "JOIN suppliers s ON b.supplier_id = s.id " +
            "WHERE b.auction_id = ? " +
            "ORDER BY b.amount ASC, b.bid_time ASC"
        );
        stmt.setLong(1, auctionId);
        rs = stmt.executeQuery();

        while (rs.next()) {
            Object[] bidInfo = new Object[2];

            Bid bid = new Bid();
            bid.setId(rs.getLong("id"));
            bid.setAuctionId(rs.getLong("auction_id"));
            bid.setSupplierId(rs.getLong("supplier_id"));
            bid.setAmount(rs.getDouble("amount"));
            bid.setBidTime(rs.getTimestamp("bid_time"));

            bidInfo[0] = bid;
            bidInfo[1] = rs.getString("supplier_name");

            bids.add(bidInfo);
        }

    } catch (SQLException e) {
        throw new ServletException("Error retrieving all bids", e);
    } finally {
        DatabaseConnection.closeQuietly(rs, stmt, conn);
    }

    return bids;
}


    /**
     * Calculates the auction status based on start and end times.
     */
    private String calculateAuctionStatus(Date startTime, Date endTime) {
        Date now = new Date();
        
        if (now.before(startTime)) {
            return "SCHEDULED";
        } else if (now.after(endTime)) {
            return "COMPLETED";
        } else {
            return "ACTIVE";
        }
    }

    private List<ReverseAuction> getActiveAuctions(long supplierId) throws ServletException {
    List<ReverseAuction> auctions = new ArrayList<>();
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        conn = DatabaseConnection.getConnection();
        stmt = conn.prepareStatement(
            "SELECT a.*, p.name as product_name, p.unit " +
            "FROM reverse_auctions a " +
            "JOIN products p ON a.product_id = p.id " +
            "JOIN auction_invitations ai ON a.id = ai.auction_id " +
            "WHERE ai.supplier_id = ? " +
            "AND a.status = 'ACTIVE' " +
            "AND NOW() BETWEEN a.start_time AND a.end_time " +
            "ORDER BY a.end_time ASC"
        );
        stmt.setLong(1, supplierId);
        rs = stmt.executeQuery();

        while (rs.next()) {
            ReverseAuction auction = new ReverseAuction();
            auction.setId(rs.getLong("id"));
            auction.setProductId(rs.getLong("product_id"));
            auction.setProductName(rs.getString("product_name"));
            auction.setRequiredQuantity(rs.getInt("required_quantity"));
            auction.setUnit(rs.getString("unit"));
            auction.setStartingPrice(rs.getDouble("start_price"));
            auction.setCurrentPrice(rs.getDouble("current_price"));
            auction.setStartTime(rs.getTimestamp("start_time"));
            auction.setEndTime(rs.getTimestamp("end_time"));
            auction.setStatus("ACTIVE");
            auctions.add(auction);
        }

    } catch (SQLException e) {
        throw new ServletException("Error retrieving active auctions", e);
    } finally {
        DatabaseConnection.closeQuietly(rs, stmt, conn);
    }

    return auctions;
}

    private List<java.util.Map<String, Object>> getSupplierPurchaseOrders(long supplierId)
        throws ServletException {

    List<java.util.Map<String, Object>> pos = new ArrayList<>();

    String sql =
        "SELECT po.id, " +
        "       COALESCE(NULLIF(po.po_number, ''), CONCAT('PO-', po.id)) AS po_number, " +
        "       COALESCE(po.created_at, NOW()) AS created_at, " +
        "       COALESCE(NULLIF(po.product_name, ''), NULLIF(po.material, ''), p.name, 'N/A') AS product_name, " +
        "       COALESCE(NULLIF(s.name, ''), NULLIF(po.supplier_name, ''), NULLIF(po.company_name, ''), 'Unknown Supplier') AS supplier_name, " +
        "       COALESCE(po.quantity, ra.required_quantity, 1) AS quantity, " +
        "       COALESCE(po.total_amount, po.amount, po.grand_total, 0) AS amount, " +
        "       COALESCE(po.supplier_id, ra.winning_supplier_id, " +
        "           (SELECT b.supplier_id FROM bids b WHERE b.auction_id = po.auction_id ORDER BY b.amount ASC, b.bid_time ASC LIMIT 1)) AS resolved_supplier_id, " +
        "       po.status " +
        "FROM purchase_orders po " +
        "LEFT JOIN reverse_auctions ra ON ra.id = po.auction_id " +
        "LEFT JOIN products p ON p.id = COALESCE(po.product_id, ra.product_id) " +
        "LEFT JOIN suppliers s ON s.id = COALESCE(po.supplier_id, ra.winning_supplier_id, " +
        "           (SELECT b.supplier_id FROM bids b WHERE b.auction_id = po.auction_id ORDER BY b.amount ASC, b.bid_time ASC LIMIT 1)) " +
        "WHERE COALESCE(po.supplier_id, ra.winning_supplier_id, " +
        "           (SELECT b.supplier_id FROM bids b WHERE b.auction_id = po.auction_id ORDER BY b.amount ASC, b.bid_time ASC LIMIT 1)) = ? " +
        "ORDER BY po.created_at DESC";

    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setLong(1, supplierId);

        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> po = new java.util.HashMap<>();
                po.put("id", rs.getLong("id"));
                po.put("poNumber", rs.getString("po_number"));
                po.put("createdAt", rs.getTimestamp("created_at"));
                po.put("date", rs.getTimestamp("created_at"));
                po.put("productName", rs.getString("product_name"));
                po.put("supplierName", rs.getString("supplier_name"));
                po.put("supplierId", rs.getLong("resolved_supplier_id"));
                po.put("quantity", rs.getInt("quantity"));
                po.put("amount", rs.getDouble("amount"));
                po.put("status", rs.getString("status"));
                pos.add(po);
            }
        }
    } catch (SQLException e) {
        throw new ServletException("Error loading supplier POs", e);
    }

    return pos;
}

}
