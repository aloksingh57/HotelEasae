package com.hostelease.model;

import java.sql.Timestamp;

public class Hostel {
    private Long id;
    private String name;
    private String code;
    private String type; // BOYS, GIRLS, CO_ED
    private String address;
    private String contactPhone;
    private String contactEmail;
    private int totalCapacity;
    private int currentOccupancy;
    private int totalRooms;
    private boolean active;
    private Timestamp createdAt;

    public Hostel() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getContactPhone() { return contactPhone; }
    public void setContactPhone(String contactPhone) { this.contactPhone = contactPhone; }

    public String getContactEmail() { return contactEmail; }
    public void setContactEmail(String contactEmail) { this.contactEmail = contactEmail; }

    public int getTotalCapacity() { return totalCapacity; }
    public void setTotalCapacity(int totalCapacity) { this.totalCapacity = totalCapacity; }

    public int getCurrentOccupancy() { return currentOccupancy; }
    public void setCurrentOccupancy(int currentOccupancy) { this.currentOccupancy = currentOccupancy; }

    public int getTotalRooms() { return totalRooms; }
    public void setTotalRooms(int totalRooms) { this.totalRooms = totalRooms; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    private String description;

    public String getDescription() {
        return description != null ? description : (address != null ? address : "Premier student residential complex");
    }
    public void setDescription(String description) { this.description = description; }

    public int getTotalBeds() { return totalCapacity; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
