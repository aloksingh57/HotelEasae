package com.hostelease.model;

import java.util.ArrayList;
import java.util.List;

public class Room {
    private Long id;
    private Long floorId;
    private String floorName;
    private String buildingName;
    private Long hostelId;
    private String hostelName;
    private String roomNumber;
    private String roomType; // STANDARD, DELUXE, AC, NON_AC
    private int capacity;
    private int currentOccupancy;
    private String status; // AVAILABLE, FULL, MAINTENANCE, DECOMMISSIONED
    private List<Bed> beds = new ArrayList<>();

    public Room() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getFloorId() { return floorId; }
    public void setFloorId(Long floorId) { this.floorId = floorId; }

    public String getFloorName() { return floorName; }
    public void setFloorName(String floorName) { this.floorName = floorName; }

    public String getBuildingName() { return buildingName; }
    public void setBuildingName(String buildingName) { this.buildingName = buildingName; }

    public Long getHostelId() { return hostelId; }
    public void setHostelId(Long hostelId) { this.hostelId = hostelId; }

    public String getHostelName() { return hostelName; }
    public void setHostelName(String hostelName) { this.hostelName = hostelName; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }

    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }

    public int getCurrentOccupancy() { return currentOccupancy; }
    public void setCurrentOccupancy(int currentOccupancy) { this.currentOccupancy = currentOccupancy; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public List<Bed> getBeds() { return beds; }
    public void setBeds(List<Bed> beds) { this.beds = beds; }
}
