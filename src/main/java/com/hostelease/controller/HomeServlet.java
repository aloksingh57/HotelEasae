package com.hostelease.controller;

import com.hostelease.dao.HostelDAO;
import com.hostelease.dao.NoticeDAO;
import com.hostelease.dao.RoomDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "HomeServlet", urlPatterns = {"", "/index"})
public class HomeServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();
    private final HostelDAO hostelDAO = new HostelDAO();
    private final NoticeDAO noticeDAO = new NoticeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Map<String, Object> stats = roomDAO.getOccupancyStats(null);
        req.setAttribute("stats", stats);
        req.setAttribute("hostels", hostelDAO.findAll());
        req.setAttribute("notices", noticeDAO.findAll(null, "ALL"));
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }
}
