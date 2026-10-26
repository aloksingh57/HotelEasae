package com.hostelease.dao;

import com.hostelease.config.DatabaseConfig;
import com.hostelease.model.Invoice;
import com.hostelease.model.Payment;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class FeeDAO {

    private static final Logger logger = LoggerFactory.getLogger(FeeDAO.class);

    public List<Invoice> findInvoices(Long studentId, Long hostelId, String status) {
        List<Invoice> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT inv.id, inv.invoice_number, inv.student_id, inv.fee_structure_id, 
                   inv.amount, inv.paid_amount, inv.due_date, inv.late_fee, inv.status, inv.created_at,
                   u.first_name, u.last_name, s.roll_number,
                   fs.fee_category,
                   h.name AS hostel_name, rm.room_number
            FROM invoices inv
            JOIN students s ON inv.student_id = s.id
            JOIN users u ON s.user_id = u.id
            LEFT JOIN fee_structures fs ON inv.fee_structure_id = fs.id
            LEFT JOIN room_allocations ra ON s.id = ra.student_id AND ra.is_active = TRUE
            LEFT JOIN beds bd ON ra.bed_id = bd.id
            LEFT JOIN rooms rm ON bd.room_id = rm.id
            LEFT JOIN hostel_floors f ON rm.floor_id = f.id
            LEFT JOIN hostel_buildings b ON f.building_id = b.id
            LEFT JOIN hostels h ON b.hostel_id = h.id
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();
        if (studentId != null && studentId > 0) {
            sql.append(" AND inv.student_id = ? ");
            params.add(studentId);
        }
        if (hostelId != null && hostelId > 0) {
            sql.append(" AND h.id = ? ");
            params.add(hostelId);
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND inv.status = ? ");
            params.add(status.trim().toUpperCase());
        }

        sql.append(" ORDER BY inv.due_date ASC, inv.id DESC");

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapInvoice(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding invoices: {}", e.getMessage(), e);
        }
        return list;
    }

    public Invoice findInvoiceById(Long invoiceId) {
        String sql = """
            SELECT inv.id, inv.invoice_number, inv.student_id, inv.fee_structure_id, 
                   inv.amount, inv.paid_amount, inv.due_date, inv.late_fee, inv.status, inv.created_at,
                   u.first_name, u.last_name, s.roll_number,
                   fs.fee_category,
                   h.name AS hostel_name, rm.room_number
            FROM invoices inv
            JOIN students s ON inv.student_id = s.id
            JOIN users u ON s.user_id = u.id
            LEFT JOIN fee_structures fs ON inv.fee_structure_id = fs.id
            LEFT JOIN room_allocations ra ON s.id = ra.student_id AND ra.is_active = TRUE
            LEFT JOIN beds bd ON ra.bed_id = bd.id
            LEFT JOIN rooms rm ON bd.room_id = rm.id
            LEFT JOIN hostel_floors f ON rm.floor_id = f.id
            LEFT JOIN hostel_buildings b ON f.building_id = b.id
            LEFT JOIN hostels h ON b.hostel_id = h.id
            WHERE inv.id = ?
        """;

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapInvoice(rs);
            }
        } catch (SQLException e) {
            logger.error("Error finding invoice by id: {}", e.getMessage(), e);
        }
        return null;
    }

    /**
     * Atomically records a payment, updates the invoice status/paid amount, and generates a receipt.
     */
    public boolean recordPayment(Long invoiceId, Long studentId, BigDecimal amount, String method, String txnRef, Long recordedByUserId) {
        String lockInvoiceSql = "SELECT amount, paid_amount, status FROM invoices WHERE id = ? FOR UPDATE";
        String insertPaymentSql = """
            INSERT INTO payments (invoice_id, student_id, amount, payment_method, transaction_reference, recorded_by_user_id, status)
            VALUES (?, ?, ?, ?, ?, ?, 'PAID') RETURNING id
        """;
        String updateInvoiceSql = "UPDATE invoices SET paid_amount = ?, status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        String insertReceiptSql = "INSERT INTO payment_receipts (payment_id, receipt_number) VALUES (?, ?)";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            BigDecimal currentPaid;
            BigDecimal totalAmount;
            try (PreparedStatement ps = conn.prepareStatement(lockInvoiceSql)) {
                ps.setLong(1, invoiceId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        logger.warn("Invoice ID {} not found", invoiceId);
                        return false;
                    }
                    totalAmount = rs.getBigDecimal("amount");
                    currentPaid = rs.getBigDecimal("paid_amount");
                }
            }

            BigDecimal newPaid = currentPaid.add(amount);
            if (newPaid.compareTo(totalAmount) > 0) {
                logger.warn("Payment amount {} exceeds outstanding balance", amount);
                conn.rollback();
                return false;
            }

            String newStatus = newPaid.compareTo(totalAmount) >= 0 ? "PAID" : "PARTIALLY_PAID";

            long paymentId;
            try (PreparedStatement ps = conn.prepareStatement(insertPaymentSql)) {
                ps.setLong(1, invoiceId);
                ps.setLong(2, studentId);
                ps.setBigDecimal(3, amount);
                ps.setString(4, method);
                ps.setString(5, txnRef);
                if (recordedByUserId != null) ps.setLong(6, recordedByUserId); else ps.setNull(6, Types.BIGINT);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        paymentId = rs.getLong(1);
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateInvoiceSql)) {
                ps.setBigDecimal(1, newPaid);
                ps.setString(2, newStatus);
                ps.setLong(3, invoiceId);
                ps.executeUpdate();
            }

            String receiptNo = "RCP-" + Calendar.getInstance().get(Calendar.YEAR) + "-" + String.format("%05d", paymentId);
            try (PreparedStatement ps = conn.prepareStatement(insertReceiptSql)) {
                ps.setLong(1, paymentId);
                ps.setString(2, receiptNo);
                ps.executeUpdate();
            }

            conn.commit();
            logger.info("Successfully recorded payment of {} for invoice {} (Receipt: {})", amount, invoiceId, receiptNo);
            return true;

        } catch (SQLException e) {
            logger.error("Transaction failed during payment recording: {}", e.getMessage(), e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    public List<Payment> findPaymentsByStudent(Long studentId) {
        List<Payment> list = new ArrayList<>();
        String sql = """
            SELECT p.id, p.invoice_id, p.student_id, p.amount, p.payment_method, 
                   p.transaction_reference, p.status, p.payment_date,
                   inv.invoice_number,
                   u.first_name, u.last_name, s.roll_number,
                   rec.receipt_number
            FROM payments p
            JOIN invoices inv ON p.invoice_id = inv.id
            JOIN students s ON p.student_id = s.id
            JOIN users u ON s.user_id = u.id
            LEFT JOIN payment_receipts rec ON p.id = rec.payment_id
            WHERE p.student_id = ?
            ORDER BY p.payment_date DESC
        """;

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Payment p = new Payment();
                    p.setId(rs.getLong("id"));
                    p.setInvoiceId(rs.getLong("invoice_id"));
                    p.setInvoiceNumber(rs.getString("invoice_number"));
                    p.setStudentId(rs.getLong("student_id"));
                    p.setStudentName(rs.getString("first_name") + " " + rs.getString("last_name"));
                    p.setRollNumber(rs.getString("roll_number"));
                    p.setAmount(rs.getBigDecimal("amount"));
                    p.setPaymentMethod(rs.getString("payment_method"));
                    p.setTransactionReference(rs.getString("transaction_reference"));
                    p.setStatus(rs.getString("status"));
                    p.setPaymentDate(rs.getTimestamp("payment_date"));
                    p.setReceiptNumber(rs.getString("receipt_number"));
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding payments by student: {}", e.getMessage(), e);
        }
        return list;
    }

    public Map<String, Object> getFinancialSummary(Long hostelId) {
        Map<String, Object> map = new HashMap<>();
        String sql = """
            SELECT 
                COALESCE(SUM(inv.amount), 0.00) AS total_billed,
                COALESCE(SUM(inv.paid_amount), 0.00) AS total_collected,
                COALESCE(SUM(inv.amount - inv.paid_amount), 0.00) AS total_outstanding,
                COUNT(inv.id) AS total_invoices,
                COUNT(CASE WHEN inv.status = 'PAID' THEN 1 END) AS paid_count,
                COUNT(CASE WHEN inv.status = 'PENDING' THEN 1 END) AS pending_count,
                COUNT(CASE WHEN inv.status = 'OVERDUE' THEN 1 END) AS overdue_count
            FROM invoices inv
            JOIN students s ON inv.student_id = s.id
            LEFT JOIN room_allocations ra ON s.id = ra.student_id AND ra.is_active = TRUE
            LEFT JOIN beds bd ON ra.bed_id = bd.id
            LEFT JOIN rooms rm ON bd.room_id = rm.id
            LEFT JOIN hostel_floors f ON rm.floor_id = f.id
            LEFT JOIN hostel_buildings b ON f.building_id = b.id
            LEFT JOIN hostels h ON b.hostel_id = h.id
            WHERE 1=1
        """;

        if (hostelId != null && hostelId > 0) {
            sql += " AND h.id = " + hostelId;
        }

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                map.put("totalBilled", rs.getBigDecimal("total_billed"));
                map.put("totalCollected", rs.getBigDecimal("total_collected"));
                map.put("totalOutstanding", rs.getBigDecimal("total_outstanding"));
                map.put("totalInvoices", rs.getInt("total_invoices"));
                map.put("paidCount", rs.getInt("paid_count"));
                map.put("pendingCount", rs.getInt("pending_count"));
                map.put("overdueCount", rs.getInt("overdue_count"));
            }
        } catch (SQLException e) {
            logger.error("Error calculating financial summary: {}", e.getMessage(), e);
        }
        return map;
    }

    public Long createInvoice(Long studentId, Long feeStructureId, BigDecimal amount, java.sql.Date dueDate) {
        String countSql = "SELECT COUNT(id) + 1 FROM invoices";
        String insertSql = """
            INSERT INTO invoices (invoice_number, student_id, fee_structure_id, amount, paid_amount, due_date, late_fee, status)
            VALUES (?, ?, ?, ?, 0.00, ?, 0.00, 'PENDING')
            RETURNING id
        """;

        try (Connection conn = DatabaseConfig.getConnection()) {
            long seq = System.currentTimeMillis() % 100000;
            try (PreparedStatement psCount = conn.prepareStatement(countSql);
                 ResultSet rs = psCount.executeQuery()) {
                if (rs.next()) seq = rs.getLong(1);
            }

            String invNo = "INV-" + Calendar.getInstance().get(Calendar.YEAR) + "-" + String.format("%05d", seq);

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, invNo);
                ps.setLong(2, studentId);
                if (feeStructureId != null) ps.setLong(3, feeStructureId); else ps.setNull(3, Types.BIGINT);
                ps.setBigDecimal(4, amount);
                ps.setDate(5, dueDate);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        } catch (SQLException e) {
            logger.error("Error creating invoice: {}", e.getMessage(), e);
        }
        return null;
    }

    private Invoice mapInvoice(ResultSet rs) throws SQLException {
        Invoice inv = new Invoice();
        inv.setId(rs.getLong("id"));
        inv.setInvoiceNumber(rs.getString("invoice_number"));
        inv.setStudentId(rs.getLong("student_id"));
        inv.setFeeStructureId(rs.getLong("fee_structure_id"));
        inv.setAmount(rs.getBigDecimal("amount"));
        inv.setPaidAmount(rs.getBigDecimal("paid_amount"));
        inv.setDueDate(rs.getDate("due_date"));
        inv.setLateFee(rs.getBigDecimal("late_fee"));
        inv.setStatus(rs.getString("status"));
        inv.setCreatedAt(rs.getTimestamp("created_at"));

        inv.setStudentName(rs.getString("first_name") + " " + rs.getString("last_name"));
        inv.setRollNumber(rs.getString("roll_number"));
        inv.setFeeCategory(rs.getString("fee_category"));
        inv.setHostelName(rs.getString("hostel_name"));
        inv.setRoomNumber(rs.getString("room_number"));
        return inv;
    }
}
