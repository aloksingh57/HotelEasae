package com.hostelease.controller.admin;

import com.hostelease.dao.AuditDAO;
import com.hostelease.dao.ComplaintDAO;
import com.hostelease.dao.FeeDAO;
import com.hostelease.dao.HostelDAO;
import com.hostelease.dao.LeaveDAO;
import com.hostelease.dao.RoomDAO;
import com.hostelease.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();
    private final FeeDAO feeDAO = new FeeDAO();
    private final LeaveDAO leaveDAO = new LeaveDAO();
    private final ComplaintDAO complaintDAO = new ComplaintDAO();
    private final HostelDAO hostelDAO = new HostelDAO();
    private final AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String hostelParam = req.getParameter("hostelId");
        Long hostelId = (hostelParam != null && !hostelParam.isEmpty()) ? Long.parseLong(hostelParam) : null;

        Map<String, Object> occupancyStats = roomDAO.getOccupancyStats(hostelId);
        Map<String, Object> financialSummary = feeDAO.getFinancialSummary(hostelId);

        req.setAttribute("occupancy", occupancyStats);
        req.setAttribute("finance", financialSummary);
        req.setAttribute("hostels", hostelDAO.findAll());
        req.setAttribute("selectedHostelId", hostelId);

        req.setAttribute("pendingLeaves", leaveDAO.findAll(hostelId, "PENDING", null));
        req.setAttribute("recentComplaints", complaintDAO.findAll(hostelId, "OPEN", null));
        req.setAttribute("recentAudits", auditDAO.findRecent(8));

        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }
}
