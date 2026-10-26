package com.hostelease.dao;

import com.hostelease.config.DatabaseConfig;
import com.hostelease.model.LeaveRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LeaveDAO {

    private static final Logger logger = LoggerFactory.getLogger(LeaveDAO.class);

    private static final String BASE_SELECT = """
        SELECT lr.id, lr.student_id, lr.leave_type, lr.reason, 
               lr.departure_datetime, lr.expected_return_datetime, 
               lr.actual_departure_datetime, lr.actual_return_datetime, 
               lr.emergency_contact, lr.destination_address, 
               lr.status, lr.reviewed_by_user_id, lr.review_remarks, 
               lr.created_at, lr.updated_at,
               u.first_name, u.last_name, s.roll_number, u.phone_number AS student_phone, s.guardian_phone,
               h.id AS hostel_id, h.name AS hostel_name, rm.room_number, bd.bed_label,
               rev.first_name AS rev_first_name, rev.last_name AS rev_last_name
        FROM student_leave_requests lr
        JOIN students s ON lr.student_id = s.id
        JOIN users u ON s.user_id = u.id
        LEFT JOIN room_allocations ra ON s.id = ra.student_id AND ra.is_active = TRUE
        LEFT JOIN beds bd ON ra.bed_id = bd.id
        LEFT JOIN rooms rm ON bd.room_id = rm.id
        LEFT JOIN hostel_floors f ON rm.floor_id = f.id
        LEFT JOIN hostel_buildings b ON f.building_id = b.id
        LEFT JOIN hostels h ON b.hostel_id = h.id
        LEFT JOIN users rev ON lr.reviewed_by_user_id = rev.id
    """;

    public boolean create(LeaveRequest req) {
        String sql = """
            INSERT INTO student_leave_requests (student_id, leave_type, reason, departure_datetime, expected_return_datetime, emergency_contact, destination_address, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING')
        """;

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, req.getStudentId());
            ps.setString(2, req.getLeaveType());
            ps.setString(3, req.getReason());
            ps.setTimestamp(4, req.getDepartureDatetime());
            ps.setTimestamp(5, req.getExpectedReturnDatetime());
            ps.setString(6, req.getEmergencyContact());
            ps.setString(7, req.getDestinationAddress());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        req.setId(rs.getLong(1));
                    }
                }
                logger.info("Created leave request for student ID {}", req.getStudentId());
                return true;
            }
        } catch (SQLException e) {
            logger.error("Error creating leave request: {}", e.getMessage(), e);
        }
        return false;
    }

    public LeaveRequest findById(Long leaveId) {
        String sql = BASE_SELECT + " WHERE lr.id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, leaveId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapLeave(rs);
            }
        } catch (SQLException e) {
            logger.error("Error finding leave by id: {}", e.getMessage(), e);
        }
        return null;
    }

    public List<LeaveRequest> findAll(Long hostelId, String status, String leaveType) {
        List<LeaveRequest> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT).append(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (hostelId != null && hostelId > 0) {
            sql.append(" AND h.id = ? ");
            params.add(hostelId);
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND lr.status = ? ");
            params.add(status.trim().toUpperCase());
        }
        if (leaveType != null && !leaveType.trim().isEmpty() && !"ALL".equalsIgnoreCase(leaveType)) {
            sql.append(" AND lr.leave_type = ? ");
            params.add(leaveType.trim().toUpperCase());
        }

        sql.append(" ORDER BY lr.created_at DESC");

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapLeave(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding leave requests: {}", e.getMessage(), e);
        }
        return list;
    }

    public List<LeaveRequest> findByStudentId(Long studentId) {
        List<LeaveRequest> list = new ArrayList<>();
        String sql = BASE_SELECT + " WHERE lr.student_id = ? ORDER BY lr.created_at DESC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapLeave(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding leave requests by student: {}", e.getMessage(), e);
        }
        return list;
    }

    public boolean approveLeave(Long leaveId, Long wardenUserId, String remarks) {
        String updateLeave = """
            UPDATE student_leave_requests 
            SET status = 'APPROVED', reviewed_by_user_id = ?, review_remarks = ?, updated_at = CURRENT_TIMESTAMP
            WHERE id = ? AND status = 'PENDING'
        """;
        String updatePresence = """
            UPDATE students 
            SET current_presence = 'EXPECTED_TO_LEAVE', updated_at = CURRENT_TIMESTAMP
            WHERE id = (SELECT student_id FROM student_leave_requests WHERE id = ?)
        """;
        String logHistory = "INSERT INTO leave_history (leave_request_id, previous_status, new_status, changed_by_user_id, change_reason) VALUES (?, 'PENDING', 'APPROVED', ?, ?)";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(updateLeave)) {
                ps.setLong(1, wardenUserId);
                ps.setString(2, remarks);
                ps.setLong(3, leaveId);
                if (ps.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updatePresence)) {
                ps.setLong(1, leaveId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(logHistory)) {
                ps.setLong(1, leaveId);
                ps.setLong(2, wardenUserId);
                ps.setString(3, remarks);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            logger.error("Transaction failed during leave approval: {}", e.getMessage(), e);
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

    public boolean rejectLeave(Long leaveId, Long wardenUserId, String remarks) {
        String updateLeave = """
            UPDATE student_leave_requests 
            SET status = 'REJECTED', reviewed_by_user_id = ?, review_remarks = ?, updated_at = CURRENT_TIMESTAMP
            WHERE id = ? AND status = 'PENDING'
        """;
        String logHistory = "INSERT INTO leave_history (leave_request_id, previous_status, new_status, changed_by_user_id, change_reason) VALUES (?, 'PENDING', 'REJECTED', ?, ?)";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(updateLeave)) {
                ps.setLong(1, wardenUserId);
                ps.setString(2, remarks);
                ps.setLong(3, leaveId);
                if (ps.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(logHistory)) {
                ps.setLong(1, leaveId);
                ps.setLong(2, wardenUserId);
                ps.setString(3, remarks);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            logger.error("Transaction failed during leave rejection: {}", e.getMessage(), e);
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

    /**
     * Records student departure (Gate check-out).
     * Transitions student presence to 'AWAY'.
     * Room allocation remains active! Bed is now marked as Temporarily Vacant.
     */
    public boolean recordDeparture(Long leaveId, Long wardenUserId) {
        String updateLeave = """
            UPDATE student_leave_requests 
            SET status = 'DEPARTED', actual_departure_datetime = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
            WHERE id = ? AND status = 'APPROVED'
        """;
        String updatePresence = """
            UPDATE students 
            SET current_presence = 'AWAY', updated_at = CURRENT_TIMESTAMP
            WHERE id = (SELECT student_id FROM student_leave_requests WHERE id = ?)
        """;
        String logHistory = "INSERT INTO leave_history (leave_request_id, previous_status, new_status, changed_by_user_id, change_reason) VALUES (?, 'APPROVED', 'DEPARTED', ?, 'Departure confirmed at gate checkpoint')";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(updateLeave)) {
                ps.setLong(1, leaveId);
                if (ps.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updatePresence)) {
                ps.setLong(1, leaveId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(logHistory)) {
                ps.setLong(1, leaveId);
                ps.setLong(2, wardenUserId);
                ps.executeUpdate();
            }

            conn.commit();
            logger.info("Recorded departure for leave ID {}. Student is now AWAY (temporary vacancy active).", leaveId);
            return true;
        } catch (SQLException e) {
            logger.error("Transaction failed during departure recording: {}", e.getMessage(), e);
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

    /**
     * Records student return (Gate check-in).
     * Transitions student presence to 'PRESENT'.
     * Room allocation is retained throughout! Temporary vacancy badge removed.
     */
    public boolean recordReturn(Long leaveId, Long wardenUserId) {
        String updateLeave = """
            UPDATE student_leave_requests 
            SET status = 'RETURNED', actual_return_datetime = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
            WHERE id = ? AND status IN ('DEPARTED', 'OVERDUE')
        """;
        String updatePresence = """
            UPDATE students 
            SET current_presence = 'PRESENT', updated_at = CURRENT_TIMESTAMP
            WHERE id = (SELECT student_id FROM student_leave_requests WHERE id = ?)
        """;
        String logHistory = "INSERT INTO leave_history (leave_request_id, previous_status, new_status, changed_by_user_id, change_reason) VALUES (?, 'DEPARTED', 'RETURNED', ?, 'Student returned safely to hostel')";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(updateLeave)) {
                ps.setLong(1, leaveId);
                if (ps.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updatePresence)) {
                ps.setLong(1, leaveId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(logHistory)) {
                ps.setLong(1, leaveId);
                ps.setLong(2, wardenUserId);
                ps.executeUpdate();
            }

            conn.commit();
            logger.info("Recorded return for leave ID {}. Student is now PRESENT.", leaveId);
            return true;
        } catch (SQLException e) {
            logger.error("Transaction failed during return recording: {}", e.getMessage(), e);
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

    /**
     * Background reconciliation job identifying students whose expected return time has passed.
     * Flags leave request as 'OVERDUE' and student presence as 'RETURN_OVERDUE'.
     * Preserves bed allocation!
     */
    public int reconcileOverdueLeaves() {
        String findSql = """
            SELECT lr.id, lr.student_id 
            FROM student_leave_requests lr 
            WHERE lr.status = 'DEPARTED' AND lr.expected_return_datetime < CURRENT_TIMESTAMP
        """;
        String updateLeaveSql = "UPDATE student_leave_requests SET status = 'OVERDUE', updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        String updateStudentSql = "UPDATE students SET current_presence = 'RETURN_OVERDUE', updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        String logHistory = "INSERT INTO leave_history (leave_request_id, previous_status, new_status, change_reason) VALUES (?, 'DEPARTED', 'OVERDUE', 'Expected return window expired')";

        int count = 0;
        try (Connection conn = DatabaseConfig.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psFind = conn.prepareStatement(findSql);
                 ResultSet rs = psFind.executeQuery()) {
                while (rs.next()) {
                    long leaveId = rs.getLong("id");
                    long studentId = rs.getLong("student_id");

                    try (PreparedStatement ps1 = conn.prepareStatement(updateLeaveSql);
                         PreparedStatement ps2 = conn.prepareStatement(updateStudentSql);
                         PreparedStatement ps3 = conn.prepareStatement(logHistory)) {
                        ps1.setLong(1, leaveId);
                        ps1.executeUpdate();

                        ps2.setLong(1, studentId);
                        ps2.executeUpdate();

                        ps3.setLong(1, leaveId);
                        ps3.executeUpdate();

                        count++;
                    }
                }
            }
            conn.commit();
            if (count > 0) {
                logger.warn("Reconciled {} overdue returns", count);
            }
        } catch (SQLException e) {
            logger.error("Error during overdue leave reconciliation: {}", e.getMessage(), e);
        }
        return count;
    }

    private LeaveRequest mapLeave(ResultSet rs) throws SQLException {
        LeaveRequest lr = new LeaveRequest();
        lr.setId(rs.getLong("id"));
        lr.setStudentId(rs.getLong("student_id"));
        lr.setLeaveType(rs.getString("leave_type"));
        lr.setReason(rs.getString("reason"));
        lr.setDepartureDatetime(rs.getTimestamp("departure_datetime"));
        lr.setExpectedReturnDatetime(rs.getTimestamp("expected_return_datetime"));
        lr.setActualDepartureDatetime(rs.getTimestamp("actual_departure_datetime"));
        lr.setActualReturnDatetime(rs.getTimestamp("actual_return_datetime"));
        lr.setEmergencyContact(rs.getString("emergency_contact"));
        lr.setDestinationAddress(rs.getString("destination_address"));
        lr.setStatus(rs.getString("status"));
        lr.setReviewedByUserId(rs.getLong("reviewed_by_user_id"));
        lr.setReviewRemarks(rs.getString("review_remarks"));
        lr.setCreatedAt(rs.getTimestamp("created_at"));
        lr.setUpdatedAt(rs.getTimestamp("updated_at"));

        lr.setStudentName(rs.getString("first_name") + " " + rs.getString("last_name"));
        lr.setRollNumber(rs.getString("roll_number"));
        lr.setStudentPhone(rs.getString("student_phone"));
        lr.setGuardianPhone(rs.getString("guardian_phone"));
        lr.setHostelId(rs.getLong("hostel_id"));
        lr.setHostelName(rs.getString("hostel_name"));
        lr.setRoomNumber(rs.getString("room_number"));
        lr.setBedLabel(rs.getString("bed_label"));

        String revFirst = rs.getString("rev_first_name");
        if (revFirst != null) {
            lr.setReviewerName(revFirst + " " + rs.getString("rev_last_name"));
        }
        return lr;
    }
}
