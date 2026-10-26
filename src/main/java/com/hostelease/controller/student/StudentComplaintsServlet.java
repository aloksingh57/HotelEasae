package com.hostelease.controller.student;

import com.hostelease.dao.StudentDAO;
import com.hostelease.model.Complaint;
import com.hostelease.model.Student;
import com.hostelease.model.User;
import com.hostelease.service.ComplaintService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "StudentComplaintsServlet", urlPatterns = {"/student/complaints"})
public class StudentComplaintsServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();
    private final ComplaintService complaintService = new ComplaintService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Student student = studentDAO.findByUserId(user.getId());

        req.setAttribute("student", student);
        req.setAttribute("complaints", complaintService.findByStudentId(student.getId()));

        req.getRequestDispatcher("/WEB-INF/views/student/complaints.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Student student = studentDAO.findByUserId(user.getId());

        String category = req.getParameter("category");
        String priority = req.getParameter("priority");
        String subject = req.getParameter("subject");
        String description = req.getParameter("description");

        Complaint c = new Complaint();
        c.setStudentId(student.getId());
        c.setHostelId(student.getAllocatedHostelId() != null ? student.getAllocatedHostelId() : 1L);
        c.setCategory(category != null ? category : "MAINTENANCE");
        c.setPriority(priority != null ? priority : "MEDIUM");
        if (subject == null || subject.trim().isEmpty()) {
            subject = (category != null ? category : "General") + " Maintenance" + (student.getAllocatedRoomNumber() != null ? (" - Room " + student.getAllocatedRoomNumber()) : "");
        }
        c.setSubject(subject);
        c.setDescription(description != null ? description : subject);

        boolean ok = complaintService.createComplaint(c);
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/student/complaints?msg=complaint_registered");
        } else {
            resp.sendRedirect(req.getContextPath() + "/student/complaints?error=registration_failed");
        }
    }
}
