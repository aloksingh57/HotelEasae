package com.hostelease.dao;

import com.hostelease.config.DatabaseConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;

public class AllocationDAO {

    private static final Logger logger = LoggerFactory.getLogger(AllocationDAO.class);

    /**
     * Atomically allocates a bed to a student inside a database transaction.
     */
    public boolean allocateBed(Long studentId, Long bedId, Long sessionId, Long allocatedByUserId) {
        String checkBedSql = "SELECT allocation_status, room_id FROM beds WHERE id = ? FOR UPDATE";
        String checkStudentSql = "SELECT id FROM room_allocations WHERE student_id = ? AND is_active = TRUE";
        String insertAllocSql = """
            INSERT INTO room_allocations (student_id, bed_id, academic_session_id, allocated_from, is_active, allocated_by_user_id)
            VALUES (?, ?, ?, CURRENT_DATE, TRUE, ?)
        """;
        String updateBedSql = "UPDATE beds SET allocation_status = 'ALLOCATED' WHERE id = ?";
        String updateRoomSql = "UPDATE rooms SET current_occupancy = current_occupancy + 1 WHERE id = ?";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            long roomId;
            // 1. Verify Bed is free and lock bed row
            try (PreparedStatement ps = conn.prepareStatement(checkBedSql)) {
                ps.setLong(1, bedId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        logger.warn("Bed ID {} not found", bedId);
                        return false;
                    }
                    String status = rs.getString("allocation_status");
                    if (!"UNALLOCATED".equalsIgnoreCase(status)) {
                        conn.rollback();
                        logger.warn("Bed ID {} is not unallocated (status: {})", bedId, status);
                        return false;
                    }
                    roomId = rs.getLong("room_id");
                }
            }

