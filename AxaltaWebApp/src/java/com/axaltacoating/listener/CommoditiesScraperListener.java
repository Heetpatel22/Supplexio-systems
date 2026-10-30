package com.axaltacoating.listener;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.io.IOException;

@WebListener
public class CommoditiesScraperListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        Runnable scraperTask = () -> {
            String pythonScript = sce.getServletContext().getRealPath("/../../scrape_copper_prices.py");
            while (true) {
                try {
                    ProcessBuilder pb = new ProcessBuilder("c:/Users/vaibh/CascadeProjects/AxaltaWebApp/.venv/Scripts/python.exe", pythonScript);
                    pb.inheritIO();
                    pb.start().waitFor();
                    Thread.sleep(5 * 60 * 1000); // 5 minutes
                } catch (Exception e) {
                    e.printStackTrace();
                    try { Thread.sleep(5 * 60 * 1000); } catch (InterruptedException ignored) {}
                }
            }
        };
        Thread scraperThread = new Thread(scraperTask);
        scraperThread.setDaemon(true);
        scraperThread.start();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // No cleanup needed
    }
}
