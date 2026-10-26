package com.hostelease.controller.admin;

import com.hostelease.dao.HostelDAO;
import com.hostelease.model.Invoice;
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

@WebServlet(name = "AdminFeesServlet", urlPatterns = {"/admin/fees"})
public class AdminFeesServlet extends HttpServlet {

    private final FeeService feeService = new FeeService();
    private final HostelDAO hostelDAO = new HostelDAO();
    private final com.hostelease.dao.StudentDAO studentDAO = new com.hostelease.dao.StudentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String hostelParam = req.getParameter("hostelId");
        Long hostelId = (hostelParam != null && !hostelParam.isEmpty() && !"ALL".equalsIgnoreCase(hostelParam)) 
                ? Long.parseLong(hostelParam) : null;
        String status = req.getParameter("status");

        List<Invoice> invoices = feeService.findInvoices(null, hostelId, status);

        req.setAttribute("invoices", invoices);
        req.setAttribute("summary", feeService.getFinancialSummary(hostelId));
        req.setAttribute("hostels", hostelDAO.findAll());
        req.setAttribute("students", studentDAO.findAll(null, null, null));
        req.setAttribute("selectedHostelId", hostelId);
        req.setAttribute("selectedStatus", status);

        req.getRequestDispatcher("/WEB-INF/views/admin/fees.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Long userId = (user != null) ? user.getId() : null;

        try {
            if ("recordPayment".equalsIgnoreCase(action)) {
                Long invoiceId = Long.parseLong(req.getParameter("invoiceId"));
                Long studentId = Long.parseLong(req.getParameter("studentId"));
                BigDecimal amount = new BigDecimal(req.getParameter("amount"));
                String method = req.getParameter("paymentMethod");
                String txnRef = req.getParameter("transactionReference");

                boolean ok = feeService.recordPayment(invoiceId, studentId, amount, method, txnRef, userId);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/admin/fees?msg=payment_recorded");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/fees?error=payment_failed");
                }
            } else if ("createInvoice".equalsIgnoreCase(action)) {
                Long studentId = Long.parseLong(req.getParameter("studentId"));
                String feeStructureParam = req.getParameter("feeStructureId");
                Long feeStructureId = (feeStructureParam != null && !feeStructureParam.isEmpty()) 
                        ? Long.parseLong(feeStructureParam) : 1L;
                BigDecimal amount = new BigDecimal(req.getParameter("amount"));
                java.sql.Date dueDate = java.sql.Date.valueOf(req.getParameter("dueDate"));

                boolean ok = feeService.createInvoice(studentId, feeStructureId, amount, dueDate, userId);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/admin/fees?msg=invoice_created");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/fees?error=invoice_failed");
                }
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/fees");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/fees?error=invalid_input");
        }
    }
}
