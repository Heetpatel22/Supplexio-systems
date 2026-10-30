package com.axaltacoating.model;

import java.io.Serializable;

public class Supplier implements Serializable {
    private Long id;
    private String name;
    private String email;
    private String phone;
    private String address;
    private String status; // ACTIVE, INACTIVE, PENDING

    public Supplier() {}

    public Supplier(Long id, String name, String email, String phone, String address, String status) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.status = status;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    @Override
    public String toString() {
        return name;
    }
}
