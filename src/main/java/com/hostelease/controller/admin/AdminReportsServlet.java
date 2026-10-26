package com.hostelease.controller.admin;

import com.hostelease.dao.ComplaintDAO;
import com.hostelease.dao.FeeDAO;
import com.hostelease.dao.HostelDAO;
import com.hostelease.dao.LeaveDAO;
import com.hostelease.dao.RoomDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "AdminReportsServlet", urlPatterns = {"/admin/reports"})
public class AdminReportsServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();
    private final LeaveDAO leaveDAO = new LeaveDAO();
    private final FeeDAO feeDAO = new FeeDAO();
    private final ComplaintDAO complaintDAO = new ComplaintDAO();
    private final HostelDAO hostelDAO = new HostelDAO();
    private final com.hostelease.dao.NotificationDAO notificationDAO = new com.hostelease.dao.NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String type = req.getParameter("type");
        if (type == null || type.isEmpty()) type = "occupancy";

        String hostelParam = req.getParameter("hostelId");
        Long hostelId = (hostelParam != null && !hostelParam.isEmpty() && !"ALL".equalsIgnoreCase(hostelParam)) 
                ? Long.parseLong(hostelParam) : null;

        req.setAttribute("reportType", type);
        req.setAttribute("hostels", hostelDAO.findAll());
        req.setAttribute("selectedHostelId", hostelId);

        switch (type.toLowerCase()) {
            case "occupancy" -> {
                req.setAttribute("matrix", roomDAO.getRoomMatrix(hostelId));
                req.setAttribute("stats", roomDAO.getOccupancyStats(hostelId));
            }
            case "away", "vacancies" -> {
                req.setAttribute("awayLeaves", leaveDAO.findAll(hostelId, "DEPARTED", null));
                req.setAttribute("awayBeds", roomDAO.findAllBeds(hostelId, "ALLOCATED", "AWAY"));
            }
            case "overdue" -> req.setAttribute("overdueLeaves", leaveDAO.findAll(hostelId, "OVERDUE", null));
            case "finance" -> {
                req.setAttribute("invoices", feeDAO.findInvoices(null, hostelId, null));
                req.setAttribute("summary", feeDAO.getFinancialSummary(hostelId));
            }
            case "complaints" -> req.setAttribute("complaints", complaintDAO.findAll(hostelId, null, null));
            case "notifications" -> req.setAttribute("notificationLogs", notificationDAO.getRecentLogs(50));
        }

        req.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(req, resp);
    }
}
