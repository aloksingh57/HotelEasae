package com.hostelease.dao;

import com.hostelease.config.DatabaseConfig;
import com.hostelease.model.Hostel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HostelDAO {

    private static final Logger logger = LoggerFactory.getLogger(HostelDAO.class);

    public List<Hostel> findAll() {
        List<Hostel> list = new ArrayList<>();
        String sql = """
            SELECT h.id, h.name, h.code, h.type, h.address, h.contact_phone, 
                   h.contact_email, h.total_capacity, h.is_active, h.created_at,
                   COUNT(DISTINCT r.id) AS total_rooms,
                   COUNT(DISTINCT CASE WHEN bd.allocation_status = 'ALLOCATED' THEN bd.id END) AS current_occupancy
            FROM hostels h
            LEFT JOIN hostel_buildings b ON h.id = b.hostel_id
            LEFT JOIN hostel_floors f ON b.id = f.building_id
            LEFT JOIN rooms r ON f.id = r.floor_id
            LEFT JOIN beds bd ON r.id = bd.room_id
            GROUP BY h.id
            ORDER BY h.id ASC
        """;

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Hostel h = mapHostel(rs);
                h.setTotalRooms(rs.getInt("total_rooms"));
                h.setCurrentOccupancy(rs.getInt("current_occupancy"));
                list.add(h);
            }
        } catch (SQLException e) {
            logger.error("Error finding all hostels: {}", e.getMessage(), e);
        }
        return list;
    }

    public Hostel findById(Long id) {
        String sql = "SELECT * FROM hostels WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapHostel(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding hostel by id: {}", e.getMessage(), e);
        }
        return null;
    }

    public Long createHostel(String name, String code, String type, String address, String phone, String email, int capacity) {
        String hostelSql = """
            INSERT INTO hostels (name, code, type, address, contact_phone, contact_email, total_capacity, is_active)
            VALUES (?, ?, ?, ?, ?, ?, ?, TRUE)
            RETURNING id
        """;
        String buildingSql = "INSERT INTO hostel_buildings (hostel_id, building_name, building_code, total_floors) VALUES (?, ?, ?, 1) RETURNING id";
        String floorSql = "INSERT INTO hostel_floors (building_id, floor_number, floor_name, total_rooms) VALUES (?, 0, 'Ground Floor', 0)";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            String normalizedType = "BOYS";
            if (type != null) {
                String clean = type.trim().toUpperCase().replace("-", "_");
                if (clean.equals("GIRLS")) normalizedType = "GIRLS";
                else if (clean.equals("COED") || clean.equals("CO_ED")) normalizedType = "CO_ED";
            }

            long hostelId;
            try (PreparedStatement ps = conn.prepareStatement(hostelSql)) {
                ps.setString(1, name);
                ps.setString(2, code != null ? code.toUpperCase() : "HST");
                ps.setString(3, normalizedType);
                ps.setString(4, address != null ? address : "Campus Residential Block");
                ps.setString(5, phone != null ? phone : "");
                ps.setString(6, email != null ? email : "");
                ps.setInt(7, capacity > 0 ? capacity : 100);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        hostelId = rs.getLong(1);
                    } else {
                        conn.rollback();
                        return null;
                    }
                }
            }

            long buildingId;
            try (PreparedStatement ps = conn.prepareStatement(buildingSql)) {
                ps.setLong(1, hostelId);
                ps.setString(2, "Main Block");
                ps.setString(3, code.toUpperCase() + "-BLK-A");
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        buildingId = rs.getLong(1);
                    } else {
                        conn.rollback();
                        return null;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(floorSql)) {
                ps.setLong(1, buildingId);
                ps.executeUpdate();
            }

            conn.commit();
            return hostelId;
        } catch (SQLException e) {
            logger.error("Error creating hostel {}: {}", name, e.getMessage(), e);
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

    private Hostel mapHostel(ResultSet rs) throws SQLException {
        Hostel h = new Hostel();
        h.setId(rs.getLong("id"));
        h.setName(rs.getString("name"));
        h.setCode(rs.getString("code"));
        h.setType(rs.getString("type"));
        h.setAddress(rs.getString("address"));
        h.setContactPhone(rs.getString("contact_phone"));
        h.setContactEmail(rs.getString("contact_email"));
        h.setTotalCapacity(rs.getInt("total_capacity"));
        h.setActive(rs.getBoolean("is_active"));
        h.setCreatedAt(rs.getTimestamp("created_at"));
        return h;
    }
}
