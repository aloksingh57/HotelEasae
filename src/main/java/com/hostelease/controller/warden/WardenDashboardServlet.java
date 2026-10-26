package com.hostelease.controller.warden;

import com.hostelease.dao.*;
import com.hostelease.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "WardenDashboardServlet", urlPatterns = {"/warden/dashboard"})
public class WardenDashboardServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();
    private final LeaveDAO leaveDAO = new LeaveDAO();
    private final ComplaintDAO complaintDAO = new ComplaintDAO();
    private final VisitorDAO visitorDAO = new VisitorDAO();
    private final HostelDAO hostelDAO = new HostelDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Long hostelId = user.getAssociatedHostelId();
        if (hostelId == null) {
            hostelId = 1L; // Fallback for administrator viewing warden dashboard
        }

        Map<String, Object> occupancy = roomDAO.getOccupancyStats(hostelId);

        req.setAttribute("hostel", hostelDAO.findById(hostelId));
        req.setAttribute("occupancy", occupancy);
        req.setAttribute("pendingLeaves", leaveDAO.findAll(hostelId, "PENDING", null));
        req.setAttribute("overdueLeaves", leaveDAO.findAll(hostelId, "OVERDUE", null));
        req.setAttribute("awayLeaves", leaveDAO.findAll(hostelId, "DEPARTED", null));
        req.setAttribute("approvedLeaves", leaveDAO.findAll(hostelId, "APPROVED", null));
        req.setAttribute("openComplaints", complaintDAO.findAll(hostelId, "OPEN", null));
        req.setAttribute("activeVisitors", visitorDAO.findAll(hostelId, "IN_HOSTEL"));

        req.getRequestDispatcher("/WEB-INF/views/warden/dashboard.jsp").forward(req, resp);
    }
}
