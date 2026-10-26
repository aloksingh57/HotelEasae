package com.hostelease.model;

import java.sql.Timestamp;

public class Bed {
    private Long id;
    private Long roomId;
    private String roomNumber;
    private String buildingName;
    private String floorName;
    private Long hostelId;
    private String hostelName;
    private String bedLabel;
    private String allocationStatus; // UNALLOCATED, ALLOCATED, RESERVED, MAINTENANCE, ALLOCATION_ENDED

    // Dynamic occupant and presence state
    private Long studentId;
    private String studentName;
    private String rollNumber;
    private String studentPhone;
    private String studentPresence; // PRESENT, EXPECTED_TO_LEAVE, AWAY, RETURN_OVERDUE
    private Long activeLeaveId;
    private String leaveType;
    private Timestamp departureDatetime;
    private Timestamp expectedReturnDatetime;

    public Bed() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getRoomId() { return roomId; }
    public void setRoomId(Long roomId) { this.roomId = roomId; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public String getBuildingName() { return buildingName; }
    public void setBuildingName(String buildingName) { this.buildingName = buildingName; }

    public String getFloorName() { return floorName; }
    public void setFloorName(String floorName) { this.floorName = floorName; }

    public Long getHostelId() { return hostelId; }
    public void setHostelId(Long hostelId) { this.hostelId = hostelId; }

    public String getHostelName() { return hostelName; }
    public void setHostelName(String hostelName) { this.hostelName = hostelName; }

    public String getBedLabel() { return bedLabel; }
    public void setBedLabel(String bedLabel) { this.bedLabel = bedLabel; }

    public String getAllocationStatus() { return allocationStatus; }
    public void setAllocationStatus(String allocationStatus) { this.allocationStatus = allocationStatus; }

    public Long getStudentId() { return studentId; }
    public void setStudentId(Long studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getRollNumber() { return rollNumber; }
    public void setRollNumber(String rollNumber) { this.rollNumber = rollNumber; }

    public String getStudentPhone() { return studentPhone; }
    public void setStudentPhone(String studentPhone) { this.studentPhone = studentPhone; }

    public String getStudentPresence() { return studentPresence; }
    public void setStudentPresence(String studentPresence) { this.studentPresence = studentPresence; }

    public Long getActiveLeaveId() { return activeLeaveId; }
    public void setActiveLeaveId(Long activeLeaveId) { this.activeLeaveId = activeLeaveId; }

    public String getLeaveType() { return leaveType; }
    public void setLeaveType(String leaveType) { this.leaveType = leaveType; }

    public Timestamp getDepartureDatetime() { return departureDatetime; }
    public void setDepartureDatetime(Timestamp departureDatetime) { this.departureDatetime = departureDatetime; }

    public Timestamp getExpectedReturnDatetime() { return expectedReturnDatetime; }
    public void setExpectedReturnDatetime(Timestamp expectedReturnDatetime) { this.expectedReturnDatetime = expectedReturnDatetime; }

    /**
     * Determines whether this bed is temporarily vacant due to student holiday/leave.
     */
    public boolean isTemporarilyVacant() {
        return "ALLOCATED".equalsIgnoreCase(allocationStatus) && "AWAY".equalsIgnoreCase(studentPresence);
    }

    /**
     * Determines whether student is expected to leave soon.
     */
    public boolean isExpectedToLeave() {
        return "EXPECTED_TO_LEAVE".equalsIgnoreCase(studentPresence);
    }

    /**
     * Determines whether student's return is overdue.
     */
    public boolean isReturnOverdue() {
        return "RETURN_OVERDUE".equalsIgnoreCase(studentPresence);
    }

    public String getStatus() { return allocationStatus; }
    public Long getCurrentStudentId() { return studentId; }
    public String getCurrentPresenceStatus() { return studentPresence; }
    public String getBedNumber() { return bedLabel; }
    public String getCurrentStudentName() { return studentName; }
    public String getCurrentStudentRegNumber() { return rollNumber; }
    public String getEmergencyContactPhone() { return studentPhone; }
}
