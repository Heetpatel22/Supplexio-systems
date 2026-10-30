package com.axaltacoating.servlet;

import com.axaltacoating.util.DatabaseConnection;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import java.util.logging.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/payment/*")
public class PaymentServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PaymentServlet.class.getName());

    // ── GET ──────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action         = request.getParameter("action");
        String auctionIdParam = request.getParameter("auctionId");

        // New payment form
        if ("new".equals(action) || (action == null && auctionIdParam != null)) {
            handleNewPaymentForm(request, response, auctionIdParam);
            return;
        }

        // Filter or default list
        // list.jsp sends: startDate, endDate, status, paymentMethod
        String startDate    = emptyToNull(request.getParameter("startDate"));
        String endDate      = emptyToNull(request.getParameter("endDate"));
        String statusFilter = emptyToNull(request.getParameter("status"));
        String methodFilter = emptyToNull(request.getParameter("paymentMethod"));

        // Echo back for form repopulation
        request.setAttribute("startDate",           startDate);
        request.setAttribute("endDate",             endDate);
        request.setAttribute("statusFilter",        statusFilter);
        request.setAttribute("paymentMethodFilter", methodFilter);

        try {
            // Auction Winners = completed auctions with no payment yet
            List<Map<String, Object>> auctionWinners = getAuctionWinners();
            request.setAttribute("auctionWinners", auctionWinners);

            // Payment History with filters
            List<Map<String, Object>> paymentHistory =
                    getPaymentHistory(startDate, endDate, statusFilter, methodFilter);
            request.setAttribute("paymentHistory", paymentHistory);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "DB error loading payments page", e);
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/views/payment/list.jsp")
               .forward(request, response);
    }

    // ── POST ─────────────────────────────────────────────────────────────────
@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    String auctionIdParam     = request.getParameter("auctionId");
    String supplierIdParam    = request.getParameter("supplierId");
    String amountParam        = request.getParameter("amount");
    String paymentMethod      = request.getParameter("paymentMethod");
    String transactionId      = request.getParameter("transactionId");
    String paymentDate        = request.getParameter("paymentDate");
    String statusParam        = request.getParameter("status");
    String remarks            = request.getParameter("remarks");

    if (auctionIdParam == null || supplierIdParam == null || amountParam == null) {
        request.getSession().setAttribute("error", "Missing required parameters");
        response.sendRedirect(request.getContextPath() + "/payment");
        return;
    }

    try {
        long auctionId = Long.parseLong(auctionIdParam);
        long supplierId = Long.parseLong(supplierIdParam);
        double amount = Double.parseDouble(amountParam);

        boolean success = createPayment(
            auctionId,
            supplierId,
            amount,
            paymentMethod,
            transactionId,
            paymentDate,
            statusParam,
            remarks
        );

        if (success) {
            request.getSession().setAttribute("success", "Payment successful");
        } else {
            request.getSession().setAttribute("error", "Failed to create payment");
        }
    } catch (NumberFormatException e) {
        request.getSession().setAttribute("error", "Invalid amount or ID format");
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "DB error creating payment", e);
        request.getSession().setAttribute("error", "Database error: " + e.getMessage());
    }

    response.sendRedirect(request.getContextPath() + "/payment");
}

    // ── PRIVATE HELPERS ───────────────────────────────────────────────────────

    private void handleNewPaymentForm(HttpServletRequest request,
            HttpServletResponse response, String auctionIdParam)
            throws ServletException, IOException {

        if (auctionIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/payment");
            return;
        }
        try {
            long auctionId = Long.parseLong(auctionIdParam);
            Map<String, Object> auction = getAuctionDetails(auctionId);
            if (auction == null) {
                request.getSession().setAttribute("error", "Auction not found");
                response.sendRedirect(request.getContextPath() + "/payment");
                return;
            }
            String supplierIdParam = request.getParameter("supplierId");
            long supplierId;
            if (supplierIdParam != null && !supplierIdParam.isEmpty()) {
                supplierId = Long.parseLong(supplierIdParam);
            } else {
                Long sid = getWinnerSupplierId(auctionId);
                if (sid == null) {
                    request.getSession().setAttribute("error",
                            "No winning supplier found for this auction");
                    response.sendRedirect(request.getContextPath() + "/payment");
                    return;
                }
                supplierId = sid;
            }
            Map<String, Object> supplier = getSupplierDetails(supplierId);
            request.setAttribute("auction",  auction);
            request.setAttribute("supplier", supplier);
            request.getRequestDispatcher("/WEB-INF/views/payment/form.jsp")
                   .forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/payment");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "DB error in new-payment form", e);
            request.getSession().setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/payment");
        }
    }

    /**
     * Completed auctions that do NOT yet have a purchase order (and therefore
     * no payment). These show in the "Auction Winners" section so the user
     * can create a payment for them.
     */
