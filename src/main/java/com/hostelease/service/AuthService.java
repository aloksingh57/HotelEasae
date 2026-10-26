package com.hostelease.service;

import com.hostelease.dao.AuditDAO;
import com.hostelease.dao.UserDAO;
import com.hostelease.model.User;
import com.hostelease.util.PasswordUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);
    private final UserDAO userDAO = new UserDAO();
    private final AuditDAO auditDAO = new AuditDAO();

    public User authenticate(String username, String plainPassword, String ipAddress) {
        if (username == null || plainPassword == null || username.trim().isEmpty() || plainPassword.trim().isEmpty()) {
            return null;
        }

        User user = userDAO.findByUsername(username.trim());
        if (user == null) {
            logger.warn("Authentication failed: User '{}' not found from IP {}", username, ipAddress);
            auditDAO.log(null, "LOGIN_FAILED", "USER", username, ipAddress, "Unknown user attempt");
            return null;
        }

        if (!user.isActive()) {
            logger.warn("Authentication failed: User '{}' is deactivated", username);
            auditDAO.log(user.getId(), "LOGIN_BLOCKED", "USER", user.getUsername(), ipAddress, "Account is disabled");
            return null;
        }

        boolean match = PasswordUtil.checkPassword(plainPassword, user.getPasswordHash());
        if (match) {
            logger.info("User '{}' ({}) successfully logged in from IP {}", user.getUsername(), user.getRole(), ipAddress);
            auditDAO.log(user.getId(), "LOGIN_SUCCESS", "USER", user.getUsername(), ipAddress, "Role: " + user.getRole());
            return user;
        } else {
            logger.warn("Authentication failed: Invalid credentials for user '{}' from IP {}", username, ipAddress);
            auditDAO.log(user.getId(), "LOGIN_FAILED", "USER", user.getUsername(), ipAddress, "Incorrect password attempt");
            return null;
        }
    }
}
