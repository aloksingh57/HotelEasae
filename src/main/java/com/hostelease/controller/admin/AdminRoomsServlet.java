package com.hostelease.controller.admin;

import com.hostelease.dao.HostelDAO;
import com.hostelease.dao.RoomDAO;
import com.hostelease.model.Room;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminRoomsServlet", urlPatterns = {"/admin/rooms"})
public class AdminRoomsServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();
    private final HostelDAO hostelDAO = new HostelDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String hostelParam = req.getParameter("hostelId");
        Long hostelId = (hostelParam != null && !hostelParam.isEmpty() && !"ALL".equalsIgnoreCase(hostelParam)) 
                ? Long.parseLong(hostelParam) : null;

        String presence = req.getParameter("presence");
        String allocation = req.getParameter("allocation");

        List<Room> matrix = roomDAO.getRoomMatrix(hostelId);

        req.setAttribute("floors", roomDAO.findFloorsByHostelId(hostelId));
        req.setAttribute("rooms", matrix);
        req.setAttribute("beds", roomDAO.findAllBeds(hostelId, allocation, presence));
        req.setAttribute("hostels", hostelDAO.findAll());
        req.setAttribute("stats", roomDAO.getOccupancyStats(hostelId));
        req.setAttribute("selectedHostelId", hostelId);
        req.setAttribute("selectedPresence", presence);
        req.setAttribute("selectedAllocation", allocation);

        req.getRequestDispatcher("/WEB-INF/views/admin/rooms.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("createRoom".equalsIgnoreCase(action)) {
                Long floorId = Long.parseLong(req.getParameter("floorId"));
                String roomNumber = req.getParameter("roomNumber");
                String roomType = req.getParameter("roomType");
                int capacity = Integer.parseInt(req.getParameter("capacity"));

                Long roomId = roomDAO.createRoom(floorId, roomNumber, roomType, capacity);
                if (roomId != null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/rooms?msg=room_created");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/rooms?error=room_create_failed");
                }
            } else if ("updateBedStatus".equalsIgnoreCase(action)) {
                Long bedId = Long.parseLong(req.getParameter("bedId"));
                String status = req.getParameter("status");

                boolean ok = roomDAO.updateBedStatus(bedId, status);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/admin/rooms?msg=bed_updated");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/rooms?error=bed_update_failed");
                }
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/rooms");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/rooms?error=invalid_input");
        }
    }
}
