package com.hostelease.controller.student;

import com.hostelease.dao.FeeDAO;
import com.hostelease.dao.StudentDAO;
import com.hostelease.model.Invoice;
import com.hostelease.model.Payment;
import com.hostelease.model.Student;
import com.hostelease.model.User;
import com.hostelease.service.FeeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "StudentFeesServlet", urlPatterns = {"/student/fees"})
public class StudentFeesServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();
    private final FeeService feeService = new FeeService();
    private final FeeDAO feeDAO = new FeeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Student student = studentDAO.findByUserId(user.getId());

        List<Invoice> invoices = feeService.findInvoices(student.getId(), null, null);
        List<Payment> payments = feeDAO.findPaymentsByStudent(student.getId());

        req.setAttribute("student", student);
        req.setAttribute("invoices", invoices);
        req.setAttribute("payments", payments);

        req.getRequestDispatcher("/WEB-INF/views/student/fees.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Student student = studentDAO.findByUserId(user.getId());

        if ("simulatePayment".equalsIgnoreCase(action)) {
            Long invoiceId = Long.parseLong(req.getParameter("invoiceId"));
            BigDecimal amount = new BigDecimal(req.getParameter("amount"));
            String method = req.getParameter("paymentMethod");
            String txnRef = "SIM-PAY-" + System.currentTimeMillis();

            boolean ok = feeService.recordPayment(invoiceId, student.getId(), amount, method, txnRef, user.getId());
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/student/fees?msg=payment_simulated_success");
            } else {
                resp.sendRedirect(req.getContextPath() + "/student/fees?error=payment_simulation_failed");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/student/fees");
        }
    }
}
