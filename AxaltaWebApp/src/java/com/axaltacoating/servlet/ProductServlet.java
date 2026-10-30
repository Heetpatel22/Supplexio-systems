package com.axaltacoating.servlet;

import com.axaltacoating.model.Product;
import com.axaltacoating.util.DatabaseConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet for handling product management operations.
 */
@WebServlet(name = "ProductServlet", urlPatterns = {"/product"})
public class ProductServlet extends HttpServlet {

    /**
     * Handles the HTTP GET method - displays product list or form.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "new":
                showNewForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteProduct(request, response);
                break;
            default:
                listProducts(request, response);
                break;
        }
    }

    /**
     * Handles the HTTP POST method - processes form submissions.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        switch (action) {
            case "create":
                createProduct(request, response);
                break;
            case "update":
                updateProduct(request, response);
                break;
            default:
                listProducts(request, response);
                break;
        }
    }

    /**
     * Lists all products.
     */
    private void listProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Product> products = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement("SELECT * FROM products ORDER BY name");
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Product product = new Product();
                product.setId(rs.getLong("id"));
                Long inventoryId = rs.getLong("inventory_id");
                if (rs.wasNull()) {
                    inventoryId = null;
                }
                product.setInventoryId(inventoryId);
                product.setName(rs.getString("name"));
                product.setDescription(rs.getString("description"));
                product.setCategory(rs.getString("category"));
                product.setUnitPrice(rs.getDouble("base_price"));
                product.setUnit(rs.getString("unit"));
                product.setInventoryQuantity(rs.getInt("stock_quantity"));
                products.add(product);
            }
            
            request.setAttribute("products", products);
            request.getRequestDispatcher("/WEB-INF/views/product/list.jsp").forward(request, response);
            
        } catch (SQLException e) {
            throw new ServletException("Error retrieving products", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }

    /**
     * Shows form to create a new product.
     */
    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/product/form.jsp").forward(request, response);
    }

    /**
     * Shows form to edit an existing product.
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/product");
            return;
        }
        
        long id = Long.parseLong(idParam);
        Product product = null;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement("SELECT * FROM products WHERE id = ?");
            stmt.setLong(1, id);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                product = new Product();
                product.setId(rs.getLong("id"));
                product.setInventoryId(rs.getLong("inventory_id"));
                product.setName(rs.getString("name"));
                product.setDescription(rs.getString("description"));
                product.setCategory(rs.getString("category"));
                product.setUnitPrice(rs.getDouble("base_price"));
                product.setUnit(rs.getString("unit"));
            }
            
            if (product != null) {
                request.setAttribute("product", product);
                request.getRequestDispatcher("/WEB-INF/views/product/form.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/product");
            }
            
        } catch (SQLException e) {
            throw new ServletException("Error retrieving product", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }

    /**
     * Creates a new product.
     * Handles null inventory_id values and validates if provided.
     */
    private void createProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String unit = request.getParameter("unit");
        String category = request.getParameter("category");
        String basePriceStr = request.getParameter("basePrice");
        String inventoryIdStr = request.getParameter("inventoryId");
        String inventoryQuantityStr = request.getParameter("inventoryQuantity");
        
        // Default category if not provided
        if (category == null || category.trim().isEmpty()) {
            category = "General";
        } else {
            category = category.trim();
        }
        
        // Default base price if not provided
        double basePrice = 0.0;
        if (basePriceStr != null && !basePriceStr.trim().isEmpty()) {
            try {
                basePrice = Double.parseDouble(basePriceStr);
            } catch (NumberFormatException e) {
                // Use default value if parsing fails
            }
        }
        
        // Parse inventoryId
        Long inventoryId = null;
        if (inventoryIdStr != null && !inventoryIdStr.trim().isEmpty()) {
            try {
                long parsedInventoryId = Long.parseLong(inventoryIdStr);
                if (parsedInventoryId > 0) {
                    inventoryId = parsedInventoryId;
                } else {
                    request.setAttribute("error", "Inventory ID must be a positive integer");
                    request.getRequestDispatcher("/WEB-INF/views/product/form.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid Inventory ID format");
                request.getRequestDispatcher("/WEB-INF/views/product/form.jsp").forward(request, response);
                return;
            }
        }
        
        // Parse inventoryQuantity
        int inventoryQuantity = 0;
        if (inventoryQuantityStr != null && !inventoryQuantityStr.trim().isEmpty()) {
            try {
                inventoryQuantity = Integer.parseInt(inventoryQuantityStr);
                if (inventoryQuantity < 0) {
                    request.setAttribute("error", "Inventory quantity must be a non-negative integer");
                    request.getRequestDispatcher("/WEB-INF/views/product/form.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid inventory quantity format");
                request.getRequestDispatcher("/WEB-INF/views/product/form.jsp").forward(request, response);
                return;
            }
        }
        
        if (name == null || name.trim().isEmpty() || unit == null || unit.trim().isEmpty()) {
            request.setAttribute("error", "Product name and unit are required");
            request.getRequestDispatcher("/WEB-INF/views/product/form.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement(
                "INSERT INTO products (name, description, category, base_price, stock_quantity, unit, inventory_id) VALUES (?, ?, ?, ?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS
            );
            
            stmt.setString(1, name);
            stmt.setString(2, description);
            stmt.setString(3, category);
            stmt.setDouble(4, basePrice);
            stmt.setInt(5, inventoryQuantity);
            stmt.setString(6, unit);
            stmt.setLong(7, inventoryId);
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                request.setAttribute("success", "Product created successfully");
            } else {
                request.setAttribute("error", "Failed to create product");
            }
            
            listProducts(request, response);
            
        } catch (SQLException e) {
            throw new ServletException("Error creating product", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }

    /**
     * Updates an existing product.
     */
    /**
     * Updates an existing product.
     * Handles null inventory_id values and validates if provided.
     */
    private void updateProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String basePriceStr = request.getParameter("basePrice");
        String unitStr = request.getParameter("unit");
        String inventoryIdStr = request.getParameter("inventoryId");
        String inventoryQuantityStr = request.getParameter("inventoryQuantity");
        
        // Default category if not provided
        if (category == null || category.trim().isEmpty()) {
            category = "General";
        }
        
        // Default base price if not provided
        double basePrice = 0.0;
        if (basePriceStr != null && !basePriceStr.trim().isEmpty()) {
            try {
                basePrice = Double.parseDouble(basePriceStr);
            } catch (NumberFormatException e) {
                // Use default value if parsing fails
            }
        }
        
        // Parse and validate inventoryId
        Long inventoryId = null;
        if (inventoryIdStr != null && !inventoryIdStr.trim().isEmpty()) {
            try {
                long parsedInventoryId = Long.parseLong(inventoryIdStr);
                if (parsedInventoryId > 0) {
                    inventoryId = parsedInventoryId;
                } else {
                    request.setAttribute("error", "Inventory ID must be a positive integer");
                    request.getRequestDispatcher("/WEB-INF/views/product/form.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid Inventory ID format");
                request.getRequestDispatcher("/WEB-INF/views/product/form.jsp").forward(request, response);
                return;
            }
        }
        
        // Parse inventoryQuantity
        int inventoryQuantity = 0;
        if (inventoryQuantityStr != null && !inventoryQuantityStr.trim().isEmpty()) {
            try {
                inventoryQuantity = Integer.parseInt(inventoryQuantityStr);
                if (inventoryQuantity < 0) {
                    request.setAttribute("error", "Inventory quantity must be a non-negative integer");
                    request.getRequestDispatcher("/WEB-INF/views/product/form.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid inventory quantity format");
                request.getRequestDispatcher("/WEB-INF/views/product/form.jsp").forward(request, response);
                return;
            }
        }
        
        if (idParam == null || idParam.isEmpty() || name == null || name.trim().isEmpty() || unitStr == null || unitStr.trim().isEmpty()) {
            request.setAttribute("error", "Product ID, name, and unit are required");
            request.getRequestDispatcher("/WEB-INF/views/product/form.jsp").forward(request, response);
            return;
        }
        
        long id = Long.parseLong(idParam);
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement(
                "UPDATE products SET name = ?, description = ?, category = ?, base_price = ?, stock_quantity = ?, unit = ?, inventory_id = ? WHERE id = ?"
            );
            
            stmt.setString(1, name);
            stmt.setString(2, description);
            stmt.setString(3, category);
            stmt.setDouble(4, basePrice);
            stmt.setInt(5, inventoryQuantity);
            stmt.setString(6, unitStr);
            if (inventoryId != null) {
                stmt.setLong(7, inventoryId);
            } else {
                stmt.setNull(7, java.sql.Types.BIGINT);
            }
            stmt.setLong(8, id);
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                request.setAttribute("success", "Product updated successfully");
            } else {
                request.setAttribute("error", "Failed to update product");
            }
            
            listProducts(request, response);
            
        } catch (SQLException e) {
            throw new ServletException("Error updating product", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }

    /**
     * Deletes a product.
     */
    private void deleteProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/product");
            return;
        }
        
        long id = Long.parseLong(idParam);
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement("DELETE FROM products WHERE id = ?");
            stmt.setLong(1, id);
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                request.setAttribute("success", "Product deleted successfully");
            } else {
                request.setAttribute("error", "Failed to delete product");
            }
            
            listProducts(request, response);
            
        } catch (SQLException e) {
            throw new ServletException("Error deleting product", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }
}
