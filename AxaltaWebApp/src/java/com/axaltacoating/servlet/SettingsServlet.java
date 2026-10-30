package com.axaltacoating.servlet;

import com.axaltacoating.model.User;
import com.axaltacoating.util.AuthUtil;
import com.axaltacoating.util.DatabaseConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet for handling settings and user management.
 */
public class SettingsServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(SettingsServlet.class.getName());
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        if (!"ADMIN".equals(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "users"; // Default action
        }
        
        switch (action) {
            case "users":
                listUsers(request, response);
                break;
            case "editUser":
                editUser(request, response);
                break;
            case "newUser":
                showNewUserForm(request, response);
                break;
            default:
                listUsers(request, response);
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        if (!"ADMIN".equals(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action is required");
            return;
        }
        
        switch (action) {
            case "createUser":
                createUser(request, response);
                break;
            case "updateUser":
                updateUser(request, response);
                break;
            case "deleteUser":
                deleteUser(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
                break;
        }
    }
    
    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Get all users
            stmt = conn.prepareStatement(
                "SELECT * FROM users ORDER BY username"
            );
            rs = stmt.executeQuery();
            
            List<User> users = new ArrayList<>();
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                user.setEmail(rs.getString("email"));
                user.setLastLogin(rs.getTimestamp("last_login"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setUpdatedAt(rs.getTimestamp("updated_at"));
                users.add(user);
            }
            
            request.setAttribute("users", users);
            request.getRequestDispatcher("/WEB-INF/views/settings/users.jsp").forward(request, response);
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error listing users", e);
            throw new ServletException("Error listing users", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }
    
    private void editUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userId = request.getParameter("id");
        if (userId == null || userId.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required");
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Get user by ID
            stmt = conn.prepareStatement(
                "SELECT * FROM users WHERE id = ?"
            );
            stmt.setInt(1, Integer.parseInt(userId));
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                user.setEmail(rs.getString("email"));
                user.setLastLogin(rs.getTimestamp("last_login"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setUpdatedAt(rs.getTimestamp("updated_at"));
                
                request.setAttribute("user", user);
                request.getRequestDispatcher("/WEB-INF/views/settings/edit_user.jsp").forward(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "User not found");
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting user", e);
            throw new ServletException("Error getting user", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }
    
    private void showNewUserForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/settings/new_user.jsp").forward(request, response);
    }
    
    private void createUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");
        String email = request.getParameter("email");
        String status = request.getParameter("status");
        
        // Validate input
        List<String> errors = validateUserInput(username, password, confirmPassword, role, email, status, true);
        
        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("username", username);
            request.setAttribute("role", role);
            request.setAttribute("email", email);
            request.setAttribute("status", status);
            request.getRequestDispatcher("/WEB-INF/views/settings/new_user.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Check if username already exists
            stmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM users WHERE username = ?"
            );
            stmt.setString(1, username);
            rs = stmt.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                errors.add("Username already exists");
                request.setAttribute("errors", errors);
                request.setAttribute("username", username);
                request.setAttribute("role", role);
                request.setAttribute("email", email);
                request.setAttribute("status", status);
                request.getRequestDispatcher("/WEB-INF/views/settings/new_user.jsp").forward(request, response);
                return;
            }
            
            // Check if email already exists
            stmt.close();
            stmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM users WHERE email = ?"
            );
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                errors.add("Email already exists");
                request.setAttribute("errors", errors);
                request.setAttribute("username", username);
                request.setAttribute("role", role);
                request.setAttribute("email", email);
                request.setAttribute("status", status);
                request.getRequestDispatcher("/WEB-INF/views/settings/new_user.jsp").forward(request, response);
                return;
            }
            
            // Hash password
            String passwordHash = AuthUtil.hashPassword(password);
            
            // Insert new user
            stmt.close();
            stmt = conn.prepareStatement(
                "INSERT INTO users (username, password_hash, role, status, email) VALUES (?, ?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS
            );
            stmt.setString(1, username);
            stmt.setString(2, passwordHash);
            stmt.setString(3, role);
            stmt.setString(4, status);
            stmt.setString(5, email);
            stmt.executeUpdate();
            
            // If user is a supplier, create supplier record
            if ("SUPPLIER".equals(role)) {
                rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    int userId = rs.getInt(1);
                    createSupplierRecord(conn, userId, username, email);
                }
            }
            
            // Redirect to user list with success message
            request.getSession().setAttribute("successMessage", "User created successfully");
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating user", e);
            throw new ServletException("Error creating user", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }
    
    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userId = request.getParameter("id");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");
        String email = request.getParameter("email");
        String status = request.getParameter("status");
        
        if (userId == null || userId.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required");
            return;
        }
        
        // Validate input (password can be empty for update)
        boolean passwordRequired = password != null && !password.trim().isEmpty();
        List<String> errors = validateUserInput(username, password, confirmPassword, role, email, status, passwordRequired);
        
        if (!errors.isEmpty()) {
            User user = new User();
            user.setId(Integer.parseInt(userId));
            user.setUsername(username);
            user.setRole(role);
            user.setStatus(status);
            user.setEmail(email);
            
            request.setAttribute("user", user);
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/WEB-INF/views/settings/edit_user.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Check if username already exists for another user
            stmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM users WHERE username = ? AND id != ?"
            );
            stmt.setString(1, username);
            stmt.setInt(2, Integer.parseInt(userId));
            rs = stmt.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                errors.add("Username already exists");
                User user = new User();
                user.setId(Integer.parseInt(userId));
                user.setUsername(username);
                user.setRole(role);
                user.setStatus(status);
                user.setEmail(email);
                
                request.setAttribute("user", user);
                request.setAttribute("errors", errors);
                request.getRequestDispatcher("/WEB-INF/views/settings/edit_user.jsp").forward(request, response);
                return;
            }
            
            // Check if email already exists for another user
            stmt.close();
            stmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM users WHERE email = ? AND id != ?"
            );
            stmt.setString(1, email);
            stmt.setInt(2, Integer.parseInt(userId));
            rs = stmt.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                errors.add("Email already exists");
                User user = new User();
                user.setId(Integer.parseInt(userId));
                user.setUsername(username);
                user.setRole(role);
                user.setStatus(status);
                user.setEmail(email);
                
                request.setAttribute("user", user);
                request.setAttribute("errors", errors);
                request.getRequestDispatcher("/WEB-INF/views/settings/edit_user.jsp").forward(request, response);
                return;
            }
            
            // Update user
            String sql;
            if (passwordRequired) {
                // Update with new password
                String passwordHash = AuthUtil.hashPassword(password);
                sql = "UPDATE users SET username = ?, password_hash = ?, role = ?, status = ?, email = ? WHERE id = ?";
                stmt.close();
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, username);
                stmt.setString(2, passwordHash);
                stmt.setString(3, role);
                stmt.setString(4, status);
                stmt.setString(5, email);
                stmt.setInt(6, Integer.parseInt(userId));
            } else {
                // Update without changing password
                sql = "UPDATE users SET username = ?, role = ?, status = ?, email = ? WHERE id = ?";
                stmt.close();
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, username);
                stmt.setString(2, role);
                stmt.setString(3, status);
                stmt.setString(4, email);
                stmt.setInt(5, Integer.parseInt(userId));
            }
            
            stmt.executeUpdate();
            
            // Check if user is a supplier and create supplier record if needed
            if ("SUPPLIER".equals(role)) {
                stmt.close();
                stmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM suppliers WHERE user_id = ?"
                );
                stmt.setInt(1, Integer.parseInt(userId));
                rs = stmt.executeQuery();
                rs.next();
                if (rs.getInt(1) == 0) {
                    createSupplierRecord(conn, Integer.parseInt(userId), username, email);
                }
            }
            
            // Redirect to user list with success message
            request.getSession().setAttribute("successMessage", "User updated successfully");
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating user", e);
            throw new ServletException("Error updating user", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }
    
    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userId = request.getParameter("id");
        
        if (userId == null || userId.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required");
            return;
        }
        
        // Don't allow deleting the admin user
        if ("1".equals(userId)) {
            request.getSession().setAttribute("errorMessage", "Cannot delete the admin user");
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Delete user
            stmt = conn.prepareStatement(
                "DELETE FROM users WHERE id = ?"
            );
            stmt.setInt(1, Integer.parseInt(userId));
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                request.getSession().setAttribute("successMessage", "User deleted successfully");
            } else {
                request.getSession().setAttribute("errorMessage", "User not found");
            }
            
            response.sendRedirect(request.getContextPath() + "/settings?action=users");
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting user", e);
            throw new ServletException("Error deleting user", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, conn);
        }
    }
    
    private List<String> validateUserInput(String username, String password, String confirmPassword, 
                                         String role, String email, String status, boolean passwordRequired) {
        List<String> errors = new ArrayList<>();
        
        if (username == null || username.trim().isEmpty()) {
            errors.add("Username is required");
        } else if (username.length() < 3 || username.length() > 50) {
            errors.add("Username must be between 3 and 50 characters");
        }
        
        if (passwordRequired) {
            if (password == null || password.trim().isEmpty()) {
                errors.add("Password is required");
            } else if (password.length() < 6) {
                errors.add("Password must be at least 6 characters");
            }
            
            if (confirmPassword == null || !confirmPassword.equals(password)) {
                errors.add("Passwords do not match");
            }
        }
        
        if (role == null || role.trim().isEmpty()) {
            errors.add("Role is required");
        } else if (!"ADMIN".equals(role) && !"USER".equals(role) && !"SUPPLIER".equals(role)) {
            errors.add("Invalid role");
        }
        
        if (email == null || email.trim().isEmpty()) {
            errors.add("Email is required");
        } else if (!email.matches("^[\\w.-]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
            errors.add("Invalid email format");
        }
        
        if (status == null || status.trim().isEmpty()) {
            errors.add("Status is required");
        } else if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status) && !"BLOCKED".equals(status)) {
            errors.add("Invalid status");
        }
        
        return errors;
    }
    
    private void createSupplierRecord(Connection conn, int userId, String username, String email) throws SQLException {
        PreparedStatement stmt = null;
        
        try {
            stmt = conn.prepareStatement(
                "INSERT INTO suppliers (user_id, name, email, company_name, contact_person, status) VALUES (?, ?, ?, ?, ?, 'PENDING')"
            );
            stmt.setInt(1, userId);
            stmt.setString(2, username); // Supplier name
            stmt.setString(3, email); // Email
            stmt.setString(4, username + " Company"); // Default company name
            stmt.setString(5, email); // Use email as contact person
            stmt.executeUpdate();
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, null);
        }
    }
}
