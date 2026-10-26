package com.hostelease.model;

import java.sql.Timestamp;

public class User {
    private Long id;
    private String username;
    private String email;
    private String phoneNumber;
    private String passwordHash;
    private String firstName;
    private String lastName;
    private boolean active;
    private String role; // Primary role: ADMIN, WARDEN, STUDENT
    private Long associatedHostelId; // For wardens
    private Timestamp createdAt;

    public User() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getFullName() {
        return (firstName != null ? firstName : "") + " " + (lastName != null ? lastName : "");
    }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Long getAssociatedHostelId() { return associatedHostelId; }
    public void setAssociatedHostelId(Long associatedHostelId) { this.associatedHostelId = associatedHostelId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
