package com.axaltacoating.servlet;

import com.axaltacoating.util.DatabaseConnection;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "DashboardApiServlet", urlPatterns = {"/api/dashboard/*"})
public class DashboardApiServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(DashboardApiServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo.contains("auctions-over-time")) {
                getAuctionsOverTime(response);
            } else if (pathInfo.contains("supplier-performance")) {
                getSupplierPerformance(response);
            } else if (pathInfo.contains("payment-status")) {
                getPaymentStatus(response);
            } else if (pathInfo.contains("inventory-status")) {
                getInventoryStatus(response);
            } else if (pathInfo.contains("top-products")) {
                getTopProducts(response);
            } else if (pathInfo.contains("spend-by-category")) {
                getSpendByCategory(response);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in Dashboard API", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void getAuctionsOverTime(HttpServletResponse response) throws Exception {
        JSONObject result = new JSONObject();
        JSONArray labels = new JSONArray();
        JSONArray values = new JSONArray();

        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement()) {

            String query =
                    "SELECT DATE(auction_created_at) AS auction_date, COUNT(*) AS count " +
                    "FROM (" +
                    "    SELECT COALESCE(ra.created_at, ra.start_time) AS auction_created_at, " +
                    "           CASE " +
                    "               WHEN UPPER(COALESCE(po.status, '')) = 'DELIVERED' THEN 'DELIVERED' " +
                    "               WHEN UPPER(COALESCE(po.status, '')) = 'PAID' THEN 'PAID' " +
                    "               WHEN UPPER(COALESCE(po.status, '')) = 'PAYMENT_PENDING' THEN 'PAYMENT_PENDING' " +
                    "               WHEN UPPER(COALESCE(po.status, '')) = 'SENT' THEN 'SENT' " +
                    "               WHEN UPPER(COALESCE(po.status, '')) = 'COMPLETED' " +
                    "                    OR UPPER(COALESCE(ra.status, '')) = 'COMPLETED' THEN 'COMPLETED' " +
                    "               WHEN UPPER(COALESCE(ra.status, '')) = 'CANCELLED' THEN 'CANCELLED' " +
                    "               WHEN ra.start_time IS NOT NULL AND ra.start_time > NOW() THEN 'SCHEDULED' " +
                    "               WHEN ra.end_time IS NOT NULL AND ra.end_time < NOW() THEN 'COMPLETED' " +
                    "               ELSE 'ACTIVE' " +
                    "           END AS effective_status " +
                    "    FROM reverse_auctions ra " +
                    "    LEFT JOIN purchase_orders po ON po.auction_id = ra.id " +
                    "    WHERE COALESCE(ra.created_at, ra.start_time) >= DATE_SUB(NOW(), INTERVAL 30 DAY) " +
                    ") active_auctions " +
                    "WHERE effective_status = 'ACTIVE' " +
                    "GROUP BY DATE(auction_created_at) " +
                    "ORDER BY auction_date";

            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                labels.add(rs.getString("auction_date"));
                values.add(rs.getLong("count"));
            }
        }

        result.put("labels", labels);
        result.put("values", values);
        PrintWriter out = response.getWriter();
        out.print(result.toJSONString());
        out.flush();
    }

    private void getSupplierPerformance(HttpServletResponse response) throws Exception {
        JSONObject result = new JSONObject();
        JSONArray labels = new JSONArray();
        JSONArray values = new JSONArray();

        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            String query = "SELECT s.name, COUNT(b.id) as bid_count " +
                          "FROM suppliers s " +
                          "LEFT JOIN bids b ON s.id = (SELECT supplier_id FROM reverse_auctions ra WHERE ra.id = b.auction_id LIMIT 1) " +
                          "GROUP BY s.id, s.name " +
                          "ORDER BY bid_count DESC " +
                          "LIMIT 10";
            
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                labels.add(rs.getString("name"));
                values.add(rs.getLong("bid_count"));
            }
        }

        result.put("labels", labels);
        result.put("values", values);
        PrintWriter out = response.getWriter();
        out.print(result.toJSONString());
        out.flush();
    }

    private void getPaymentStatus(HttpServletResponse response) throws Exception {
        JSONObject result = new JSONObject();
        JSONArray labels = new JSONArray();
        JSONArray values = new JSONArray();

        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement()) {

            String query =
                    "SELECT payment_label, payment_count " +
                    "FROM (" +
                    "    SELECT 1 AS sort_order, 'Completed' AS payment_label, " +
                    "           COALESCE(SUM(CASE WHEN UPPER(COALESCE(status, '')) = 'COMPLETED' THEN 1 ELSE 0 END), 0) AS payment_count " +
                    "    FROM payments " +
                    "    UNION ALL " +
                    "    SELECT 2 AS sort_order, 'Pending' AS payment_label, " +
                    "           COALESCE(SUM(CASE WHEN UPPER(COALESCE(status, '')) = 'PENDING' THEN 1 ELSE 0 END), 0) AS payment_count " +
                    "    FROM payments " +
                    "    UNION ALL " +
                    "    SELECT 3 AS sort_order, 'Failed' AS payment_label, " +
                    "           COALESCE(SUM(CASE WHEN UPPER(COALESCE(status, '')) = 'FAILED' THEN 1 ELSE 0 END), 0) AS payment_count " +
                    "    FROM payments " +
                    ") payment_summary " +
                    "ORDER BY sort_order";

            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                labels.add(rs.getString("payment_label"));
                values.add(rs.getLong("payment_count"));
            }
        }

        result.put("labels", labels);
        result.put("values", values);
        PrintWriter out = response.getWriter();
        out.print(result.toJSONString());
        out.flush();
    }

    private void getInventoryStatus(HttpServletResponse response) throws Exception {
        JSONObject result = new JSONObject();
        JSONArray labels = new JSONArray();
        JSONArray values = new JSONArray();

        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            String query = "SELECT kanban_status, COUNT(*) as count " +
                          "FROM inventory " +
                          "GROUP BY kanban_status";
            
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                labels.add(rs.getString("kanban_status"));
                values.add(rs.getLong("count"));
            }
        }

        result.put("labels", labels);
        result.put("values", values);
        PrintWriter out = response.getWriter();
        out.print(result.toJSONString());
        out.flush();
    }

    private void getTopProducts(HttpServletResponse response) throws Exception {
        JSONObject result = new JSONObject();
        JSONArray labels = new JSONArray();
        JSONArray values = new JSONArray();

        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            String query = "SELECT p.name, COUNT(ra.id) as auction_count " +
                          "FROM products p " +
                          "LEFT JOIN reverse_auctions ra ON p.id = ra.product_id " +
                          "GROUP BY p.id, p.name " +
                          "ORDER BY auction_count DESC " +
                          "LIMIT 10";
            
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                labels.add(rs.getString("name"));
                values.add(rs.getLong("auction_count"));
            }
        }

        result.put("labels", labels);
        result.put("values", values);
        PrintWriter out = response.getWriter();
        out.print(result.toJSONString());
        out.flush();
    }

    private void getSpendByCategory(HttpServletResponse response) throws Exception {
        JSONObject result = new JSONObject();
        JSONArray labels = new JSONArray();
        JSONArray values = new JSONArray();

        try (Connection conn = DatabaseConnection.getConnection()) {
            
            // Define the categories that should be displayed
            String[] categories = {"Paints", "Coating", "Primers", "Sealants"};
            
            String query = "SELECT COALESCE(SUM(pay.amount), 0) as total_spend " +
                          "FROM payments pay " +
                          "JOIN reverse_auctions ra ON pay.auction_id = ra.id " +
                          "JOIN products p ON ra.product_id = p.id " +
                          "WHERE pay.status = 'COMPLETED' AND p.category = ?";
            
            for (String category : categories) {
                try (PreparedStatement pstmt = conn.prepareStatement(query)) {
                    pstmt.setString(1, category);
                    ResultSet rs = pstmt.executeQuery();
                    if (rs.next()) {
                        labels.add(category);
                        values.add(rs.getDouble("total_spend"));
                    }
                }
            }
        }

        result.put("labels", labels);
        result.put("values", values);
        PrintWriter out = response.getWriter();
        out.print(result.toJSONString());
        out.flush();
    }
}
