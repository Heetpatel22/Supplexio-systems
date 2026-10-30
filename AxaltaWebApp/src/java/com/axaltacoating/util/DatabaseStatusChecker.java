package com.axaltacoating.util;

import com.axaltacoating.listener.DatabaseInitializationListener;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DatabaseStatusChecker {
    private static final Logger LOGGER = Logger.getLogger(DatabaseStatusChecker.class.getName());
    
    public static boolean isDatabaseReady() {
        return DatabaseInitializationListener.isDatabaseInitialized();
    }
    
    public static void waitForDatabase(long timeoutMillis) throws InterruptedException {
        long startTime = System.currentTimeMillis();
        while (!isDatabaseReady()) {
            if (System.currentTimeMillis() - startTime > timeoutMillis) {
                LOGGER.log(Level.SEVERE, "Timeout waiting for database initialization");
                throw new InterruptedException("Timeout waiting for database initialization");
            }
            Thread.sleep(100);
        }
        if (!isDatabaseReady()) {
            LOGGER.log(Level.WARNING, "Database initialization failed or timed out, but continuing operation");
        }
    }
}