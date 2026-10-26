package com.hostelease.dao;

import com.hostelease.config.DatabaseConfig;
import com.hostelease.model.Student;
import com.hostelease.model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StudentDAO {

    private static final Logger logger = LoggerFactory.getLogger(StudentDAO.class);

    private static final String BASE_SELECT = """
        SELECT s.id, s.user_id, s.roll_number, s.registration_no, s.course, s.batch_year, 
               s.gender, s.dob, s.blood_group, s.guardian_name, s.guardian_phone, 
               s.guardian_email, s.permanent_address, s.current_presence, s.created_at,
               u.first_name, u.last_name, u.email, u.phone_number,
               ra.bed_id AS allocated_bed_id, bd.bed_label AS allocated_bed_label,
               rm.room_number AS allocated_room_number,
               h.id AS allocated_hostel_id, h.name AS allocated_hostel_name
        FROM students s
        JOIN users u ON s.user_id = u.id
        LEFT JOIN room_allocations ra ON s.id = ra.student_id AND ra.is_active = TRUE
        LEFT JOIN beds bd ON ra.bed_id = bd.id
        LEFT JOIN rooms rm ON bd.room_id = rm.id
        LEFT JOIN hostel_floors f ON rm.floor_id = f.id
        LEFT JOIN hostel_buildings b ON f.building_id = b.id
        LEFT JOIN hostels h ON b.hostel_id = h.id
    """;

    public Student findByUserId(Long userId) {
        String sql = BASE_SELECT + " WHERE s.user_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapStudent(rs);
            }
        } catch (SQLException e) {
            logger.error("Error finding student by userId: {}", e.getMessage(), e);
        }
        return null;
    }

    public Student findById(Long studentId) {
        String sql = BASE_SELECT + " WHERE s.id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapStudent(rs);
            }
        } catch (SQLException e) {
            logger.error("Error finding student by id: {}", e.getMessage(), e);
        }
        return null;
    }

    public List<Student> findAll(String search, Long hostelId, String presence) {
        List<Student> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT).append(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (hostelId != null && hostelId > 0) {
            sql.append(" AND h.id = ? ");
            params.add(hostelId);
        }

        if (presence != null && !presence.trim().isEmpty() && !"ALL".equalsIgnoreCase(presence)) {
            sql.append(" AND s.current_presence = ? ");
            params.add(presence.trim().toUpperCase());
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(s.roll_number) LIKE ? OR LOWER(u.first_name) LIKE ? OR LOWER(u.last_name) LIKE ? OR LOWER(u.email) LIKE ?) ");
            String pattern = "%" + search.trim().toLowerCase() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }

        sql.append(" ORDER BY s.id ASC");

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapStudent(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error searching students: {}", e.getMessage(), e);
        }
        return list;
    }

    public List<Student> getUnallocatedStudents() {
        List<Student> list = new ArrayList<>();
        String sql = BASE_SELECT + " WHERE ra.id IS NULL ORDER BY s.roll_number ASC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapStudent(rs));
            }
        } catch (SQLException e) {
            logger.error("Error fetching unallocated students: {}", e.getMessage(), e);
        }
        return list;
    }

    public boolean updatePresence(Long studentId, String presence, Connection conn) throws SQLException {
        String sql = "UPDATE students SET current_presence = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        boolean closeConn = false;
        if (conn == null) {
            conn = DatabaseConfig.getConnection();
            closeConn = true;
        }

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, presence);
            ps.setLong(2, studentId);
            return ps.executeUpdate() > 0;
        } finally {
            if (closeConn) {
                conn.close();
            }
        }
    }

    public boolean createStudent(User user, Student student) {
        String userSql = "INSERT INTO users (username, email, phone_number, password_hash, first_name, last_name, is_active) VALUES (?, ?, ?, ?, ?, ?, TRUE) RETURNING id";
        String roleSql = "INSERT INTO user_roles (user_id, role_id) VALUES (?, 3)";
        String studentSql = """
            INSERT INTO students (user_id, roll_number, registration_no, course, batch_year, gender, dob, blood_group, guardian_name, guardian_phone, guardian_email, permanent_address, current_presence)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PRESENT')
        """;

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            long userId;
            try (PreparedStatement ps = conn.prepareStatement(userSql)) {
                ps.setString(1, user.getUsername());
                ps.setString(2, user.getEmail());
                ps.setString(3, user.getPhoneNumber());
                ps.setString(4, user.getPasswordHash());
                ps.setString(5, user.getFirstName());
                ps.setString(6, user.getLastName());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        userId = rs.getLong(1);
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(roleSql)) {
                ps.setLong(1, userId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(studentSql)) {
                ps.setLong(1, userId);
                ps.setString(2, student.getRollNumber());
                ps.setString(3, student.getRegistrationNo());
                ps.setString(4, student.getCourse());
                ps.setInt(5, student.getBatchYear());
                ps.setString(6, student.getGender());
                ps.setDate(7, student.getDob());
                ps.setString(8, student.getBloodGroup());
                ps.setString(9, student.getGuardianName());
                ps.setString(10, student.getGuardianPhone());
                ps.setString(11, student.getGuardianEmail());
                ps.setString(12, student.getPermanentAddress());
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            logger.error("Transaction failed creating student: {}", e.getMessage(), e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { logger.error("Rollback error: {}", ex.getMessage()); }
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    public boolean updateStudent(Long studentId, String phone, String course, int batchYear, String guardianName, String guardianPhone, String guardianEmail, String address) {
        String fetchUserSql = "SELECT user_id FROM students WHERE id = ?";
        String updateStudentSql = """
            UPDATE students 
            SET course = ?, batch_year = ?, guardian_name = ?, guardian_phone = ?, guardian_email = ?, permanent_address = ?
            WHERE id = ?
        """;
        String updateUserSql = "UPDATE users SET phone_number = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            long userId;
            try (PreparedStatement ps = conn.prepareStatement(fetchUserSql)) {
                ps.setLong(1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    userId = rs.getLong("user_id");
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateStudentSql)) {
                ps.setString(1, course);
                ps.setInt(2, batchYear);
                ps.setString(3, guardianName);
                ps.setString(4, guardianPhone);
                ps.setString(5, guardianEmail);
                ps.setString(6, address);
                ps.setLong(7, studentId);
                ps.executeUpdate();
            }

            if (phone != null && !phone.trim().isEmpty()) {
                try (PreparedStatement ps = conn.prepareStatement(updateUserSql)) {
                    ps.setString(1, phone.trim());
                    ps.setLong(2, userId);
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            logger.error("Error updating student {}: {}", studentId, e.getMessage(), e);
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

    public boolean updateStudentContacts(Long userId, String phone, String guardianPhone, String guardianEmail, String address) {
        String updateStudentSql = """
            UPDATE students 
            SET guardian_phone = ?, guardian_email = ?, permanent_address = ?
            WHERE user_id = ?
        """;
        String updateUserSql = "UPDATE users SET phone_number = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(updateStudentSql)) {
                ps.setString(1, guardianPhone);
                ps.setString(2, guardianEmail);
                ps.setString(3, address);
                ps.setLong(4, userId);
                ps.executeUpdate();
            }

            if (phone != null && !phone.trim().isEmpty()) {
                try (PreparedStatement ps = conn.prepareStatement(updateUserSql)) {
                    ps.setString(1, phone.trim());
                    ps.setLong(2, userId);
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            logger.error("Error updating student contacts for user {}: {}", userId, e.getMessage(), e);
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

    private Student mapStudent(ResultSet rs) throws SQLException {
        Student s = new Student();
        s.setId(rs.getLong("id"));
        s.setUserId(rs.getLong("user_id"));
        s.setRollNumber(rs.getString("roll_number"));
        s.setRegistrationNo(rs.getString("registration_no"));
        s.setCourse(rs.getString("course"));
        s.setBatchYear(rs.getInt("batch_year"));
        s.setGender(rs.getString("gender"));
        s.setDob(rs.getDate("dob"));
        s.setBloodGroup(rs.getString("blood_group"));
        s.setGuardianName(rs.getString("guardian_name"));
        s.setGuardianPhone(rs.getString("guardian_phone"));
        s.setGuardianEmail(rs.getString("guardian_email"));
        s.setPermanentAddress(rs.getString("permanent_address"));
        s.setCurrentPresence(rs.getString("current_presence"));
        s.setCreatedAt(rs.getTimestamp("created_at"));

        s.setFirstName(rs.getString("first_name"));
        s.setLastName(rs.getString("last_name"));
        s.setEmail(rs.getString("email"));
        s.setPhoneNumber(rs.getString("phone_number"));

        long bedId = rs.getLong("allocated_bed_id");
        if (!rs.wasNull()) {
            s.setAllocatedBedId(bedId);
            s.setAllocatedBedLabel(rs.getString("allocated_bed_label"));
            s.setAllocatedRoomNumber(rs.getString("allocated_room_number"));
            s.setAllocatedHostelId(rs.getLong("allocated_hostel_id"));
            s.setAllocatedHostelName(rs.getString("allocated_hostel_name"));
        }
        return s;
    }
}
