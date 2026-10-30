package com.axaltacoating.servlet;

import com.axaltacoating.util.DatabaseConnection;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import java.io.IOException;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * PaymentPdfServlet — server-side PDF using iText 5.
 *
 * Dependency (Maven):
 *   <dependency>
 *     <groupId>com.itextpdf</groupId>
 *     <artifactId>itextpdf</artifactId>
 *     <version>5.5.13.3</version>
 *   </dependency>
 *
 * URL pattern: GET /payment/pdf?id={paymentId}
 *
 * Example link in JSP:
 *   <a href="${pageContext.request.contextPath}/payment/pdf?id=${payment.id}">
 *       Download PDF
 *   </a>
 */
@WebServlet("/payment/pdf")
public class PaymentPdfServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PaymentPdfServlet.class.getName());
    private static final BaseColor BRAND_BLUE = new BaseColor(30, 136, 229);
    private static final BaseColor LIGHT_BLUE = new BaseColor(232, 245, 253);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing payment id");
            return;
        }

        long paymentId;
        try {
            paymentId = Long.parseLong(idParam.trim());
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid payment id");
            return;
        }

        try {
            PaymentData data = loadPayment(paymentId);
            if (data == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Payment not found");
                return;
            }
            streamPdf(data, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "DB error generating payment PDF " + paymentId, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        } catch (DocumentException e) {
            LOGGER.log(Level.SEVERE, "iText error generating payment PDF " + paymentId, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "PDF generation error");
        }
    }

    // ──────────────────────────────────────────────────────────────────────────
    // PDF construction
    // ──────────────────────────────────────────────────────────────────────────

    private void streamPdf(PaymentData d, HttpServletResponse response)
            throws DocumentException, IOException {

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition",
                "attachment; filename=\"payment-slip-" + d.id + ".pdf\"");

        Document doc = new Document(PageSize.A5, 36, 36, 36, 36);
        PdfWriter writer = PdfWriter.getInstance(doc, response.getOutputStream());
        doc.open();

        // ── Header band ──────────────────────────────────────────────────────
        PdfContentByte canvas = writer.getDirectContent();
        canvas.saveState();
        canvas.setColorFill(BRAND_BLUE);
        canvas.rectangle(0, PageSize.A5.getHeight() - 60,
                         PageSize.A5.getWidth(), 60);
        canvas.fill();
        canvas.restoreState();

        Font headerFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD, BaseColor.WHITE);
        Font subFont    = new Font(Font.FontFamily.HELVETICA,  9, Font.NORMAL, BaseColor.WHITE);

        Paragraph companyName = new Paragraph("SUPPLEXIO", headerFont);
        companyName.setAlignment(Element.ALIGN_CENTER);
        companyName.setSpacingBefore(10f);
        doc.add(companyName);

        Paragraph subTitle = new Paragraph("Payment Slip", subFont);
        subTitle.setAlignment(Element.ALIGN_CENTER);
        doc.add(subTitle);

        doc.add(Chunk.NEWLINE);

        // ── Status badge ─────────────────────────────────────────────────────
        String statusText  = d.status;
        BaseColor badgeColor = "COMPLETED".equalsIgnoreCase(d.status)
                ? new BaseColor(40, 167, 69)
                : new BaseColor(255, 193, 7);

        PdfPTable statusTable = new PdfPTable(1);
        statusTable.setWidthPercentage(40);
        statusTable.setHorizontalAlignment(Element.ALIGN_CENTER);
        PdfPCell statusCell = new PdfPCell(
                new Phrase(statusText,
                        new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD, BaseColor.WHITE)));
        statusCell.setBackgroundColor(badgeColor);
        statusCell.setHorizontalAlignment(Element.ALIGN_CENTER);
        statusCell.setPadding(6);
        statusCell.setBorder(Rectangle.NO_BORDER);
        statusTable.addCell(statusCell);
        doc.add(statusTable);

        doc.add(Chunk.NEWLINE);

        // ── Details table ─────────────────────────────────────────────────────
        Font labelFont = new Font(Font.FontFamily.HELVETICA, 9, Font.BOLD,
                                  new BaseColor(80, 80, 80));
        Font valueFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL,
                                  new BaseColor(20, 20, 20));
        Font amountFont = new Font(Font.FontFamily.HELVETICA, 13, Font.BOLD, BRAND_BLUE);

        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{35f, 65f});

        addRow(table, labelFont, valueFont, "Payment ID",    "#" + d.id);
        addRow(table, labelFont, valueFont, "Auction ID",    "#" + d.auctionId);
        addRow(table, labelFont, valueFont, "Product",       d.productName);
        addRow(table, labelFont, valueFont, "Supplier",      d.supplierName);
        addRow(table, labelFont, valueFont, "Method",        d.paymentMethod);
        addRow(table, labelFont, valueFont, "Transaction ID",
               d.transactionId != null ? d.transactionId : "—");
        addRow(table, labelFont, valueFont, "Date",
               d.paymentDate != null
                   ? new SimpleDateFormat("dd MMM yyyy").format(d.paymentDate)
                   : "—");

        // Amount row — highlighted
        PdfPCell amtLabel = styledCell("Amount", labelFont, LIGHT_BLUE);
        PdfPCell amtValue = styledCell(
                String.format("$%,.2f", d.amount), amountFont, LIGHT_BLUE);
        table.addCell(amtLabel);
        table.addCell(amtValue);

        if (d.remarks != null && !d.remarks.trim().isEmpty()) {
            addRow(table, labelFont, valueFont, "Remarks", d.remarks);
        }

        doc.add(table);

        // ── Footer ────────────────────────────────────────────────────────────
        doc.add(Chunk.NEWLINE);
        Font footerFont = new Font(Font.FontFamily.HELVETICA, 7, Font.ITALIC,
                                   new BaseColor(150, 150, 150));
        Paragraph footer = new Paragraph(
                "Generated by Supplexio on " + new java.util.Date(), footerFont);
        footer.setAlignment(Element.ALIGN_CENTER);
        doc.add(footer);

        doc.close();
    }

    private void addRow(PdfPTable table, Font labelFont, Font valueFont,
                        String label, String value) {
        table.addCell(styledCell(label, labelFont, BaseColor.WHITE));
        table.addCell(styledCell(value, valueFont, BaseColor.WHITE));
    }

    private PdfPCell styledCell(String text, Font font, BaseColor bg) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(bg);
        cell.setPadding(6);
        cell.setBorderColor(new BaseColor(220, 220, 220));
        return cell;
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Data access
    // ──────────────────────────────────────────────────────────────────────────

    private PaymentData loadPayment(long paymentId) throws SQLException {
        String sql =
            "SELECT p.id, p.auction_id, p.amount, p.status, " +
            "       p.transaction_id, p.payment_method, p.payment_date, p.remarks, " +
            "       pr.name AS product_name, s.name AS supplier_name " +
            "FROM payments p " +
            "JOIN reverse_auctions ra ON p.auction_id  = ra.id " +
            "JOIN products         pr ON ra.product_id = pr.id " +
            "JOIN suppliers        s  ON p.supplier_id = s.id " +
            "WHERE p.id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, paymentId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    PaymentData d = new PaymentData();
                    d.id            = rs.getLong("id");
                    d.auctionId     = rs.getLong("auction_id");
                    d.amount        = rs.getDouble("amount");
                    d.status        = rs.getString("status");
                    d.transactionId = rs.getString("transaction_id");
                    d.paymentMethod = rs.getString("payment_method");
                    d.paymentDate   = rs.getTimestamp("payment_date");
                    d.remarks       = rs.getString("remarks");
                    d.productName   = rs.getString("product_name");
                    d.supplierName  = rs.getString("supplier_name");
                    return d;
                }
            }
        }
        return null;
    }

    private static class PaymentData {
        long      id, auctionId;
        double    amount;
        String    status, transactionId, paymentMethod, remarks, productName, supplierName;
        java.util.Date paymentDate;
    }
}
