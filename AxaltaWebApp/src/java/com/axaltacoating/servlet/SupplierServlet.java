package com.axaltacoating.servlet;

import com.axaltacoating.model.Supplier;
import com.axaltacoating.util.DatabaseConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet for handling supplier management operations.
 */
@WebServlet(name = "SupplierServlet", urlPatterns = {"/supplier"})
public class SupplierServlet extends HttpServlet {

    /**
     * Handles the HTTP GET method - displays supplier list or form.
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
                deleteSupplier(request, response);
                break;
            default:
                listSuppliers(request, response);
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
                createSupplier(request, response);
                break;
            case "update":
                updateSupplier(request, response);
                break;
            default:
                listSuppliers(request, response);
                break;
        }
    }

    /**
     * Lists all suppliers.
     */
    private void listSuppliers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Supplier> suppliers = new ArrayList<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT * FROM suppliers ORDER BY id");
            
            while (rs.next()) {
                Supplier supplier = new Supplier();
                supplier.setId(rs.getLong("id"));
                supplier.setName(rs.getString("name"));
                supplier.setEmail(rs.getString("email"));
                supplier.setPhone(rs.getString("phone"));
                supplier.setAddress(rs.getString("address"));
                supplier.setStatus(rs.getString("status"));
                suppliers.add(supplier);
            }
            
            request.setAttribute("suppliers", suppliers);
            request.getRequestDispatcher("/WEB-INF/views/supplier/list.jsp").forward(request, response);
            
        } catch (SQLException e) {
            throw new ServletException("Error retrieving suppliers", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }

    /**
     * Shows form to create a new supplier.
     */
    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/supplier/form.jsp").forward(request, response);
    }

    /**
     * Shows form to edit an existing supplier.
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/supplier");
            return;
        }
        
        long id = Long.parseLong(idParam);
        Supplier supplier = null;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement("SELECT * FROM suppliers WHERE id = ?");
            stmt.setLong(1, id);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                supplier = new Supplier();
                supplier.setId(rs.getLong("id"));
                supplier.setName(rs.getString("name"));
                supplier.setEmail(rs.getString("email"));
                supplier.setPhone(rs.getString("phone"));
                supplier.setAddress(rs.getString("address"));
                supplier.setStatus(rs.getString("status"));
            }
            
            if (supplier != null) {
                request.setAttribute("supplier", supplier);
                request.getRequestDispatcher("/WEB-INF/views/supplier/form.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/supplier");
            }
            
        } catch (SQLException e) {
            throw new ServletException("Error retrieving supplier", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }

    /**
     * Creates a new supplier.
     */
    private void createSupplier(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String status = request.getParameter("status");
        
        if (name == null || name.trim().isEmpty() || 
            email == null || email.trim().isEmpty() || 
            phone == null || phone.trim().isEmpty()) {
            
            request.setAttribute("error", "Name, email, and phone are required");
            request.getRequestDispatcher("/WEB-INF/views/supplier/form.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Log the database connection and supplier data for debugging
            System.out.println("Database connection: " + (conn != null ? "Success" : "Failed"));
            System.out.println("Adding supplier: " + name + ", " + email + ", " + phone);
            
            // Use a simpler SQL statement with only the essential columns
            stmt = conn.prepareStatement(
                "INSERT INTO suppliers (name, email, phone, address, status) " +
                "VALUES (?, ?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS
            );
            
            stmt.setString(1, name);
            stmt.setString(2, email);
            stmt.setString(3, phone);
            stmt.setString(4, address);
            stmt.setString(5, status != null && !status.isEmpty() ? status : "ACTIVE");
            
            System.out.println("Executing SQL: INSERT INTO suppliers (name, email, phone, address, status) VALUES ('" + 
                name + "', '" + email + "', '" + phone + "', '" + address + "', '" + 
                (status != null && !status.isEmpty() ? status : "ACTIVE") + "')");
            
            int affectedRows = stmt.executeUpdate();
            
            System.out.println("SQL execution result: " + affectedRows + " rows affected");
            
            if (affectedRows > 0) {
                request.setAttribute("success", "Supplier created successfully");
            } else {
                request.setAttribute("error", "Failed to create supplier");
            }
            
            listSuppliers(request, response);
            
        } catch (SQLException e) {
            System.err.println("SQL Error: " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            throw new ServletException("Error creating supplier", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }

    /**
     * Updates an existing supplier.
     */
    private void updateSupplier(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String status = request.getParameter("status");
        
        if (idParam == null || idParam.isEmpty() || 
            name == null || name.trim().isEmpty() || 
            email == null || email.trim().isEmpty() || 
            phone == null || phone.trim().isEmpty()) {
            
            request.setAttribute("error", "ID, name, email, and phone are required");
            request.getRequestDispatcher("/WEB-INF/views/supplier/form.jsp").forward(request, response);
            return;
        }
        
        long id = Long.parseLong(idParam);
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement(
                "UPDATE suppliers SET name = ?, email = ?, phone = ?, address = ?, status = ? WHERE id = ?"
            );
            
            stmt.setString(1, name);
            stmt.setString(2, email);
            stmt.setString(3, phone);
            stmt.setString(4, address);
            stmt.setString(5, status != null && !status.isEmpty() ? status : "ACTIVE");
            stmt.setLong(6, id);
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                request.setAttribute("success", "Supplier updated successfully");
            } else {
                request.setAttribute("error", "Failed to update supplier");
            }
            
            listSuppliers(request, response);
            
        } catch (SQLException e) {
            throw new ServletException("Error updating supplier", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }

    /**
     * Deletes a supplier.
     */
    private void deleteSupplier(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/supplier");
            return;
        }
        
        long id = Long.parseLong(idParam);
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement("DELETE FROM suppliers WHERE id = ?");
            stmt.setLong(1, id);
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                request.setAttribute("success", "Supplier deleted successfully");
            } else {
                request.setAttribute("error", "Failed to delete supplier");
            }
            
            listSuppliers(request, response);
        } catch (SQLIntegrityConstraintViolationException e) {
            request.setAttribute("error", "Cannot delete supplier: There are payments or other records linked to this supplier. Please remove related payments first.");
            listSuppliers(request, response);
        } catch (SQLException e) {
            throw new ServletException("Error deleting supplier", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }
}
