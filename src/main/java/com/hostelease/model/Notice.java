package com.hostelease.model;

import java.sql.Date;
import java.sql.Timestamp;

public class Notice {
    private Long id;
    private String title;
    private String content;
    private Long hostelId;
    private String hostelName;
    private String targetRole; // ALL, STUDENT, WARDEN
    private boolean urgent;
    private Long publishedByUserId;
    private String publishedByName;
    private Date expiresAt;
    private Timestamp createdAt;

    public Notice() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Long getHostelId() { return hostelId; }
    public void setHostelId(Long hostelId) { this.hostelId = hostelId; }

    public String getHostelName() { return hostelName; }
    public void setHostelName(String hostelName) { this.hostelName = hostelName; }

    public String getTargetRole() { return targetRole; }
    public void setTargetRole(String targetRole) { this.targetRole = targetRole; }

    public boolean isUrgent() { return urgent; }
    public void setUrgent(boolean urgent) { this.urgent = urgent; }

    public Long getPublishedByUserId() { return publishedByUserId; }
    public void setPublishedByUserId(Long publishedByUserId) { this.publishedByUserId = publishedByUserId; }

    public String getPublishedByName() { return publishedByName; }
    public void setPublishedByName(String publishedByName) { this.publishedByName = publishedByName; }

    public Date getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Date expiresAt) { this.expiresAt = expiresAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getPriority() { return urgent ? "HIGH" : "NORMAL"; }
    public Timestamp getPublishedAt() { return createdAt; }
}
