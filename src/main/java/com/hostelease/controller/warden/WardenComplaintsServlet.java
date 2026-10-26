package com.hostelease.controller.warden;

import com.hostelease.model.Complaint;
import com.hostelease.model.User;
import com.hostelease.service.ComplaintService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "WardenComplaintsServlet", urlPatterns = {"/warden/complaints"})
public class WardenComplaintsServlet extends HttpServlet {

    private final ComplaintService complaintService = new ComplaintService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Long hostelId = user.getAssociatedHostelId();
        if (hostelId == null) hostelId = 1L;

        String status = req.getParameter("status");
        String category = req.getParameter("category");

        List<Complaint> list = complaintService.findAll(hostelId, status, category);
        req.setAttribute("complaints", list);
        req.setAttribute("selectedStatus", status);
        req.setAttribute("selectedCategory", category);

        req.getRequestDispatcher("/WEB-INF/views/warden/complaints.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long complaintId = Long.parseLong(req.getParameter("complaintId"));
        String newStatus = req.getParameter("newStatus");
        String remarks = req.getParameter("remarks");

        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");

        boolean ok = complaintService.updateStatus(complaintId, newStatus, null, remarks, user.getId());
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/warden/complaints?msg=status_updated");
        } else {
            resp.sendRedirect(req.getContextPath() + "/warden/complaints?error=update_failed");
        }
    }
}
