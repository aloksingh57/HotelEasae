package com.hostelease.service;

import com.hostelease.dao.AuditDAO;
import com.hostelease.dao.ComplaintDAO;
import com.hostelease.dao.NotificationDAO;
import com.hostelease.model.Complaint;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

public class ComplaintService {

    private static final Logger logger = LoggerFactory.getLogger(ComplaintService.class);
    private final ComplaintDAO complaintDAO = new ComplaintDAO();
    private final AuditDAO auditDAO = new AuditDAO();
    private final NotificationService notificationService = NotificationService.getInstance();

    public boolean createComplaint(Complaint complaint) {
        if (complaint.getSubject() == null || complaint.getDescription() == null) {
            return false;
        }

        // Robust category normalization against DB check constraint
        String cat = complaint.getCategory();
        if (cat != null) {
            cat = cat.trim().toUpperCase();
            if (cat.contains("ELECTR")) cat = "ELECTRICITY";
            else if (cat.contains("WATER") || cat.contains("PLUMB")) cat = "WATER";
            else if (cat.contains("CLEAN")) cat = "CLEANING";
            else if (cat.contains("FURN")) cat = "FURNITURE";
            else if (cat.contains("NET") || cat.contains("WIFI")) cat = "INTERNET";
            else if (cat.contains("SEC")) cat = "SECURITY";
            else if (!List.of("ELECTRICITY", "WATER", "CLEANING", "FURNITURE", "INTERNET", "MAINTENANCE", "SECURITY", "OTHER").contains(cat)) {
                cat = "MAINTENANCE";
            }
        } else {
            cat = "MAINTENANCE";
        }
        complaint.setCategory(cat);

        // Robust priority normalization against DB check constraint
        String pri = complaint.getPriority();
        if (pri != null) {
            pri = pri.trim().toUpperCase();
            if (pri.equals("CRITICAL")) pri = "URGENT";
            else if (!List.of("LOW", "MEDIUM", "HIGH", "URGENT").contains(pri)) {
                pri = "MEDIUM";
            }
        } else {
            pri = "MEDIUM";
        }
        complaint.setPriority(pri);

        boolean success = complaintDAO.create(complaint);
        if (success) {
            auditDAO.log(null, "COMPLAINT_REGISTERED", "COMPLAINT", complaint.getComplaintCode(), "127.0.0.1", "Subject: " + complaint.getSubject());
            notificationService.notifyComplaintRegistered(complaint);
        }
        return success;
    }

    public Complaint findById(Long id) {
        return complaintDAO.findById(id);
    }

    public List<Complaint> findAll(Long hostelId, String status, String category) {
        return complaintDAO.findAll(hostelId, status, category);
    }

    public List<Complaint> findByStudentId(Long studentId) {
        return complaintDAO.findByStudentId(studentId);
    }

    public boolean updateStatus(Long complaintId, String newStatus, Long staffId, String remarks, Long updatedByUserId) {
        boolean success = complaintDAO.updateStatus(complaintId, newStatus, staffId, remarks, updatedByUserId);
        if (success) {
            auditDAO.log(updatedByUserId, "COMPLAINT_STATUS_UPDATE", "COMPLAINT", String.valueOf(complaintId), "127.0.0.1", "New Status: " + newStatus);
            Complaint c = complaintDAO.findById(complaintId);
            if (c != null) {
                notificationService.notifyComplaintUpdated(c, remarks);
            }
        }
        return success;
    }
}
