package com.hostelease.controller;

import com.hostelease.model.User;
import com.hostelease.security.CsrfProtection;
import com.hostelease.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("CURRENT_USER") != null) {
            User user = (User) session.getAttribute("CURRENT_USER");
            redirectToDashboard(user, req, resp);
            return;
        }

        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String ip = req.getRemoteAddr();

        User user = authService.authenticate(username, password, ip);
        if (user != null) {
            // Renew session ID to prevent Session Fixation
            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession newSession = req.getSession(true);
            newSession.setMaxInactiveInterval(3600); // 60 minutes session timeout
            newSession.setAttribute("CURRENT_USER", user);
            CsrfProtection.getToken(newSession); // seed token

            String redirectUrl = req.getParameter("redirect");
            if (redirectUrl != null && !redirectUrl.trim().isEmpty() && !redirectUrl.contains("://")) {
                resp.sendRedirect(redirectUrl);
                return;
            }

            redirectToDashboard(user, req, resp);
        } else {
            req.setAttribute("errorMessage", "Invalid username or password. Please try again.");
            req.setAttribute("enteredUsername", username);
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }

    private void redirectToDashboard(User user, HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String role = user.getRole();
        if ("ADMIN".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        } else if ("WARDEN".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/warden/dashboard");
        } else if ("STUDENT".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");
        } else {
            resp.sendRedirect(req.getContextPath() + "/index");
        }
    }
}
