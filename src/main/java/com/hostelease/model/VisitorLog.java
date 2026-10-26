package com.hostelease.model;

import java.sql.Timestamp;

public class VisitorLog {
    private Long id;
    private Long visitorId;
    private String visitorName;
    private String contactNumber;
    private String governmentIdType;
    private String governmentIdNumber;

    private Long studentId;
    private String studentName;
    private String rollNumber;
    private Long hostelId;
    private String hostelName;
    private String roomNumber;

    private String purpose;
    private Timestamp entryDatetime;
    private Timestamp exitDatetime;
    private Long recordedByUserId;
    private String recordedByName;
    private String status; // IN_HOSTEL, EXITED, OVERSTAYED

    public VisitorLog() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getVisitorId() { return visitorId; }
    public void setVisitorId(Long visitorId) { this.visitorId = visitorId; }

    public String getVisitorName() { return visitorName; }
    public void setVisitorName(String visitorName) { this.visitorName = visitorName; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public String getGovernmentIdType() { return governmentIdType; }
    public void setGovernmentIdType(String governmentIdType) { this.governmentIdType = governmentIdType; }

    public String getGovernmentIdNumber() { return governmentIdNumber; }
    public void setGovernmentIdNumber(String governmentIdNumber) { this.governmentIdNumber = governmentIdNumber; }

    public Long getStudentId() { return studentId; }
    public void setStudentId(Long studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getRollNumber() { return rollNumber; }
    public void setRollNumber(String rollNumber) { this.rollNumber = rollNumber; }

    public Long getHostelId() { return hostelId; }
    public void setHostelId(Long hostelId) { this.hostelId = hostelId; }

    public String getHostelName() { return hostelName; }
    public void setHostelName(String hostelName) { this.hostelName = hostelName; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public String getPurpose() { return purpose; }
    public void setPurpose(String purpose) { this.purpose = purpose; }

    public Timestamp getEntryDatetime() { return entryDatetime; }
    public void setEntryDatetime(Timestamp entryDatetime) { this.entryDatetime = entryDatetime; }

    public Timestamp getExitDatetime() { return exitDatetime; }
    public void setExitDatetime(Timestamp exitDatetime) { this.exitDatetime = exitDatetime; }

    public Long getRecordedByUserId() { return recordedByUserId; }
    public void setRecordedByUserId(Long recordedByUserId) { this.recordedByUserId = recordedByUserId; }

    public String getRecordedByName() { return recordedByName; }
    public void setRecordedByName(String recordedByName) { this.recordedByName = recordedByName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getEntryTime() { return entryDatetime; }
    public Timestamp getExitTime() { return exitDatetime; }
}
