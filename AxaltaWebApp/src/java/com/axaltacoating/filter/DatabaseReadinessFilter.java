package com.axaltacoating.filter;

import com.axaltacoating.util.DatabaseConnection;
import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletResponse;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebFilter("/*")
public class DatabaseReadinessFilter implements Filter {
    private static final Logger LOGGER = Logger.getLogger(DatabaseReadinessFilter.class.getName());
    private static final long DATABASE_TIMEOUT = 30; // 30 seconds timeout
    private static final int MAX_RETRIES = 3;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        LOGGER.info("DatabaseReadinessFilter initialized");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        int retries = 0;
        while (!DatabaseConnection.isInitialized() && retries < MAX_RETRIES) {
            LOGGER.info("Database not initialized. Attempt " + (retries + 1) + " of " + MAX_RETRIES);
            try {
                boolean initialized = DatabaseConnection.waitForInitialization(DATABASE_TIMEOUT, TimeUnit.SECONDS);
                if (initialized) {
                    LOGGER.info("Database initialized successfully");
                    break;
                }
                retries++;
                if (retries >= MAX_RETRIES) {
                    LOGGER.severe("Max retries reached. Database initialization failed.");
                    HttpServletResponse httpResponse = (HttpServletResponse) response;
                    httpResponse.sendRedirect(request.getServletContext().getContextPath() + "/please-wait.jsp?error=db_timeout");
                    return;
                }
            } catch (InterruptedException e) {
                LOGGER.log(Level.SEVERE, "Interrupted while waiting for database initialization", e);
                Thread.currentThread().interrupt();
                HttpServletResponse httpResponse = (HttpServletResponse) response;
                httpResponse.sendRedirect(request.getServletContext().getContextPath() + "/please-wait.jsp?error=interrupted");
                return;
            }
        }
        
        if (DatabaseConnection.isInitialized()) {
            LOGGER.fine("Database is ready. Proceeding with the request.");
            chain.doFilter(request, response);
        } else {
            LOGGER.severe("Database initialization failed after " + MAX_RETRIES + " attempts.");
            HttpServletResponse httpResponse = (HttpServletResponse) response;
            httpResponse.sendRedirect(request.getServletContext().getContextPath() + "/please-wait.jsp?error=db_not_ready");
        }
    }

    @Override
    public void destroy() {
        LOGGER.info("DatabaseReadinessFilter destroyed");
    }
}