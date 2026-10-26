package com.hostelease.dao;

import com.hostelease.config.DatabaseConfig;
import com.hostelease.model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    private static final Logger logger = LoggerFactory.getLogger(UserDAO.class);

    public User findByUsername(String username) {
        String sql = """
            SELECT u.id, u.username, u.email, u.phone_number, u.password_hash, 
                   u.first_name, u.last_name, u.is_active, u.created_at,
                   r.role_name, s.assigned_hostel_id
            FROM users u
            JOIN user_roles ur ON u.id = ur.user_id
            JOIN roles r ON ur.role_id = r.id
            LEFT JOIN staff s ON u.id = s.user_id
            WHERE LOWER(u.username) = LOWER(?) OR LOWER(u.email) = LOWER(?)
            LIMIT 1
        """;

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding user by username/email: {}", e.getMessage(), e);
        }
        return null;
    }

    public User findById(Long id) {
        String sql = """
            SELECT u.id, u.username, u.email, u.phone_number, u.password_hash, 
                   u.first_name, u.last_name, u.is_active, u.created_at,
                   r.role_name, s.assigned_hostel_id
            FROM users u
            JOIN user_roles ur ON u.id = ur.user_id
            JOIN roles r ON ur.role_id = r.id
            LEFT JOIN staff s ON u.id = s.user_id
            WHERE u.id = ?
        """;

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding user by id: {}", e.getMessage(), e);
        }
        return null;
    }

    public List<User> findAllStaff() {
        List<User> list = new ArrayList<>();
        String sql = """
            SELECT u.id, u.username, u.email, u.phone_number, u.password_hash, 
                   u.first_name, u.last_name, u.is_active, u.created_at,
                   r.role_name, s.assigned_hostel_id
            FROM users u
            JOIN user_roles ur ON u.id = ur.user_id
            JOIN roles r ON ur.role_id = r.id
            JOIN staff s ON u.id = s.user_id
            ORDER BY u.id ASC
        """;

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (SQLException e) {
            logger.error("Error listing staff users: {}", e.getMessage(), e);
        }
        return list;
    }

    public boolean updatePassword(Long userId, String passwordHash) {
        String sql = "UPDATE users SET password_hash = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, passwordHash);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error updating password: {}", e.getMessage(), e);
            return false;
        }
    }

    public User findWardenByHostelId(Long hostelId) {
        String sql = """
            SELECT u.id, u.username, u.email, u.phone_number, u.password_hash, 
                   u.first_name, u.last_name, u.is_active, u.created_at,
                   r.role_name, s.assigned_hostel_id
            FROM users u
            JOIN user_roles ur ON u.id = ur.user_id
            JOIN roles r ON ur.role_id = r.id
            LEFT JOIN staff s ON u.id = s.user_id
            WHERE r.role_name = 'WARDEN'
              AND (s.assigned_hostel_id = ? OR s.assigned_hostel_id IS NULL)
            ORDER BY (CASE WHEN s.assigned_hostel_id = ? THEN 1 ELSE 2 END) ASC
            LIMIT 1
        """;

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, hostelId != null ? hostelId : 1L);
            ps.setObject(2, hostelId != null ? hostelId : 1L);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding warden for hostel {}: {}", hostelId, e.getMessage(), e);
        }
        return findByUsername("warden.boys");
    }

    public Long createUser(String username, String email, String phone, String passwordHash, String firstName, String lastName, String roleName) {
        String insertUserSql = """
            INSERT INTO users (username, email, phone_number, password_hash, first_name, last_name, is_active)
            VALUES (?, ?, ?, ?, ?, ?, TRUE)
            RETURNING id
        """;
        String insertRoleSql = """
            INSERT INTO user_roles (user_id, role_id)
            SELECT ?, id FROM roles WHERE role_name = ?
        """;

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            long userId;
            try (PreparedStatement ps = conn.prepareStatement(insertUserSql)) {
                ps.setString(1, username);
                ps.setString(2, email);
                ps.setString(3, phone);
                ps.setString(4, passwordHash);
                ps.setString(5, firstName);
                ps.setString(6, lastName);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        userId = rs.getLong(1);
                    } else {
                        conn.rollback();
                        return null;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(insertRoleSql)) {
                ps.setLong(1, userId);
                ps.setString(2, roleName);
                ps.executeUpdate();
            }

            conn.commit();
            return userId;
        } catch (SQLException e) {
            logger.error("Error creating user {}: {}", username, e.getMessage(), e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            return null;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    public boolean toggleUserStatus(Long userId, boolean active) {
        String sql = "UPDATE users SET is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error toggling user status for {}: {}", userId, e.getMessage(), e);
            return false;
        }
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getLong("id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPhoneNumber(rs.getString("phone_number"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFirstName(rs.getString("first_name"));
        u.setLastName(rs.getString("last_name"));
        u.setActive(rs.getBoolean("is_active"));
        u.setRole(rs.getString("role_name"));
        u.setCreatedAt(rs.getTimestamp("created_at"));

        long hostelId = rs.getLong("assigned_hostel_id");
        if (!rs.wasNull()) {
            u.setAssociatedHostelId(hostelId);
        }
        return u;
    }
}
