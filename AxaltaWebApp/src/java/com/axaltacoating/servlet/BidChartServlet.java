package com.axaltacoating.servlet;

import com.axaltacoating.util.DatabaseConnection;
import java.io.IOException;
import java.io.PrintWriter;
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
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

@WebServlet(name = "BidChartServlet", urlPatterns = {"/api/bids/chart"})
@SuppressWarnings("unchecked")
public class BidChartServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(BidChartServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String auctionIdParam = request.getParameter("auctionId");

        if (auctionIdParam == null || auctionIdParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing required parameter: auctionId");
            return;
        }

        long auctionId;
        try {
            auctionId = Long.parseLong(auctionIdParam);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid auction ID format");
            return;
        }

        List<Map<String, Object>> chartData = getBidChartData(auctionId);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONArray jsonArray = new JSONArray();

        for (Map<String, Object> dataPoint : chartData) {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("bidTime", dataPoint.get("bidTime"));
            jsonObject.put("bidAmount", dataPoint.get("bidAmount"));
            jsonObject.put("supplierName", dataPoint.get("supplierName"));
            jsonArray.add(jsonObject);
        }

        PrintWriter out = response.getWriter();
        out.print(jsonArray.toJSONString());
        out.flush();
    }

    private List<Map<String, Object>> getBidChartData(long auctionId) {
        List<Map<String, Object>> chartData = new ArrayList<Map<String, Object>>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();

            boolean chartTableExists = false;
            ResultSet tables = conn.getMetaData().getTables(null, null, "bid_chart_data", null);
            if (tables.next()) {
                chartTableExists = true;
            }
            tables.close();

            if (chartTableExists) {
                try {
                    stmt = conn.prepareStatement(
                        "SELECT bid_time, amount, supplier_name " +
                        "FROM bid_chart_data " +
                        "WHERE auction_id = ? " +
                        "ORDER BY bid_time ASC"
                    );
                    stmt.setLong(1, auctionId);
                    rs = stmt.executeQuery();

                    while (rs.next()) {
                        Map<String, Object> dataPoint = new HashMap<String, Object>();
                        dataPoint.put("bidTime", rs.getTimestamp("bid_time").getTime());
                        dataPoint.put("bidAmount", rs.getDouble("amount"));
                        dataPoint.put("supplierName", rs.getString("supplier_name"));
                        chartData.add(dataPoint);
                    }
                } catch (SQLException ignored) {
                    DatabaseConnection.closeQuietly(rs, stmt, null);
                    rs = null;
                    stmt = null;
                }
            }

            if (chartData.isEmpty()) {
                DatabaseConnection.closeQuietly(rs, stmt, null);
                rs = null;
                stmt = conn.prepareStatement(
                    "SELECT b.bid_time, b.amount, s.name AS supplier_name " +
                    "FROM bids b " +
                    "JOIN suppliers s ON b.supplier_id = s.id " +
                    "WHERE b.auction_id = ? " +
                    "ORDER BY b.bid_time ASC"
                );
                stmt.setLong(1, auctionId);
                rs = stmt.executeQuery();

                while (rs.next()) {
                    Map<String, Object> dataPoint = new HashMap<String, Object>();
                    dataPoint.put("bidTime", rs.getTimestamp("bid_time").getTime());
                    dataPoint.put("bidAmount", rs.getDouble("amount"));
                    dataPoint.put("supplierName", rs.getString("supplier_name"));
                    chartData.add(dataPoint);
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving bid chart data", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }

        return chartData;
    }
}
