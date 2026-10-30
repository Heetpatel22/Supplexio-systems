package com.axaltacoating.controller;

import com.axaltacoating.model.Inventory;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class HomeServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        List<Inventory> inventoryList = (List<Inventory>) session.getAttribute("inventoryList");
        boolean lowStock = false;
        StringBuilder lowStockItems = new StringBuilder();

        if (inventoryList != null) {
            for (Inventory inv : inventoryList) {
                if (inv.getQuantity() < inv.getThreshold()) {
                    lowStock = true;
                    lowStockItems.append(inv.getItemName()).append(", ");
                }
            }
        }

        if (lowStock) {
            // Remove trailing comma and space
            String items = lowStockItems.substring(0, lowStockItems.length() - 2);
            request.setAttribute("inventoryAlert", "Low stock for: " + items);
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/home.jsp");
        dispatcher.forward(request, response);
    }
}