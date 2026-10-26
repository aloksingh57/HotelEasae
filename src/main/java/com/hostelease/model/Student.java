package com.hostelease.model;

import java.sql.Date;
import java.sql.Timestamp;

public class Student {
    private Long id;
    private Long userId;
    private String rollNumber;
    private String registrationNo;
    private String course;
    private int batchYear;
    private String gender;
    private Date dob;
    private String bloodGroup;
    private String guardianName;
    private String guardianPhone;
    private String guardianEmail;
    private String permanentAddress;
    private String currentPresence; // PRESENT, EXPECTED_TO_LEAVE, AWAY, RETURN_OVERDUE

    // Associated User & Allocation info
    private String firstName;
    private String lastName;
    private String email;
    private String phoneNumber;
    private Long allocatedBedId;
    private String allocatedBedLabel;
    private String allocatedRoomNumber;
    private Long allocatedHostelId;
    private String allocatedHostelName;
    private Timestamp createdAt;

    public Student() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getRollNumber() { return rollNumber; }
    public void setRollNumber(String rollNumber) { this.rollNumber = rollNumber; }

    public String getRegistrationNo() { return registrationNo; }
    public void setRegistrationNo(String registrationNo) { this.registrationNo = registrationNo; }

    public String getCourse() { return course; }
    public void setCourse(String course) { this.course = course; }

    public int getBatchYear() { return batchYear; }
    public void setBatchYear(int batchYear) { this.batchYear = batchYear; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public Date getDob() { return dob; }
    public void setDob(Date dob) { this.dob = dob; }

    public String getBloodGroup() { return bloodGroup; }
    public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }

    public String getGuardianName() { return guardianName; }
    public void setGuardianName(String guardianName) { this.guardianName = guardianName; }

    public String getGuardianPhone() { return guardianPhone; }
    public void setGuardianPhone(String guardianPhone) { this.guardianPhone = guardianPhone; }

    public String getGuardianEmail() { return guardianEmail; }
    public void setGuardianEmail(String guardianEmail) { this.guardianEmail = guardianEmail; }

    public String getPermanentAddress() { return permanentAddress; }
    public void setPermanentAddress(String permanentAddress) { this.permanentAddress = permanentAddress; }

    public String getCurrentPresence() { return currentPresence; }
    public void setCurrentPresence(String currentPresence) { this.currentPresence = currentPresence; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getFullName() {
        return (firstName != null ? firstName : "") + " " + (lastName != null ? lastName : "");
    }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public Long getAllocatedBedId() { return allocatedBedId; }
    public void setAllocatedBedId(Long allocatedBedId) { this.allocatedBedId = allocatedBedId; }

    public String getAllocatedBedLabel() { return allocatedBedLabel; }
    public void setAllocatedBedLabel(String allocatedBedLabel) { this.allocatedBedLabel = allocatedBedLabel; }

    public String getAllocatedRoomNumber() { return allocatedRoomNumber; }
    public void setAllocatedRoomNumber(String allocatedRoomNumber) { this.allocatedRoomNumber = allocatedRoomNumber; }

    public Long getAllocatedHostelId() { return allocatedHostelId; }
    public void setAllocatedHostelId(Long allocatedHostelId) { this.allocatedHostelId = allocatedHostelId; }

    public String getAllocatedHostelName() { return allocatedHostelName; }
    public void setAllocatedHostelName(String allocatedHostelName) { this.allocatedHostelName = allocatedHostelName; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getCurrentPresenceStatus() { return currentPresence; }
    public Long getCurrentBedId() { return allocatedBedId; }
    public String getRegistrationNumber() { return registrationNo; }
    public String getPhone() { return phoneNumber; }
    public String getCurrentHostelName() { return allocatedHostelName; }
    public String getCurrentRoomNumber() { return allocatedRoomNumber; }
    public String getCurrentBedNumber() { return allocatedBedLabel; }
    public int getYearOfStudy() { return batchYear > 2000 ? Math.max(1, 2027 - batchYear) : 1; }
    public int getAdmissionYear() { return batchYear; }
    public String getAddressLine1() { return permanentAddress; }
    public String getAddressLine2() { return ""; }
    public String getCity() { return ""; }
    public String getState() { return ""; }
    public String getPincode() { return ""; }
    public String getEmergencyContactPhone() { return guardianPhone; }
    public String getGuardianRelationship() { return "Parent"; }
    public Date getDateOfBirth() { return dob; }
}
