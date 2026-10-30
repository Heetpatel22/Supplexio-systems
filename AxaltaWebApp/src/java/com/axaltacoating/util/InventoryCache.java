package com.axaltacoating.util;

import com.axaltacoating.model.Inventory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

public class InventoryCache {
    private static final Logger LOGGER = Logger.getLogger(InventoryCache.class.getName());
    private static final ConcurrentHashMap<Integer, Inventory> cache = new ConcurrentHashMap<>();
    private static final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    private static final int CACHE_UPDATE_INTERVAL = 5; // minutes

    static {
        scheduler.scheduleAtFixedRate(InventoryCache::updateCache, 0, CACHE_UPDATE_INTERVAL, TimeUnit.MINUTES);
    }

    public static List<Inventory> getAll() {
        return new ArrayList<>(cache.values());
    }

    public static Inventory get(int id) {
        return cache.get(id);
    }

    public static void update(Inventory item) {
        cache.put(item.getId(), item);
    }

    private static void updateCache() {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.prepareStatement("SELECT * FROM inventory");
            rs = stmt.executeQuery();

            while (rs.next()) {
                Inventory item = new Inventory(
                    rs.getInt("id"),
                    rs.getString("item_name"),
                    rs.getInt("quantity"),
                    rs.getInt("min_threshold"),
                    rs.getInt("max_threshold")
                );
                item.setKanbanStatus(rs.getString("kanban_status"));
                item.setAuctionStarted(rs.getBoolean("auction_started"));
                cache.put(item.getId(), item);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating inventory cache", e);
        } finally {
            DatabaseConnection.closeQuietly(rs, stmt, conn);
        }
    }

    public static void updateKanbanStatus(int itemId, String newStatus) {
        Inventory item = cache.get(itemId);
        if (item != null) {
            item.setKanbanStatus(newStatus);
            cache.put(itemId, item);
        }
    }

    public static void updateAuctionStarted(int itemId, boolean auctionStarted) {
        Inventory item = cache.get(itemId);
        if (item != null) {
            item.setAuctionStarted(auctionStarted);
            cache.put(itemId, item);
        }
    }
}