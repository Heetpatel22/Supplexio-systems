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
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "SendPOToSupplierServlet", urlPatterns = {"/send-po-to-supplier"})
public class SendPOToSupplierServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(SendPOToSupplierServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String poIdParam = request.getParameter("poId");
        if (poIdParam == null || poIdParam.trim().isEmpty()) {
            response.sendRedirect("user-po-view?error=Missing+PO+ID");
            return;
        }

        long poId;
        try {
            poId = Long.parseLong(poIdParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect("user-po-view?error=Invalid+PO+ID");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
    "UPDATE purchase_orders po " +
    "LEFT JOIN suppliers s ON s.id = po.supplier_id " +
    "LEFT JOIN reverse_auctions ra ON ra.id = po.auction_id " +
    "LEFT JOIN products p ON p.id = COALESCE(po.product_id, ra.product_id) " +
    "SET po.status = 'SENT', " +
    "    po.supplier_name = COALESCE(NULLIF(po.supplier_name, ''), s.name, po.company_name, 'Unknown Supplier'), " +
    "    po.company_name = COALESCE(NULLIF(po.company_name, ''), s.name, po.supplier_name, 'Unknown Supplier'), " +
    "    po.product_name = COALESCE(NULLIF(po.product_name, ''), NULLIF(po.material, ''), p.name, 'N/A'), " +
    "    po.material = COALESCE(NULLIF(po.material, ''), NULLIF(po.product_name, ''), p.name, 'N/A') " +
    "WHERE po.id = ? AND po.status = 'COMPLETED'");

            stmt.setLong(1, poId);
            int updated = stmt.executeUpdate();
            stmt.close();

            if (updated > 0) {
                response.sendRedirect("user-po-view?success=PO+sent+to+supplier");
            } else {
                response.sendRedirect("user-po-view?error=PO+not+found");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error sending PO to supplier", e);
            response.sendRedirect("user-po-view?error=Database+error");
        }
    }
}
