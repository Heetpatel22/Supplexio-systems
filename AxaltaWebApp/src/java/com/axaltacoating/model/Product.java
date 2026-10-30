package com.axaltacoating.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Product implements Serializable {
    private Long id;
    private String name;
    private String description;
    private String category;
    private double unitPrice;
    private String unit;
    private Timestamp createdAt;
    private Long inventoryId;
    private int inventoryQuantity;
    private String kanbanStatus;
    private int minThreshold;
    private int maxThreshold;
    private boolean needsAuction;
    private boolean auctionStarted;
    
    public Product() {}
    
    public Product(Long id, String name, String description, String category, double unitPrice, String unit, Long inventoryId, int inventoryQuantity) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.category = category;
        this.unitPrice = unitPrice;
        this.unit = unit;
        this.inventoryId = inventoryId;
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }
    
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Long getInventoryId() { return inventoryId; }
    public void setInventoryId(Long inventoryId) { this.inventoryId = inventoryId; }
    
    public int getInventoryQuantity() { return inventoryQuantity; }
    public void setInventoryQuantity(int inventoryQuantity) { this.inventoryQuantity = inventoryQuantity; }
    
    public String getKanbanStatus() { return kanbanStatus; }
    public void setKanbanStatus(String kanbanStatus) { this.kanbanStatus = kanbanStatus; }
    
    public int getMinThreshold() { return minThreshold; }
    public void setMinThreshold(int minThreshold) { this.minThreshold = minThreshold; }
    
    public int getMaxThreshold() { return maxThreshold; }
    public void setMaxThreshold(int maxThreshold) { this.maxThreshold = maxThreshold; }
    
    public boolean isNeedsAuction() { return needsAuction; }
    public void setNeedsAuction(boolean needsAuction) { this.needsAuction = needsAuction; }
    
    public boolean isAuctionStarted() { return auctionStarted; }
    public void setAuctionStarted(boolean auctionStarted) { this.auctionStarted = auctionStarted; }
    
    @Override
    public String toString() {
        return "Product{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", category='" + category + '\'' +
                ", unitPrice=" + unitPrice +
                ", unit='" + unit + '\'' +
                ", createdAt=" + createdAt +
                ", inventoryId=" + inventoryId +
                ", inventoryQuantity=" + inventoryQuantity +
                ", kanbanStatus='" + kanbanStatus + '\'' +
                ", minThreshold=" + minThreshold +
                ", maxThreshold=" + maxThreshold +
                ", needsAuction=" + needsAuction +
                ", auctionStarted=" + auctionStarted +
                '}';
    }
}
