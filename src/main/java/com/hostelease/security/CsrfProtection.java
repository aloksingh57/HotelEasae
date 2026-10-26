package com.hostelease.security;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.security.SecureRandom;
import java.util.Base64;

public class CsrfProtection {

    private static final String CSRF_SESSION_ATTR = "CSRF_TOKEN";
    private static final SecureRandom secureRandom = new SecureRandom();

    public static String getToken(HttpSession session) {
        if (session == null) return "";
        String token = (String) session.getAttribute(CSRF_SESSION_ATTR);
        if (token == null) {
            byte[] bytes = new byte[24];
            secureRandom.nextBytes(bytes);
            token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            session.setAttribute(CSRF_SESSION_ATTR, token);
        }
        return token;
    }

    public static boolean validate(HttpServletRequest request) {
        if ("GET".equalsIgnoreCase(request.getMethod()) || "HEAD".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        HttpSession session = request.getSession(false);
        if (session == null) return false;

        String sessionToken = (String) session.getAttribute(CSRF_SESSION_ATTR);
        if (sessionToken == null || sessionToken.isEmpty()) return false;

        String requestToken = request.getParameter("csrf_token");
        if (requestToken == null || requestToken.isEmpty()) {
            requestToken = request.getParameter("csrfToken");
        }
        if (requestToken == null || requestToken.isEmpty()) {
            requestToken = request.getParameter("_csrf");
        }
        if (requestToken == null || requestToken.isEmpty()) {
            requestToken = request.getHeader("X-CSRF-TOKEN");
        }

        return sessionToken.equals(requestToken);
    }
}
