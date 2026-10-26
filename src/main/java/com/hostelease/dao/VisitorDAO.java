package com.hostelease.dao;

import com.hostelease.config.DatabaseConfig;
import com.hostelease.model.VisitorLog;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VisitorDAO {

    private static final Logger logger = LoggerFactory.getLogger(VisitorDAO.class);

    private static final String BASE_SELECT = """
        SELECT vl.id, vl.visitor_id, vl.student_id, vl.hostel_id, vl.purpose, 
               vl.entry_datetime, vl.exit_datetime, vl.recorded_by_user_id, vl.status,
               v.visitor_name, v.contact_number, v.government_id_type, v.government_id_number,
               u.first_name, u.last_name, s.roll_number,
               h.name AS hostel_name, rm.room_number,
               stf.first_name AS staff_first, stf.last_name AS staff_last
        FROM visitor_logs vl
        JOIN visitors v ON vl.visitor_id = v.id
        JOIN students s ON vl.student_id = s.id
        JOIN users u ON s.user_id = u.id
        JOIN hostels h ON vl.hostel_id = h.id
        LEFT JOIN room_allocations ra ON s.id = ra.student_id AND ra.is_active = TRUE
        LEFT JOIN beds bd ON ra.bed_id = bd.id
        LEFT JOIN rooms rm ON bd.room_id = rm.id
        LEFT JOIN users stf ON vl.recorded_by_user_id = stf.id
    """;

    public boolean recordEntry(String visitorName, String contactNumber, String idType, String idNo,
                               Long studentId, Long hostelId, String purpose, Long recordedByUserId) {
        String insertVisitor = """
            INSERT INTO visitors (visitor_name, contact_number, government_id_type, government_id_number)
            VALUES (?, ?, ?, ?) RETURNING id
        """;
        String insertLog = """
            INSERT INTO visitor_logs (visitor_id, student_id, hostel_id, purpose, recorded_by_user_id, status)
            VALUES (?, ?, ?, ?, ?, 'IN_HOSTEL')
        """;

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            long visitorId;
            try (PreparedStatement ps = conn.prepareStatement(insertVisitor)) {
                ps.setString(1, visitorName);
                ps.setString(2, contactNumber);
                ps.setString(3, idType);
                ps.setString(4, idNo);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        visitorId = rs.getLong(1);
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(insertLog)) {
                ps.setLong(1, visitorId);
                ps.setLong(2, studentId);
                ps.setLong(3, hostelId);
                ps.setString(4, purpose);
                if (recordedByUserId != null) ps.setLong(5, recordedByUserId); else ps.setNull(5, Types.BIGINT);
                ps.executeUpdate();
            }

            conn.commit();
            logger.info("Recorded visitor entry for {} visiting student {}", visitorName, studentId);
            return true;
        } catch (SQLException e) {
            logger.error("Error recording visitor entry: {}", e.getMessage(), e);
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

    public boolean recordExit(Long logId) {
        String sql = "UPDATE visitor_logs SET status = 'EXITED', exit_datetime = CURRENT_TIMESTAMP WHERE id = ? AND status = 'IN_HOSTEL'";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, logId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error recording visitor exit: {}", e.getMessage(), e);
            return false;
        }
    }

    public List<VisitorLog> findAll(Long hostelId, String status) {
        List<VisitorLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT).append(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (hostelId != null && hostelId > 0) {
            sql.append(" AND vl.hostel_id = ? ");
            params.add(hostelId);
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND vl.status = ? ");
            params.add(status.trim().toUpperCase());
        }

        sql.append(" ORDER BY vl.entry_datetime DESC");

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapVisitor(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding visitors: {}", e.getMessage(), e);
        }
        return list;
    }

    private VisitorLog mapVisitor(ResultSet rs) throws SQLException {
        VisitorLog vl = new VisitorLog();
        vl.setId(rs.getLong("id"));
        vl.setVisitorId(rs.getLong("visitor_id"));
        vl.setStudentId(rs.getLong("student_id"));
        vl.setHostelId(rs.getLong("hostel_id"));
        vl.setPurpose(rs.getString("purpose"));
        vl.setEntryDatetime(rs.getTimestamp("entry_datetime"));
        vl.setExitDatetime(rs.getTimestamp("exit_datetime"));
        vl.setStatus(rs.getString("status"));

        vl.setVisitorName(rs.getString("visitor_name"));
        vl.setContactNumber(rs.getString("contact_number"));
        vl.setGovernmentIdType(rs.getString("government_id_type"));
        vl.setGovernmentIdNumber(rs.getString("government_id_number"));

        vl.setStudentName(rs.getString("first_name") + " " + rs.getString("last_name"));
        vl.setRollNumber(rs.getString("roll_number"));
        vl.setHostelName(rs.getString("hostel_name"));
        vl.setRoomNumber(rs.getString("room_number"));

        String staffFirst = rs.getString("staff_first");
        if (staffFirst != null) {
            vl.setRecordedByName(staffFirst + " " + rs.getString("staff_last"));
        }
        return vl;
    }
}