private List<Map<String, Object>> getAuctionWinners() throws SQLException {
    String sql =
        "SELECT " +
        "  po.id AS po_id, " +
        "  po.auction_id AS auction_id, " +
        "  COALESCE(po.product_name, p.name, 'N/A') AS product_name, " +
        "  COALESCE(NULLIF(s.name, ''), NULLIF(po.supplier_name, ''), NULLIF(po.company_name, ''), 'Unknown Supplier') AS supplier_name, " +
        "  COALESCE(po.total_amount, po.amount, po.grand_total, 0) AS winning_amount, " +
        "  COALESCE(po.supplier_id, ra.winning_supplier_id, " +
        "      (SELECT b.supplier_id FROM bids b WHERE b.auction_id = po.auction_id ORDER BY b.amount ASC, b.bid_time ASC LIMIT 1)) AS supplier_id, " +
        "  po.status AS po_status, " +
        "  po.created_at AS created_at " +
        "FROM purchase_orders po " +
        "LEFT JOIN reverse_auctions ra ON ra.id = po.auction_id " +
        "LEFT JOIN products p ON p.id = COALESCE(po.product_id, ra.product_id) " +
        "LEFT JOIN suppliers s ON s.id = COALESCE(po.supplier_id, ra.winning_supplier_id, " +
        "      (SELECT b.supplier_id FROM bids b WHERE b.auction_id = po.auction_id ORDER BY b.amount ASC, b.bid_time ASC LIMIT 1)) " +
        "WHERE po.status = 'PAYMENT_PENDING' " +
        "ORDER BY po.created_at DESC";

    List<Map<String, Object>> winners = new ArrayList<>();
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql);
         ResultSet rs = stmt.executeQuery()) {

        while (rs.next()) {
            Map<String, Object> w = new HashMap<>();
            w.put("poId", rs.getLong("po_id"));
            w.put("auctionId", rs.getLong("auction_id"));
            w.put("productName", rs.getString("product_name"));
            w.put("supplierName", rs.getString("supplier_name"));
            w.put("amount", rs.getDouble("winning_amount"));
            w.put("supplierId", rs.getLong("supplier_id"));
            w.put("poStatus", rs.getString("po_status"));
            winners.add(w);
        }
    }
    return winners;
}

    /**
     * Payment history joining:
     *   payments → purchase_orders → reverse_auctions / products / suppliers
     *
     * Actual column names from DESCRIBE payments:
     *   id, po_id, amount, status, payment_method,
     *   transaction_id, payment_date, activated_at, created_at, remarks
     *
     * Actual column names from purchase_orders:
     *   id, auction_id, supplier_id, product_id, supplier_name,
     *   product_name, grand_total, status, ...
     */
    private List<Map<String, Object>> getPaymentHistory(
        String startDate, String endDate,
        String statusFilter, String methodFilter) throws SQLException {

    StringBuilder sql = new StringBuilder(
        "SELECT " +
        "  pay.id, " +
        "  pay.po_id, " +
        "  pay.amount, " +
        "  pay.status, " +
        "  pay.payment_method, " +
        "  pay.transaction_id, " +
        "  pay.payment_date, " +
        "  pay.created_at, " +
        "  po.auction_id, " +
        "  COALESCE(po.supplier_id, ra.winning_supplier_id, " +
        "      (SELECT b.supplier_id FROM bids b WHERE b.auction_id = po.auction_id ORDER BY b.amount ASC, b.bid_time ASC LIMIT 1)) AS supplier_id, " +
        "  COALESCE(NULLIF(s.name, ''), NULLIF(po.supplier_name, ''), NULLIF(po.company_name, ''), 'Unknown Supplier') AS supplier_name, " +
        "  COALESCE(NULLIF(po.product_name, ''), NULLIF(po.material, ''), p.name, 'N/A') AS product_name " +
        "FROM payments pay " +
        "JOIN purchase_orders po ON pay.po_id = po.id " +
        "LEFT JOIN reverse_auctions ra ON ra.id = po.auction_id " +
        "LEFT JOIN products p ON p.id = COALESCE(po.product_id, ra.product_id) " +
        "LEFT JOIN suppliers s ON s.id = COALESCE(po.supplier_id, ra.winning_supplier_id, " +
        "      (SELECT b.supplier_id FROM bids b WHERE b.auction_id = po.auction_id ORDER BY b.amount ASC, b.bid_time ASC LIMIT 1)) " +
        "WHERE 1=1 "
    );

    List<Object> params = new ArrayList<>();

    if (statusFilter != null) {
        sql.append("AND pay.status = ? ");
        params.add(statusFilter);
    }
    if (methodFilter != null) {
        sql.append("AND pay.payment_method = ? ");
        params.add(methodFilter);
    }
    if (startDate != null) {
        sql.append("AND DATE(pay.payment_date) >= ? ");
        params.add(startDate);
    }
    if (endDate != null) {
        sql.append("AND DATE(pay.payment_date) <= ? ");
        params.add(endDate);
    }

    sql.append("ORDER BY pay.created_at DESC");

    List<Map<String, Object>> history = new ArrayList<>();
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

        for (int i = 0; i < params.size(); i++) {
            stmt.setObject(i + 1, params.get(i));
        }

        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> pay = new HashMap<>();
                pay.put("id", rs.getLong("id"));
                pay.put("poId", rs.getLong("po_id"));
                pay.put("auctionId", rs.getLong("auction_id"));
                pay.put("supplierId", rs.getLong("supplier_id"));
                pay.put("amount", rs.getDouble("amount"));
                pay.put("status", rs.getString("status"));
                pay.put("paymentMethod", rs.getString("payment_method"));
                pay.put("transactionId", rs.getString("transaction_id"));
                pay.put("paymentDate", rs.getTimestamp("payment_date"));
                pay.put("createdAt", rs.getTimestamp("created_at"));
                pay.put("productName", rs.getString("product_name"));
                pay.put("supplierName", rs.getString("supplier_name"));
                history.add(pay);
            }
        }
    }
    return history;
}

    /**
     * Creates a purchase order then a payment linked to it.
     */
    private boolean createPayment(long auctionId, long supplierId, double amount,
        String paymentMethod, String transactionId, String paymentDate,
        String statusParam, String remarks) throws SQLException {

    try (Connection conn = DatabaseConnection.getConnection()) {
        conn.setAutoCommit(false);
        try {
            long poId = 0L;

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id FROM purchase_orders " +
                    "WHERE auction_id = ? AND supplier_id = ? AND status = 'PAYMENT_PENDING'")) {
                ps.setLong(1, auctionId);
                ps.setLong(2, supplierId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        poId = rs.getLong("id");
                    }
                }
            }

            if (poId == 0L) {
                conn.rollback();
                return false;
            }

            String finalMethod = (paymentMethod == null || paymentMethod.trim().isEmpty())
                    ? "BANK_TRANSFER" : paymentMethod.trim();
            String finalTxn = (transactionId == null || transactionId.trim().isEmpty())
                    ? "TXN-" + System.currentTimeMillis() : transactionId.trim();
            String finalStatus = (statusParam == null || statusParam.trim().isEmpty())
                    ? "COMPLETED" : statusParam.trim();

            String paySql =
                "INSERT INTO payments (po_id, amount, status, payment_method, transaction_id, payment_date, created_at, remarks) " +
                "VALUES (?, ?, ?, ?, ?, ?, NOW(), ?)";

            try (PreparedStatement ps = conn.prepareStatement(paySql)) {
                ps.setLong(1, poId);
                ps.setDouble(2, amount);
                ps.setString(3, finalStatus);
                ps.setString(4, finalMethod);
                ps.setString(5, finalTxn);
                if (paymentDate != null && !paymentDate.trim().isEmpty()) {
                    ps.setDate(6, java.sql.Date.valueOf(paymentDate));
                } else {
                    ps.setDate(6, new java.sql.Date(System.currentTimeMillis()));
                }
                ps.setString(7, remarks);
                ps.executeUpdate();
            }

            if ("COMPLETED".equalsIgnoreCase(finalStatus)) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE purchase_orders SET status = 'PAID' WHERE id = ?")) {
                    ps.setLong(1, poId);
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }
}

    private Map<String, Object> getAuctionDetails(long auctionId) throws SQLException {
        String sql =
            "SELECT ra.id, ra.product_id, p.name AS product_name, " +
            "       ra.current_price AS winning_amount, ra.end_time " +
            "FROM reverse_auctions ra JOIN products p ON ra.product_id = p.id " +
            "WHERE ra.id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, auctionId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> a = new HashMap<>();
                    a.put("id",             rs.getLong("id"));
                    a.put("product_id",     rs.getLong("product_id"));
                    a.put("product_name",   rs.getString("product_name"));
                    a.put("winning_amount", rs.getDouble("winning_amount"));
                    a.put("end_time",       rs.getTimestamp("end_time"));
                    return a;
                }
            }
        }
        return null;
    }

    private Map<String, Object> getSupplierDetails(long supplierId) throws SQLException {
        String sql = "SELECT id, name, email, phone FROM suppliers WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, supplierId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> s = new HashMap<>();
                    s.put("id",    rs.getLong("id"));
                    s.put("name",  rs.getString("name"));
                    s.put("email", rs.getString("email"));
                    s.put("phone", rs.getString("phone"));
                    return s;
                }
            }
        }
        return null;
    }

    private Long getWinnerSupplierId(long auctionId) throws SQLException {
        String sql =
            "SELECT COALESCE(ra.winning_supplier_id, " +
            "  (SELECT b.supplier_id FROM bids b WHERE b.auction_id = ra.id " +
            "   ORDER BY b.amount ASC LIMIT 1)) AS winner " +
            "FROM reverse_auctions ra WHERE ra.id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, auctionId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    long val = rs.getLong("winner");
                    return rs.wasNull() ? null : val;
                }
            }
        }
        return null;
    }

    private static String emptyToNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private static String coalesce(String s, String fallback) {
        return (s == null || s.trim().isEmpty()) ? fallback : s;
    }
}
