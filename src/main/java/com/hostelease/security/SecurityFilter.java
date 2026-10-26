package com.hostelease.security;

import com.hostelease.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(filterName = "SecurityFilter", urlPatterns = {"/*"})
public class SecurityFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // Security headers
        res.setHeader("X-Content-Type-Options", "nosniff");
        res.setHeader("X-Frame-Options", "SAMEORIGIN");
        res.setHeader("X-XSS-Protection", "1; mode=block");

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // Allow static assets
        if (path.startsWith("/assets/") || path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/")) {
            chain.doFilter(request, response);
            return;
        }

        // Prevent direct browser access to JSP files in views or protected directories
        if (path.endsWith(".jsp") && !path.equals("/index.jsp") && !path.equals("/login.jsp")) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Direct access to JSP templates is forbidden");
            return;
        }

        // Public URLs
        if (path.equals("/") || path.equals("/index") || path.equals("/index.jsp") || 
            path.equals("/login") || path.equals("/login.jsp") || 
            path.equals("/logout") || path.equals("/health") || path.startsWith("/api/")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("CURRENT_USER") : null;

        if (user == null) {
            String returnUrl = req.getRequestURI();
            if (req.getQueryString() != null) {
                returnUrl += "?" + req.getQueryString();
            }
            res.sendRedirect(req.getContextPath() + "/login?msg=session_expired&redirect=" + java.net.URLEncoder.encode(returnUrl, "UTF-8"));
            return;
        }

        if (session != null) {
            String token = CsrfProtection.getToken(session);
            req.setAttribute("csrfToken", token);
            req.setAttribute("CSRF_TOKEN", token);
        }

        // Role-Based Authorization
        if (path.startsWith("/admin/")) {
            if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Administrative privileges required");
                return;
            }
        } else if (path.startsWith("/warden/")) {
            if (!"WARDEN".equalsIgnoreCase(user.getRole()) && !"ADMIN".equalsIgnoreCase(user.getRole())) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Warden privileges required");
                return;
            }
        } else if (path.startsWith("/student/")) {
            if (!"STUDENT".equalsIgnoreCase(user.getRole()) && !"ADMIN".equalsIgnoreCase(user.getRole())) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Student resident privileges required");
                return;
            }
        }

        // CSRF Verification on state-changing requests (except login/logout which generate initial session)
        if ("POST".equalsIgnoreCase(req.getMethod()) && !path.equals("/login") && !path.equals("/logout")) {
            if (!CsrfProtection.validate(req)) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF validation failed: Invalid or missing token");
                return;
            }
        }

        chain.doFilter(request, response);
    }
}
