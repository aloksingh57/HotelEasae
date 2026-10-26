package com.hostelease.controller.student;

import com.hostelease.dao.ComplaintDAO;
import com.hostelease.dao.FeeDAO;
import com.hostelease.dao.NoticeDAO;
import com.hostelease.dao.StudentDAO;
import com.hostelease.model.Student;
import com.hostelease.model.User;
import com.hostelease.service.LeaveService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "StudentDashboardServlet", urlPatterns = {"/student/dashboard"})
public class StudentDashboardServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();
    private final LeaveService leaveService = new LeaveService();
    private final FeeDAO feeDAO = new FeeDAO();
    private final ComplaintDAO complaintDAO = new ComplaintDAO();
    private final NoticeDAO noticeDAO = new NoticeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");

        Student student = studentDAO.findByUserId(user.getId());
        if (student == null) {
            req.setAttribute("errorMessage", "Student profile not linked to user account.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("student", student);
        req.setAttribute("leaves", leaveService.findByStudentId(student.getId()));
        req.setAttribute("invoices", feeDAO.findInvoices(student.getId(), null, null));
        req.setAttribute("complaints", complaintDAO.findByStudentId(student.getId()));
        req.setAttribute("notices", noticeDAO.findAll(student.getAllocatedHostelId(), "STUDENT"));

        req.getRequestDispatcher("/WEB-INF/views/student/dashboard.jsp").forward(req, resp);
    }
}
