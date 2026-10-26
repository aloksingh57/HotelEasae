package com.hostelease.controller.warden;

import com.hostelease.dao.HostelDAO;
import com.hostelease.dao.RoomDAO;
import com.hostelease.model.Room;
import com.hostelease.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "WardenRoomsServlet", urlPatterns = {"/warden/rooms"})
public class WardenRoomsServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();
    private final HostelDAO hostelDAO = new HostelDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("CURRENT_USER");
        Long hostelId = user.getAssociatedHostelId();
        if (hostelId == null) hostelId = 1L;

        String presence = req.getParameter("presence");
        String allocation = req.getParameter("allocation");

        List<Room> matrix = roomDAO.getRoomMatrix(hostelId);

        req.setAttribute("rooms", matrix);
        req.setAttribute("beds", roomDAO.findAllBeds(hostelId, allocation, presence));
        req.setAttribute("hostel", hostelDAO.findById(hostelId));
        req.setAttribute("stats", roomDAO.getOccupancyStats(hostelId));
        req.setAttribute("selectedPresence", presence);
        req.setAttribute("selectedAllocation", allocation);

        req.getRequestDispatcher("/WEB-INF/views/warden/rooms.jsp").forward(req, resp);
    }
}
