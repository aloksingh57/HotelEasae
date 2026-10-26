package com.hostelease.controller.warden;

import com.hostelease.model.LeaveRequest;
import com.hostelease.model.User;
import com.hostelease.service.LeaveService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "WardenPresenceServlet", urlPatterns = {"/warden/presence"})
public class WardenPresenceServlet extends HttpServlet {

    private final LeaveService leaveService = new LeaveService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Long hostelId = user.getAssociatedHostelId();
        if (hostelId == null) hostelId = 1L;

        // 1. Students approved for leave (Expected to depart)
        List<LeaveRequest> departuresPending = leaveService.findAll(hostelId, "APPROVED", null);

        // 2. Students currently away (Temporary Vacancies)
        List<LeaveRequest> currentlyAway = leaveService.findAll(hostelId, "DEPARTED", null);

        // 3. Students whose returns are overdue
        List<LeaveRequest> overdueReturns = leaveService.findAll(hostelId, "OVERDUE", null);

        req.setAttribute("departuresPending", departuresPending);
        req.setAttribute("currentlyAway", currentlyAway);
        req.setAttribute("overdueReturns", overdueReturns);

        req.getRequestDispatcher("/WEB-INF/views/warden/presence.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Long userId = (user != null) ? user.getId() : null;

        String leaveIdStr = req.getParameter("leaveId");
        Long leaveId = (leaveIdStr != null && !leaveIdStr.trim().isEmpty()) ? Long.parseLong(leaveIdStr.trim()) : null;

        if ("depart".equalsIgnoreCase(action) && leaveId != null) {
            boolean ok = leaveService.recordDeparture(leaveId, userId);
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/warden/presence?msg=departure_confirmed");
            } else {
                resp.sendRedirect(req.getContextPath() + "/warden/presence?error=departure_failed");
            }
        } else if ("return".equalsIgnoreCase(action) && leaveId != null) {
            boolean ok = leaveService.recordReturn(leaveId, userId);
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/warden/presence?msg=return_confirmed");
            } else {
                resp.sendRedirect(req.getContextPath() + "/warden/presence?error=return_failed");
            }
        } else if ("reconcile".equalsIgnoreCase(action)) {
            int count = leaveService.reconcileOverdueLeaves();
            resp.sendRedirect(req.getContextPath() + "/warden/presence?msg=reconciled_" + count);
        } else {
            resp.sendRedirect(req.getContextPath() + "/warden/presence");
        }
    }
}
