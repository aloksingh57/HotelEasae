package com.hostelease.controller.student;

import com.hostelease.dao.StudentDAO;
import com.hostelease.model.Student;
import com.hostelease.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "StudentProfileServlet", urlPatterns = {"/student/profile"})
public class StudentProfileServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Student student = studentDAO.findByUserId(user.getId());

        req.setAttribute("student", student);
        req.getRequestDispatcher("/WEB-INF/views/student/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String phone = req.getParameter("phone");
        String guardianPhone = req.getParameter("guardianPhone");
        String guardianEmail = req.getParameter("guardianEmail");
        String address = req.getParameter("address");

        boolean ok = studentDAO.updateStudentContacts(user.getId(), phone, guardianPhone, guardianEmail, address);
        if (ok) {
            user.setPhoneNumber(phone);
            session.setAttribute("CURRENT_USER", user);
            resp.sendRedirect(req.getContextPath() + "/student/profile?msg=profile_updated");
        } else {
            resp.sendRedirect(req.getContextPath() + "/student/profile?error=update_failed");
        }
    }
}
