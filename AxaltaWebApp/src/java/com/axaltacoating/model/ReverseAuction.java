package com.axaltacoating.model;

import java.util.Date;

public class ReverseAuction {
    private Long id;
    private Long productId;
    private String productName;
    private Integer requiredQuantity;
    private String unit;
    private Double startingPrice;
    private Double currentPrice;
    private Date startTime;
    private Date endTime;
    private String status;
    private Long supplierId;
    private String supplierName;
    private Double amount;
    private boolean hasPayment;
    
    public ReverseAuction() {}
    
    public ReverseAuction(Long id, Long productId, String productName, Integer requiredQuantity, String unit, Double startPrice, Double currentPrice, Date startTime, Date endTime, String status, Long supplierId, String supplierName, Double amount, boolean hasPayment) {
        this.id = id;
        this.productId = productId;
        this.productName = productName;
        this.requiredQuantity = requiredQuantity;
        this.unit = unit;
        this.startingPrice = startPrice;
        this.currentPrice = currentPrice;
        this.startTime = startTime;
        this.endTime = endTime;
        this.status = status;
    }
    
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public Long getProductId() {
        return productId;
    }
    
    public void setProductId(Long productId) {
        this.productId = productId;
    }
    
    public String getProductName() {
        return productName;
    }
    
    public void setProductName(String productName) {
        this.productName = productName;
    }
    
    public Integer getRequiredQuantity() {
        return requiredQuantity;
    }
    
    public void setRequiredQuantity(Integer requiredQuantity) {
        this.requiredQuantity = requiredQuantity;
    }
    
    public String getUnit() {
        return unit;
    }
    
    public void setUnit(String unit) {
        this.unit = unit;
    }
    
    public Double getStartingPrice() {
        return startingPrice;
    }
    
    public void setStartingPrice(Double startingPrice) {
        this.startingPrice = startingPrice;
    }
    
    // For backward compatibility
    public Double getStartPrice() {
        return startingPrice;
    }
    
    public void setStartPrice(Double startPrice) {
        this.startingPrice = startPrice;
    }
    
    public Double getCurrentPrice() {
        return currentPrice;
    }
    
    public void setCurrentPrice(Double currentPrice) {
        this.currentPrice = currentPrice;
    }
    
    public Date getStartTime() {
        return startTime;
    }
    
    public void setStartTime(Date startTime) {
        this.startTime = startTime;
    }
    
    public Date getEndTime() {
        return endTime;
    }
    
    public void setEndTime(Date endTime) {
        this.endTime = endTime;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Long getSupplierId() {
        return supplierId;
    }
    
    public void setSupplierId(Long supplierId) {
        this.supplierId = supplierId;
    }
    
    public String getSupplierName() {
        return supplierName;
    }
    
    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }
    
    public Double getAmount() {
        return amount;
    }
    
    public void setAmount(Double amount) {
        this.amount = amount;
    }
    
    public boolean isHasPayment() {
        return hasPayment;
    }
    
    public void setHasPayment(boolean hasPayment) {
        this.hasPayment = hasPayment;
    }
    
    @Override
    public String toString() {
        return "ReverseAuction{" +
                "id=" + id +
                ", productId=" + productId +
                ", productName='" + productName + '\'' +
                ", requiredQuantity=" + requiredQuantity +
                ", unit='" + unit + '\'' +
                ", startingPrice=" + startingPrice +
                ", currentPrice=" + currentPrice +
                ", startTime=" + startTime +
                ", endTime=" + endTime +
                ", status='" + status + '\'' +
                ", supplierId=" + supplierId +
                ", supplierName='" + supplierName + '\'' +
                ", amount=" + amount +
                ", hasPayment=" + hasPayment +
                '}';
    }
}
