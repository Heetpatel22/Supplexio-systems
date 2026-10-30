package com.axaltacoating.controller;

public class Inventory {
    private int id;
    private String itemName;
    private int quantity;
    private int threshold;

    public Inventory() {}

    public Inventory(int id, String itemName, int quantity, int threshold) {
        this.id = id;
        this.itemName = itemName;
        this.quantity = quantity;
        this.threshold = threshold;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public int getThreshold() { return threshold; }
    public void setThreshold(int threshold) { this.threshold = threshold; }
}