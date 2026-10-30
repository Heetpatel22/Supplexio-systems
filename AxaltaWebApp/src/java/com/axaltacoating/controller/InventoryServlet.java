package com.axaltacoating.controller;

import com.axaltacoating.model.Inventory;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class InventoryServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get inventory from session or create new
        HttpSession session = request.getSession();
        List<Inventory> inventoryList = (List<Inventory>) session.getAttribute("inventoryList");
        if (inventoryList == null) {
            inventoryList = new ArrayList<>();
            inventoryList.add(new Inventory(1, "Steel Rods", 50, 20));
            inventoryList.add(new Inventory(2, "Copper Sheets", 30, 10));
            inventoryList.add(new Inventory(3, "Aluminum Plates", 80, 40));
            inventoryList.add(new Inventory(4, "Plastic Granules", 120, 60));
            inventoryList.add(new Inventory(5, "Paint Buckets", 15, 25));
            session.setAttribute("inventoryList", inventoryList);
        }
        request.setAttribute("inventoryList", inventoryList);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/inventory/inventory.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        List<Inventory> inventoryList = (List<Inventory>) session.getAttribute("inventoryList");
        if (inventoryList == null) {
            inventoryList = new ArrayList<>();
        }

        String action = request.getParameter("action");
        if ("add".equals(action)) {
            // Create
            String name = request.getParameter("itemName");
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            int threshold = Integer.parseInt(request.getParameter("threshold"));
            int newId = inventoryList.size() > 0 ? inventoryList.get(inventoryList.size() - 1).getId() + 1 : 1;
            inventoryList.add(new Inventory(newId, name, quantity, threshold));
        } else if ("update".equals(action)) {
            // Update
            int id = Integer.parseInt(request.getParameter("id"));
            for (Inventory inv : inventoryList) {
                if (inv.getId() == id) {
                    inv.setItemName(request.getParameter("itemName"));
                    inv.setQuantity(Integer.parseInt(request.getParameter("quantity")));
                    inv.setThreshold(Integer.parseInt(request.getParameter("threshold")));
                    break;
                }
            }
        } else if ("delete".equals(action)) {
            // Delete
            int id = Integer.parseInt(request.getParameter("id"));
            inventoryList.removeIf(inv -> inv.getId() == id);
        }

        session.setAttribute("inventoryList", inventoryList);
        response.sendRedirect(request.getContextPath() + "/inventory");
    }
}