package com.axaltacoating.model;

public class Inventory {
    private int id;
    private String itemName;
    private int quantity;
    private int minThreshold;
    private int maxThreshold;
    private String kanbanStatus;
    private boolean needsAuction;
    private boolean auctionStarted;

    public Inventory() {}

    // Constructor with 4 parameters (backward compatibility)
    public Inventory(int id, String itemName, int quantity, int threshold) {
        this.id = id;
        this.itemName = itemName;
        this.quantity = quantity;
        this.minThreshold = threshold;
        this.maxThreshold = threshold * 2; // Set max threshold as double of min threshold
        this.auctionStarted = false;
        updateKanbanStatus();
    }

    public Inventory(int id, String itemName, int quantity, int minThreshold, int maxThreshold) {
        this.id = id;
        this.itemName = itemName;
        this.quantity = quantity;
        this.minThreshold = minThreshold;
        this.maxThreshold = maxThreshold;
        this.auctionStarted = false;
        updateKanbanStatus();
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { 
        this.quantity = quantity;
        updateKanbanStatus();
    }

    public int getMinThreshold() { return minThreshold; }
    public void setMinThreshold(int minThreshold) { 
        this.minThreshold = minThreshold;
        updateKanbanStatus();
    }

    // Alias method for backward compatibility
    public int getThreshold() { return minThreshold; }
    public void setThreshold(int threshold) { 
        this.minThreshold = threshold;
        updateKanbanStatus();
    }

    public int getMaxThreshold() { return maxThreshold; }
    public void setMaxThreshold(int maxThreshold) { 
        this.maxThreshold = maxThreshold;
        updateKanbanStatus();
    }

    public String getKanbanStatus() { return kanbanStatus; }
    public void setKanbanStatus(String kanbanStatus) { this.kanbanStatus = kanbanStatus; }

    public boolean getNeedsAuction() { return needsAuction; }
    public void setNeedsAuction(boolean needsAuction) { this.needsAuction = needsAuction; }

    public boolean isAuctionStarted() { return auctionStarted; }
    public void setAuctionStarted(boolean auctionStarted) { this.auctionStarted = auctionStarted; }

    private void updateKanbanStatus() {
        if (quantity <= minThreshold) {
            kanbanStatus = "Low";
            needsAuction = true;
        } else if (quantity >= maxThreshold) {
            kanbanStatus = "High";
            needsAuction = false;
        } else {
            kanbanStatus = "Medium";
            needsAuction = false;
        }
    }
}