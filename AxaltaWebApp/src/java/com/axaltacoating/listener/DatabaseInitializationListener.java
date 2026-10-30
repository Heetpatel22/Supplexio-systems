package com.axaltacoating.listener;

import com.axaltacoating.util.DatabaseConnection;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebListener
public class DatabaseInitializationListener implements ServletContextListener {
    private static final Logger LOGGER = Logger.getLogger(DatabaseInitializationListener.class.getName());
    private static final CountDownLatch initLatch = new CountDownLatch(1);
    private static final long INIT_TIMEOUT = 60; // Timeout in seconds

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        Thread initThread = new Thread(() -> {
            try {
                LOGGER.info("Starting database initialization...");
                long startTime = System.currentTimeMillis();
                DatabaseConnection.initializeTables();
                long endTime = System.currentTimeMillis();
                LOGGER.info("Database initialization completed successfully in " + (endTime - startTime) + " ms.");
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Failed to initialize database: " + e.getMessage(), e);
            } finally {
                initLatch.countDown();
            }
        });
        initThread.setName("DatabaseInitializationThread");
        initThread.start();
        LOGGER.info("Database initialization started in background thread.");

        try {
            if (!initLatch.await(INIT_TIMEOUT, TimeUnit.SECONDS)) {
                LOGGER.severe("Database initialization timed out after " + INIT_TIMEOUT + " seconds.");
            }
            if (DatabaseConnection.isInitialized()) {
                LOGGER.info("Database is fully initialized and ready.");
            } else {
                LOGGER.warning("Database initialization completed, but isInitialized() returned false. Check for errors.");
            }
        } catch (InterruptedException e) {
            LOGGER.log(Level.SEVERE, "Database initialization was interrupted", e);
            Thread.currentThread().interrupt();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Cleanup if needed
    }

    public static boolean isDatabaseInitialized() {
        return DatabaseConnection.isInitialized();
    }
}
