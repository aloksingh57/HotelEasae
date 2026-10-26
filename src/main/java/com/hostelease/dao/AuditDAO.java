package com.hostelease.dao;

import com.hostelease.config.DatabaseConfig;
import com.hostelease.model.AuditLog;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AuditDAO {

    private static final Logger logger = LoggerFactory.getLogger(AuditDAO.class);

    public void log(Long userId, String action, String entityName, String entityId, String ipAddress, String details) {
        String sql = """
            INSERT INTO audit_logs (user_id, action, entity_name, entity_id, ip_address, details)
            VALUES (?, ?, ?, ?, ?, ?)
        """;
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (userId != null) ps.setLong(1, userId); else ps.setNull(1, Types.BIGINT);
            ps.setString(2, action);
            ps.setString(3, entityName);
            ps.setString(4, entityId);
            ps.setString(5, ipAddress != null ? ipAddress : "127.0.0.1");
            ps.setString(6, details);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.error("Error creating audit log: {}", e.getMessage(), e);
        }
    }

    public List<AuditLog> findRecent(int limit) {
        List<AuditLog> list = new ArrayList<>();
        String sql = """
            SELECT a.id, a.user_id, a.action, a.entity_name, a.entity_id, a.ip_address, a.details, a.created_at,
                   u.username
            FROM audit_logs a
            LEFT JOIN users u ON a.user_id = u.id
            ORDER BY a.created_at DESC
            LIMIT ?
        """;
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = new AuditLog();
                    log.setId(rs.getLong("id"));
                    log.setUserId(rs.getLong("user_id"));
                    log.setUsername(rs.getString("username"));
                    log.setAction(rs.getString("action"));
                    log.setEntityName(rs.getString("entity_name"));
                    log.setEntityId(rs.getString("entity_id"));
                    log.setIpAddress(rs.getString("ip_address"));
                    log.setDetails(rs.getString("details"));
                    log.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(log);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding recent audit logs: {}", e.getMessage(), e);
        }
        return list;
    }
}
