package com.hostelease.dao;

import com.hostelease.config.DatabaseConfig;
import com.hostelease.model.Notice;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NoticeDAO {

    private static final Logger logger = LoggerFactory.getLogger(NoticeDAO.class);

    public List<Notice> findAll(Long hostelId, String targetRole) {
        List<Notice> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT n.id, n.title, n.content, n.hostel_id, n.target_role, 
                   n.is_urgent, n.published_by_user_id, n.expires_at, n.created_at,
                   h.name AS hostel_name,
                   u.first_name, u.last_name
            FROM notices n
            LEFT JOIN hostels h ON n.hostel_id = h.id
            LEFT JOIN users u ON n.published_by_user_id = u.id
            WHERE (n.expires_at IS NULL OR n.expires_at >= CURRENT_DATE)
        """);

        if (hostelId != null && hostelId > 0) {
            sql.append(" AND (n.hostel_id IS NULL OR n.hostel_id = ").append(hostelId).append(") ");
        }

        if (targetRole != null && !targetRole.trim().isEmpty() && !"ALL".equalsIgnoreCase(targetRole)) {
            sql.append(" AND (n.target_role = 'ALL' OR n.target_role = '").append(targetRole.trim().toUpperCase()).append("') ");
        }

        sql.append(" ORDER BY n.is_urgent DESC, n.created_at DESC");

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString());
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Notice n = new Notice();
                n.setId(rs.getLong("id"));
                n.setTitle(rs.getString("title"));
                n.setContent(rs.getString("content"));
                n.setHostelId(rs.getLong("hostel_id"));
                n.setHostelName(rs.getString("hostel_name"));
                n.setTargetRole(rs.getString("target_role"));
                n.setUrgent(rs.getBoolean("is_urgent"));
                n.setExpiresAt(rs.getDate("expires_at"));
                n.setCreatedAt(rs.getTimestamp("created_at"));

                String first = rs.getString("first_name");
                if (first != null) {
                    n.setPublishedByName(first + " " + rs.getString("last_name"));
                } else {
                    n.setPublishedByName("Administration");
                }
                list.add(n);
            }
        } catch (SQLException e) {
            logger.error("Error finding notices: {}", e.getMessage(), e);
        }
        return list;
    }

    public boolean create(Notice n) {
        String sql = """
            INSERT INTO notices (title, content, hostel_id, target_role, is_urgent, published_by_user_id, expires_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """;
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, n.getTitle());
            ps.setString(2, n.getContent());
            if (n.getHostelId() != null && n.getHostelId() > 0) ps.setLong(3, n.getHostelId()); else ps.setNull(3, Types.BIGINT);
            ps.setString(4, n.getTargetRole() != null ? n.getTargetRole() : "ALL");
            ps.setBoolean(5, n.isUrgent());
            if (n.getPublishedByUserId() != null) ps.setLong(6, n.getPublishedByUserId()); else ps.setNull(6, Types.BIGINT);
            ps.setDate(7, n.getExpiresAt());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error creating notice: {}", e.getMessage(), e);
            return false;
        }
    }
}
