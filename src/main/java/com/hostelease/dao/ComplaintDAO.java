package com.hostelease.dao;

import com.hostelease.config.DatabaseConfig;
import com.hostelease.model.Complaint;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

public class ComplaintDAO {

    private static final Logger logger = LoggerFactory.getLogger(ComplaintDAO.class);

    private static final String BASE_SELECT = """
        SELECT c.id, c.complaint_code, c.student_id, c.hostel_id, c.room_id, 
               c.category, c.priority, c.subject, c.description, c.attachment_path, 
               c.status, c.assigned_staff_id, c.created_at, c.updated_at,
               u.first_name, u.last_name, s.roll_number,
               h.name AS hostel_name, rm.room_number,
               stf_u.first_name AS staff_first, stf_u.last_name AS staff_last
        FROM complaints c
        JOIN students s ON c.student_id = s.id
        JOIN users u ON s.user_id = u.id
        JOIN hostels h ON c.hostel_id = h.id
        LEFT JOIN rooms rm ON c.room_id = rm.id
        LEFT JOIN staff stf ON c.assigned_staff_id = stf.id
        LEFT JOIN users stf_u ON stf.user_id = stf_u.id
    """;

    public boolean create(Complaint c) {
        String insertSql = """
            INSERT INTO complaints (complaint_code, student_id, hostel_id, room_id, category, priority, subject, description, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'OPEN') RETURNING id
        """;
        String logHist = "INSERT INTO complaint_status_history (complaint_id, previous_status, new_status, remarks) VALUES (?, NULL, 'OPEN', 'Ticket registered by resident')";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            String code = "CMP-" + Calendar.getInstance().get(Calendar.YEAR) + "-" + System.currentTimeMillis() % 100000;
            c.setComplaintCode(code);

            long compId;
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, code);
                ps.setLong(2, c.getStudentId());
                ps.setLong(3, c.getHostelId());
                if (c.getRoomId() != null) ps.setLong(4, c.getRoomId()); else ps.setNull(4, Types.BIGINT);
                ps.setString(5, c.getCategory());
                ps.setString(6, c.getPriority());
                ps.setString(7, c.getSubject());
                ps.setString(8, c.getDescription());

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        compId = rs.getLong(1);
                        c.setId(compId);
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(logHist)) {
                ps.setLong(1, compId);
                ps.executeUpdate();
            }

            conn.commit();
            logger.info("Created complaint {} for student {}", code, c.getStudentId());
            return true;
        } catch (SQLException e) {
            logger.error("Error creating complaint: {}", e.getMessage(), e);
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

    public Complaint findById(Long id) {
        String sql = BASE_SELECT + " WHERE c.id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapComplaint(rs);
            }
        } catch (SQLException e) {
            logger.error("Error finding complaint by id: {}", e.getMessage(), e);
        }
        return null;
    }

    public List<Complaint> findAll(Long hostelId, String status, String category) {
        List<Complaint> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT).append(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (hostelId != null && hostelId > 0) {
            sql.append(" AND c.hostel_id = ? ");
            params.add(hostelId);
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND c.status = ? ");
            params.add(status.trim().toUpperCase());
        }
        if (category != null && !category.trim().isEmpty() && !"ALL".equalsIgnoreCase(category)) {
            sql.append(" AND c.category = ? ");
            params.add(category.trim().toUpperCase());
        }

        sql.append(" ORDER BY c.created_at DESC");

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapComplaint(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding complaints: {}", e.getMessage(), e);
        }
        return list;
    }

    public List<Complaint> findByStudentId(Long studentId) {
        List<Complaint> list = new ArrayList<>();
        String sql = BASE_SELECT + " WHERE c.student_id = ? ORDER BY c.created_at DESC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapComplaint(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding complaints by student: {}", e.getMessage(), e);
        }
        return list;
    }

    public boolean updateStatus(Long complaintId, String newStatus, Long staffId, String remarks, Long updatedByUserId) {
        String findOld = "SELECT status FROM complaints WHERE id = ? FOR UPDATE";
        String updateComp = "UPDATE complaints SET status = ?, assigned_staff_id = COALESCE(?, assigned_staff_id), updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        String logHist = "INSERT INTO complaint_status_history (complaint_id, previous_status, new_status, updated_by_user_id, remarks) VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            String prevStatus = "OPEN";
            try (PreparedStatement ps = conn.prepareStatement(findOld)) {
                ps.setLong(1, complaintId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        prevStatus = rs.getString("status");
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateComp)) {
                ps.setString(1, newStatus);
                if (staffId != null) ps.setLong(2, staffId); else ps.setNull(2, Types.BIGINT);
                ps.setLong(3, complaintId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(logHist)) {
                ps.setLong(1, complaintId);
                ps.setString(2, prevStatus);
                ps.setString(3, newStatus);
                if (updatedByUserId != null) ps.setLong(4, updatedByUserId); else ps.setNull(4, Types.BIGINT);
                ps.setString(5, remarks);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            logger.error("Error updating complaint status: {}", e.getMessage(), e);
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

    private Complaint mapComplaint(ResultSet rs) throws SQLException {
        Complaint c = new Complaint();
        c.setId(rs.getLong("id"));
        c.setComplaintCode(rs.getString("complaint_code"));
        c.setStudentId(rs.getLong("student_id"));
        c.setHostelId(rs.getLong("hostel_id"));
        c.setRoomId(rs.getLong("room_id"));
        c.setCategory(rs.getString("category"));
        c.setPriority(rs.getString("priority"));
        c.setSubject(rs.getString("subject"));
        c.setDescription(rs.getString("description"));
        c.setAttachmentPath(rs.getString("attachment_path"));
        c.setStatus(rs.getString("status"));
        c.setAssignedStaffId(rs.getLong("assigned_staff_id"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setUpdatedAt(rs.getTimestamp("updated_at"));

        c.setStudentName(rs.getString("first_name") + " " + rs.getString("last_name"));
        c.setRollNumber(rs.getString("roll_number"));
        c.setHostelName(rs.getString("hostel_name"));
        c.setRoomNumber(rs.getString("room_number"));

        String staffFirst = rs.getString("staff_first");
        if (staffFirst != null) {
            c.setAssignedStaffName(staffFirst + " " + rs.getString("staff_last"));
        }
        return c;
    }
}
