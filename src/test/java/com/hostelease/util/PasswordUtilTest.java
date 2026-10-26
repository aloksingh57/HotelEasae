package com.hostelease.util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class PasswordUtilTest {

    @Test
    @DisplayName("Hash password produces valid BCrypt hash and verifies correctly")
    void testHashAndVerify() {
        String rawPassword = "SecurePassword@2026";
        String hash = PasswordUtil.hash(rawPassword);

        assertNotNull(hash);
        assertTrue(hash.startsWith("$2a$10$") || hash.startsWith("$2b$10$") || hash.startsWith("$2y$10$"));
        assertTrue(PasswordUtil.verify(rawPassword, hash));
        assertFalse(PasswordUtil.verify("WrongPassword", hash));
    }

    @Test
    @DisplayName("Verify returns false for null or empty passwords")
    void testNullAndEmptyPasswords() {
        String hash = PasswordUtil.hash("ValidPassword123");

        assertFalse(PasswordUtil.verify(null, hash));
        assertFalse(PasswordUtil.verify("", hash));
        assertFalse(PasswordUtil.verify("ValidPassword123", null));
        assertFalse(PasswordUtil.verify("ValidPassword123", ""));
    }

    @Test
    @DisplayName("Different salts produce different hashes for same password")
    void testSaltUniqueness() {
        String password = "IdenticalPassword@123";
        String hash1 = PasswordUtil.hash(password);
        String hash2 = PasswordUtil.hash(password);

        assertNotEquals(hash1, hash2);
        assertTrue(PasswordUtil.verify(password, hash1));
        assertTrue(PasswordUtil.verify(password, hash2));
    }
}
