package com.axaltacoating.servlet;

import com.axaltacoating.util.DatabaseConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "UserPOViewServlet", urlPatterns = {"/user-po-view"})
public class UserPOViewServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(UserPOViewServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<PurchaseOrderBean> poList = new ArrayList<>();

        String sql =
            "SELECT po.id, po.auction_id, " +
            "       COALESCE(po.supplier_id, ra.winning_supplier_id, " +
            "           (SELECT b.supplier_id FROM bids b WHERE b.auction_id = po.auction_id ORDER BY b.amount ASC, b.bid_time ASC LIMIT 1)) AS supplier_id, " +
            "       COALESCE(NULLIF(s.name, ''), NULLIF(po.supplier_name, ''), NULLIF(po.company_name, ''), 'Unknown Supplier') AS supplier_name, " +
            "       COALESCE(NULLIF(po.product_name, ''), NULLIF(po.material, ''), p.name, 'N/A') AS material, " +
            "       COALESCE(po.total_amount, po.amount, ra.current_price, 0) AS amount, " +
            "       COALESCE(po.quantity, ra.required_quantity, 1) AS quantity, " +
            "       CASE " +
"           WHEN ad.status = 'DELIVERED' THEN 'DELIVERED' " +
"           WHEN EXISTS (SELECT 1 FROM payments pay WHERE pay.po_id = po.id AND pay.status = 'COMPLETED') THEN 'PAID' " +
"           ELSE COALESCE(po.status, 'COMPLETED') " +
"       END AS display_status, " +

            "       COALESCE(po.created_at, ra.end_time, ra.start_time) AS created_at " +
            "FROM purchase_orders po " +
            "LEFT JOIN reverse_auctions ra ON ra.id = po.auction_id " +
            "LEFT JOIN auction_deliveries ad ON ad.auction_id = po.auction_id " +
            "LEFT JOIN products p ON p.id = COALESCE(po.product_id, ra.product_id) " +
            "LEFT JOIN suppliers s ON s.id = COALESCE(po.supplier_id, ra.winning_supplier_id, " +
            "           (SELECT b.supplier_id FROM bids b WHERE b.auction_id = po.auction_id ORDER BY b.amount ASC, b.bid_time ASC LIMIT 1)) " +
            "ORDER BY COALESCE(po.created_at, ra.end_time, ra.start_time) DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                PurchaseOrderBean po = new PurchaseOrderBean();
                po.setId(rs.getLong("id"));
                po.setAuctionId(rs.getLong("auction_id"));
                po.setSupplierId(rs.getLong("supplier_id"));
                po.setSupplierName(rs.getString("supplier_name"));
                po.setCompanyName(rs.getString("supplier_name"));
                po.setMaterial(rs.getString("material"));
                po.setAmount(rs.getDouble("amount"));
                po.setQuantity(rs.getInt("quantity"));
                po.setStatus(rs.getString("display_status"));
                po.setCreatedAt(rs.getTimestamp("created_at"));
                poList.add(po);
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading user POs", e);
        }

        request.setAttribute("poList", poList);
        request.getRequestDispatcher("user_po.jsp").forward(request, response);
    }

    public static class PurchaseOrderBean {
        private long id;
        private long auctionId;
        private String supplierName;
        private String companyName;
        private String material;
        private double amount;
        private String status;
        private java.util.Date createdAt;
        private long supplierId;
        private int quantity;

        public long getId() { return id; }
        public void setId(long id) { this.id = id; }

        public long getAuctionId() { return auctionId; }
        public void setAuctionId(long auctionId) { this.auctionId = auctionId; }

        public String getSupplierName() { return supplierName; }
        public void setSupplierName(String supplierName) { this.supplierName = supplierName; }

        public String getCompanyName() { return companyName; }
        public void setCompanyName(String companyName) { this.companyName = companyName; }

        public String getMaterial() { return material; }
        public void setMaterial(String material) { this.material = material; }

        public double getAmount() { return amount; }
        public void setAmount(double amount) { this.amount = amount; }

        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }

        public java.util.Date getCreatedAt() { return createdAt; }
        public void setCreatedAt(java.util.Date createdAt) { this.createdAt = createdAt; }

        public long getSupplierId() { return supplierId; }
        public void setSupplierId(long supplierId) { this.supplierId = supplierId; }

        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }
    }
}
