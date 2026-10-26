package com.hostelease.controller.api;

import com.google.gson.Gson;
import com.hostelease.dao.RoomDAO;
import com.hostelease.model.Bed;
import com.hostelease.model.Room;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ApiRoomsServlet", urlPatterns = {"/api/rooms"})
public class ApiRoomsServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");

        String bedIdParam = req.getParameter("bedId");
        if (bedIdParam != null && !bedIdParam.isEmpty()) {
            Bed bed = roomDAO.findBedById(Long.parseLong(bedIdParam));
            resp.getWriter().write(gson.toJson(bed));
            return;
        }

        String hostelParam = req.getParameter("hostelId");
        Long hostelId = (hostelParam != null && !hostelParam.isEmpty() && !"ALL".equalsIgnoreCase(hostelParam)) 
                ? Long.parseLong(hostelParam) : null;

        List<Room> matrix = roomDAO.getRoomMatrix(hostelId);
        resp.getWriter().write(gson.toJson(matrix));
    }
}
