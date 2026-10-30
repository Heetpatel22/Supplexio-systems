package com.axaltacoating.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DatabaseConnection {
    private static final Logger LOGGER = Logger.getLogger(DatabaseConnection.class.getName());
    private static final String DB_URL;
    private static final String DB_USER;
    private static final String DB_PASSWORD;

    private static final String APP_TIMEZONE = "Asia/Kolkata";

    static {
        String host = envOrDefault("MYSQLHOST", "MYSQL_HOST", "localhost");
        String port = envOrDefault("MYSQLPORT", "MYSQL_PORT", "3306");
        String db = envOrDefault("MYSQLDATABASE", "MYSQL_DATABASE", "axalta");
        String user = envOrDefault("MYSQLUSER", "MYSQL_USER", "root");
        String password = envOrDefault("MYSQLPASSWORD", "MYSQL_PASSWORD", "root");

        DB_USER = user;
        DB_PASSWORD = password;
        DB_URL = "jdbc:mysql://" + host + ":" + port + "/" + db
                + "?useSSL=false&allowPublicKeyRetrieval=true"
                + "&serverTimezone=" + APP_TIMEZONE
                + "&connectionTimeZone=" + APP_TIMEZONE;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL JDBC Driver not found", e);
        }
    }
    private static final CountDownLatch initLatch = new CountDownLatch(1);
    private static volatile boolean tablesInitialized = false;
    
    public static Connection getConnection() throws SQLException {
        Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        try (Statement tz = conn.createStatement()) {
            tz.execute("SET time_zone = '+05:30'");
        } catch (SQLException ex) {
            LOGGER.log(Level.FINE, "Could not set MySQL session time_zone: {0}", ex.getMessage());
        }
        return conn;
    }

    private static String envOrDefault(String primary, String alternate, String defaultValue) {
        String value = System.getenv(primary);
        if (value == null || value.trim().isEmpty()) {
            value = System.getenv(alternate);
        }
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        return value.trim();
    }

    public static void initializeTables() throws SQLException {
        if (tablesInitialized) {
            return;
        }

        Connection conn = null;
        Statement stmt = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();

            // Create inventory table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS inventory (" +
                "id INT PRIMARY KEY AUTO_INCREMENT, " +
                "item_name VARCHAR(255) NOT NULL, " +
                "quantity INT NOT NULL, " +
                "min_threshold INT NOT NULL, " +
                "max_threshold INT NOT NULL, " +
                "kanban_status ENUM('Low', 'Medium', 'High') DEFAULT 'Medium', " +
                "needs_auction BOOLEAN DEFAULT FALSE, " +
                "auction_started BOOLEAN DEFAULT FALSE, " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ")"
            );

            // Create products table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS products (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "name VARCHAR(255) NOT NULL, " +
                "description TEXT, " +
                "category VARCHAR(100) DEFAULT 'General', " +
                "base_price DECIMAL(10,2) DEFAULT 0.00, " +
                "unit VARCHAR(50) DEFAULT 'pcs', " +
                "stock_quantity INT DEFAULT 0, " +
                "inventory_id BIGINT NULL, " +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP" +
                ")"
            );

            // Create suppliers table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS suppliers (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "name VARCHAR(255) NOT NULL, " +
                "email VARCHAR(255) NOT NULL UNIQUE, " +
                "phone VARCHAR(20), " +
                "address TEXT, " +
                "password VARCHAR(255) NOT NULL, " +
                "status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE', " +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP" +
                ")"
            );

            // Create reverse auctions table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS reverse_auctions (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "product_id BIGINT NOT NULL, " +
                "start_price DOUBLE NOT NULL, " +
                "current_price DOUBLE NOT NULL, " +
                "start_time TIMESTAMP NOT NULL, " +
                "end_time TIMESTAMP NOT NULL, " +
                "status ENUM('PENDING', 'ACTIVE', 'COMPLETED', 'CANCELLED', 'SCHEDULED') DEFAULT 'PENDING', " +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                "FOREIGN KEY (product_id) REFERENCES products(id)" +
                ")"
            );

            // Create bids table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS bids (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "auction_id BIGINT NOT NULL, " +
                "user_id BIGINT NOT NULL, " +
                "bid_amount DOUBLE NOT NULL, " +
                "bid_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                "FOREIGN KEY (auction_id) REFERENCES reverse_auctions(id)" +
                ")"
            );

            // Create auction invitations table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS auction_invitations (" +
                "auction_id BIGINT NOT NULL, " +
                "supplier_id BIGINT NOT NULL, " +
                "status ENUM('PENDING', 'ACCEPTED', 'DECLINED') DEFAULT 'PENDING', " +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                "PRIMARY KEY (auction_id, supplier_id), " +
                "FOREIGN KEY (auction_id) REFERENCES reverse_auctions(id), " +
                "FOREIGN KEY (supplier_id) REFERENCES suppliers(id)" +
                ")"
            );

            // Create payments table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS payments (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "auction_id BIGINT NOT NULL, " +
                "supplier_id BIGINT NOT NULL, " +
                "amount DOUBLE NOT NULL, " +
                "status VARCHAR(20) NOT NULL DEFAULT 'PENDING', " +
                "payment_method VARCHAR(20), " +
                "transaction_id VARCHAR(100), " +
                "payment_date TIMESTAMP NULL, " +
                "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                "remarks TEXT, " +
                "FOREIGN KEY (auction_id) REFERENCES reverse_auctions(id), " +
                "FOREIGN KEY (supplier_id) REFERENCES suppliers(id)" +
                ")"
            );

            // Add columns to existing tables (ignoring errors if they already exist)
            try { stmt.executeUpdate("ALTER TABLE reverse_auctions ADD COLUMN winning_supplier_id BIGINT NULL"); } catch(Exception e) { /* ignore */ }
            try { stmt.executeUpdate("ALTER TABLE reverse_auctions ADD COLUMN created_by_email VARCHAR(255) NULL"); } catch(Exception e) { /* ignore */ }
            try { stmt.executeUpdate("ALTER TABLE reverse_auctions ADD COLUMN required_quantity INT DEFAULT 1"); } catch(Exception e) { /* ignore */ }
            
            try { stmt.executeUpdate("ALTER TABLE bids ADD COLUMN supplier_id BIGINT NULL"); } catch(Exception e) { /* ignore */ }
            try { stmt.executeUpdate("UPDATE bids SET supplier_id = user_id WHERE supplier_id IS NULL"); } catch(Exception e) { /* ignore */ }

            // Create new tables for Trade Credit Workflow
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS purchase_orders (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "po_number VARCHAR(100), " +
                "auction_id BIGINT NOT NULL, " +
                "product_id BIGINT NOT NULL, " +
                "product_name VARCHAR(255), " +
                "supplier_id BIGINT NOT NULL, " +
                "supplier_name VARCHAR(255), " +
                "company_name VARCHAR(255), " +
                "material VARCHAR(255), " +
                "amount DECIMAL(15,2), " +
                "quantity INT, " +
                "unit_price DECIMAL(15,2), " +
                "total_amount DECIMAL(15,2), " +
                "tax_amount DECIMAL(15,2), " +
                "grand_total DECIMAL(15,2), " +
                "supplier_email VARCHAR(255), " +
                "supplier_address TEXT, " +
                "status VARCHAR(50), " +
                "quality_terms TEXT, " +
                "buyer_email VARCHAR(255), " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "po_sent_at TIMESTAMP NULL, " +
                "accepted_at TIMESTAMP NULL, " +
                "shipped_at TIMESTAMP NULL, " +
                "delivered_at TIMESTAMP NULL, " +
                "invoice_requested_at TIMESTAMP NULL, " +
                "payment_due_date DATE NULL, " +
                "paid_at TIMESTAMP NULL, " +
                "closed_at TIMESTAMP NULL, " +
                "updated_at TIMESTAMP NULL)"
            );

            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS goods_receipts (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "po_id BIGINT NOT NULL, " +
                "grn_number VARCHAR(100), " +
                "asn_number VARCHAR(100), " +
                "shipping_carrier VARCHAR(100), " +
                "tracking_number VARCHAR(100), " +
                "shipped_at TIMESTAMP NULL, " +
                "delivered_at TIMESTAMP NULL, " +
                "received_quantity INT, " +
                "warehouse_location VARCHAR(255), " +
                "received_by VARCHAR(255), " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)"
            );

            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS commercial_invoices (" +
                "id BIGINT PRIMARY KEY AUTO_INCREMENT, " +
                "po_id BIGINT NOT NULL, " +
                "invoice_number VARCHAR(100), " +
                "invoice_date DATE, " +
                "invoice_price DECIMAL(15,2), " +
                "invoice_quantity INT, " +
                "gst_rate DECIMAL(5,2), " +
                "gst_amount DECIMAL(15,2), " +
                "total_amount DECIMAL(15,2), " +
                "status VARCHAR(50), " +
                "due_date DATE, " +
                "payment_unlocked_at TIMESTAMP NULL, " +
                "paid_at TIMESTAMP NULL, " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)"
            );

            // Add new columns if tables already existed
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN po_sent_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN accepted_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN shipped_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN delivered_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN invoice_requested_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN payment_due_date DATE NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN paid_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN closed_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }

            try { stmt.executeUpdate("ALTER TABLE commercial_invoices ADD COLUMN due_date DATE"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE commercial_invoices ADD COLUMN payment_unlocked_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE commercial_invoices ADD COLUMN paid_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }
            try { stmt.executeUpdate("ALTER TABLE purchase_orders ADD COLUMN updated_at TIMESTAMP NULL"); } catch (SQLException e) { /* ignored */ }

            TradeCreditSchemaMigration.migrate(conn);

            tablesInitialized = true;
            LOGGER.info("All tables created successfully");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error initializing database tables", e);
            throw e; // Rethrow the exception to signal initialization failure
        } finally {
            closeQuietly(null, stmt, conn);
            initLatch.countDown(); // Signal that initialization attempt is complete
        }
    }

    public static boolean waitForInitialization(long timeout, TimeUnit unit) throws InterruptedException {
        return initLatch.await(timeout, unit);
    }

    public static boolean isInitialized() {
        return tablesInitialized;
    }

    public static void closeQuietly(ResultSet rs, Statement stmt, Connection conn) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing ResultSet", e);
            }
        }
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing Statement", e);
            }
        }
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing Connection", e);
            }
        }
    }
}