            // 2. Verify student doesn't already have an active allocation
            try (PreparedStatement ps = conn.prepareStatement(checkStudentSql)) {
                ps.setLong(1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        conn.rollback();
                        logger.warn("Student ID {} already has an active allocation", studentId);
                        return false;
                    }
                }
            }

            // 3. Insert Room Allocation
            try (PreparedStatement ps = conn.prepareStatement(insertAllocSql)) {
                ps.setLong(1, studentId);
                ps.setLong(2, bedId);
                if (sessionId != null) ps.setLong(3, sessionId); else ps.setNull(3, Types.BIGINT);
                if (allocatedByUserId != null) ps.setLong(4, allocatedByUserId); else ps.setNull(4, Types.BIGINT);
                ps.executeUpdate();
            }

            // 4. Update Bed allocation status
            try (PreparedStatement ps = conn.prepareStatement(updateBedSql)) {
                ps.setLong(1, bedId);
                ps.executeUpdate();
            }

            // 5. Increment room occupancy
            try (PreparedStatement ps = conn.prepareStatement(updateRoomSql)) {
                ps.setLong(1, roomId);
                ps.executeUpdate();
            }

            conn.commit();
            logger.info("Successfully allocated bed {} to student {}", bedId, studentId);
            return true;

        } catch (SQLException e) {
            logger.error("Transaction failed during room allocation: {}", e.getMessage(), e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { logger.error("Rollback failed: {}", ex.getMessage()); }
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Atomically transfers a student from their current bed to a new target bed.
     */
    public boolean transferBed(Long studentId, Long currentBedId, Long targetBedId, Long sessionId, Long transferredByUserId) {
        String endCurrentAllocSql = """
            UPDATE room_allocations 
            SET is_active = FALSE, checkout_date = CURRENT_TIMESTAMP, checkout_remarks = 'Room Transfer' 
            WHERE student_id = ? AND bed_id = ? AND is_active = TRUE
        """;
        String freeOldBedSql = "UPDATE beds SET allocation_status = 'UNALLOCATED' WHERE id = ?";
        String decOldRoomSql = "UPDATE rooms SET current_occupancy = GREATEST(0, current_occupancy - 1) WHERE id = (SELECT room_id FROM beds WHERE id = ?)";

        String checkNewBedSql = "SELECT allocation_status, room_id FROM beds WHERE id = ? FOR UPDATE";
        String insertNewAllocSql = """
            INSERT INTO room_allocations (student_id, bed_id, academic_session_id, allocated_from, is_active, allocated_by_user_id)
            VALUES (?, ?, ?, CURRENT_DATE, TRUE, ?)
        """;
        String occNewBedSql = "UPDATE beds SET allocation_status = 'ALLOCATED' WHERE id = ?";
        String incNewRoomSql = "UPDATE rooms SET current_occupancy = current_occupancy + 1 WHERE id = ?";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            // 1. End old allocation
            try (PreparedStatement ps = conn.prepareStatement(endCurrentAllocSql)) {
                ps.setLong(1, studentId);
                ps.setLong(2, currentBedId);
                int updated = ps.executeUpdate();
                if (updated == 0) {
                    conn.rollback();
                    logger.warn("Could not find active allocation for student {} on bed {}", studentId, currentBedId);
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(freeOldBedSql)) {
                ps.setLong(1, currentBedId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(decOldRoomSql)) {
                ps.setLong(1, currentBedId);
                ps.executeUpdate();
            }

            // 2. Lock & check target bed
            long newRoomId;
            try (PreparedStatement ps = conn.prepareStatement(checkNewBedSql)) {
                ps.setLong(1, targetBedId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next() || !"UNALLOCATED".equalsIgnoreCase(rs.getString("allocation_status"))) {
                        conn.rollback();
                        logger.warn("Target bed {} is not available for transfer", targetBedId);
                        return false;
                    }
                    newRoomId = rs.getLong("room_id");
                }
            }

            // 3. Insert new allocation
            try (PreparedStatement ps = conn.prepareStatement(insertNewAllocSql)) {
                ps.setLong(1, studentId);
                ps.setLong(2, targetBedId);
                if (sessionId != null) ps.setLong(3, sessionId); else ps.setNull(3, Types.BIGINT);
                if (transferredByUserId != null) ps.setLong(4, transferredByUserId); else ps.setNull(4, Types.BIGINT);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(occNewBedSql)) {
                ps.setLong(1, targetBedId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(incNewRoomSql)) {
                ps.setLong(1, newRoomId);
                ps.executeUpdate();
            }

            conn.commit();
            logger.info("Successfully transferred student {} from bed {} to bed {}", studentId, currentBedId, targetBedId);
            return true;

        } catch (SQLException e) {
            logger.error("Transaction failed during room transfer: {}", e.getMessage(), e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { logger.error("Rollback failed: {}", ex.getMessage()); }
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Atomically executes a permanent checkout, terminating the allocation and releasing the bed.
     */
    public boolean permanentCheckout(Long studentId, String remarks, Long checkoutByUserId) {
        String findAllocSql = "SELECT id, bed_id FROM room_allocations WHERE student_id = ? AND is_active = TRUE FOR UPDATE";
        String endAllocSql = "UPDATE room_allocations SET is_active = FALSE, checkout_date = CURRENT_TIMESTAMP, checkout_remarks = ? WHERE id = ?";
        String freeBedSql = "UPDATE beds SET allocation_status = 'UNALLOCATED' WHERE id = ?";
        String decRoomSql = "UPDATE rooms SET current_occupancy = GREATEST(0, current_occupancy - 1) WHERE id = (SELECT room_id FROM beds WHERE id = ?)";
        String resetPresenceSql = "UPDATE students SET current_presence = 'PRESENT' WHERE id = ?";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            long allocId, bedId;
            try (PreparedStatement ps = conn.prepareStatement(findAllocSql)) {
                ps.setLong(1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        logger.warn("No active allocation found for student {}", studentId);
                        return false;
                    }
                    allocId = rs.getLong("id");
                    bedId = rs.getLong("bed_id");
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(endAllocSql)) {
                ps.setString(1, remarks != null ? remarks : "Permanent Checkout");
                ps.setLong(2, allocId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(freeBedSql)) {
                ps.setLong(1, bedId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(decRoomSql)) {
                ps.setLong(1, bedId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(resetPresenceSql)) {
                ps.setLong(1, studentId);
                ps.executeUpdate();
            }

            conn.commit();
            logger.info("Successfully checked out student {} and released bed {}", studentId, bedId);
            return true;

        } catch (SQLException e) {
            logger.error("Transaction failed during permanent checkout: {}", e.getMessage(), e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { logger.error("Rollback failed: {}", ex.getMessage()); }
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }
}
