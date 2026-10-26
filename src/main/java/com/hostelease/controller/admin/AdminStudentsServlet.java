package com.hostelease.controller.admin;

import com.hostelease.dao.HostelDAO;
import com.hostelease.dao.StudentDAO;
import com.hostelease.dao.UserDAO;
import com.hostelease.model.Student;
import com.hostelease.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "AdminStudentsServlet", urlPatterns = {"/admin/students"})
public class AdminStudentsServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();
    private final HostelDAO hostelDAO = new HostelDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String search = req.getParameter("search");
        String hostelParam = req.getParameter("hostelId");
        Long hostelId = (hostelParam != null && !hostelParam.isEmpty() && !"ALL".equalsIgnoreCase(hostelParam)) 
                ? Long.parseLong(hostelParam) : null;
        String presence = req.getParameter("presence");

        List<Student> students = studentDAO.findAll(search, hostelId, presence);

        req.setAttribute("students", students);
        req.setAttribute("hostels", hostelDAO.findAll());
        req.setAttribute("search", search);
        req.setAttribute("selectedHostelId", hostelId);
        req.setAttribute("selectedPresence", presence);

        req.getRequestDispatcher("/WEB-INF/views/admin/students.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("create".equalsIgnoreCase(action)) {
            try {
                String firstName = req.getParameter("firstName");
                String lastName = req.getParameter("lastName");
                String username = req.getParameter("username");
                String email = req.getParameter("email");
                String phone = req.getParameter("phone");
                String password = req.getParameter("password");
                if (password == null || password.trim().isEmpty()) {
                    password = "Student@123";
                }

                String rollNumber = req.getParameter("rollNumber");
                String registrationNo = req.getParameter("registrationNo");
                String course = req.getParameter("course");
                int batchYear = Integer.parseInt(req.getParameter("batchYear"));
                String gender = req.getParameter("gender");
                String dobStr = req.getParameter("dob");
                Date dob = (dobStr != null && !dobStr.isEmpty()) ? Date.valueOf(dobStr) : Date.valueOf("2005-01-01");
                String bloodGroup = req.getParameter("bloodGroup");
                String guardianName = req.getParameter("guardianName");
                String guardianPhone = req.getParameter("guardianPhone");
                String guardianEmail = req.getParameter("guardianEmail");
                String address = req.getParameter("permanentAddress");

                User user = new User();
                user.setFirstName(firstName);
                user.setLastName(lastName);
                user.setUsername(username != null && !username.isEmpty() ? username : rollNumber.toLowerCase());
                user.setEmail(email);
                user.setPhoneNumber(phone);
                user.setPasswordHash(BCrypt.hashpw(password, BCrypt.gensalt(10)));

                Student student = new Student();
                student.setRollNumber(rollNumber);
                student.setRegistrationNo(registrationNo != null && !registrationNo.isEmpty() ? registrationNo : "REG-" + rollNumber);
                student.setCourse(course);
                student.setBatchYear(batchYear);
                student.setGender(gender != null ? gender.toUpperCase() : "MALE");
                student.setDob(dob);
                student.setBloodGroup(bloodGroup != null ? bloodGroup : "B+");
                student.setGuardianName(guardianName);
                student.setGuardianPhone(guardianPhone);
                student.setGuardianEmail(guardianEmail != null ? guardianEmail : email);
                student.setPermanentAddress(address);

                boolean ok = studentDAO.createStudent(user, student);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/admin/students?msg=student_created");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/students?error=create_failed");
                }
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/students?error=" + e.getMessage());
            }
        } else if ("update".equalsIgnoreCase(action)) {
            try {
                Long studentId = Long.parseLong(req.getParameter("studentId"));
                String phone = req.getParameter("phone");
                String course = req.getParameter("course");
                int batchYear = Integer.parseInt(req.getParameter("batchYear"));
                String guardianName = req.getParameter("guardianName");
                String guardianPhone = req.getParameter("guardianPhone");
                String guardianEmail = req.getParameter("guardianEmail");
                String address = req.getParameter("permanentAddress");

                boolean ok = studentDAO.updateStudent(studentId, phone, course, batchYear, guardianName, guardianPhone, guardianEmail, address);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/admin/students?msg=student_updated");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/students?error=update_failed");
                }
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/students?error=update_error");
            }
        } else if ("toggleStatus".equalsIgnoreCase(action)) {
            try {
                Long userId = Long.parseLong(req.getParameter("userId"));
                boolean active = Boolean.parseBoolean(req.getParameter("active"));
                boolean ok = userDAO.toggleUserStatus(userId, active);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/admin/students?msg=status_updated");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/students?error=status_failed");
                }
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/students?error=status_error");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/students");
        }
    }
}
