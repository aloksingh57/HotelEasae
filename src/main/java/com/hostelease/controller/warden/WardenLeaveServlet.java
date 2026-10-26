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

@WebServlet(name = "WardenLeaveServlet", urlPatterns = {"/warden/leaves"})
public class WardenLeaveServlet extends HttpServlet {

    private final LeaveService leaveService = new LeaveService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Long hostelId = user.getAssociatedHostelId();
        if (hostelId == null) hostelId = 1L;

        String status = req.getParameter("status");
        String type = req.getParameter("type");

        List<LeaveRequest> list = leaveService.findAll(hostelId, status, type);
        req.setAttribute("leaves", list);
        req.setAttribute("selectedStatus", status);
        req.setAttribute("selectedType", type);

        req.getRequestDispatcher("/WEB-INF/views/warden/leaves.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        Long leaveId = Long.parseLong(req.getParameter("leaveId"));
        String remarks = req.getParameter("remarks");

        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");

        if ("approve".equalsIgnoreCase(action)) {
            boolean ok = leaveService.approveLeave(leaveId, user.getId(), remarks);
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/warden/leaves?msg=leave_approved");
            } else {
                resp.sendRedirect(req.getContextPath() + "/warden/leaves?error=approval_failed");
            }
        } else if ("reject".equalsIgnoreCase(action)) {
            boolean ok = leaveService.rejectLeave(leaveId, user.getId(), remarks);
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/warden/leaves?msg=leave_rejected");
            } else {
                resp.sendRedirect(req.getContextPath() + "/warden/leaves?error=rejection_failed");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/warden/leaves");
        }
    }
}
