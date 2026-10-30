package com.axaltacoating.db;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.stream.Collectors;
import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class DatabaseInitializer implements ServletContextListener {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/";
    private static final String DB_NAME = "axalta";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "root";
   
    
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            initializeDatabase(sce);
        } catch (Exception e) {
            System.err.println("Failed to initialize database: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void initializeDatabase(ServletContextEvent sce) throws ClassNotFoundException, SQLException, IOException {
        try {
            // Load MySQL JDBC Driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // First try to create database if it doesn't exist
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                 Statement stmt = conn.createStatement()) {
                stmt.executeUpdate("CREATE DATABASE IF NOT EXISTS " + DB_NAME);
            }
            
            // Now connect to the database and create tables
            try (Connection conn = DriverManager.getConnection(DB_URL + DB_NAME, DB_USER, DB_PASSWORD)) {
                executeSqlScript(sce, conn, "/WEB-INF/sql/init_database.sql");
                executeSqlScript(sce, conn, "/WEB-INF/sql/migrate_kanban_fields.sql");
                executeSqlScript(sce, conn, "/WEB-INF/sql/migrate_inventory_table.sql");
                System.out.println("Database initialized and migrated successfully!");
            }
            
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver not found: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("Database initialization error: " + e.getMessage());
        }
    }
    
    private void executeSqlScript(ServletContextEvent sce, Connection conn, String scriptPath) throws SQLException, IOException {
        ServletContext context = sce.getServletContext();
        try (InputStream inputStream = context.getResourceAsStream(scriptPath)) {
            if (inputStream != null) {
                String sql;
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
                    sql = reader.lines().collect(Collectors.joining("\n"));
                }
                
                // Split SQL statements and execute them
                String[] statements = sql.split(";");
                try (Statement stmt = conn.createStatement()) {
                    for (String statement : statements) {
                        if (!statement.trim().isEmpty()) {
                            stmt.execute(statement.trim());
                        }
                    }
                }
                System.out.println("Executed SQL script: " + scriptPath);
            } else {
                System.err.println("Could not find SQL script: " + scriptPath);
            }
        }
    }
    
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Cleanup if needed
    }
}
