package com.axaltacoating.listener;

import com.axaltacoating.task.AuctionClosingTask;
import com.axaltacoating.util.DatabaseConnection;
import java.util.Timer;
import java.util.concurrent.TimeUnit;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebListener
public class ApplicationListener implements ServletContextListener {
    private static final Logger LOGGER = Logger.getLogger(ApplicationListener.class.getName());
    private Timer timer;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("Application initialization started");

        // Check database readiness
        try {
            boolean isDatabaseReady = DatabaseConnection.waitForInitialization(60, TimeUnit.SECONDS);
            if (isDatabaseReady) {
                LOGGER.info("Database initialized successfully");
            } else {
                LOGGER.severe("Database initialization timed out. Application may not function correctly.");
            }
        } catch (InterruptedException e) {
            LOGGER.log(Level.SEVERE, "Database initialization was interrupted", e);
            Thread.currentThread().interrupt();
        }

        // Start auction closing task
        timer = new Timer(true); // Run as daemon thread
        timer.scheduleAtFixedRate(new AuctionClosingTask(), 0, 60000); // Run every minute
        LOGGER.info("Auction closing task scheduled");

        LOGGER.info("Application initialization completed");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOGGER.info("Application shutdown initiated");
        if (timer != null) {
            timer.cancel();
            LOGGER.info("Auction closing task cancelled");
        }
        LOGGER.info("Application shutdown completed");
    }
}
