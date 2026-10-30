package com.axaltacoating.servlet;

import com.axaltacoating.util.DatabaseConnection;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.Rectangle;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.BaseFont;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfGState;


import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet(name = "DownloadPOPdfServlet", urlPatterns = {"/download-po-pdf"})
public class DownloadPOPdfServlet extends HttpServlet {

    private static final BaseColor BRAND = new BaseColor(31, 74, 125);
    private static final BaseColor LIGHT = new BaseColor(240, 245, 250);
    private static final BaseColor BORDER = new BaseColor(210, 220, 230);
    private static final BaseColor TEXT = new BaseColor(55, 55, 55);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String poIdParam = request.getParameter("poId");
        if (poIdParam == null || poIdParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing PO ID");
            return;
        }

        long poId;
        try {
            poId = Long.parseLong(poIdParam.trim());
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid PO ID");
            return;
        }

        String sql =
            "SELECT po.id, " +
            "       COALESCE(NULLIF(po.po_number, ''), CONCAT('PO-', po.id)) AS po_number, " +
            "       COALESCE(po.created_at, NOW()) AS created_at, " +
            "       COALESCE(NULLIF(po.product_name, ''), NULLIF(po.material, ''), p.name, 'N/A') AS product_name, " +
            "       COALESCE(NULLIF(po.supplier_name, ''), s.name, po.company_name, 'Unknown Supplier') AS supplier_name, " +
            "       COALESCE(NULLIF(po.company_name, ''), s.name, po.supplier_name, 'Unknown Supplier') AS company_name, " +
            "       COALESCE(NULLIF(po.supplier_email, ''), s.email, 'Not Available') AS supplier_email, " +
            "       COALESCE(NULLIF(po.supplier_address, ''), s.address, 'Address not available') AS supplier_address, " +
            "       COALESCE(po.quantity, ra.required_quantity, 1) AS quantity, " +
                "       EXISTS (SELECT 1 FROM payments pay WHERE pay.po_id = po.id AND pay.status = 'COMPLETED') AS payment_done, " +

            "       COALESCE(po.unit_price, CASE WHEN COALESCE(po.quantity, ra.required_quantity, 0) > 0 THEN ROUND(COALESCE(po.total_amount, po.amount, ra.current_price, 0) / COALESCE(po.quantity, ra.required_quantity, 1), 2) ELSE COALESCE(po.total_amount, po.amount, ra.current_price, 0) END) AS unit_price, " +
            "       COALESCE(po.total_amount, po.amount, ra.current_price, 0) AS subtotal, " +
            "       COALESCE(po.tax_amount, ROUND(COALESCE(po.total_amount, po.amount, ra.current_price, 0) * 0.075, 2)) AS tax_amount, " +
            "       COALESCE(po.grand_total, ROUND(COALESCE(po.total_amount, po.amount, ra.current_price, 0) * 1.075, 2)) AS grand_total, " +
            "       COALESCE(po.status, ra.status, 'COMPLETED') AS po_status " +
            "FROM purchase_orders po " +
            "LEFT JOIN reverse_auctions ra ON ra.id = po.auction_id " +
            "LEFT JOIN products p ON p.id = COALESCE(po.product_id, ra.product_id) " +
            "LEFT JOIN suppliers s ON s.id = COALESCE(po.supplier_id, ra.winning_supplier_id) " +
            "WHERE po.id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, poId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "PO not found");
                    return;
                }
boolean paymentDone = rs.getBoolean("payment_done");
String poStatus = rs.getString("po_status");

if (!paymentDone && !"DELIVERED".equalsIgnoreCase(poStatus) && !"PAID".equalsIgnoreCase(poStatus)) {
    response.sendError(HttpServletResponse.SC_FORBIDDEN, "PDF can be downloaded only after successful payment");
    return;
}

                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition", "attachment; filename=" + rs.getString("po_number") + ".pdf");

                Document document = new Document(PageSize.A4, 36, 36, 36, 36);
                PdfWriter writer = PdfWriter.getInstance(document, response.getOutputStream());
