package com.axaltacoating.model;

import java.io.Serializable;
import java.util.Date;

public class Bid implements Serializable {
    private Long id;
    private Long auctionId;
    private Long supplierId;
    private String supplierName;
    private String supplierCompany;
    private double amount;
    private Date bidTime;
    
    public Bid() {}
    
    public Bid(Long id, Long auctionId, Long supplierId, double amount, Date bidTime) {
        this.id = id;
        this.auctionId = auctionId;
        this.supplierId = supplierId;
        this.amount = amount;
        this.bidTime = bidTime;
    }
    
    public Bid(Long id, Long auctionId, Long supplierId, String supplierName, String supplierCompany, double amount, Date bidTime) {
        this.id = id;
        this.auctionId = auctionId;
        this.supplierId = supplierId;
        this.supplierName = supplierName;
        this.supplierCompany = supplierCompany;
        this.amount = amount;
        this.bidTime = bidTime;
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Long getAuctionId() { return auctionId; }
    public void setAuctionId(Long auctionId) { this.auctionId = auctionId; }
    
    public Long getSupplierId() { return supplierId; }
    public void setSupplierId(Long supplierId) { this.supplierId = supplierId; }
    
    public String getSupplierName() { return supplierName; }
    public void setSupplierName(String supplierName) { this.supplierName = supplierName; }
    
    public String getSupplierCompany() { return supplierCompany; }
    public void setSupplierCompany(String supplierCompany) { this.supplierCompany = supplierCompany; }
    
    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }
    
    public Date getBidTime() { return bidTime; }
    public void setBidTime(Date bidTime) { this.bidTime = bidTime; }
}
