package com.hostelease.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Enterprise Password Hashing and Verification utility using BCrypt.
 */
public class PasswordUtil {

    private static final int BCRYPT_WORK_FACTOR = 10;

    /**
     * Hashes a plaintext password using BCrypt with salt.
     *
     * @param plainPassword Raw password string
     * @return 60-character secure BCrypt hash
     */
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.trim().isEmpty()) {
            throw new IllegalArgumentException("Password cannot be empty");
        }
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(BCRYPT_WORK_FACTOR));
    }

    /**
     * Verifies if a plaintext password matches the BCrypt hash.
     *
     * @param plainPassword Raw password attempt
     * @param hashedPassword Stored BCrypt hash
     * @return true if password matches, false otherwise
     */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (Exception e) {
            return false;
        }
    }

    public static String hash(String plainPassword) {
        return hashPassword(plainPassword);
    }

    public static boolean verify(String plainPassword, String hashedPassword) {
        return checkPassword(plainPassword, hashedPassword);
    }
}
