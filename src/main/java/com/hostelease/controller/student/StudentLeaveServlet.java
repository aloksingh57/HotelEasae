package com.hostelease.controller.student;

import com.hostelease.dao.StudentDAO;
import com.hostelease.model.LeaveRequest;
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
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet(name = "StudentLeaveServlet", urlPatterns = {"/student/leaves"})
public class StudentLeaveServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();
    private final LeaveService leaveService = new LeaveService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Student student = studentDAO.findByUserId(user.getId());

        req.setAttribute("student", student);
        req.setAttribute("leaves", leaveService.findByStudentId(student.getId()));

        req.getRequestDispatcher("/WEB-INF/views/student/leave_form.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Student student = studentDAO.findByUserId(user.getId());

        String leaveType = req.getParameter("leaveType");
        String reason = req.getParameter("reason");
        String depStr = req.getParameter("departureDatetime");
        if (depStr == null || depStr.trim().isEmpty()) depStr = req.getParameter("departureDate");
        String retStr = req.getParameter("expectedReturnDatetime");
        if (retStr == null || retStr.trim().isEmpty()) retStr = req.getParameter("expectedReturn");
        String emergencyContact = req.getParameter("emergencyContact");
        String destination = req.getParameter("destinationAddress");
        if (destination == null || destination.trim().isEmpty()) destination = req.getParameter("destination");

        try {
            if (depStr != null && depStr.length() == 10) depStr += "T09:00";
            if (retStr != null && retStr.length() == 10) retStr += "T18:00";

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime depLdt = LocalDateTime.parse(depStr, formatter);
            LocalDateTime retLdt = LocalDateTime.parse(retStr, formatter);

            Timestamp depTs = Timestamp.valueOf(depLdt);
            Timestamp retTs = Timestamp.valueOf(retLdt);

            LeaveRequest reqObj = new LeaveRequest();
            reqObj.setStudentId(student.getId());
            reqObj.setLeaveType(leaveType);
            reqObj.setReason(reason);
            reqObj.setDepartureDatetime(depTs);
            reqObj.setExpectedReturnDatetime(retTs);
            reqObj.setEmergencyContact(emergencyContact != null ? emergencyContact : student.getGuardianPhone());
            reqObj.setDestinationAddress(destination);

            boolean ok = leaveService.submitLeaveRequest(reqObj);
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/student/leaves?msg=leave_submitted");
            } else {
                resp.sendRedirect(req.getContextPath() + "/student/leaves?error=submission_failed");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/student/leaves?error=invalid_dates");
        }
    }
}
