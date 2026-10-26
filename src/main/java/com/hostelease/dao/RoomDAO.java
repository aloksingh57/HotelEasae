package com.hostelease.dao;

import com.hostelease.config.DatabaseConfig;
import com.hostelease.model.Bed;
import com.hostelease.model.Room;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.*;

public class RoomDAO {

    private static final Logger logger = LoggerFactory.getLogger(RoomDAO.class);

    public List<Room> findAll(Long hostelId, Long floorId, String status) {
        List<Room> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT r.id, r.floor_id, r.room_number, r.room_type, r.capacity, 
                   r.current_occupancy, r.status,
                   f.floor_name, b.building_name, h.id AS hostel_id, h.name AS hostel_name
            FROM rooms r
            JOIN hostel_floors f ON r.floor_id = f.id
            JOIN hostel_buildings b ON f.building_id = b.id
            JOIN hostels h ON b.hostel_id = h.id
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();
        if (hostelId != null && hostelId > 0) {
            sql.append(" AND h.id = ? ");
            params.add(hostelId);
        }
        if (floorId != null && floorId > 0) {
            sql.append(" AND f.id = ? ");
            params.add(floorId);
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND r.status = ? ");
            params.add(status.trim().toUpperCase());
        }

        sql.append(" ORDER BY h.id, b.id, f.floor_number, r.room_number ");

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRoom(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding rooms: {}", e.getMessage(), e);
        }
        return list;
    }

    public List<Room> getRoomMatrix(Long hostelId) {
        List<Room> rooms = findAll(hostelId, null, null);
        Map<Long, Room> roomMap = new LinkedHashMap<>();
        for (Room r : rooms) {
            roomMap.put(r.getId(), r);
        }

        if (roomMap.isEmpty()) {
            return rooms;
        }

        String bedSql = """
            SELECT bd.id AS bed_id, bd.room_id, bd.bed_label, bd.allocation_status,
                   s.id AS student_id, u.first_name, u.last_name, s.roll_number, u.phone_number,
                   s.current_presence,
                   lr.id AS leave_id, lr.leave_type, lr.departure_datetime, lr.expected_return_datetime
            FROM beds bd
            LEFT JOIN room_allocations ra ON bd.id = ra.bed_id AND ra.is_active = TRUE
            LEFT JOIN students s ON ra.student_id = s.id
            LEFT JOIN users u ON s.user_id = u.id
            LEFT JOIN student_leave_requests lr ON s.id = lr.student_id AND lr.status IN ('APPROVED', 'DEPARTED', 'OVERDUE')
            ORDER BY bd.room_id, bd.bed_label
        """;

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(bedSql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                long roomId = rs.getLong("room_id");
                Room r = roomMap.get(roomId);
                if (r != null) {
                    Bed bed = new Bed();
                    bed.setId(rs.getLong("bed_id"));
                    bed.setRoomId(roomId);
                    bed.setRoomNumber(r.getRoomNumber());
                    bed.setHostelName(r.getHostelName());
                    bed.setBuildingName(r.getBuildingName());
                    bed.setFloorName(r.getFloorName());
                    bed.setBedLabel(rs.getString("bed_label"));
                    bed.setAllocationStatus(rs.getString("allocation_status"));

                    long studentId = rs.getLong("student_id");
                    if (!rs.wasNull()) {
                        bed.setStudentId(studentId);
                        bed.setStudentName(rs.getString("first_name") + " " + rs.getString("last_name"));
                        bed.setRollNumber(rs.getString("roll_number"));
                        bed.setStudentPhone(rs.getString("phone_number"));
                        bed.setStudentPresence(rs.getString("current_presence"));

                        long leaveId = rs.getLong("leave_id");
                        if (!rs.wasNull()) {
                            bed.setActiveLeaveId(leaveId);
                            bed.setLeaveType(rs.getString("leave_type"));
                            bed.setDepartureDatetime(rs.getTimestamp("departure_datetime"));
                            bed.setExpectedReturnDatetime(rs.getTimestamp("expected_return_datetime"));
                        }
                    }
                    r.getBeds().add(bed);
                }
            }
        } catch (SQLException e) {
            logger.error("Error loading room matrix beds: {}", e.getMessage(), e);
        }