document.open();

if (paymentDone || "PAID".equalsIgnoreCase(poStatus) || "DELIVERED".equalsIgnoreCase(poStatus)) {
    addPaidWatermark(writer, document);
}


                Font titleFont = new Font(Font.FontFamily.HELVETICA, 24, Font.BOLD, BRAND);
                Font sectionFont = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD, BaseColor.WHITE);
                Font labelFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, TEXT);
                Font valueFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, TEXT);
                Font smallFont = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, TEXT);
                Font totalFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, BRAND);

                Paragraph heading = new Paragraph("PURCHASE ORDER", titleFont);
                heading.setAlignment(Element.ALIGN_LEFT);
                document.add(heading);

                Paragraph company = new Paragraph("Supplexio Procurement Division\nAxaltaWebApp Enterprise Purchasing System", valueFont);
                company.setSpacingAfter(15f);
                document.add(company);

                PdfPTable topTable = new PdfPTable(new float[]{2.2f, 1.4f});
                topTable.setWidthPercentage(100);

                PdfPCell leftTop = new PdfPCell();
                leftTop.setBorder(Rectangle.BOX);
                leftTop.setBorderColor(BORDER);
                leftTop.setPadding(10f);
                leftTop.addElement(new Paragraph("ISSUED BY", labelFont));
                leftTop.addElement(new Paragraph("Supplexio Corporate Procurement", valueFont));
                leftTop.addElement(new Paragraph("Industrial Sourcing & Reverse Auction Operations", smallFont));
                leftTop.addElement(new Paragraph("Email: procurement@supplexio.com", smallFont));
                leftTop.addElement(new Paragraph("Phone: +91 98765 43210", smallFont));

                PdfPCell rightTop = new PdfPCell();
                rightTop.setBorder(Rectangle.BOX);
                rightTop.setBorderColor(BORDER);
                rightTop.setPadding(0f);

                PdfPTable meta = new PdfPTable(2);
                meta.setWidthPercentage(100);
                meta.addCell(metaHeader("PO Number", sectionFont));
                meta.addCell(metaValue(rs.getString("po_number"), valueFont));
                meta.addCell(metaHeader("Issue Date", sectionFont));
                meta.addCell(metaValue(String.valueOf(rs.getTimestamp("created_at")), valueFont));
                meta.addCell(metaHeader("Status", sectionFont));
                meta.addCell(metaValue(rs.getString("po_status"), valueFont));
                meta.addCell(metaHeader("Reference", sectionFont));
                meta.addCell(metaValue("Auction-linked procurement order", valueFont));
                rightTop.addElement(meta);

                topTable.addCell(leftTop);
                topTable.addCell(rightTop);
                topTable.setSpacingAfter(15f);
                document.add(topTable);

                PdfPTable partyTable = new PdfPTable(2);
                partyTable.setWidthPercentage(100);
                partyTable.setWidths(new float[]{1f, 1f});

                PdfPCell supplierCell = blockCell("SUPPLIER DETAILS", sectionFont);
                supplierCell.addElement(new Paragraph(rs.getString("supplier_name"), labelFont));
                supplierCell.addElement(new Paragraph(rs.getString("supplier_address"), valueFont));
                supplierCell.addElement(new Paragraph("Email: " + rs.getString("supplier_email"), smallFont));
                supplierCell.addElement(new Paragraph("Company: " + rs.getString("company_name"), smallFont));

                PdfPCell billToCell = blockCell("BILL TO / DELIVERY", sectionFont);
                billToCell.addElement(new Paragraph("Supplexio Receiving & Accounts", labelFont));
                billToCell.addElement(new Paragraph("AxaltaWebApp Industrial Procurement Cell", valueFont));
                billToCell.addElement(new Paragraph("Inbound Materials Department", smallFont));
                billToCell.addElement(new Paragraph("Payment Terms: As per approved supplier agreement", smallFont));

                partyTable.addCell(supplierCell);
                partyTable.addCell(billToCell);
                partyTable.setSpacingAfter(16f);
                document.add(partyTable);

                PdfPTable itemTable = new PdfPTable(new float[]{0.8f, 3.2f, 1.0f, 1.2f, 1.2f, 1.3f});
                itemTable.setWidthPercentage(100);

                itemTable.addCell(tableHeader("S/N", sectionFont));
                itemTable.addCell(tableHeader("DESCRIPTION", sectionFont));
                itemTable.addCell(tableHeader("QTY", sectionFont));
                itemTable.addCell(tableHeader("UNIT RATE", sectionFont));
                itemTable.addCell(tableHeader("GST", sectionFont));
                itemTable.addCell(tableHeader("AMOUNT", sectionFont));

                itemTable.addCell(tableValue("1", valueFont, Element.ALIGN_CENTER));
                itemTable.addCell(tableValue(
                    rs.getString("product_name") + "\nReverse-auction sourced procurement item under approved purchase flow.",
                    valueFont, Element.ALIGN_LEFT));
                itemTable.addCell(tableValue(String.valueOf(rs.getInt("quantity")), valueFont, Element.ALIGN_CENTER));
                itemTable.addCell(tableValue("₹" + String.format("%.2f", rs.getDouble("unit_price")), valueFont, Element.ALIGN_RIGHT));
                itemTable.addCell(tableValue("₹" + String.format("%.2f", rs.getDouble("tax_amount")), valueFont, Element.ALIGN_RIGHT));
                itemTable.addCell(tableValue("₹" + String.format("%.2f", rs.getDouble("subtotal")), valueFont, Element.ALIGN_RIGHT));

                for (int i = 0; i < 8; i++) {
                    itemTable.addCell(tableValue("", valueFont, Element.ALIGN_CENTER));
                    itemTable.addCell(tableValue("", valueFont, Element.ALIGN_LEFT));
                    itemTable.addCell(tableValue("", valueFont, Element.ALIGN_CENTER));
                    itemTable.addCell(tableValue("", valueFont, Element.ALIGN_RIGHT));
                    itemTable.addCell(tableValue("", valueFont, Element.ALIGN_RIGHT));
                    itemTable.addCell(tableValue("", valueFont, Element.ALIGN_RIGHT));
                }

                itemTable.setSpacingAfter(16f);
                document.add(itemTable);

                PdfPTable remarksTotals = new PdfPTable(new float[]{2.2f, 1.1f});
                remarksTotals.setWidthPercentage(100);

                PdfPCell remarks = new PdfPCell();
                remarks.setBorder(Rectangle.BOX);
                remarks.setBorderColor(BORDER);
                remarks.setPadding(10f);
                remarks.addElement(new Paragraph("REMARKS / INSTRUCTIONS", labelFont));
                remarks.addElement(new Paragraph("1. Material must match approved quality and technical specifications.", smallFont));
                remarks.addElement(new Paragraph("2. Delivery acknowledgement and inward verification are mandatory.", smallFont));
                remarks.addElement(new Paragraph("3. Invoice and PO number must be quoted on all dispatch documents.", smallFont));
                remarks.addElement(new Paragraph("4. This document is system generated through Supplexio procurement workflow.", smallFont));

                PdfPCell totals = new PdfPCell();
                totals.setBorder(Rectangle.BOX);
                totals.setBorderColor(BORDER);
                totals.setPadding(0f);

                PdfPTable totalsTable = new PdfPTable(2);
                totalsTable.setWidthPercentage(100);
                totalsTable.addCell(sumLabel("Subtotal", labelFont));
                totalsTable.addCell(sumValue("₹" + String.format("%.2f", rs.getDouble("subtotal")), valueFont));
                totalsTable.addCell(sumLabel("GST @ 7.5%", labelFont));
                totalsTable.addCell(sumValue("₹" + String.format("%.2f", rs.getDouble("tax_amount")), valueFont));
                totalsTable.addCell(sumLabel("Freight / Handling", labelFont));
                totalsTable.addCell(sumValue("₹0.00", valueFont));
                totalsTable.addCell(sumLabel("Grand Total", totalFont));
                totalsTable.addCell(sumValue("₹" + String.format("%.2f", rs.getDouble("grand_total")), totalFont));
                totals.addElement(totalsTable);

                remarksTotals.addCell(remarks);
                remarksTotals.addCell(totals);
                remarksTotals.setSpacingAfter(18f);
                document.add(remarksTotals);

                Paragraph thanks = new Paragraph("Thank you for partnering with Supplexio.", totalFont);
                thanks.setAlignment(Element.ALIGN_CENTER);
                document.add(thanks);

                Paragraph footer = new Paragraph(
                    "For procurement support, contact procurement@supplexio.com | This document is valid without physical signature.",
                    smallFont);
                footer.setAlignment(Element.ALIGN_CENTER);
                footer.setSpacingBefore(8f);
                document.add(footer);

                document.close();
            }
        } catch (Exception e) {
            throw new ServletException("Error generating PO PDF", e);
        }
    }
