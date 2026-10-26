package com.hostelease.controller.admin;

import com.hostelease.dao.HostelDAO;
import com.hostelease.dao.RoomDAO;
import com.hostelease.dao.StudentDAO;
import com.hostelease.model.Bed;
import com.hostelease.model.Student;
import com.hostelease.model.User;
import com.hostelease.service.RoomService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminAllocationsServlet", urlPatterns = {"/admin/allocations"})
public class AdminAllocationsServlet extends HttpServlet {

    private final RoomService roomService = new RoomService();
    private final StudentDAO studentDAO = new StudentDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final HostelDAO hostelDAO = new HostelDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String hostelParam = req.getParameter("hostelId");
        Long hostelId = (hostelParam != null && !hostelParam.isEmpty() && !"ALL".equalsIgnoreCase(hostelParam)) 
                ? Long.parseLong(hostelParam) : null;

        List<Bed> allocatedBeds = roomDAO.findAllBeds(hostelId, "ALLOCATED", null);
        List<Bed> availableBeds = roomDAO.findAllBeds(hostelId, "UNALLOCATED", null);
        List<Student> unallocatedStudents = studentDAO.getUnallocatedStudents();

        req.setAttribute("allocatedBeds", allocatedBeds);
        req.setAttribute("availableBeds", availableBeds);
        req.setAttribute("unallocatedStudents", unallocatedStudents);
        req.setAttribute("hostels", hostelDAO.findAll());
        req.setAttribute("selectedHostelId", hostelId);

        req.getRequestDispatcher("/WEB-INF/views/admin/allocations.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("CURRENT_USER");
        Long userId = (currentUser != null) ? currentUser.getId() : null;

        if ("allocate".equalsIgnoreCase(action)) {
            Long studentId = Long.parseLong(req.getParameter("studentId"));
            Long bedId = Long.parseLong(req.getParameter("bedId"));
            boolean ok = roomService.allocateBed(studentId, bedId, 1L, userId);
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/admin/allocations?msg=allocated_success");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/allocations?error=allocation_failed");
            }
        } else if ("transfer".equalsIgnoreCase(action)) {
            Long studentId = Long.parseLong(req.getParameter("studentId"));
            Long currentBedId = Long.parseLong(req.getParameter("currentBedId"));
            Long targetBedId = Long.parseLong(req.getParameter("targetBedId"));
            boolean ok = roomService.transferBed(studentId, currentBedId, targetBedId, 1L, userId);
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/admin/allocations?msg=transfer_success");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/allocations?error=transfer_failed");
            }
        } else if ("checkout".equalsIgnoreCase(action)) {
            Long studentId = Long.parseLong(req.getParameter("studentId"));
            String remarks = req.getParameter("remarks");
            boolean ok = roomService.permanentCheckout(studentId, remarks, userId);
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/admin/allocations?msg=checkout_success");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/allocations?error=checkout_failed");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/allocations");
        }
    }
}
