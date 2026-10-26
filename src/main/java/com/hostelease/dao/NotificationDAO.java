package com.hostelease.dao;

import com.hostelease.config.DatabaseConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NotificationDAO {

    private static final Logger logger = LoggerFactory.getLogger(NotificationDAO.class);

    public boolean enqueue(String idempotencyKey, String email, String phone, String channel, 
                           String notificationType, String subject, String messageContent) {
        String sql = """
            INSERT INTO notification_queue (idempotency_key, recipient_email, recipient_phone, channel, notification_type, subject, message_content, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING')
            ON CONFLICT (idempotency_key) DO NOTHING
        """;

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, idempotencyKey);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, channel);
            ps.setString(5, notificationType);
            ps.setString(6, subject);
            ps.setString(7, messageContent);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error enqueuing notification: {}", e.getMessage(), e);
            return false;
        }
    }

    public List<Map<String, Object>> pollPending(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = """
            SELECT id, idempotency_key, recipient_email, recipient_phone, channel, 
                   notification_type, subject, message_content, retry_count, max_retries
            FROM notification_queue
            WHERE status IN ('PENDING', 'RETRY_SCHEDULED')
              AND scheduled_for <= CURRENT_TIMESTAMP
            ORDER BY id ASC
            LIMIT ?
        """;

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getLong("id"));
                    map.put("key", rs.getString("idempotency_key"));
                    map.put("email", rs.getString("recipient_email"));
                    map.put("phone", rs.getString("recipient_phone"));
                    map.put("channel", rs.getString("channel"));
                    map.put("type", rs.getString("notification_type"));
                    map.put("subject", rs.getString("subject"));
                    map.put("message", rs.getString("message_content"));
                    map.put("retryCount", rs.getInt("retry_count"));
                    map.put("maxRetries", rs.getInt("max_retries"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            logger.error("Error polling notification queue: {}", e.getMessage(), e);
        }
        return list;
    }

    public void updateStatus(Long queueId, String status, int retryCount) {
        String sql = "UPDATE notification_queue SET status = ?, retry_count = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, retryCount);
            ps.setLong(3, queueId);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.error("Error updating notification status: {}", e.getMessage(), e);
        }
    }

    public void logDelivery(Long queueId, String recipient, String channel, String type, String status, String response) {
        String sql = """
            INSERT INTO notification_logs (queue_id, recipient, channel, notification_type, delivery_status, provider_response)
            VALUES (?, ?, ?, ?, ?, ?)
        """;
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (queueId != null) ps.setLong(1, queueId); else ps.setNull(1, Types.BIGINT);
            ps.setString(2, recipient != null ? recipient : "UNKNOWN");
            ps.setString(3, channel);
            ps.setString(4, type);
            ps.setString(5, status);
            ps.setString(6, response);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.error("Error logging notification delivery: {}", e.getMessage(), e);
        }
    }

    public List<Map<String, Object>> getRecentLogs(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, recipient, channel, notification_type, delivery_status, provider_response, attempted_at FROM notification_logs ORDER BY attempted_at DESC LIMIT ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getLong("id"));
                    map.put("recipient", rs.getString("recipient"));
                    map.put("channel", rs.getString("channel"));
                    map.put("type", rs.getString("notification_type"));
                    map.put("status", rs.getString("delivery_status"));
                    map.put("response", rs.getString("provider_response"));
                    map.put("attemptedAt", rs.getTimestamp("attempted_at"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            logger.error("Error getting recent notification logs: {}", e.getMessage(), e);
        }
        return list;
    }
}
