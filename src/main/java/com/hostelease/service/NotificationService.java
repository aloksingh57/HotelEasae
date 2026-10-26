package com.hostelease.service;

import com.hostelease.dao.*;
import com.hostelease.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;

public class NotificationService {

    private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);
    private static final NotificationService INSTANCE = new NotificationService();

    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final StudentDAO studentDAO = new StudentDAO();
    private final UserDAO userDAO = new UserDAO();
    private final LeaveDAO leaveDAO = new LeaveDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final FeeDAO feeDAO = new FeeDAO();

    public static NotificationService getInstance() {
        return INSTANCE;
    }

    // 1. LEAVE NOTIFICATIONS
    public void notifyLeaveSubmitted(LeaveRequest req) {
        try {
            Student student = studentDAO.findById(req.getStudentId());
            if (student == null) return;
            Long hostelId = student.getAllocatedHostelId() != null ? student.getAllocatedHostelId() : 1L;
            User warden = userDAO.findWardenByHostelId(hostelId);

            String studentSubject = "Leave Request #" + req.getId() + " Submitted — HostelEase";
            String studentBody = "Hello " + student.getFullName() + ", your leave request #" + req.getId() + 
                    " (" + req.getLeaveType() + ") from " + req.getDepartureDatetime() + " to " + req.getExpectedReturnDatetime() + 
                    " has been successfully submitted and is under review by the Warden.";
            String studentSms = "HostelEase: Leave req #" + req.getId() + " submitted (" + req.getLeaveType() + "). Under warden review.";

            // Student Email & SMS
            notificationDAO.enqueue("LEAVE_SUBMIT_EM_" + req.getId(), student.getEmail(), student.getPhone(), "EMAIL", "LEAVE_SUBMITTED", studentSubject, studentBody);
            notificationDAO.enqueue("LEAVE_SUBMIT_SMS_" + req.getId(), student.getEmail(), student.getPhone(), "SMS", "LEAVE_SUBMITTED", studentSubject, studentSms);

            // Warden Email & SMS
            if (warden != null) {
                String wardenSubject = "Action Required: New Leave Application from " + student.getFullName();
                String wardenBody = "Resident " + student.getFullName() + " (Reg: " + student.getRegistrationNumber() + 
                        ", Room: " + student.getCurrentRoomNumber() + ", Bed: " + student.getCurrentBedNumber() + ") has submitted a leave application (" +
                        req.getLeaveType() + ") from " + req.getDepartureDatetime() + " to " + req.getExpectedReturnDatetime() + 
                        ". Destination: " + req.getDestinationAddress() + ". Please review in Warden portal.";
                String wardenSms = "HostelEase Alert: New leave request from " + student.getFullName() + " (Room " + student.getCurrentRoomNumber() + "). Please review.";

                notificationDAO.enqueue("LEAVE_SUBMIT_WRD_EM_" + req.getId(), warden.getEmail(), warden.getPhoneNumber(), "EMAIL", "WARDEN_LEAVE_ALERT", wardenSubject, wardenBody);
                notificationDAO.enqueue("LEAVE_SUBMIT_WRD_SMS_" + req.getId(), warden.getEmail(), warden.getPhoneNumber(), "SMS", "WARDEN_LEAVE_ALERT", wardenSubject, wardenSms);
            }
        } catch (Exception e) {
            logger.error("Error in notifyLeaveSubmitted: {}", e.getMessage(), e);
        }
    }

    public void notifyLeaveDecision(Long leaveId, boolean approved, String remarks) {
        try {
            LeaveRequest leave = leaveDAO.findById(leaveId);
            if (leave == null) return;
            Student student = studentDAO.findById(leave.getStudentId());
            if (student == null) return;

            if (approved) {
                String subject = "Leave Request #" + leaveId + " APPROVED — HostelEase";
                String body = "Dear " + student.getFullName() + ", your leave request #" + leaveId + 
                        " has been APPROVED by the Warden. Departure: " + leave.getDepartureDatetime() + 
                        ", Return by: " + leave.getExpectedReturnDatetime() + ". Remarks: " + (remarks != null ? remarks : "Approved") + ". Have a safe journey!";
                String sms = "HostelEase: Leave #" + leaveId + " APPROVED by Warden. Expected return: " + leave.getExpectedReturnDatetime();

                notificationDAO.enqueue("LEAVE_APP_EM_" + leaveId, student.getEmail(), student.getPhone(), "EMAIL", "LEAVE_APPROVED", subject, body);
                notificationDAO.enqueue("LEAVE_APP_SMS_" + leaveId, student.getEmail(), student.getPhone(), "SMS", "LEAVE_APPROVED", subject, sms);

                // Guardian SMS notification
                if (student.getGuardianPhone() != null && !student.getGuardianPhone().isEmpty()) {
                    String gSms = "HostelEase Notice: Leave request for your ward " + student.getFullName() + " has been approved by the hostel warden.";
                    notificationDAO.enqueue("LEAVE_APP_GRD_SMS_" + leaveId, student.getGuardianEmail(), student.getGuardianPhone(), "SMS", "GUARDIAN_ALERT", "Ward Leave Approved", gSms);
                }
            } else {
                String subject = "Leave Request #" + leaveId + " REJECTED — HostelEase";
                String body = "Dear " + student.getFullName() + ", your leave request #" + leaveId + 
                        " has been REJECTED by the Warden. Reason / Remarks: " + (remarks != null ? remarks : "Not approved at this time") + ".";
                String sms = "HostelEase: Leave #" + leaveId + " was REJECTED. Remarks: " + (remarks != null ? remarks : "Contact warden office");

                notificationDAO.enqueue("LEAVE_REJ_EM_" + leaveId, student.getEmail(), student.getPhone(), "EMAIL", "LEAVE_REJECTED", subject, body);
                notificationDAO.enqueue("LEAVE_REJ_SMS_" + leaveId, student.getEmail(), student.getPhone(), "SMS", "LEAVE_REJECTED", subject, sms);
            }
        } catch (Exception e) {
            logger.error("Error in notifyLeaveDecision: {}", e.getMessage(), e);
        }
    }

    public void notifyDeparture(Long leaveId) {
        try {
            LeaveRequest leave = leaveDAO.findById(leaveId);
            if (leave == null) return;
            Student student = studentDAO.findById(leave.getStudentId());
            if (student == null) return;

            String subject = "Campus Gate Departure Recorded — HostelEase";
            String body = "Dear " + student.getFullName() + ", your departure through the hostel security checkpoint has been officially recorded. " +
                    "Your bed is designated as a Temporary Holiday Vacancy while preserving your allocation. Please ensure return before " + leave.getExpectedReturnDatetime() + ".";
            String sms = "HostelEase: Departure recorded at campus gate. Bed marked temporary vacancy. Return by: " + leave.getExpectedReturnDatetime();

            notificationDAO.enqueue("DEP_EM_" + leaveId, student.getEmail(), student.getPhone(), "EMAIL", "STUDENT_DEPARTED", subject, body);
            notificationDAO.enqueue("DEP_SMS_" + leaveId, student.getEmail(), student.getPhone(), "SMS", "STUDENT_DEPARTED", subject, sms);

            if (student.getGuardianPhone() != null && !student.getGuardianPhone().isEmpty()) {
                String gSms = "HostelEase Gate Alert: " + student.getFullName() + " has checked out of hostel campus for approved leave.";
                notificationDAO.enqueue("DEP_GRD_SMS_" + leaveId, student.getGuardianEmail(), student.getGuardianPhone(), "SMS", "GUARDIAN_ALERT", "Ward Campus Departure", gSms);
            }
        } catch (Exception e) {
            logger.error("Error in notifyDeparture: {}", e.getMessage(), e);
        }
    }

    public void notifyReturn(Long leaveId) {
        try {
            LeaveRequest leave = leaveDAO.findById(leaveId);
            if (leave == null) return;
            Student student = studentDAO.findById(leave.getStudentId());
            if (student == null) return;

            String subject = "Return Re-Entry Verified — Welcome Back!";
            String body = "Welcome back to the hostel, " + student.getFullName() + "! Your return entry has been confirmed at the gate checkpoint. " +
                    "Your residency status has been restored to PRESENT in Room " + student.getCurrentRoomNumber() + ", Bed " + student.getCurrentBedNumber() + ".";
            String sms = "HostelEase: Welcome back! Gate return entry verified. Status restored to PRESENT in Room " + student.getCurrentRoomNumber() + ".";

            notificationDAO.enqueue("RET_EM_" + leaveId, student.getEmail(), student.getPhone(), "EMAIL", "STUDENT_RETURNED", subject, body);
            notificationDAO.enqueue("RET_SMS_" + leaveId, student.getEmail(), student.getPhone(), "SMS", "STUDENT_RETURNED", subject, sms);
        } catch (Exception e) {
            logger.error("Error in notifyReturn: {}", e.getMessage(), e);
        }
    }

    public void notifyOverdue(LeaveRequest req) {
        try {
            Student student = studentDAO.findById(req.getStudentId());
            if (student == null) return;
            Long hostelId = student.getAllocatedHostelId() != null ? student.getAllocatedHostelId() : 1L;
            User warden = userDAO.findWardenByHostelId(hostelId);

            String sSubject = "URGENT: Return Overdue Alert — HostelEase";
            String sBody = "Dear " + student.getFullName() + ", your expected return datetime (" + req.getExpectedReturnDatetime() + 
                    ") has passed. You have been flagged as OVERDUE. Please contact the Warden Office immediately.";
            String sSms = "HostelEase URGENT: You are OVERDUE to return. Contact hostel warden immediately.";

            notificationDAO.enqueue("OVD_EM_" + req.getId() + "_" + System.currentTimeMillis(), student.getEmail(), student.getPhone(), "EMAIL", "RETURN_OVERDUE", sSubject, sBody);
            notificationDAO.enqueue("OVD_SMS_" + req.getId() + "_" + System.currentTimeMillis(), student.getEmail(), student.getPhone(), "SMS", "RETURN_OVERDUE", sSubject, sSms);

            if (warden != null) {
                String wSubject = "CRITICAL ALERT: Student Return Overdue (" + student.getFullName() + ")";
                String wBody = "Student " + student.getFullName() + " (Reg: " + student.getRegistrationNumber() + 
                        ", Phone: " + student.getPhone() + ", Room: " + student.getCurrentRoomNumber() + ") failed to return by " + 
                        req.getExpectedReturnDatetime() + ". Guardian Contact: " + student.getGuardianPhone() + ". Immediate action required.";
                String wSms = "HostelEase ALERT: " + student.getFullName() + " (Room " + student.getCurrentRoomNumber() + ") is OVERDUE for return. Phone: " + student.getPhone();

                notificationDAO.enqueue("OVD_WRD_EM_" + req.getId() + "_" + System.currentTimeMillis(), warden.getEmail(), warden.getPhoneNumber(), "EMAIL", "WARDEN_OVERDUE_ALERT", wSubject, wBody);
                notificationDAO.enqueue("OVD_WRD_SMS_" + req.getId() + "_" + System.currentTimeMillis(), warden.getEmail(), warden.getPhoneNumber(), "SMS", "WARDEN_OVERDUE_ALERT", wSubject, wSms);
            }
        } catch (Exception e) {
            logger.error("Error in notifyOverdue: {}", e.getMessage(), e);
        }
    }

    // 2. COMPLAINT NOTIFICATIONS
    public void notifyComplaintRegistered(Complaint c) {
        try {
            Student student = studentDAO.findById(c.getStudentId());
            if (student == null) return;
            User warden = userDAO.findWardenByHostelId(c.getHostelId());

            String sSubject = "Maintenance Ticket #" + c.getComplaintCode() + " Registered — HostelEase";
            String sBody = "Hello " + student.getFullName() + ", your maintenance complaint regarding '" + c.getSubject() + 
                    "' (Category: " + c.getCategory() + ") has been registered under ticket #" + c.getComplaintCode() + 
                    ". The warden and maintenance staff have been alerted.";
            String sSms = "HostelEase: Maintenance ticket #" + c.getComplaintCode() + " ('" + c.getSubject() + "') registered successfully.";

            notificationDAO.enqueue("CMP_REG_EM_" + c.getComplaintCode(), student.getEmail(), student.getPhone(), "EMAIL", "COMPLAINT_REGISTERED", sSubject, sBody);
            notificationDAO.enqueue("CMP_REG_SMS_" + c.getComplaintCode(), student.getEmail(), student.getPhone(), "SMS", "COMPLAINT_REGISTERED", sSubject, sSms);

            if (warden != null) {
                String wSubject = "New Maintenance Ticket #" + c.getComplaintCode() + " (" + c.getCategory() + ")";
                String wBody = "A new " + c.getCategory() + " complaint has been logged by resident " + student.getFullName() + 
                        " (Room: " + student.getCurrentRoomNumber() + "). Subject: " + c.getSubject() + 
                        ". Priority: " + c.getPriority() + ". Description: " + c.getDescription();
                String wSms = "HostelEase Alert: New " + c.getCategory() + " ticket #" + c.getComplaintCode() + " filed for Room " + student.getCurrentRoomNumber();

                notificationDAO.enqueue("CMP_WRD_EM_" + c.getComplaintCode(), warden.getEmail(), warden.getPhoneNumber(), "EMAIL", "WARDEN_COMPLAINT_ALERT", wSubject, wBody);
                notificationDAO.enqueue("CMP_WRD_SMS_" + c.getComplaintCode(), warden.getEmail(), warden.getPhoneNumber(), "SMS", "WARDEN_COMPLAINT_ALERT", wSubject, wSms);
            }
        } catch (Exception e) {
            logger.error("Error in notifyComplaintRegistered: {}", e.getMessage(), e);
        }
    }

    public void notifyComplaintUpdated(Complaint c, String remarks) {
        try {
            Student student = studentDAO.findById(c.getStudentId());
            if (student == null) return;

            String subject = "Complaint Update: Ticket #" + c.getComplaintCode() + " is now " + c.getStatus();
            String body = "Dear " + student.getFullName() + ", the status of your maintenance complaint ticket #" + 
                    c.getComplaintCode() + " ('" + c.getSubject() + "') has been updated to " + c.getStatus() + 
                    ". Remarks / Resolution notes: " + (remarks != null ? remarks : "Updated by hostel administration");
            String sms = "HostelEase: Ticket #" + c.getComplaintCode() + " status updated to " + c.getStatus() + ". Notes: " + (remarks != null ? remarks : "In progress");

            String keySuffix = "_" + System.currentTimeMillis();
            notificationDAO.enqueue("CMP_UPD_EM_" + c.getId() + keySuffix, student.getEmail(), student.getPhone(), "EMAIL", "COMPLAINT_UPDATE", subject, body);
            notificationDAO.enqueue("CMP_UPD_SMS_" + c.getId() + keySuffix, student.getEmail(), student.getPhone(), "SMS", "COMPLAINT_UPDATE", subject, sms);
        } catch (Exception e) {
            logger.error("Error in notifyComplaintUpdated: {}", e.getMessage(), e);
        }
    }

    // 3. ALLOCATION AND ROOM NOTIFICATIONS
    public void notifyRoomAllocated(Long studentId, Long bedId) {
        try {
            Student student = studentDAO.findById(studentId);
            Bed bed = roomDAO.findBedById(bedId);
            if (student == null || bed == null) return;
            User warden = userDAO.findWardenByHostelId(bed.getHostelId());

            String sSubject = "Official Bed Allocation Confirmed — HostelEase";
            String sBody = "Congratulations " + student.getFullName() + "! You have been allocated " + bed.getBedLabel() + 
                    " in Room " + bed.getRoomNumber() + " at " + bed.getHostelName() + " (" + bed.getBuildingName() + 
                    ", " + bed.getFloorName() + "). Please present your student ID to the warden office upon arrival.";
            String sSms = "HostelEase: Room allocated! Bed: " + bed.getBedLabel() + ", Room " + bed.getRoomNumber() + ", " + bed.getHostelName() + ".";

            notificationDAO.enqueue("ALLOC_EM_" + studentId + "_" + bedId, student.getEmail(), student.getPhone(), "EMAIL", "ROOM_ALLOCATED", sSubject, sBody);
            notificationDAO.enqueue("ALLOC_SMS_" + studentId + "_" + bedId, student.getEmail(), student.getPhone(), "SMS", "ROOM_ALLOCATED", sSubject, sSms);

            if (warden != null) {
                String wSubject = "New Resident Allocation: " + student.getFullName();
                String wBody = "Student " + student.getFullName() + " (Reg: " + student.getRegistrationNumber() + 
                        ", Phone: " + student.getPhone() + ") has been allocated to Room " + bed.getRoomNumber() + " (" + bed.getBedLabel() + ").";
                String wSms = "HostelEase: New resident " + student.getFullName() + " allocated to Room " + bed.getRoomNumber() + " (" + bed.getBedLabel() + ")";

                notificationDAO.enqueue("ALLOC_WRD_EM_" + studentId + "_" + bedId, warden.getEmail(), warden.getPhoneNumber(), "EMAIL", "WARDEN_ALLOC_ALERT", wSubject, wBody);
                notificationDAO.enqueue("ALLOC_WRD_SMS_" + studentId + "_" + bedId, warden.getEmail(), warden.getPhoneNumber(), "SMS", "WARDEN_ALLOC_ALERT", wSubject, wSms);
            }
        } catch (Exception e) {
            logger.error("Error in notifyRoomAllocated: {}", e.getMessage(), e);
        }
    }

    public void notifyRoomTransferred(Long studentId, Long oldBedId, Long newBedId) {
        try {
            Student student = studentDAO.findById(studentId);
            Bed newBed = roomDAO.findBedById(newBedId);
            if (student == null || newBed == null) return;
            User warden = userDAO.findWardenByHostelId(newBed.getHostelId());

            String sSubject = "Room Transfer Executed — HostelEase";
            String sBody = "Dear " + student.getFullName() + ", your room transfer has been processed. Your new accommodation is " + 
                    newBed.getBedLabel() + " in Room " + newBed.getRoomNumber() + " (" + newBed.getHostelName() + ").";
            String sSms = "HostelEase: Room transfer confirmed. New Room: " + newBed.getRoomNumber() + " (" + newBed.getBedLabel() + "), " + newBed.getHostelName() + ".";

            String keySuffix = "_" + System.currentTimeMillis();
            notificationDAO.enqueue("TRANS_EM_" + studentId + keySuffix, student.getEmail(), student.getPhone(), "EMAIL", "ROOM_TRANSFERRED", sSubject, sBody);
            notificationDAO.enqueue("TRANS_SMS_" + studentId + keySuffix, student.getEmail(), student.getPhone(), "SMS", "ROOM_TRANSFERRED", sSubject, sSms);

            if (warden != null) {
                String wSubject = "Resident Transferred: " + student.getFullName();
                String wBody = "Student " + student.getFullName() + " was transferred to Room " + newBed.getRoomNumber() + " (" + newBed.getBedLabel() + ").";
                String wSms = "HostelEase: " + student.getFullName() + " transferred to Room " + newBed.getRoomNumber();

                notificationDAO.enqueue("TRANS_WRD_EM_" + studentId + keySuffix, warden.getEmail(), warden.getPhoneNumber(), "EMAIL", "WARDEN_TRANS_ALERT", wSubject, wBody);
                notificationDAO.enqueue("TRANS_WRD_SMS_" + studentId + keySuffix, warden.getEmail(), warden.getPhoneNumber(), "SMS", "WARDEN_TRANS_ALERT", wSubject, wSms);
            }
        } catch (Exception e) {
            logger.error("Error in notifyRoomTransferred: {}", e.getMessage(), e);
        }
    }

    public void notifyPermanentCheckout(Long studentId, String remarks) {
        try {
            Student student = studentDAO.findById(studentId);
            if (student == null) return;
            Long hostelId = student.getAllocatedHostelId() != null ? student.getAllocatedHostelId() : 1L;
            User warden = userDAO.findWardenByHostelId(hostelId);

            String sSubject = "Permanent Hostel Checkout Clearance — HostelEase";
            String sBody = "Dear " + student.getFullName() + ", your permanent checkout from the hostel has been finalized. " +
                    "Your bed allocation has been released. Clearance remarks: " + (remarks != null ? remarks : "Completed") + ". We wish you all the best!";
            String sSms = "HostelEase: Permanent checkout completed. Bed released. Clearance remarks: " + (remarks != null ? remarks : "Cleared");

            String keySuffix = "_" + System.currentTimeMillis();
            notificationDAO.enqueue("CHK_EM_" + studentId + keySuffix, student.getEmail(), student.getPhone(), "EMAIL", "CHECKOUT_COMPLETED", sSubject, sBody);
            notificationDAO.enqueue("CHK_SMS_" + studentId + keySuffix, student.getEmail(), student.getPhone(), "SMS", "CHECKOUT_COMPLETED", sSubject, sSms);

            if (warden != null) {
                String wSubject = "Permanent Checkout: " + student.getFullName();
                String wBody = "Resident " + student.getFullName() + " (Reg: " + student.getRegistrationNumber() + ") has checked out permanently. Remarks: " + remarks;
                String wSms = "HostelEase: " + student.getFullName() + " has completed permanent checkout.";

                notificationDAO.enqueue("CHK_WRD_EM_" + studentId + keySuffix, warden.getEmail(), warden.getPhoneNumber(), "EMAIL", "WARDEN_CHK_ALERT", wSubject, wBody);
                notificationDAO.enqueue("CHK_WRD_SMS_" + studentId + keySuffix, warden.getEmail(), warden.getPhoneNumber(), "SMS", "WARDEN_CHK_ALERT", wSubject, wSms);
            }
        } catch (Exception e) {
            logger.error("Error in notifyPermanentCheckout: {}", e.getMessage(), e);
        }
    }

    // 4. FINANCIAL NOTIFICATIONS
    public void notifyPaymentReceived(Long invoiceId, Long studentId, BigDecimal amount, String method, String txnRef) {
        try {
            Invoice inv = feeDAO.findInvoiceById(invoiceId);
            Student student = studentDAO.findById(studentId);
            if (student == null) return;
            Long hostelId = student.getAllocatedHostelId() != null ? student.getAllocatedHostelId() : 1L;
            User warden = userDAO.findWardenByHostelId(hostelId);

            String invNum = (inv != null) ? inv.getInvoiceNumber() : "INV-" + invoiceId;
            String sSubject = "Official Fee Payment Receipt — " + invNum;
            String sBody = "Dear " + student.getFullName() + ", we have received your payment of ₹" + amount + 
                    " for invoice " + invNum + " via " + method + ". Transaction Ref: " + txnRef + 
                    ". An official digital receipt has been posted to your resident portal.";
            String sSms = "HostelEase: Fee payment of Rs. " + amount + " received for " + invNum + ". Ref: " + txnRef + ". Receipt available in portal.";

            String keySuffix = "_" + System.currentTimeMillis();
            notificationDAO.enqueue("PAY_EM_" + invoiceId + keySuffix, student.getEmail(), student.getPhone(), "EMAIL", "PAYMENT_SUCCESS", sSubject, sBody);
            notificationDAO.enqueue("PAY_SMS_" + invoiceId + keySuffix, student.getEmail(), student.getPhone(), "SMS", "PAYMENT_SUCCESS", sSubject, sSms);

            if (warden != null) {
                String wSubject = "Fee Payment Received: " + student.getFullName() + " (₹" + amount + ")";
                String wBody = "Payment of ₹" + amount + " posted for resident " + student.getFullName() + " (" + invNum + ", " + method + ").";
                String wSms = "HostelEase Finance: Payment of Rs. " + amount + " posted for " + student.getFullName();

                notificationDAO.enqueue("PAY_WRD_EM_" + invoiceId + keySuffix, warden.getEmail(), warden.getPhoneNumber(), "EMAIL", "WARDEN_PAY_ALERT", wSubject, wBody);
                notificationDAO.enqueue("PAY_WRD_SMS_" + invoiceId + keySuffix, warden.getEmail(), warden.getPhoneNumber(), "SMS", "WARDEN_PAY_ALERT", wSubject, wSms);
            }
        } catch (Exception e) {
            logger.error("Error in notifyPaymentReceived: {}", e.getMessage(), e);
        }
    }

    public void notifyInvoiceGenerated(Invoice inv) {
        try {
            Student student = studentDAO.findById(inv.getStudentId());
            if (student == null) return;

            String subject = "New Hostel Fee Invoice #" + inv.getInvoiceNumber() + " Issued";
            String body = "Dear " + student.getFullName() + ", a new invoice #" + inv.getInvoiceNumber() + 
                    " for the amount of ₹" + inv.getAmount() + " has been generated for your hostel residency. Due date: " + 
                    inv.getDueDate() + ". Please settle the dues on or before the due date to avoid late penalty.";
            String sms = "HostelEase: Invoice #" + inv.getInvoiceNumber() + " of Rs. " + inv.getAmount() + " issued. Due date: " + inv.getDueDate();

            notificationDAO.enqueue("INV_GEN_EM_" + inv.getId(), student.getEmail(), student.getPhone(), "EMAIL", "INVOICE_GENERATED", subject, body);
            notificationDAO.enqueue("INV_GEN_SMS_" + inv.getId(), student.getEmail(), student.getPhone(), "SMS", "INVOICE_GENERATED", subject, sms);
        } catch (Exception e) {
            logger.error("Error in notifyInvoiceGenerated: {}", e.getMessage(), e);
        }
    }

    // 5. VISITOR NOTIFICATIONS
    public void notifyVisitorEntry(String visitorName, String contactNumber, Long studentId, Long hostelId, String purpose) {
        try {
            Student student = studentDAO.findById(studentId);
            if (student == null) return;
            User warden = userDAO.findWardenByHostelId(hostelId);

            String sSubject = "Security Gate Alert: Visitor Arrived to Meet You";
            String sBody = "Hello " + student.getFullName() + ", visitor " + visitorName + " (Contact: " + contactNumber + 
                    ") has arrived at the security gate and registered to meet you. Purpose: " + purpose + 
                    ". Please proceed to the visitor reception lounge.";
            String sSms = "HostelEase Gate: Visitor " + visitorName + " (Ph: " + contactNumber + ") has arrived to meet you. Purpose: " + purpose;

            String keySuffix = "_" + System.currentTimeMillis();
            notificationDAO.enqueue("VIS_IN_EM_" + studentId + keySuffix, student.getEmail(), student.getPhone(), "EMAIL", "VISITOR_ARRIVED", sSubject, sBody);
            notificationDAO.enqueue("VIS_IN_SMS_" + studentId + keySuffix, student.getEmail(), student.getPhone(), "SMS", "VISITOR_ARRIVED", sSubject, sSms);

            if (warden != null) {
                String wSubject = "Gate Log: Visitor Entry for " + student.getFullName();
                String wBody = "Visitor " + visitorName + " (Phone: " + contactNumber + ") entered gate to meet resident " + 
                        student.getFullName() + " (Room " + student.getCurrentRoomNumber() + "). Purpose: " + purpose;
                String wSms = "HostelEase Security: Visitor " + visitorName + " entered to meet " + student.getFullName() + " (Room " + student.getCurrentRoomNumber() + ")";

                notificationDAO.enqueue("VIS_IN_WRD_EM_" + studentId + keySuffix, warden.getEmail(), warden.getPhoneNumber(), "EMAIL", "WARDEN_VISITOR_ALERT", wSubject, wBody);
                notificationDAO.enqueue("VIS_IN_WRD_SMS_" + studentId + keySuffix, warden.getEmail(), warden.getPhoneNumber(), "SMS", "WARDEN_VISITOR_ALERT", wSubject, wSms);
            }
        } catch (Exception e) {
            logger.error("Error in notifyVisitorEntry: {}", e.getMessage(), e);
        }
    }
}
