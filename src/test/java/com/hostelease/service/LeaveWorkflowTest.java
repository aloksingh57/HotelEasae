package com.hostelease.service;

import com.hostelease.dao.StudentDAO;
import com.hostelease.model.Bed;
import com.hostelease.model.LeaveRequest;
import com.hostelease.model.Student;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Timestamp;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

class LeaveWorkflowTest {

    private LeaveService leaveService;
    private RoomService roomService;
    private StudentDAO studentDAO;

    @BeforeEach
    void setUp() {
        leaveService = new LeaveService();
        roomService = new RoomService();
        studentDAO = new StudentDAO();
    }

    @Test
    @DisplayName("Complete student leave lifecycle preserves bed allocation during temporary vacancy")
    void testCompleteLeaveLifecycleAndAllocationPreservation() {
        // Use student 4 (Aditya Joshi - allocated to Room 102 Bed B1)
        Student student = studentDAO.findById(4L);
        assertNotNull(student, "Test student 4 should exist");
        assertEquals("PRESENT", student.getCurrentPresenceStatus(), "Initial status should be PRESENT");

        Long originalBedId = student.getCurrentBedId();
        assertNotNull(originalBedId, "Student must have an active allocated bed");

        // 1. Submit Leave Request
        LocalDateTime now = LocalDateTime.now();
        Timestamp departure = Timestamp.valueOf(now.plusHours(2));
        Timestamp expectedReturn = Timestamp.valueOf(now.plusDays(4));

        LeaveRequest req = new LeaveRequest();
        req.setStudentId(student.getId());
        req.setLeaveType("HOME");
        req.setDepartureDatetime(departure);
        req.setExpectedReturnDatetime(expectedReturn);
        req.setReason("Weekend family visit");
        req.setDestinationAddress("Pune, Maharashtra");
        req.setEmergencyContact(student.getGuardianPhone());

        boolean submitted = leaveService.submitLeaveRequest(req);
        assertTrue(submitted, "Leave request submission should succeed");
        assertNotNull(req.getId(), "Generated leave request ID should not be null");

        LeaveRequest fetched = leaveService.findById(req.getId());
        assertNotNull(fetched);
        assertEquals("PENDING", fetched.getStatus(), "Initial leave status should be PENDING");

        // 2. Warden Approves Leave
        boolean approved = leaveService.approveLeave(req.getId(), 2L, "Verified with father via phone");
        assertTrue(approved, "Warden approval should succeed");

        fetched = leaveService.findById(req.getId());
        assertEquals("APPROVED", fetched.getStatus(), "Leave status should be APPROVED");

        // 3. Physical Gate Checkpoint Departure -> Student is AWAY, Bed is Temporarily Vacant
        boolean departed = leaveService.recordDeparture(req.getId(), 2L);
        assertTrue(departed, "Gate departure should succeed");

        fetched = leaveService.findById(req.getId());
        assertEquals("DEPARTED", fetched.getStatus(), "Leave status should be DEPARTED");

        Student updatedStudent = studentDAO.findById(4L);
        assertEquals("AWAY", updatedStudent.getCurrentPresenceStatus(), "Student presence must be updated to AWAY");

        // CRITICAL BUSINESS RULE VERIFICATION:
        // Bed must remain ALLOCATED, never released to public pool!
        Bed allocatedBed = roomService.findBedById(originalBedId);
        assertEquals("ALLOCATED", allocatedBed.getStatus(), "Bed allocation status must remain ALLOCATED while student is away");
        assertEquals("AWAY", allocatedBed.getCurrentPresenceStatus(), "Bed must indicate student is temporarily away");
        assertTrue(allocatedBed.isTemporarilyVacant(), "Bed helper should recognize temporary vacancy");

        // 4. Physical Gate Return -> Student checks back into hostel
        boolean returned = leaveService.recordReturn(req.getId(), 2L);
        assertTrue(returned, "Gate return should succeed");

        fetched = leaveService.findById(req.getId());
        assertEquals("RETURNED", fetched.getStatus(), "Leave status should be RETURNED");

        updatedStudent = studentDAO.findById(4L);
        assertEquals("PRESENT", updatedStudent.getCurrentPresenceStatus(), "Student presence must restore to PRESENT");

        allocatedBed = roomService.findBedById(originalBedId);
        assertEquals("ALLOCATED", allocatedBed.getStatus());
        assertEquals("PRESENT", allocatedBed.getCurrentPresenceStatus());
        assertFalse(allocatedBed.isTemporarilyVacant(), "Bed is no longer temporarily vacant");
    }

    @Test
    @DisplayName("Leave submission rejected when return date is before departure date")
    void testInvalidLeaveDatesRejected() {
        LocalDateTime now = LocalDateTime.now();
        Timestamp departure = Timestamp.valueOf(now.plusDays(3));
        Timestamp returnEarlier = Timestamp.valueOf(now.plusDays(1)); // Invalid: before departure

        LeaveRequest req = new LeaveRequest();
        req.setStudentId(5L);
        req.setLeaveType("MEDICAL");
        req.setDepartureDatetime(departure);
        req.setExpectedReturnDatetime(returnEarlier);
        req.setReason("Medical checkup");

        boolean result = leaveService.submitLeaveRequest(req);
        assertFalse(result, "Submission with invalid date range should be rejected");
    }
}
