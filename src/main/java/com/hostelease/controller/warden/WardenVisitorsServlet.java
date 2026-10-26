package com.hostelease.controller.warden;

import com.hostelease.dao.StudentDAO;
import com.hostelease.model.Student;
import com.hostelease.model.User;
import com.hostelease.model.VisitorLog;
import com.hostelease.service.VisitorService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "WardenVisitorsServlet", urlPatterns = {"/warden/visitors"})
public class WardenVisitorsServlet extends HttpServlet {

    private final VisitorService visitorService = new VisitorService();
    private final StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Long hostelId = user.getAssociatedHostelId();
        if (hostelId == null) hostelId = 1L;

        String status = req.getParameter("status");

        List<VisitorLog> list = visitorService.findAll(hostelId, status);
        List<Student> students = studentDAO.findAll(null, hostelId, null);

        req.setAttribute("visitors", list);
        req.setAttribute("students", students);
        req.setAttribute("selectedStatus", status);

        req.getRequestDispatcher("/WEB-INF/views/warden/visitors.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Long hostelId = user.getAssociatedHostelId();
        if (hostelId == null) hostelId = 1L;

        if ("entry".equalsIgnoreCase(action)) {
            String name = req.getParameter("visitorName");
            String phone = req.getParameter("contactNumber");
            String idType = req.getParameter("governmentIdType");
            String idNo = req.getParameter("governmentIdNumber");
            Long studentId = Long.parseLong(req.getParameter("studentId"));
            String purpose = req.getParameter("purpose");

            boolean ok = visitorService.recordEntry(name, phone, idType, idNo, studentId, hostelId, purpose, user.getId());
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/warden/visitors?msg=visitor_entered");
            } else {
                resp.sendRedirect(req.getContextPath() + "/warden/visitors?error=entry_failed");
            }
        } else if ("exit".equalsIgnoreCase(action)) {
            Long logId = Long.parseLong(req.getParameter("logId"));
            boolean ok = visitorService.recordExit(logId, user.getId());
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/warden/visitors?msg=visitor_exited");
            } else {
                resp.sendRedirect(req.getContextPath() + "/warden/visitors?error=exit_failed");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/warden/visitors");
        }
    }
}
