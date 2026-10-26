package com.hostelease.service;

import com.hostelease.dao.AuditDAO;
import com.hostelease.dao.LeaveDAO;
import com.hostelease.dao.NotificationDAO;
import com.hostelease.model.LeaveRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

public class LeaveService {

    private static final Logger logger = LoggerFactory.getLogger(LeaveService.class);
    private final LeaveDAO leaveDAO = new LeaveDAO();
    private final AuditDAO auditDAO = new AuditDAO();
    private final NotificationService notificationService = NotificationService.getInstance();

    public boolean submitLeaveRequest(LeaveRequest req) {
        if (req.getDepartureDatetime() == null || req.getExpectedReturnDatetime() == null) {
            return false;
        }
        if (!req.getExpectedReturnDatetime().after(req.getDepartureDatetime())) {
            logger.warn("Leave rejection: expected return must be after departure time");
            return false;
        }

        // Robust leave type normalization against DB check constraint
        String lt = req.getLeaveType();
        if (lt != null) {
            lt = lt.trim().toUpperCase();
            if (lt.contains("HOME")) lt = "HOME";
            else if (lt.contains("VACATION") || lt.contains("HOLIDAY")) lt = "VACATION";
            else if (lt.contains("MED")) lt = "MEDICAL";
            else if (lt.contains("WEEKEND")) lt = "WEEKEND";
            else if (lt.contains("FESTIV")) lt = "FESTIVAL";
            else if (lt.contains("ACADEMIC") || lt.contains("DUTY") || lt.contains("OD")) lt = "ACADEMIC_OD";
            else if (lt.contains("EMERG")) lt = "EMERGENCY";
            else if (!java.util.List.of("WEEKEND", "SEMESTER_HOLIDAY", "FESTIVAL", "PERSONAL", "MEDICAL", "OTHER", "HOME", "VACATION", "EMERGENCY", "ACADEMIC_OD").contains(lt)) {
                lt = "PERSONAL";
            }
        } else {
            lt = "PERSONAL";
        }
        req.setLeaveType(lt);

        boolean success = leaveDAO.create(req);
        if (success) {
            auditDAO.log(null, "LEAVE_SUBMITTED", "LEAVE_REQUEST", String.valueOf(req.getId()), "127.0.0.1", "Type: " + req.getLeaveType());
            notificationService.notifyLeaveSubmitted(req);
        }
        return success;
    }

    public List<LeaveRequest> findAll(Long hostelId, String status, String leaveType) {
        return leaveDAO.findAll(hostelId, status, leaveType);
    }

    public List<LeaveRequest> findByStudentId(Long studentId) {
        return leaveDAO.findByStudentId(studentId);
    }

    public LeaveRequest findById(Long leaveId) {
        return leaveDAO.findById(leaveId);
    }

    public boolean approveLeave(Long leaveId, Long wardenUserId, String remarks) {
        boolean success = leaveDAO.approveLeave(leaveId, wardenUserId, remarks);
        if (success) {
            auditDAO.log(wardenUserId, "LEAVE_APPROVED", "LEAVE_REQUEST", String.valueOf(leaveId), "127.0.0.1", remarks);
            notificationService.notifyLeaveDecision(leaveId, true, remarks);
        }
        return success;
    }

    public boolean rejectLeave(Long leaveId, Long wardenUserId, String remarks) {
        boolean success = leaveDAO.rejectLeave(leaveId, wardenUserId, remarks);
        if (success) {
            auditDAO.log(wardenUserId, "LEAVE_REJECTED", "LEAVE_REQUEST", String.valueOf(leaveId), "127.0.0.1", remarks);
            notificationService.notifyLeaveDecision(leaveId, false, remarks);
        }
        return success;
    }

    public boolean recordDeparture(Long leaveId, Long staffUserId) {
        boolean success = leaveDAO.recordDeparture(leaveId, staffUserId);
        if (success) {
            auditDAO.log(staffUserId, "STUDENT_DEPARTED", "LEAVE_REQUEST", String.valueOf(leaveId), "127.0.0.1", "Student is now AWAY. Temporary vacancy active.");
            notificationService.notifyDeparture(leaveId);
        }
        return success;
    }

    public boolean recordReturn(Long leaveId, Long staffUserId) {
        boolean success = leaveDAO.recordReturn(leaveId, staffUserId);
        if (success) {
            auditDAO.log(staffUserId, "STUDENT_RETURNED", "LEAVE_REQUEST", String.valueOf(leaveId), "127.0.0.1", "Student is now PRESENT. Allocation confirmed.");
            notificationService.notifyReturn(leaveId);
        }
        return success;
    }

    public int reconcileOverdueLeaves() {
        int count = leaveDAO.reconcileOverdueLeaves();
        if (count > 0) {
            List<LeaveRequest> overdues = leaveDAO.findAll(null, "OVERDUE", null);
            for (LeaveRequest ov : overdues) {
                notificationService.notifyOverdue(ov);
            }
        }
        return count;
    }
}
