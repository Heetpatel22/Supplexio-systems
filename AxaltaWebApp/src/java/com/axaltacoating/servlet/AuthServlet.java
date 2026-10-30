package com.axaltacoating.servlet;

import com.axaltacoating.model.User;
import com.axaltacoating.util.DatabaseConnection;
import com.axaltacoating.util.DatabaseStatusChecker;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet for handling user authentication (login, logout).
 */
public class AuthServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AuthServlet.class.getName());
    private static final long DATABASE_TIMEOUT = 30000; // 30 seconds timeout
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("logout".equals(action)) {
            // Handle logout
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        } else {
            // Default to login page
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("login".equals(action)) {
            handleLogin(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }
    
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        LOGGER.log(Level.INFO, "Login attempt for username: {0}", username);
        
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Username and password are required");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        // Always allow admin login with hardcoded credentials for demo purposes
        if ("admin".equals(username) && "admin123".equals(password)) {
            LOGGER.log(Level.INFO, "Admin user logging in with hardcoded credentials");
            // Create admin user session
            User adminUser = new User();
            adminUser.setId(1); // Assuming admin has ID 1
            adminUser.setUsername("admin");
            adminUser.setRole("ADMIN");
            adminUser.setStatus("ACTIVE");
            adminUser.setEmail("admin@example.com");
            
            // Create session
            HttpSession session = request.getSession(true);
            session.setAttribute("user", adminUser);
            session.setAttribute("userRole", adminUser.getRole());
            session.setAttribute("userId", adminUser.getId());
            
            // Redirect to admin page
            response.sendRedirect(request.getContextPath() + "/home");

            return;
        }
        
        // Check if database is ready
        if (!DatabaseStatusChecker.isDatabaseReady()) {
            try {
                DatabaseStatusChecker.waitForDatabase(DATABASE_TIMEOUT);
            } catch (InterruptedException e) {
                LOGGER.log(Level.SEVERE, "Timeout waiting for database initialization", e);
                response.sendRedirect(request.getContextPath() + "/please-wait.jsp");
                return;
            }
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            LOGGER.log(Level.INFO, "Attempting to connect to database");
            conn = DatabaseConnection.getConnection();
            LOGGER.log(Level.INFO, "Database connection successful");
            
            // Get user by username
            stmt = conn.prepareStatement(
                "SELECT * FROM users WHERE username = ? AND status = 'ACTIVE'"
            );
            stmt.setString(1, username);
            LOGGER.log(Level.INFO, "Executing query for username: {0}", username);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                String storedPassword = rs.getString("password_hash");
                
                // Verify password with simple comparison
                if (password.equals(storedPassword)) {
                    // Password is correct, create session
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setRole(rs.getString("role"));
                    user.setStatus(rs.getString("status"));
                    user.setEmail(rs.getString("email"));
                    
                    // Update last login timestamp
                    updateLastLogin(conn, user.getId());
                    
                    // Create session
                    HttpSession session = request.getSession(true);
                    session.setAttribute("user", user);
                    session.setAttribute("userRole", user.getRole());
                    session.setAttribute("userId", user.getId());
                    
                    // Redirect based on role
                    if ("ADMIN".equals(user.getRole())) {
                        response.sendRedirect(request.getContextPath() + "/settings?action=users");
                    } else if ("SUPPLIER".equals(user.getRole())) {
                        response.sendRedirect(request.getContextPath() + "/bidding");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/home");

                    }
                } else {
                    // Password is incorrect
                    request.setAttribute("errorMessage", "Invalid username or password");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                }
            } else {
                // User not found or not active
                request.setAttribute("errorMessage", "Invalid username or password");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error during login: {0}", e.getMessage());
            e.printStackTrace();  // Print stack trace for detailed debugging
            
            // Show a more user-friendly error message
            request.setAttribute("errorMessage", "Database connection error. Please try again later.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }
    
    private void updateLastLogin(Connection conn, int userId) {
        PreparedStatement stmt = null;
        
        try {
            stmt = conn.prepareStatement(
                "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?"
            );
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Error updating last login", e);
        } finally {
            DatabaseConnection.closeQuietly(null, stmt, null);
        }
    }
}
