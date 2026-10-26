package com.hostelease.service;

import com.hostelease.dao.StudentDAO;
import com.hostelease.model.Bed;
import com.hostelease.model.Student;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class AllocationServiceTest {

    private RoomService roomService;
    private StudentDAO studentDAO;

    @BeforeEach
    void setUp() {
        roomService = new RoomService();
        studentDAO = new StudentDAO();
    }

    @Test
    @DisplayName("Double-allocation to already occupied bed is strictly rejected by concurrency control")
    void testDoubleAllocationPrevention() {
        // Bed 1 is already allocated to Student 1 in seed data
        Bed occupiedBed = roomService.findBedById(1L);
        assertNotNull(occupiedBed);
        assertEquals("ALLOCATED", occupiedBed.getStatus(), "Bed 1 should already be ALLOCATED");

        // Attempt to allocate Bed 1 to student 5
        boolean doubleAllocationResult = roomService.allocateBed(5L, 1L, 1L, 1L);

        assertFalse(doubleAllocationResult, "Double allocation must fail atomically");

        // Verify Bed 1 still belongs to its original occupant
        Bed recheckedBed = roomService.findBedById(1L);
        assertEquals(1L, recheckedBed.getCurrentStudentId(), "Original occupant must not be overwritten");
    }

    @Test
    @DisplayName("Fetch unallocated students returns correct list")
    void testGetUnallocatedStudents() {
        List<Student> unallocated = roomService.getUnallocatedStudents();
        assertNotNull(unallocated);

        // All returned students must have null currentBedId
        for (Student s : unallocated) {
            assertNull(s.getCurrentBedId(), "Unallocated student must have null bed ID");
        }
    }
}
