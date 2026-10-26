package com.hostelease.service;

import com.hostelease.dao.AllocationDAO;
import com.hostelease.dao.AuditDAO;
import com.hostelease.dao.RoomDAO;
import com.hostelease.dao.StudentDAO;
import com.hostelease.model.Bed;
import com.hostelease.model.Room;
import com.hostelease.model.Student;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Map;

public class RoomService {

    private static final Logger logger = LoggerFactory.getLogger(RoomService.class);
    private final RoomDAO roomDAO = new RoomDAO();
    private final AllocationDAO allocationDAO = new AllocationDAO();
    private final StudentDAO studentDAO = new StudentDAO();
    private final AuditDAO auditDAO = new AuditDAO();
    private final NotificationService notificationService = NotificationService.getInstance();

    public List<Room> getRoomMatrix(Long hostelId) {
        return roomDAO.getRoomMatrix(hostelId);
    }

    public List<Room> findAllRooms(Long hostelId, Long floorId, String status) {
        return roomDAO.findAll(hostelId, floorId, status);
    }

    public List<Bed> findAllBeds(Long hostelId, String allocationStatus, String studentPresence) {
        return roomDAO.findAllBeds(hostelId, allocationStatus, studentPresence);
    }

    public Bed findBedById(Long bedId) {
        return roomDAO.findBedById(bedId);
    }

    public Map<String, Object> getOccupancyStats(Long hostelId) {
        return roomDAO.getOccupancyStats(hostelId);
    }

    public boolean allocateBed(Long studentId, Long bedId, Long sessionId, Long adminUserId) {
        boolean success = allocationDAO.allocateBed(studentId, bedId, sessionId, adminUserId);
        if (success) {
            auditDAO.log(adminUserId, "ROOM_ALLOCATED", "BED", String.valueOf(bedId), "127.0.0.1", "Allocated to Student ID " + studentId);
            notificationService.notifyRoomAllocated(studentId, bedId);
        }
        return success;
    }

    public boolean transferBed(Long studentId, Long currentBedId, Long targetBedId, Long sessionId, Long adminUserId) {
        boolean success = allocationDAO.transferBed(studentId, currentBedId, targetBedId, sessionId, adminUserId);
        if (success) {
            auditDAO.log(adminUserId, "ROOM_TRANSFERRED", "STUDENT", String.valueOf(studentId), "127.0.0.1", "From Bed " + currentBedId + " to Bed " + targetBedId);
            notificationService.notifyRoomTransferred(studentId, currentBedId, targetBedId);
        }
        return success;
    }

    public boolean permanentCheckout(Long studentId, String remarks, Long staffUserId) {
        boolean success = allocationDAO.permanentCheckout(studentId, remarks, staffUserId);
        if (success) {
            auditDAO.log(staffUserId, "PERMANENT_CHECKOUT", "STUDENT", String.valueOf(studentId), "127.0.0.1", remarks);
            notificationService.notifyPermanentCheckout(studentId, remarks);
        }
        return success;
    }

    public List<Student> getUnallocatedStudents() {
        return studentDAO.getUnallocatedStudents();
    }

    public Long createRoom(Long floorId, String roomNumber, String roomType, int capacity) {
        return roomDAO.createRoom(floorId, roomNumber, roomType, capacity);
    }

    public boolean updateBedStatus(Long bedId, String status) {
        return roomDAO.updateBedStatus(bedId, status);
    }

    public List<Map<String, Object>> findFloorsByHostelId(Long hostelId) {
        return roomDAO.findFloorsByHostelId(hostelId);
    }
}
