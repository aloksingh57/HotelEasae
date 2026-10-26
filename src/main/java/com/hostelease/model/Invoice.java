package com.hostelease.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class Invoice {
    private Long id;
    private String invoiceNumber;
    private Long studentId;
    private String studentName;
    private String rollNumber;
    private String hostelName;
    private String roomNumber;
    private Long feeStructureId;
    private String feeCategory;
    private BigDecimal amount;
    private BigDecimal paidAmount;
    private BigDecimal balanceAmount;
    private Date dueDate;
    private BigDecimal lateFee;
    private String status; // PENDING, PAID, PARTIALLY_PAID, OVERDUE, CANCELLED
    private Timestamp createdAt;

    public Invoice() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getInvoiceNumber() { return invoiceNumber; }
    public void setInvoiceNumber(String invoiceNumber) { this.invoiceNumber = invoiceNumber; }

    public Long getStudentId() { return studentId; }
    public void setStudentId(Long studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getRollNumber() { return rollNumber; }
    public void setRollNumber(String rollNumber) { this.rollNumber = rollNumber; }

    public String getHostelName() { return hostelName; }
    public void setHostelName(String hostelName) { this.hostelName = hostelName; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public Long getFeeStructureId() { return feeStructureId; }
    public void setFeeStructureId(Long feeStructureId) { this.feeStructureId = feeStructureId; }

    public String getFeeCategory() { return feeCategory; }
    public void setFeeCategory(String feeCategory) { this.feeCategory = feeCategory; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public BigDecimal getPaidAmount() { return paidAmount; }
    public void setPaidAmount(BigDecimal paidAmount) { this.paidAmount = paidAmount; }

    public BigDecimal getBalanceAmount() {
        if (amount == null) return BigDecimal.ZERO;
        BigDecimal paid = paidAmount != null ? paidAmount : BigDecimal.ZERO;
        return amount.subtract(paid);
    }

    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }

    public BigDecimal getLateFee() { return lateFee; }
    public void setLateFee(BigDecimal lateFee) { this.lateFee = lateFee; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getStudentRegistrationNumber() { return rollNumber != null ? rollNumber : ""; }
    public String getStudentRollNo() { return rollNumber != null ? rollNumber : ""; }
}
