package com.hostelease.service;

import com.hostelease.dao.AuditDAO;
import com.hostelease.dao.VisitorDAO;
import com.hostelease.model.VisitorLog;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

public class VisitorService {

    private static final Logger logger = LoggerFactory.getLogger(VisitorService.class);
    private final VisitorDAO visitorDAO = new VisitorDAO();
    private final AuditDAO auditDAO = new AuditDAO();
    private final NotificationService notificationService = NotificationService.getInstance();

    public boolean recordEntry(String visitorName, String contactNumber, String idType, String idNo,
                               Long studentId, Long hostelId, String purpose, Long recordedByUserId) {
        boolean success = visitorDAO.recordEntry(visitorName, contactNumber, idType, idNo, studentId, hostelId, purpose, recordedByUserId);
        if (success) {
            auditDAO.log(recordedByUserId, "VISITOR_ENTRY", "VISITOR", visitorName, "127.0.0.1", "Visiting Student ID " + studentId);
            notificationService.notifyVisitorEntry(visitorName, contactNumber, studentId, hostelId, purpose);
        }
        return success;
    }

    public boolean recordExit(Long logId, Long recordedByUserId) {
        boolean success = visitorDAO.recordExit(logId);
        if (success) {
            auditDAO.log(recordedByUserId, "VISITOR_EXIT", "VISITOR_LOG", String.valueOf(logId), "127.0.0.1", "Visitor exit recorded");
        }
        return success;
    }

    public List<VisitorLog> findAll(Long hostelId, String status) {
        return visitorDAO.findAll(hostelId, status);
    }
}
