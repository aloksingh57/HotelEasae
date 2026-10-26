package com.hostelease.controller.admin;

import com.hostelease.dao.HostelDAO;
import com.hostelease.dao.RoomDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "AdminHostelsServlet", urlPatterns = {"/admin/hostels"})
public class AdminHostelsServlet extends HttpServlet {

    private final HostelDAO hostelDAO = new HostelDAO();
    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("hostels", hostelDAO.findAll());
        req.setAttribute("overallStats", roomDAO.getOccupancyStats(null));
        req.getRequestDispatcher("/WEB-INF/views/admin/hostels.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("createHostel".equalsIgnoreCase(action)) {
                String name = req.getParameter("name");
                String code = req.getParameter("code");
                String type = req.getParameter("type");
                String address = req.getParameter("address");
                String phone = req.getParameter("phone");
                String email = req.getParameter("email");
                int capacity = Integer.parseInt(req.getParameter("capacity"));

                Long hostelId = hostelDAO.createHostel(name, code, type, address, phone, email, capacity);
                if (hostelId != null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/hostels?msg=hostel_created");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/hostels?error=hostel_create_failed");
                }
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/hostels");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/hostels?error=invalid_input");
        }
    }
}
