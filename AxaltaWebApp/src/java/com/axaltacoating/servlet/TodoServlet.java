package com.axaltacoating.servlet;

import com.axaltacoating.model.Todo;
import com.axaltacoating.util.DatabaseConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet handling To-Do List functionality.
 */
public class TodoServlet extends HttpServlet {
    
    /**
     * Handles the HTTP GET method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
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
                deleteTodo(request, response);
                break;
            case "view":
                viewTodo(request, response);
                break;
            default:
                listTodos(request, response);
                break;
        }
    }

    /**
     * Handles the HTTP POST method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "create":
                createTodo(request, response);
                break;
            case "update":
                updateTodo(request, response);
                break;
            case "complete":
                completeTodo(request, response);
                break;
            default:
                listTodos(request, response);
                break;
        }
    }
    
    /**
     * List all todos.
     */
    private void listTodos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Todo> todos = new ArrayList<>();
        String statusFilter = request.getParameter("status");
        String priorityFilter = request.getParameter("priority");
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            StringBuilder sql = new StringBuilder("SELECT * FROM todos WHERE 1=1");
            
            // Apply filters if provided
            if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("ALL")) {
                sql.append(" AND status = '").append(statusFilter).append("'");
            }
            
            if (priorityFilter != null && !priorityFilter.isEmpty() && !priorityFilter.equals("ALL")) {
                sql.append(" AND priority = '").append(priorityFilter).append("'");
            }
            
            sql.append(" ORDER BY status = 'COMPLETED', due_date ASC");
            
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql.toString());
            
            while (rs.next()) {
                Todo todo = new Todo();
                todo.setId(rs.getInt("id"));
                todo.setTitle(rs.getString("title"));
                todo.setDescription(rs.getString("description"));
                todo.setDueDate(rs.getTimestamp("due_date"));
                todo.setPriority(rs.getString("priority"));
                todo.setStatus(rs.getString("status"));
                todo.setCreatedAt(rs.getTimestamp("created_at"));
                todo.setUpdatedAt(rs.getTimestamp("updated_at"));
                todos.add(todo);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        
        request.setAttribute("todos", todos);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("priorityFilter", priorityFilter);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/todo/list.jsp");
        dispatcher.forward(request, response);
    }
    
    /**
     * Show new todo form.
     */
    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/todo/form.jsp");
        dispatcher.forward(request, response);
    }
    
    /**
     * Show edit form for a todo.
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Todo todo = null;
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT * FROM todos WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                todo = new Todo();
                todo.setId(rs.getInt("id"));
                todo.setTitle(rs.getString("title"));
                todo.setDescription(rs.getString("description"));
                todo.setDueDate(rs.getTimestamp("due_date"));
                todo.setPriority(rs.getString("priority"));
                todo.setStatus(rs.getString("status"));
                todo.setCreatedAt(rs.getTimestamp("created_at"));
                todo.setUpdatedAt(rs.getTimestamp("updated_at"));
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        
        request.setAttribute("todo", todo);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/todo/form.jsp");
        dispatcher.forward(request, response);
    }
    
    /**
     * Create a new todo.
     */
    private void createTodo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String dueDateStr = request.getParameter("dueDate");
        String priority = request.getParameter("priority");
        
        // Validate input
        if (title == null || title.trim().isEmpty()) {
            request.setAttribute("error", "Title is required");
            showNewForm(request, response);
            return;
        }
        
        try {
            // Parse due date
            Date dueDate = null;
            if (dueDateStr != null && !dueDateStr.trim().isEmpty()) {
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                dueDate = dateFormat.parse(dueDateStr);
            }
            
            // Create todo in database
            try (Connection conn = DatabaseConnection.getConnection()) {
                String sql = "INSERT INTO todos (title, description, due_date, priority, status, created_at, updated_at) "
                        + "VALUES (?, ?, ?, ?, 'PENDING', NOW(), NOW())";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, title);
                pstmt.setString(2, description);
                pstmt.setTimestamp(3, dueDate != null ? new Timestamp(dueDate.getTime()) : null);
                pstmt.setString(4, priority);
                pstmt.executeUpdate();
                
                request.setAttribute("success", "Todo created successfully");
            } catch (SQLException e) {
                request.setAttribute("error", "Database error: " + e.getMessage());
                showNewForm(request, response);
                return;
            }
            
            response.sendRedirect(request.getContextPath() + "/todo");
        } catch (ParseException e) {
            request.setAttribute("error", "Invalid date format: " + e.getMessage());
            showNewForm(request, response);
        }
    }
    
    /**
     * Update an existing todo.
     */
    private void updateTodo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String dueDateStr = request.getParameter("dueDate");
        String priority = request.getParameter("priority");
        String status = request.getParameter("status");
        
        // Validate input
        if (title == null || title.trim().isEmpty()) {
            request.setAttribute("error", "Title is required");
            showEditForm(request, response);
            return;
        }
        
        try {
            // Parse due date
            Date dueDate = null;
            if (dueDateStr != null && !dueDateStr.trim().isEmpty()) {
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                dueDate = dateFormat.parse(dueDateStr);
            }
            
            // Update todo in database
            try (Connection conn = DatabaseConnection.getConnection()) {
                String sql = "UPDATE todos SET title = ?, description = ?, due_date = ?, "
                        + "priority = ?, status = ?, updated_at = NOW() WHERE id = ?";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, title);
                pstmt.setString(2, description);
                pstmt.setTimestamp(3, dueDate != null ? new Timestamp(dueDate.getTime()) : null);
                pstmt.setString(4, priority);
                pstmt.setString(5, status);
                pstmt.setInt(6, id);
                pstmt.executeUpdate();
                
                request.setAttribute("success", "Todo updated successfully");
            } catch (SQLException e) {
                request.setAttribute("error", "Database error: " + e.getMessage());
                showEditForm(request, response);
                return;
            }
            
            response.sendRedirect(request.getContextPath() + "/todo");
        } catch (ParseException e) {
            request.setAttribute("error", "Invalid date format: " + e.getMessage());
            showEditForm(request, response);
        }
    }
    
    /**
     * Delete a todo.
     */
    private void deleteTodo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "DELETE FROM todos WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
            
            request.setAttribute("success", "Todo deleted successfully");
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/todo");
    }
    
    /**
     * Mark a todo as complete.
     */
    private void completeTodo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "UPDATE todos SET status = 'COMPLETED', updated_at = NOW() WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
            
            request.setAttribute("success", "Todo marked as completed");
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/todo");
    }
    
    /**
     * View a todo.
     */
    private void viewTodo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Todo todo = null;
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT * FROM todos WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                todo = new Todo();
                todo.setId(rs.getInt("id"));
                todo.setTitle(rs.getString("title"));
                todo.setDescription(rs.getString("description"));
                todo.setDueDate(rs.getTimestamp("due_date"));
                todo.setPriority(rs.getString("priority"));
                todo.setStatus(rs.getString("status"));
                todo.setCreatedAt(rs.getTimestamp("created_at"));
                todo.setUpdatedAt(rs.getTimestamp("updated_at"));
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        
        request.setAttribute("todo", todo);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/todo/view.jsp");
        dispatcher.forward(request, response);
    }
}
