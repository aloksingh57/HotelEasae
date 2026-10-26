package com.hostelease.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Payment {
    private Long id;
    private Long invoiceId;
    private String invoiceNumber;
    private Long studentId;
    private String studentName;
    private String rollNumber;
    private BigDecimal amount;
    private String paymentMethod; // CASH, BANK_TRANSFER, UPI, CARD, ONLINE_SIMULATION
    private String transactionReference;
    private Long recordedByUserId;
    private String recordedByName;
    private String status; // PAID, PENDING, FAILED, CANCELLED, REFUNDED
    private Timestamp paymentDate;
    private String receiptNumber;

    public Payment() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getInvoiceId() { return invoiceId; }
    public void setInvoiceId(Long invoiceId) { this.invoiceId = invoiceId; }

    public String getInvoiceNumber() { return invoiceNumber; }
    public void setInvoiceNumber(String invoiceNumber) { this.invoiceNumber = invoiceNumber; }

    public Long getStudentId() { return studentId; }
    public void setStudentId(Long studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getRollNumber() { return rollNumber; }
    public void setRollNumber(String rollNumber) { this.rollNumber = rollNumber; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getTransactionReference() { return transactionReference; }
    public void setTransactionReference(String transactionReference) { this.transactionReference = transactionReference; }

    public Long getRecordedByUserId() { return recordedByUserId; }
    public void setRecordedByUserId(Long recordedByUserId) { this.recordedByUserId = recordedByUserId; }

    public String getRecordedByName() { return recordedByName; }
    public void setRecordedByName(String recordedByName) { this.recordedByName = recordedByName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getPaymentDate() { return paymentDate; }
    public void setPaymentDate(Timestamp paymentDate) { this.paymentDate = paymentDate; }

    public String getReceiptNumber() { return receiptNumber; }
    public void setReceiptNumber(String receiptNumber) { this.receiptNumber = receiptNumber; }
}
