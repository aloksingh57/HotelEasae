package com.hostelease.controller.api;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.hostelease.dao.ComplaintDAO;
import com.hostelease.dao.FeeDAO;
import com.hostelease.dao.LeaveDAO;
import com.hostelease.dao.RoomDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "ApiStatsServlet", urlPatterns = {"/api/stats"})
public class ApiStatsServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();
    private final FeeDAO feeDAO = new FeeDAO();
    private final ComplaintDAO complaintDAO = new ComplaintDAO();
    private final LeaveDAO leaveDAO = new LeaveDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");

        String hostelParam = req.getParameter("hostelId");
        Long hostelId = (hostelParam != null && !hostelParam.isEmpty() && !"ALL".equalsIgnoreCase(hostelParam)) 
                ? Long.parseLong(hostelParam) : null;

        Map<String, Object> occupancy = roomDAO.getOccupancyStats(hostelId);
        Map<String, Object> finance = feeDAO.getFinancialSummary(hostelId);

        JsonObject root = new JsonObject();
        root.add("occupancy", gson.toJsonTree(occupancy));
        root.add("finance", gson.toJsonTree(finance));

        resp.getWriter().write(root.toString());
    }
}
