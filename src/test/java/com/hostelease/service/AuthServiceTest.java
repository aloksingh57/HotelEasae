package com.hostelease.service;

import com.hostelease.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class AuthServiceTest {

    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService();
    }

    @Test
    @DisplayName("Admin user authenticates successfully with correct credentials")
    void testAdminAuthentication() {
        User user = authService.authenticate("admin", "Admin@123", "127.0.0.1");

        assertNotNull(user, "Admin user should authenticate successfully");
        assertEquals("admin", user.getUsername());
        assertEquals("ADMIN", user.getRole());
        assertTrue(user.isActive());
    }

    @Test
    @DisplayName("Warden user authenticates successfully and has assigned hostel")
    void testWardenAuthentication() {
        User user = authService.authenticate("warden.boys", "Warden@123", "127.0.0.1");

        assertNotNull(user, "Warden user should authenticate successfully");
        assertEquals("warden.boys", user.getUsername());
        assertEquals("WARDEN", user.getRole());
        assertNotNull(user.getAssociatedHostelId(), "Warden should be assigned to a hostel");
    }

    @Test
    @DisplayName("Student user authenticates successfully")
    void testStudentAuthentication() {
        User user = authService.authenticate("student1@hostelease.com", "Student@123", "127.0.0.1");

        assertNotNull(user, "Student user should authenticate successfully");
        assertEquals("rohan.sharma", user.getUsername());
        assertEquals("STUDENT", user.getRole());
    }

    @Test
    @DisplayName("Authentication fails with incorrect password")
    void testAuthenticationFailsWrongPassword() {
        User user = authService.authenticate("admin", "WrongPassword!999", "127.0.0.1");

        assertNull(user, "Authentication should fail with incorrect password");
    }

    @Test
    @DisplayName("Authentication fails with non-existent user")
    void testAuthenticationFailsUnknownUser() {
        User user = authService.authenticate("nonexistent_user_xyz", "AnyPassword123", "127.0.0.1");

        assertNull(user, "Authentication should fail for non-existent user");
    }

    @Test
    @DisplayName("Authentication safely handles null and empty credentials")
    void testAuthenticationEmptyInputs() {
        assertNull(authService.authenticate(null, "Admin@123", "127.0.0.1"));
        assertNull(authService.authenticate("admin", null, "127.0.0.1"));
        assertNull(authService.authenticate("", "", "127.0.0.1"));
        assertNull(authService.authenticate("   ", "   ", "127.0.0.1"));
    }
}
