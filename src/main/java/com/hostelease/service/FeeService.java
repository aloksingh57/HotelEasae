package com.hostelease.service;

import com.hostelease.dao.AuditDAO;
import com.hostelease.dao.FeeDAO;
import com.hostelease.dao.NotificationDAO;
import com.hostelease.model.Invoice;
import com.hostelease.model.Payment;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;
import java.util.Map;

public class FeeService {

    private static final Logger logger = LoggerFactory.getLogger(FeeService.class);
    private final FeeDAO feeDAO = new FeeDAO();
    private final AuditDAO auditDAO = new AuditDAO();
    private final NotificationService notificationService = NotificationService.getInstance();

    public List<Invoice> findInvoices(Long studentId, Long hostelId, String status) {
        return feeDAO.findInvoices(studentId, hostelId, status);
    }

    public Invoice findInvoiceById(Long invoiceId) {
        return feeDAO.findInvoiceById(invoiceId);
    }

    public List<Payment> findPaymentsByStudent(Long studentId) {
        return feeDAO.findPaymentsByStudent(studentId);
    }

    public boolean recordPayment(Long invoiceId, Long studentId, BigDecimal amount, String method, String txnRef, Long recordedByUserId) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            logger.warn("Invalid payment amount: {}", amount);
            return false;
        }

        boolean success = feeDAO.recordPayment(invoiceId, studentId, amount, method, txnRef, recordedByUserId);
        if (success) {
            auditDAO.log(recordedByUserId, "PAYMENT_RECORDED", "INVOICE", String.valueOf(invoiceId), "127.0.0.1", "Amount: Rs. " + amount + " via " + method);
            notificationService.notifyPaymentReceived(invoiceId, studentId, amount, method, txnRef);
        }
        return success;
    }

    public boolean createInvoice(Long studentId, Long feeStructureId, BigDecimal amount, Date dueDate, Long createdByUserId) {
        Long invoiceId = feeDAO.createInvoice(studentId, feeStructureId, amount, dueDate);
        if (invoiceId != null) {
            auditDAO.log(createdByUserId, "INVOICE_CREATED", "INVOICE", String.valueOf(invoiceId), "127.0.0.1", "Amount: Rs. " + amount);
            Invoice inv = feeDAO.findInvoiceById(invoiceId);
            if (inv != null) {
                notificationService.notifyInvoiceGenerated(inv);
            }
            return true;
        }
        return false;
    }

    public Map<String, Object> getFinancialSummary(Long hostelId) {
        return feeDAO.getFinancialSummary(hostelId);
    }
}