private void addPaidWatermark(PdfWriter writer, Document document) throws Exception {
    PdfContentByte canvas = writer.getDirectContentUnder();
    PdfGState gs = new PdfGState();
    gs.setFillOpacity(0.14f);

    canvas.saveState();
    canvas.setGState(gs);
    canvas.beginText();
    BaseFont bf = BaseFont.createFont(BaseFont.HELVETICA_BOLD, BaseFont.WINANSI, BaseFont.EMBEDDED);
    canvas.setFontAndSize(bf, 80);
    canvas.setColorFill(new BaseColor(180, 180, 180));
    canvas.showTextAligned(
        Element.ALIGN_CENTER,
        "PAID",
        document.getPageSize().getWidth() / 2,
        document.getPageSize().getHeight() / 2,
        45
    );
    canvas.endText();
    canvas.restoreState();
}

    private PdfPCell metaHeader(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(BRAND);
        cell.setHorizontalAlignment(Element.ALIGN_LEFT);
        cell.setPadding(8f);
        cell.setBorderColor(BORDER);
        return cell;
    }

    private PdfPCell metaValue(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setHorizontalAlignment(Element.ALIGN_LEFT);
        cell.setPadding(8f);
        cell.setBorderColor(BORDER);
        return cell;
    }

    private PdfPCell blockCell(String title, Font titleFont) {
        PdfPCell cell = new PdfPCell();
        cell.setBorder(Rectangle.BOX);
        cell.setBorderColor(BORDER);
        cell.setPadding(0f);

        PdfPTable inner = new PdfPTable(1);
        inner.setWidthPercentage(100);

        PdfPCell titleCell = new PdfPCell(new Phrase(title, titleFont));
        titleCell.setBackgroundColor(BRAND);
        titleCell.setPadding(8f);
        titleCell.setBorderColor(BORDER);
        inner.addCell(titleCell);

        cell.addElement(inner);
        cell.setPadding(10f);
        return cell;
    }

    private PdfPCell tableHeader(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(BRAND);
        cell.setPadding(8f);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setBorderColor(BORDER);
        return cell;
    }

    private PdfPCell tableValue(String text, Font font, int align) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(8f);
        cell.setHorizontalAlignment(align);
        cell.setVerticalAlignment(Element.ALIGN_TOP);
        cell.setBorderColor(BORDER);
        cell.setMinimumHeight(24f);
        return cell;
    }

    private PdfPCell sumLabel(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(8f);
        cell.setBackgroundColor(LIGHT);
        cell.setBorderColor(BORDER);
        return cell;
    }

    private PdfPCell sumValue(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(8f);
        cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        cell.setBorderColor(BORDER);
        return cell;
    }
}