        return new ArrayList<>(roomMap.values());
    }

    public List<Bed> findAllBeds(Long hostelId, String allocationStatus, String studentPresence) {
        List<Bed> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT bd.id AS bed_id, bd.room_id, bd.bed_label, bd.allocation_status,
                   r.room_number, f.floor_name, b.building_name, h.id AS hostel_id, h.name AS hostel_name,
                   s.id AS student_id, u.first_name, u.last_name, s.roll_number, u.phone_number,
                   s.current_presence,
                   lr.id AS leave_id, lr.leave_type, lr.departure_datetime, lr.expected_return_datetime
            FROM beds bd
            JOIN rooms r ON bd.room_id = r.id
            JOIN hostel_floors f ON r.floor_id = f.id
            JOIN hostel_buildings b ON f.building_id = b.id
            JOIN hostels h ON b.hostel_id = h.id
            LEFT JOIN room_allocations ra ON bd.id = ra.bed_id AND ra.is_active = TRUE
            LEFT JOIN students s ON ra.student_id = s.id
            LEFT JOIN users u ON s.user_id = u.id
            LEFT JOIN student_leave_requests lr ON s.id = lr.student_id AND lr.status IN ('APPROVED', 'DEPARTED', 'OVERDUE')
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();
        if (hostelId != null && hostelId > 0) {
            sql.append(" AND h.id = ? ");
            params.add(hostelId);
        }
        if (allocationStatus != null && !allocationStatus.trim().isEmpty() && !"ALL".equalsIgnoreCase(allocationStatus)) {
            sql.append(" AND bd.allocation_status = ? ");
            params.add(allocationStatus.trim().toUpperCase());
        }
        if (studentPresence != null && !studentPresence.trim().isEmpty() && !"ALL".equalsIgnoreCase(studentPresence)) {
            sql.append(" AND s.current_presence = ? ");
            params.add(studentPresence.trim().toUpperCase());
        }

        sql.append(" ORDER BY h.id, r.room_number, bd.bed_label");

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Bed bed = new Bed();
                    bed.setId(rs.getLong("bed_id"));
                    bed.setRoomId(rs.getLong("room_id"));
                    bed.setRoomNumber(rs.getString("room_number"));
                    bed.setFloorName(rs.getString("floor_name"));
                    bed.setBuildingName(rs.getString("building_name"));
                    bed.setHostelId(rs.getLong("hostel_id"));
                    bed.setHostelName(rs.getString("hostel_name"));
                    bed.setBedLabel(rs.getString("bed_label"));
                    bed.setAllocationStatus(rs.getString("allocation_status"));

                    long studentId = rs.getLong("student_id");
                    if (!rs.wasNull()) {
                        bed.setStudentId(studentId);
                        bed.setStudentName(rs.getString("first_name") + " " + rs.getString("last_name"));
                        bed.setRollNumber(rs.getString("roll_number"));
                        bed.setStudentPhone(rs.getString("phone_number"));
                        bed.setStudentPresence(rs.getString("current_presence"));

                        long leaveId = rs.getLong("leave_id");
                        if (!rs.wasNull()) {
                            bed.setActiveLeaveId(leaveId);
                            bed.setLeaveType(rs.getString("leave_type"));
                            bed.setDepartureDatetime(rs.getTimestamp("departure_datetime"));
                            bed.setExpectedReturnDatetime(rs.getTimestamp("expected_return_datetime"));
                        }
                    }
                    list.add(bed);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding beds: {}", e.getMessage(), e);
        }
        return list;
    }

    public Bed findBedById(Long bedId) {
        String sql = """
            SELECT bd.id AS bed_id, bd.room_id, bd.bed_label, bd.allocation_status,
                   r.room_number, f.floor_name, b.building_name, h.id AS hostel_id, h.name AS hostel_name,
                   s.id AS student_id, u.first_name, u.last_name, s.roll_number, u.phone_number,
                   s.current_presence
            FROM beds bd
            JOIN rooms r ON bd.room_id = r.id
            JOIN hostel_floors f ON r.floor_id = f.id
            JOIN hostel_buildings b ON f.building_id = b.id
            JOIN hostels h ON b.hostel_id = h.id
            LEFT JOIN room_allocations ra ON bd.id = ra.bed_id AND ra.is_active = TRUE
            LEFT JOIN students s ON ra.student_id = s.id
            LEFT JOIN users u ON s.user_id = u.id
            WHERE bd.id = ?
        """;

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bedId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Bed bed = new Bed();
                    bed.setId(rs.getLong("bed_id"));
                    bed.setRoomId(rs.getLong("room_id"));
                    bed.setRoomNumber(rs.getString("room_number"));
                    bed.setFloorName(rs.getString("floor_name"));
                    bed.setBuildingName(rs.getString("building_name"));
                    bed.setHostelId(rs.getLong("hostel_id"));
                    bed.setHostelName(rs.getString("hostel_name"));
                    bed.setBedLabel(rs.getString("bed_label"));
                    bed.setAllocationStatus(rs.getString("allocation_status"));

                    long studentId = rs.getLong("student_id");
                    if (!rs.wasNull()) {
                        bed.setStudentId(studentId);
                        bed.setStudentName(rs.getString("first_name") + " " + rs.getString("last_name"));
                        bed.setRollNumber(rs.getString("roll_number"));
                        bed.setStudentPhone(rs.getString("phone_number"));
                        bed.setStudentPresence(rs.getString("current_presence"));
                    }
                    return bed;
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding bed by id: {}", e.getMessage(), e);
        }
        return null;
    }

    public boolean updateBedStatus(Long bedId, String status, Connection conn) throws SQLException {
        String sql = "UPDATE beds SET allocation_status = ? WHERE id = ?";
        boolean closeConn = false;
        if (conn == null) {
            conn = DatabaseConfig.getConnection();
            closeConn = true;
        }
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, bedId);
            return ps.executeUpdate() > 0;
        } finally {
            if (closeConn) {
                conn.close();
            }
        }
    }

    public boolean updateBedStatus(Long bedId, String status) {
        try {
            return updateBedStatus(bedId, status, null);
        } catch (SQLException e) {
            logger.error("Error updating bed {} status to {}: {}", bedId, status, e.getMessage(), e);
            return false;
        }
    }

    public List<Map<String, Object>> findFloorsByHostelId(Long hostelId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = """
            SELECT f.id AS floor_id, f.floor_name, f.floor_number, b.building_name, h.id AS hostel_id, h.name AS hostel_name
            FROM hostel_floors f
            JOIN hostel_buildings b ON f.building_id = b.id
            JOIN hostels h ON b.hostel_id = h.id
            WHERE (? IS NULL OR h.id = ?)
            ORDER BY h.id, b.id, f.floor_number
        """;
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (hostelId != null && hostelId > 0) {
                ps.setLong(1, hostelId);
                ps.setLong(2, hostelId);
            } else {
                ps.setNull(1, Types.BIGINT);
                ps.setNull(2, Types.BIGINT);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("floorId", rs.getLong("floor_id"));
                    map.put("floorName", rs.getString("floor_name"));
                    map.put("buildingName", rs.getString("building_name"));
                    map.put("hostelId", rs.getLong("hostel_id"));
                    map.put("hostelName", rs.getString("hostel_name"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding floors: {}", e.getMessage(), e);
        }
        return list;
    }

    public Long createRoom(Long floorId, String roomNumber, String roomType, int capacity) {
        String insertRoomSql = """
            INSERT INTO rooms (floor_id, room_number, room_type, capacity, current_occupancy, status)
            VALUES (?, ?, ?, ?, 0, 'AVAILABLE')
            RETURNING id
        """;
        String insertBedSql = "INSERT INTO beds (room_id, bed_label, allocation_status) VALUES (?, ?, 'UNALLOCATED')";
        String updateFloorSql = "UPDATE hostel_floors SET total_rooms = total_rooms + 1 WHERE id = ?";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            long roomId;
            try (PreparedStatement ps = conn.prepareStatement(insertRoomSql)) {
                ps.setLong(1, floorId);
                ps.setString(2, roomNumber.trim().toUpperCase());
                ps.setString(3, roomType.trim().toUpperCase());
                ps.setInt(4, capacity);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        roomId = rs.getLong(1);
                    } else {
                        conn.rollback();
                        return null;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(insertBedSql)) {
                for (int i = 0; i < capacity; i++) {
                    char label = (char) ('A' + i);
                    ps.setLong(1, roomId);
                    ps.setString(2, "Bed " + label);
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            try (PreparedStatement ps = conn.prepareStatement(updateFloorSql)) {
                ps.setLong(1, floorId);
                ps.executeUpdate();
            }

            conn.commit();
            return roomId;
        } catch (SQLException e) {
            logger.error("Error creating room {}: {}", roomNumber, e.getMessage(), e);
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

    public Map<String, Object> getOccupancyStats(Long hostelId) {
        Map<String, Object> stats = new HashMap<>();
        StringBuilder sql = new StringBuilder("""
            SELECT 
                COUNT(DISTINCT r.id) AS total_rooms,
                COUNT(bd.id) AS total_beds,
                COUNT(CASE WHEN bd.allocation_status = 'ALLOCATED' THEN 1 END) AS allocated_beds,
                COUNT(CASE WHEN bd.allocation_status = 'UNALLOCATED' THEN 1 END) AS available_beds,
                COUNT(CASE WHEN bd.allocation_status = 'MAINTENANCE' THEN 1 END) AS maintenance_beds,
                COUNT(CASE WHEN bd.allocation_status = 'RESERVED' THEN 1 END) AS reserved_beds,
                COUNT(CASE WHEN s.current_presence = 'PRESENT' THEN 1 END) AS present_students,
                COUNT(CASE WHEN s.current_presence = 'AWAY' THEN 1 END) AS away_students,
                COUNT(CASE WHEN s.current_presence = 'RETURN_OVERDUE' THEN 1 END) AS overdue_students,
                COUNT(CASE WHEN s.current_presence = 'EXPECTED_TO_LEAVE' THEN 1 END) AS expected_to_leave
            FROM beds bd
            JOIN rooms r ON bd.room_id = r.id
            JOIN hostel_floors f ON r.floor_id = f.id
            JOIN hostel_buildings b ON f.building_id = b.id
            JOIN hostels h ON b.hostel_id = h.id
            LEFT JOIN room_allocations ra ON bd.id = ra.bed_id AND ra.is_active = TRUE
            LEFT JOIN students s ON ra.student_id = s.id
            WHERE 1=1
        """);

        if (hostelId != null && hostelId > 0) {
            sql.append(" AND h.id = ? ");
        }

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (hostelId != null && hostelId > 0) {
                ps.setLong(1, hostelId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalRooms", rs.getInt("total_rooms"));
                    stats.put("totalBeds", rs.getInt("total_beds"));
                    stats.put("allocatedBeds", rs.getInt("allocated_beds"));
                    stats.put("availableBeds", rs.getInt("available_beds"));
                    stats.put("maintenanceBeds", rs.getInt("maintenance_beds"));
                    stats.put("reservedBeds", rs.getInt("reserved_beds"));
                    stats.put("presentStudents", rs.getInt("present_students"));
                    stats.put("awayStudents", rs.getInt("away_students")); // Temporarily Vacant Beds!
                    stats.put("overdueStudents", rs.getInt("overdue_students"));
                    stats.put("expectedToLeave", rs.getInt("expected_to_leave"));
                }
            }
        } catch (SQLException e) {
            logger.error("Error calculating occupancy stats: {}", e.getMessage(), e);
        }
        return stats;
    }

    private Room mapRoom(ResultSet rs) throws SQLException {
        Room r = new Room();
        r.setId(rs.getLong("id"));
        r.setFloorId(rs.getLong("floor_id"));
        r.setFloorName(rs.getString("floor_name"));
        r.setBuildingName(rs.getString("building_name"));
        r.setHostelId(rs.getLong("hostel_id"));
        r.setHostelName(rs.getString("hostel_name"));
        r.setRoomNumber(rs.getString("room_number"));
        r.setRoomType(rs.getString("room_type"));
        r.setCapacity(rs.getInt("capacity"));
        r.setCurrentOccupancy(rs.getInt("current_occupancy"));
        r.setStatus(rs.getString("status"));
        return r;
    }
}
