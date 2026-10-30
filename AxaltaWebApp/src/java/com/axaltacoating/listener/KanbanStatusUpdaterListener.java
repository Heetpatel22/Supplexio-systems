package com.axaltacoating.listener;

import com.axaltacoating.task.KanbanStatusUpdater;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebListener
public class KanbanStatusUpdaterListener implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(KanbanStatusUpdaterListener.class.getName());
    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("Initializing KanbanStatusUpdater");
        scheduler = Executors.newSingleThreadScheduledExecutor();
        scheduler.submit(new KanbanStatusUpdater());
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOGGER.info("Shutting down KanbanStatusUpdater");
        if (scheduler != null) {
            try {
                scheduler.shutdown();
                if (!scheduler.awaitTermination(60, TimeUnit.SECONDS)) {
                    scheduler.shutdownNow();
                    if (!scheduler.awaitTermination(60, TimeUnit.SECONDS)) {
                        LOGGER.severe("KanbanStatusUpdater did not terminate");
                    }
                }
            } catch (InterruptedException e) {
                scheduler.shutdownNow();
                Thread.currentThread().interrupt();
                LOGGER.log(Level.SEVERE, "KanbanStatusUpdater shutdown interrupted", e);
            }
        }
    }
}