package com.hostelease.model;

import java.sql.Timestamp;

public class LeaveRequest {
    private Long id;
    private Long studentId;
    private String studentName;
    private String rollNumber;
    private String studentPhone;
    private String guardianPhone;
    private Long hostelId;
    private String hostelName;
    private String roomNumber;
    private String bedLabel;

    private String leaveType; // WEEKEND, SEMESTER_HOLIDAY, FESTIVAL, PERSONAL, MEDICAL, OTHER
    private String reason;
    private Timestamp departureDatetime;
    private Timestamp expectedReturnDatetime;
    private Timestamp actualDepartureDatetime;
    private Timestamp actualReturnDatetime;
    private String emergencyContact;
    private String destinationAddress;

    private String status; // PENDING, APPROVED, REJECTED, CANCELLED, DEPARTED, RETURNED, OVERDUE
    private Long reviewedByUserId;
    private String reviewerName;
    private String reviewRemarks;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public LeaveRequest() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getStudentId() { return studentId; }
    public void setStudentId(Long studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getRollNumber() { return rollNumber; }
    public void setRollNumber(String rollNumber) { this.rollNumber = rollNumber; }

    public String getStudentPhone() { return studentPhone; }
    public void setStudentPhone(String studentPhone) { this.studentPhone = studentPhone; }

    public String getGuardianPhone() { return guardianPhone; }
    public void setGuardianPhone(String guardianPhone) { this.guardianPhone = guardianPhone; }

    public Long getHostelId() { return hostelId; }
    public void setHostelId(Long hostelId) { this.hostelId = hostelId; }

    public String getHostelName() { return hostelName; }
    public void setHostelName(String hostelName) { this.hostelName = hostelName; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public String getBedLabel() { return bedLabel; }
    public void setBedLabel(String bedLabel) { this.bedLabel = bedLabel; }

    public String getLeaveType() { return leaveType; }
    public void setLeaveType(String leaveType) { this.leaveType = leaveType; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public Timestamp getDepartureDatetime() { return departureDatetime; }
    public void setDepartureDatetime(Timestamp departureDatetime) { this.departureDatetime = departureDatetime; }

    public Timestamp getExpectedReturnDatetime() { return expectedReturnDatetime; }
    public void setExpectedReturnDatetime(Timestamp expectedReturnDatetime) { this.expectedReturnDatetime = expectedReturnDatetime; }

    public Timestamp getActualDepartureDatetime() { return actualDepartureDatetime; }
    public void setActualDepartureDatetime(Timestamp actualDepartureDatetime) { this.actualDepartureDatetime = actualDepartureDatetime; }

    public Timestamp getActualReturnDatetime() { return actualReturnDatetime; }
    public void setActualReturnDatetime(Timestamp actualReturnDatetime) { this.actualReturnDatetime = actualReturnDatetime; }

    public String getEmergencyContact() { return emergencyContact; }
    public void setEmergencyContact(String emergencyContact) { this.emergencyContact = emergencyContact; }

    public String getDestinationAddress() { return destinationAddress; }
    public void setDestinationAddress(String destinationAddress) { this.destinationAddress = destinationAddress; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Long getReviewedByUserId() { return reviewedByUserId; }
    public void setReviewedByUserId(Long reviewedByUserId) { this.reviewedByUserId = reviewedByUserId; }

    public String getReviewerName() { return reviewerName; }
    public void setReviewerName(String reviewerName) { this.reviewerName = reviewerName; }

    public String getReviewRemarks() { return reviewRemarks; }
    public void setReviewRemarks(String reviewRemarks) { this.reviewRemarks = reviewRemarks; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getBedNumber() {
        return bedLabel != null ? bedLabel : "";
    }

    public String getStartDate() {
        return departureDatetime != null ? departureDatetime.toString().substring(0, 10) : "";
    }

    public String getEndDate() {
        return expectedReturnDatetime != null ? expectedReturnDatetime.toString().substring(0, 10) : "";
    }

    public long getTotalDays() {
        if (departureDatetime != null && expectedReturnDatetime != null) {
            long diff = expectedReturnDatetime.getTime() - departureDatetime.getTime();
            return Math.max(1, diff / (1000 * 60 * 60 * 24));
        }
        return 1;
    }

    public String getEmergencyContactPhone() {
        if (emergencyContact != null && !emergencyContact.trim().isEmpty()) {
            return emergencyContact;
        }
        if (guardianPhone != null && !guardianPhone.trim().isEmpty()) {
            return guardianPhone;
        }
        return studentPhone != null ? studentPhone : "";
    }

    public String getDestinationCity() {
        return destinationAddress != null && !destinationAddress.trim().isEmpty() ? destinationAddress : "Home / Local";
    }

    public String getRemarks() { return reviewRemarks != null ? reviewRemarks : ""; }
    public void setRemarks(String remarks) { this.reviewRemarks = remarks; }

    public Timestamp getDepartureDate() { return departureDatetime; }
    public Timestamp getExpectedReturn() { return expectedReturnDatetime; }
    public Timestamp getReturnDate() { return expectedReturnDatetime; }

    public String getStudentRegistrationNumber() { return rollNumber != null ? rollNumber : ""; }

    public boolean isParentConsentVerified() { return emergencyContact != null && !emergencyContact.trim().isEmpty(); }
    public boolean getParentConsentVerified() { return isParentConsentVerified(); }

    public Timestamp getActualDepartureTime() { return actualDepartureDatetime; }
    public Timestamp getActualReturnTime() { return actualReturnDatetime; }
}
