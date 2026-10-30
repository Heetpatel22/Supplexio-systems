package com.axaltacoating.servlet;

import com.axaltacoating.util.DatabaseConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/dbstatus")
public class DatabaseStatusServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(DatabaseStatusServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        
        LOGGER.info("DatabaseStatusServlet: Checking database status");
        
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Database Status</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Database Status</h1>");
            
            boolean isInitialized = DatabaseConnection.isInitialized();
            LOGGER.info("DatabaseStatusServlet: Database Initialized: " + isInitialized);
            out.println("<p>Database Initialized: " + isInitialized + "</p>");
            
            if (isInitialized) {
                try (Connection conn = DatabaseConnection.getConnection()) {
                    LOGGER.info("DatabaseStatusServlet: Database Connection: Success");
                    out.println("<p>Database Connection: Success</p>");
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "DatabaseStatusServlet: Database Connection Failed", e);
                    out.println("<p>Database Connection: Failed</p>");
                    out.println("<p>Error: " + e.getMessage() + "</p>");
                }
            } else {
                LOGGER.info("DatabaseStatusServlet: Database Connection: Not attempted (Database not initialized)");
                out.println("<p>Database Connection: Not attempted (Database not initialized)</p>");
            }
            
            out.println("</body>");
            out.println("</html>");
        }
    }
}